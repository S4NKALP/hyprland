import os

from fabric.widgets.centerbox import CenterBox
from fabric.widgets.stack import Stack
from fabric.widgets.wayland import WaylandWindow as Window
from gi.repository import Gdk, GLib
from modules.launcher.widgets import (
    AppLauncher,
    BluetoothManager,
    Cliphist,
    Emoji,
    PowerMenu,
    TodoManager,
    WallpaperSelector,
)


class Launcher(Window):
    def __init__(self, **kwargs):
        super().__init__(
            layer="top",
            anchor="center",
            visible=False,
            all_visible=False,
        )

        self.launcher = AppLauncher()
        self.wallpapers = WallpaperSelector(os.path.expanduser("~/Pictures/wallpapers"))
        self.power = PowerMenu()
        self.emoji = Emoji()
        self.cliphist = Cliphist()
        self.todo = TodoManager()
        self.bluetooth = BluetoothManager()

        # Initialize viewports as None
        self._emoji_viewport = None
        self._cliphist_viewport = None
        self._todo_viewport = None
        self._bluetooth_viewport = None

        self.stack = Stack(
            name="launcher-content",
            v_expand=True,
            h_expand=True,
            transition_type="crossfade",
            transition_duration=250,
            children=[
                self.launcher,
                self.wallpapers,
                self.power,
                self.emoji,
                self.cliphist,
                self.todo,
                self.bluetooth,
            ],
        )

        self.launcher_box = CenterBox(
            name="launcher",
            orientation="h",
            h_align="center",
            v_align="center",
            start_children=self.stack,
        )

        self.add(self.launcher_box)
        self.setup_widgets()

        self.connect("key-press-event", self.on_key_press)
        self.connect("delete-event", lambda w, e: self.close())

    def setup_widgets(self):
        self.show_all()
        self.hide()
        self.wallpapers.viewport.hide()

    def on_key_press(self, widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.close()
            return True
        return False

    def on_button_enter(self, widget, event):
        window = widget.get_window()
        if window:
            window.set_cursor(Gdk.Cursor(Gdk.CursorType.HAND2))

    def on_button_leave(self, widget, event):
        window = widget.get_window()
        if window:
            window.set_cursor(None)

    def close(self):
        self.set_keyboard_mode("none")
        self.hide()
        if self.bluetooth.is_active:
            self.bluetooth.stop_device_polling()

        for widget in [
            self.launcher,
            self.wallpapers,
            self.power,
            self.emoji,
            self.cliphist,
            self.todo,
            self.bluetooth,
        ]:
            widget.remove_style_class("open")

            # Handle wallpaper viewport
            if widget == self.wallpapers:
                self.wallpapers.viewport.hide()
                self.wallpapers.viewport.set_property("name", None)

            # Handle emoji viewport safely
            if widget == self.emoji and hasattr(widget, "viewport") and widget.viewport:
                widget.viewport.hide()

            # Handle cliphist viewport safely
            if (
                widget == self.cliphist
                and hasattr(widget, "viewport")
                and widget.viewport
            ):
                widget.viewport.hide()

            if widget == self.todo and hasattr(widget, "viewport") and widget.viewport:
                widget.viewport.hide()

            if widget == self.bluetooth and widget.viewport:
                widget.viewport.hide()
                widget.viewport.children = []
                widget.is_active = False

        style_classes = [
            "launcher",
            "wallpapers",
            "power",
            "emoji",
            "cliphist",
            "todo",
            "bluetooth",
        ]
        for style_class in style_classes:
            if self.stack.get_style_context().has_class(style_class):
                self.stack.get_style_context().remove_class(style_class)

        return True

    def open(self, widget):
        self.set_keyboard_mode("exclusive")
        self.show()

        widgets = {
            "launcher": self.launcher,
            "wallpapers": self.wallpapers,
            "power": self.power,
            "emoji": self.emoji,
            "cliphist": self.cliphist,
            "todo": self.todo,
            "bluetooth": self.bluetooth,
        }

        style_classes = list(widgets.keys())
        for style_class in style_classes:
            if self.stack.get_style_context().has_class(style_class):
                self.stack.get_style_context().remove_class(style_class)

        for w in widgets.values():
            w.remove_style_class("open")

        if widget in widgets:
            self.stack.get_style_context().add_class(widget)
            self.stack.set_visible_child(widgets[widget])
            widgets[widget].add_style_class("open")

            if widget == "launcher":
                self.launcher.open_launcher()
                self.launcher.search_entry.set_text("")
                self.launcher.search_entry.grab_focus()

            elif widget == "wallpapers":
                self.wallpapers.search_entry.set_text("")
                self.wallpapers.search_entry.grab_focus()
                GLib.timeout_add(
                    500,
                    lambda: (
                        self.wallpapers.viewport.show(),
                        self.wallpapers.viewport.set_property(
                            "name", "wallpaper-icons"
                        ),
                    ),
                )

            elif widget == "emoji":
                self.emoji.open_launcher()
                self.emoji.search_entry.set_text("")
                self.emoji.search_entry.grab_focus()

            elif widget == "cliphist":
                self.cliphist.open_launcher()
                self.cliphist.search_entry.set_text("")
                self.cliphist.search_entry.grab_focus()

            elif widget == "todo":
                self.todo.open_launcher()
                self.todo.todo_entry.set_text("")
                self.todo.todo_entry.grab_focus()

            elif widget == "bluetooth":
                self.bluetooth.open_launcher()
                self.bluetooth.search_entry.set_text("")
                self.bluetooth.search_entry.grab_focus()
                self.bluetooth.device_manager.arrange_viewport()

            else:
                if hasattr(self.wallpapers, "viewport"):
                    self.wallpapers.viewport.hide()
                    self.wallpapers.viewport.set_property("name", None)
