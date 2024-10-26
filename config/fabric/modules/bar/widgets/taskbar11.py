import glob
import json
import subprocess
from typing import TypedDict

from fabric.hyprland.widgets import get_hyprland_connection
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from fabric.widgets.label import Label
from gi.repository import GdkPixbuf, GLib, Gtk


class PagerClient(TypedDict):
    title: str
    initialClass: str
    mapped: bool
    hidden: bool
    address: str


class TaskBar(Box):
    def __init__(self, icon_size: int = 24, **kwargs):
        super().__init__(orientation="h", spacing=6, name="taskbar", **kwargs)
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
        GLib.timeout_add(100, self.render)

    def render(self, *_):
        self.children = []

        clients = self.fetch_clients()
        active_window_address = self.get_active_window_address()

        # Group clients by initialClass
        grouped_clients = {}
        for client in clients:
            if client["mapped"] and not client["hidden"]:
                window_class = client["initialClass"].lower()
                if window_class not in grouped_clients:
                    grouped_clients[window_class] = []
                grouped_clients[window_class].append(client)

        if grouped_clients:
            for window_class, client_group in grouped_clients.items():
                # Fetch the icon for the application (one icon per group)
                icon = self.bake_window_icon(window_class)

                # Create a vertical box inside the button for the icon and the dots
                icon_box = Box(orientation="v", spacing=0)
                icon_box.set_halign(Gtk.Align.CENTER)

                # Add the icon at the top
                icon_box.add(icon)

                # Add dot(s) directly below the icon to indicate the number of open instances
                if len(client_group) > 1:
                    dots_box = Box(orientation="h", spacing=2)  # Box to hold the dots
                    dots_box.set_halign(Gtk.Align.CENTER)

                    for _ in range(len(client_group)):
                        dot = Label(
                            label="•"
                        )  # Each dot represents one window instance
                        dot.set_style(
                            "font-size: 7px; color: rgba(255, 255, 255, 0.6);"
                        )  # Lighter dot color
                        dots_box.add(dot)

                    icon_box.add(dots_box)

                # Create a button and add the icon_box (icon + dots) inside the button
                button = Button(child=icon_box, tooltip_text=client_group[0]["title"])

                # Highlight the active window
                if any(
                    client["address"] == active_window_address
                    for client in client_group
                ):
                    button.set_style(
                        "background-color: @surfaceVariant; transition-duration: 0.3s; border-radius:100px;"
                    )

                # Connect click event to focus the application window
                button.connect(
                    "button-press-event", self.on_icon_click, client_group[0]["address"]
                )

                # Add the button to the taskbar
                self.add(button)

            self.set_visible(True)
            self.show_all()
        else:
            self.set_visible(False)

    def get_active_window_address(self) -> str:
        # Fetch the address of the currently active window
        active_window_info = json.loads(
            self.connection.send_command("j/activewindow").reply.decode()
        )
        print(f"Active window address: {active_window_info.get('address', '')}")
        return active_window_info.get("address", "")

    def on_icon_click(self, widget, event, address):
        command = ["hyprctl", "dispatch", "focuswindow", f"address:{address}"]
        subprocess.run(command, check=True)

    def fetch_clients(self) -> list[PagerClient]:
        return json.loads(self.connection.send_command("j/clients").reply.decode())

    def bake_window_icon(
        self, window_class: str, fallback_icon: str = "image-missing"
    ) -> Image:
        icon_name = self.get_icon_from_desktop_entry(window_class)

        if icon_name:
            pixbuf = self.load_icon(icon_name)
        else:
            pixbuf = self.load_icon(window_class, fallback_icon)

        return Image(pixbuf=pixbuf, size=self.icon_size)

    def get_icon_from_desktop_entry(self, window_class: str) -> str:
        desktop_files = glob.glob("/usr/share/applications/*.desktop")
        for desktop_file in desktop_files:
            with open(desktop_file, "r") as f:
                for line in f:
                    if line.startswith("Name="):
                        app_name = line.split("=", 1)[1].strip().lower()
                        if window_class in app_name:
                            for line in f:
                                if line.startswith("Icon="):
                                    return line.split("=", 1)[1].strip()
        return None

    def load_icon(
        self, icon_name: str, fallback_icon: str = "image-missing"
    ) -> GdkPixbuf.Pixbuf:
        try:
            pixbuf = self.icon_theme.load_icon(
                icon_name,ecode
    raise JSONDecodeError("Expecting value", s, err.value) from None
json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)
Active window address: 0x60d8e93ecf50
Active window address: 0x60d8e93ecf50
Active window address: 0x60d8e93ecf50
^C2024-10-22 13:47:53.414 | INFO     | fabric.core.application:on_exit:316 - [Fabric] exiting...

sankalp on 53ur!tyD3m0n  fabric/rework/bar via 🐍 v3.12.7 [⏱ 1m4s]✔
╰─λ
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

