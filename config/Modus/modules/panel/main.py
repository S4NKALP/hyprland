from fabric.hyprland.widgets import HyprlandWorkspaces, WorkspaceButton
from fabric.system_tray.widgets import SystemTray
from fabric.utils import Gdk, GLib
from fabric.widgets.box import Box
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.datetime import DateTime
from fabric.widgets.eventbox import EventBox
from fabric.widgets.revealer import Revealer
from fabric.widgets.wayland import WaylandWindow as Window

import config.data as data
from modules.panel.components import (
    Battery,
    TaskBar,
    apply_enhanced_system_tray,
)
from services import has_config_changed, on_config_change
from utils.corners import MyCorner
from utils.functions import is_special_workspace_id
from utils.occlusion import check_occlusion


def config_dependent(func):
    def wrapper(self, *args, **kwargs):
        return func(self, *args, **kwargs)

    wrapper._config_dependent = True
    return wrapper


class Panel(Window):
    def __init__(self, **kwargs):
        panel_autohide = data.DATA()["panel_autohide"]
        panel_position = data.DATA().get("panel_position") or "bottom"

        super().__init__(
            name="panel-window",
            layer="top",
            anchor=panel_position,
            exclusivity="auto" if not panel_autohide else "none",
            pass_through=False,
            visible=False,
            all_visible=False,
        )

        self.hide_id = None
        self.is_mouse_over_panel_area = False
        self.effective_occlusion_size = 40
        self.panel_position = panel_position

        # Set corner types based on position
        if panel_position == "top":
            corner_left_type = "top-right"
            corner_right_type = "top-left"
            # For top position, corner goes first (at top)
            corner_left_children = [
                MyCorner(corner_left_type),
                Box(v_expand=True, v_align="fill"),
            ]
            corner_right_children = [
                MyCorner(corner_right_type),
                Box(v_expand=True, v_align="fill"),
            ]
        else:  # bottom
            corner_left_type = "bottom-right"
            corner_right_type = "bottom-left"
            # For bottom position, corner goes last (at bottom)
            corner_left_children = [
                Box(v_expand=True, v_align="fill"),
                MyCorner(corner_left_type),
            ]
            corner_right_children = [
                Box(v_expand=True, v_align="fill"),
                MyCorner(corner_right_type),
            ]

        self.corner_left = Box(
            name="corner-left",
            orientation="v",
            h_align="start",
            children=corner_left_children,
        )
        self.corner_right = Box(
            name="corner-right",
            orientation="v",
            h_align="end",
            children=corner_right_children,
        )

        use_12hr = data.DATA()["datetime_12hrs"]
        formatter = "%a %-d %b %I:%M %P" if use_12hr else "%a %-d %b %H:%M"

        self.datetime = DateTime(name="date-time", formatters=[formatter])
        self.tray = SystemTray(name="panel-button", spacing=4, icon_size=20)
        apply_enhanced_system_tray(self.tray)
        self.battery = Battery()
        self.taskbar = TaskBar()
        self.taskbar.set_visibility_callback(self._rebuild_layout_from_config)
        self.workspaces = HyprlandWorkspaces(
            name="workspaces",
            spacing=4,
            buttons_factory=lambda ws_id: (
                None
                if (
                    data.DATA()["workspace_hide_special"]
                    and is_special_workspace_id(ws_id)
                )
                else WorkspaceButton(id=ws_id, label=str(ws_id))
            ),
        )

        self.items = Box()

        # Create panel CenterBox with position-based CSS class
        self.panel_centerbox = CenterBox(
            name="panel",
            center_children=self.items,
        )

        # Add CSS class for top position using GTK style context
        if panel_position == "top":
            self.panel_centerbox.get_style_context().add_class("panel-top")

        self.panel_content = Box(
            name="panel-container",
            orientation="h",
            h_expand=True,
            children=[
                self.corner_left,
                self.panel_centerbox,
                self.corner_right,
            ],
        )

        self.panel_eventbox = EventBox()
        self.panel_eventbox.add(self.panel_content)
        self.panel_eventbox.connect("enter-notify-event", self._on_mouse_enter)
        self.panel_eventbox.connect("leave-notify-event", self._on_mouse_leave)

        # Set revealer transition based on position
        transition = "slide-down" if panel_position == "top" else "slide-up"

        self.panel_revealer = Revealer(
            name="panel-revealer",
            transition_type=transition,
            transition_duration=350,
            child_revealed=False,
            child=self.panel_eventbox,
        )

        self.hover_activator = EventBox()
        self.hover_activator.set_size_request(-1, 5)
        self.hover_activator.connect("enter-notify-event", self._on_mouse_enter)
        self.hover_activator.connect("leave-notify-event", self._on_mouse_leave)

        # Arrange children based on position
        if panel_position == "top":
            panel_children = [self.panel_revealer, self.hover_activator]
        else:  # bottom
            panel_children = [self.hover_activator, self.panel_revealer]

        self.children = Box(
            name="panel-main",
            orientation="v",
            children=panel_children,
        )

        self.battery.connect(
            "notify::visible", lambda *_: self._rebuild_layout_from_config()
        )

        self._rebuild_layout_from_config()
        on_config_change(self._on_config_change)
        self._update_panel_visibility()

        if panel_autohide:
            self.panel_revealer.set_reveal_child(False)
            GLib.timeout_add(250, self.check_occlusion_state)

    def _get_enabled_widgets(self):
        components = data.DATA()
        enabled_widgets = {
            "workspace": components["workspace"],
            "taskbar": components["taskbar"],
            "systray": components["systray"],
            "battery": components["battery"],
            "datetime": components["datetime"],
        }
        return enabled_widgets

    @config_dependent
    def _rebuild_layout_from_config(self):
        enabled_widgets = self._get_enabled_widgets()

        items = []
        if enabled_widgets["workspace"]:
            items.append(self.workspaces)
        if enabled_widgets["taskbar"]:
            items.append(self.taskbar)
        if enabled_widgets["systray"]:
            items.append(self.tray)
        if enabled_widgets["battery"]:
            items.append(self.battery)
        if enabled_widgets["datetime"]:
            items.append(self.datetime)

        filtered_items = [w for w in items if w.get_visible()]

        self.items.children = filtered_items

        if data.DATA()["panel_enabled"]:
            self.show_all()

    def _update_panel_visibility(self):
        panel_enabled = data.DATA()["panel_enabled"]
        self.set_visible(panel_enabled)

    def _on_mouse_enter(self, widget, event):
        self.is_mouse_over_panel_area = True
        if self.hide_id:
            GLib.source_remove(self.hide_id)
            self.hide_id = None
        if data.DATA()["panel_autohide"]:
            self.panel_revealer.set_reveal_child(True)
        return True

    def _on_mouse_leave(self, widget, event):
        if event.detail == Gdk.NotifyType.INFERIOR:
            return False
        self.is_mouse_over_panel_area = False
        if data.DATA()["panel_autohide"]:
            self.delay_hide()
        return True

    def delay_hide(self):
        if self.hide_id:
            GLib.source_remove(self.hide_id)
        self.hide_id = GLib.timeout_add(250, self.hide_panel_if_not_hovered)

    def hide_panel_if_not_hovered(self):
        self.hide_id = None
        if not self.is_mouse_over_panel_area:
            occlusion_region = (self.panel_position, self.effective_occlusion_size)
            if check_occlusion(occlusion_region):
                self.panel_revealer.set_reveal_child(False)
        return False

    def check_occlusion_state(self):
        if self.is_mouse_over_panel_area:
            if not self.panel_revealer.get_reveal_child():
                self.panel_revealer.set_reveal_child(True)
            return True

        if not data.DATA()["panel_autohide"]:
            if not self.panel_revealer.get_reveal_child():
                self.panel_revealer.set_reveal_child(True)
            return True

        occlusion_region = (self.panel_position, self.effective_occlusion_size)
        is_occluded_by_window = check_occlusion(occlusion_region)

        self.panel_revealer.set_reveal_child(not is_occluded_by_window)

        return True

    @config_dependent
    def _on_config_change(self, new_config, old_config):
        config_paths = [
            "panel.enabled",
            "panel.autohide",
            "panel.position",
            "panel.systray.enabled",
            "panel.datetime.enabled",
            "panel.datetime.12hrs",
            "panel.workspace.enabled",
            "panel.workspace.hide_special_ws",
            "panel.taskbar.enabled",
            "panel.taskbar.icon_size",
            "panel.taskbar.hide_empty",
            "panel.taskbar.hide_special",
            "panel.battery.enabled",
            "panel.battery.label",
            "panel.battery.hide_on_full",
            "panel.battery.icon_size",
        ]

        config_changed = any(
            has_config_changed(old_config, new_config, path) for path in config_paths
        )

        if config_changed:
            # Check if position changed (requires application restart)
            new_position = data.DATA().get("panel_position") or "bottom"
            if new_position != self.panel_position:
                # Position change requires full restart due to Wayland limitations
                print("Panel position changed - restarting application...")
                import os
                import sys

                # Restart the Python script
                os.execv(sys.executable, ["python"] + sys.argv)
                return

            # Position didn't change, handle other config changes
            panel_autohide = data.DATA()["panel_autohide"]

            # Set exclusivity based on autohide setting
            exclusivity = "none" if panel_autohide else "auto"
            self.set_property("exclusivity", exclusivity)

            self._update_panel_visibility()

            use_12hr = data.DATA()["datetime_12hrs"]
            formatter = "%a %-d %b %I:%M %P" if use_12hr else "%a %-d %b %H:%M"
            self.datetime.formatters = [formatter]

            hide_special = data.DATA()["workspace_hide_special"]
            self.workspaces.buttons_factory = lambda ws_id: (
                None
                if (hide_special and is_special_workspace_id(ws_id))
                else WorkspaceButton(id=ws_id, label=str(ws_id))
            )

            self._rebuild_layout_from_config()

            if panel_autohide:
                GLib.timeout_add(250, self.check_occlusion_state)
