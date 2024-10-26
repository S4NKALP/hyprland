import os
from typing import Literal

from fabric.audio import Audio
from fabric.widgets.box import Box
from fabric.widgets.image import Image
from fabric.widgets.revealer import Revealer
from fabric.widgets.shapes import Corner
from fabric.widgets.wayland import WaylandWindow as Window
from fabric.widgets.widget import Widget
from gi.repository import GLib
from services.brightness import Brightness

audio = Audio()
brightness = Brightness()
# TODO: use progressbar or custom cairo widget so that I can update the accent color with css
accent = "#82C480"


# This is only for OSD, I don' want or need an inhibitor for this
class PopupWindow(Window):
    def __init__(
        self,
        child: Widget | None = None,
        transition_type: Literal[
            "none",
            "crossfade",
            "slide-right",
            "slide-left",
            "slide-up",
            "slide-down",
        ] = "none",
        transition_duration: int = 100,
        visible: bool = False,
        anchor: str = "top right",
        keyboard_mode: Literal["none", "exclusive", "on-demand"] = "on-demand",
        timeout: int = 1000,
        decorations: str = "margin: 1px",
        **kwargs,
    ):
        self.timeout = timeout
        self.currtimeout = 0
        self.popup_running = False

        self.revealer = Revealer(
            child=child,
            transition_type=transition_type,
            transition_duration=transition_duration,
            visible=False,
        )
        self.visible = visible
        super().__init__(
            layer="overlay",
            anchor=anchor,
            all_visible=False,
            visible=False,
            exclusive=False,
            child=Box(style=decorations, children=self.revealer),
            keyboard_mode=keyboard_mode,
            **kwargs,
        )
        self.set_can_focus = False

        self.revealer.connect(
            "notify::child-revealed",
            lambda revealer, is_reveal: (
                revealer.hide() if not revealer.get_child_revealed() else None
            ),
        )

        self.show()

    def toggle_popup(self):
        if not self.visible:
            self.revealer.show()
        self.visible = not self.visible
        self.revealer.set_reveal_child(self.visible)

    def toggle_popup_offset(self, offset, toggle_width):
        if not self.visible:
            self.revealer.show()
        self.visible = not self.visible
        self.revealer.set_reveal_child(self.visible)
        self.revealer.set_margin_start(
            offset - (self.revealer.get_allocated_width() - toggle_width) / 2
        )

    def popup_timeout(self):
        if not self.visible:
            self.revealer.show()
        if self.popup_running:
            self.currtimeout = 0
            return
        self.visible = True
        self.revealer.set_reveal_child(self.visible)
        self.popup_running = True

        def popup_func():
            if self.currtimeout >= self.timeout:
                self.visible = False
                self.revealer.set_reveal_child(self.visible)
                self.currtimeout = 0
                self.popup_running = False
                return False
            self.currtimeout += 500
            return True

        GLib.timeout_add(500, popup_func)


class ProgressBar(Box):
    def __init__(self, progress_ticks: int = 10):
        self.progress_filled_class = "filled"
        self.total_progress_ticks = progress_ticks
        self.visible_progress_ticks = progress_ticks
        self.tick_boxes = [
            Box(v_expand=True, h_expand=True) for _ in range(self.total_progress_ticks)
        ]
        super().__init__(
            name="osd-progress-bar",
            spacing=5,
            v_expand=True,
            h_expand=True,
            orientation="v",
            children=self.tick_boxes,
        )

    def set_tick_number(self, ticks: int):
        self.visible_progress_ticks = ticks
        for child in super().children:
            child.set_visible(True)
        for i in range(self.total_progress_ticks - ticks):
            super().children[i].set_visible(False)

    def set_progress_filled(self, percent: float):
        # TODO: rework this later, just to get it working, am sleepy frfr
        for child in super().children:
            child.remove_style_class(self.progress_filled_class)
        for tick in range(int(self.visible_progress_ticks * percent)):
            super().children[-(tick + 1)].add_style_class(self.progress_filled_class)


class SystemOSD(PopupWindow):
    def __init__(self, **kwargs):
        self.disp_backlight_path = "/sys/class/backlight/intel_backlight/"
        self.kbd_backlight_path = "/sys/class/leds/tpacpi::kbd_backlight/"
        self.max_disp_backlight = brightness.max_screen
        self.max_kbd_backlight = brightness.max_kbd
        self.brightness = brightness
        self.disp_backlight = 0
        self.kbd_backlight = 0
        self.vol = 0
        self.progress_bar = ProgressBar(progress_ticks=20)
        self.overlay_fill_box = Box(name="osd-box")
        self.icon = Image()

        super().__init__(
            transition_duration=150,
            anchor="right",
            transition_type="crossfade",
            keyboard_mode="none",
            decorations="margin: 1px 0px 1px 1px;",
            child=Box(
                orientation="v",
                h_align="end",
                children=[
                    Box(
                        name="osd-corner",
                        children=Corner(
                            h_align="end",
                            orientation="bottom-right",
                            size=50,
                        ),
                    ),
                    Box(
                        name="on-screen-display",
                        orientation="v",
                        spacing=10,
                        h_align="end",
                        children=[
                            self.progress_bar,
                            Box(name="osd-icon", children=self.icon),
                        ],
                    ),
                    Box(
                        name="osd-corner",
                        children=Corner(
                            h_align="end",
                            orientation="top-right",
                            size=50,
                        ),
                    ),
                ],
            ),
            **kwargs,
        )

    def update_label_audio(self, *args):
        icon_name = "-".join(str(audio.speaker.icon_name).split("-")[0:2])
        self.icon.set_from_icon_name(icon_name + "-symbolic", 50)
        self.vol = audio.speaker.volume
        self.progress_bar.set_progress_filled(round(self.vol) / 100)

    def update_label_brightness(self):
        self.icon.set_from_icon_name("display-brightness-symbolic", 50)
        brightness = self.brightness.screen_brightness / self.max_disp_backlight
        self.progress_bar.set_progress_filled(brightness)

    def update_label_keyboard(self, *args):
        self.icon.set_from_icon_name("keyboard-brightness-symbolic", 50)
        brightness = (
            int(
                os.read(
                    os.open(self.kbd_backlight_path + "brightness", os.O_RDONLY), 50
                ),
            )
            / self.max_kbd_backlight
        )
        self.progress_bar.set_progress_filled(brightness)

    def enable_popup(self, type: str):
        if type == "sound":
            self.update_label_audio()
        elif type == "brightness":
            self.update_label_brightness()
        elif type == "kbd":
            self.update_label_keyboard()

        self.popup_timeout()
