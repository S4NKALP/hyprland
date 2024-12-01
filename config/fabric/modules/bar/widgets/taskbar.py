import json
from typing import TypedDict

from fabric.hyprland.widgets import get_hyprland_connection
from fabric.utils import exec_shell_command
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from gi.repository import GdkPixbuf, GLib, Gtk
from snippets import IconResolver


class PagerClient(TypedDict):
    title: str
    initialClass: str
    mapped: bool
    hidden: bool
    address: str


class TaskBar(Box):
    def __init__(self, icon_size: int = 24, **kwargs):
        super().__init__(
            orientation="h",
            spacing=7,
            name="taskbar",
            **kwargs,
        )
        self.connection = get_hyprland_connection()
        self.icon_size = icon_size
        self.icon_theme = Gtk.IconTheme.get_default()
        self.icon_resolver = IconResolver()

        self.set_visible(False)
        self._icon_cache = {}

        if self.connection.ready:
            self.render_with_delay()
        else:
            self.connection.connect("event::ready", lambda *_: self.render_with_delay())

        for event in (
            "activewindow",
            "openwindow",
            "closewindow",
            "changefloatingmode",
        ):
            self.connection.connect(f"event::{event}", lambda *_: self.render())

    def render_with_delay(self, *_):
        GLib.timeout_add(101, self.render)

    def render(self, *_):
        self.children = []
        active_window_address = self.get_active_window_address()

        for client in self.fetch_clients():
            if client["mapped"] and not client["hidden"]:
                window_class = client["initialClass"].lower()
                icon = self.bake_window_icon(window_class)

                button = Button(image=icon, tooltip_text=client["title"])
                if client["address"] == active_window_address:
                    button.add_style_class("activated")
                button.connect(
                    "button-press-event", self.on_icon_click, client["address"]
                )

                self.add(button)

        self.set_visible(len(self.children) > 0)
        if self.children:
            self.show_all()

    def get_active_window_address(self) -> str:
        active_window_info = json.loads(
            self.connection.send_command("j/activewindow").reply.decode()
        )
        return active_window_info.get("address", "")

    def on_icon_click(self, widget, event, address):
        command = (
            "focuswindow"
            if event.button == 1
            else "closewindow" if event.button == 3 else None
        )
        if command:
            exec_shell_command(f"hyprctl dispatch {command} address:{address}")

    def fetch_clients(self) -> list[PagerClient]:
        return json.loads(self.connection.send_command("j/clients").reply.decode())

    def bake_window_icon(
        self, window_class: str, fallback_icon: str = "image-missing"
    ) -> Image:
        icon_name = self.icon_resolver.get_icon_name(window_class) or fallback_icon
        if icon_name not in self._icon_cache:
            pixbuf = self.load_icon(icon_name)
            self._icon_cache[icon_name] = pixbuf
        return Image(pixbuf=self._icon_cache[icon_name], size=self.icon_size)

    def load_icon(
        self, icon_name: str, fallback_icon: str = "image-missing"
    ) -> GdkPixbuf.Pixbuf:
        try:
            pixbuf = self.icon_theme.load_icon(
                icon_name, self.icon_size, Gtk.IconLookupFlags.FORCE_SIZE
            )
        except Exception:
            pixbuf = self.icon_theme.load_icon(
                fallback_icon, self.icon_size, Gtk.IconLookupFlags.FORCE_SIZE
            )
        return pixbuf
