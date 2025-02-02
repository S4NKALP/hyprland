from fabric.widgets.centerbox import CenterBox
from fabric.widgets.stack import Stack
from fabric.widgets.wayland import WaylandWindow as Window
from modules.launcher.components import (
    AppLauncher,
    BluetoothManager,
    Cliphist,
    Emoji,
    PowerMenu,
    Sh,
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
            **kwargs,
        )

        self.launcher = AppLauncher()
        self.wallpapers = WallpaperSelector()
        self.power = PowerMenu()
        self.emoji = Emoji()
        self.cliphist = Cliphist()
        self.todo = TodoManager()
        self.bluetooth = BluetoothManager()
        self.sh = Sh()

        self._emoji_viewport = None
        self._cliphist_viewport = None
        self._todo_viewport = None
        self._bluetooth_viewport = None
        self._sh_viewport = None

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
                self.sh,
            ],
        )

        self.launcher_box = CenterBox(
            name="launcher",
            orientation="v",
            start_children=self.stack,
        )

        self.add(self.launcher_box)
        self.show_all()
        self.hide()
        self.wallpapers.viewport.hide()
        self.add_keybinding("Escape", lambda *_: self.close())

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
            self.sh,
        ]:
            widget.remove_style_class("open")
            if widget == self.wallpapers:
                self.wallpapers.viewport.hide()
                self.wallpapers.viewport.set_property("name", None)

            if widget == self.emoji and hasattr(widget, "viewport") and widget.viewport:
                widget.viewport.hide()

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

            if widget == self.sh and widget.viewport:
                widget.viewport.hide()

        for style in [
            "launcher",
            "wallpapers",
            "power",
            "emoji",
            "cliphist",
            "todo",
            "bluetooth",
            "sh",
        ]:
            self.stack.remove_style_class(style)

        self.stack.set_visible_child(self.launcher)

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
            "sh": self.sh,
        }

        for style in widgets.keys():
            self.stack.remove_style_class(style)
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
                self.wallpapers.viewport.show()
                self.wallpapers.viewport.set_property("name", "wallpaper-icons")

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

            elif widget == "sh":
                self.sh.open_launcher()
                self.sh.search_entry.set_text("")
                self.sh.search_entry.grab_focus()

            else:
                if hasattr(self.wallpapers, "viewport"):
                    self.wallpapers.viewport.hide()
                    self.wallpapers.viewport.set_property("name", None)
