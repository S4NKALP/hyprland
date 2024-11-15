import json
from typing import TypedDict

from fabric.hyprland.widgets import get_hyprland_connection
from fabric.utils import DesktopApp, exec_shell_command, get_desktop_applications
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from gi.repository import GdkPixbuf, GLib, Gtk


class PagerClient(TypedDict):
    title: str
    initialClass: str
    mapped: bool
    hidden: bool
    address: str


class TaskBar(Box):
    def __init__(self, icon_size: int = 18, **kwargs):
        super().__init__(
            orientation="h",
            spacing=7,
            name="taskbar",
            **kwargs,
        )
        self.connection = get_hyprland_connection()
        self.icon_size = icon_size
        self.icon_theme = Gtk.IconTheme.get_default()

        self.set_visible(False)

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
            self.connection.connect("event::" + event, lambda *_: self.render(None))

    def render_with_delay(self, *_):
        GLib.timeout_add(101, self.render)

    def render(self, *_):
        self.children = []

        clients = self.fetch_clients()
        active_window_address = self.get_active_window_address()

        visible_clients = [
            client for client in clients if client["mapped"] and not client["hidden"]
        ]

        if visible_clients:
            for client in visible_clients:
                window_class = client["initialClass"].lower()
                icon = self.bake_window_icon(window_class)

                button = Button(image=icon, tooltip_text=client["title"])
                if client["address"] == active_window_address:
                    button.set_style(
                        "background-color: @surfaceVariant; border-radius:101px;"
                    )
                button.connect(
                    "button-press-event", self.on_icon_click, client["address"]
                )

                self.add(button)

            self.set_visible(True)
            self.show_all()
        else:
            self.set_visible(False)

    def get_active_window_address(self) -> str:
        active_window_info = json.loads(
            self.connection.send_command("j/activewindow").reply.decode()
        )
        return active_window_info.get("address", "")

    def on_icon_click(self, widget, event, address):
        exec_shell_command(f"hyprctl dispatch focuswindow address:{address}")

    def fetch_clients(self) -> list[PagerClient]:
        return json.loads(self.connection.send_command("j/clients").reply.decode())

    def bake_window_icon(
        self, window_class: str, fallback_icon: str = "image-missing"
    ) -> Image:
        icon = self.get_application_icon(window_class, fallback_icon)
        return Image(pixbuf=icon, size=self.icon_size)

    def get_application_icon(
        self, window_class: str, fallback_icon: str
    ) -> GdkPixbuf.Pixbuf:
        app = self.get_app_by_window_class(window_class)
        if app:
            pixbuf = app.get_icon_pixbuf()
            if pixbuf:
                return pixbuf

        return self.load_icon(fallback_icon)

    def get_app_by_window_class(self, window_class: str) -> DesktopApp | None:
        all_apps = get_desktop_applications()
        for app in all_apps:
            if window_class.lower() in (app.display_name or "").lower():
                return app
        return None

    def load_icon(
        self, icon_name: str, fallback_icon: str = "image-missing"
    ) -> GdkPixbuf.Pixbuf:
        try:
            pixbuf = self.icon_theme.load_icon(
                icon_name,
                self.icon_size,
                Gtk.IconLookupFlags.FORCE_SIZE,
            )
        except Exception:
            pixbuf = self.icon_theme.load_icon(
                fallback_icon,
                self.icon_size,
                Gtk.IconLookupFlags.FORCE_SIZE,
            )
        return pixbuf
