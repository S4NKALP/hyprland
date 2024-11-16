import os

from fabric.utils import exec_shell_command
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.label import Label
from services.inhibit import Inhibit


class DesktopButtonManager:
    def __init__(self, viewport):
        self.viewport = viewport
        self.inhibit_service = Inhibit()

    def show_desktop_buttons(self, search_query: str = ""):
        self.viewport.children = []
        parent_box = Box(orientation="h", spacing=10)
        column1 = Box(orientation="v", spacing=10)
        column2 = Box(orientation="v", spacing=10)

        desktop_controls = [
            {
                "name": "Wi-Fi",
                "icon": ("󰤨", "󰤭"),
                "toggle": self.toggle_wifi,
                "state": self.check_wifi_state,
            },
            {
                "name": "Bluetooth",
                "icon": ("󰂯", "󰂲"),
                "toggle": self.toggle_bluetooth,
                "state": self.check_bluetooth_state,
            },
            {
                "name": "Dark Mode",
                "icon": ("󱎖", "󱎖"),
                "toggle": self.toggle_dark_mode,
                "state": self.check_dark_mode_state,
            },
            {
                "name": "Idle",
                "icon": ("󱑁", "󱑁"),
                "toggle": self.toggle_idle_mode,
                "state": lambda: self.inhibit_service.is_inhibit,
            },
            {
                "name": "Do Not Disturb",
                "icon": ("󰂚", "󰂛"),
                "toggle": self.toggle_dnd,
                "state": None,
            },
            {
                "name": "Power Profile",
                "icons": (
                    "󰡳",
                    "󰊚",
                    "󰡴",
                ),
                "toggle": self.toggle_power_profile,
                "state": self.check_power_profile_state,
            },
        ]

        for i, control in enumerate(desktop_controls):
            if search_query.lower() not in control["name"].lower():
                continue
            current_state = (
                control["state"]()
                if control["state"] and callable(control["state"])
                else False
            )

            if "icons" in control:
                if current_state == "performance":
                    icon = control["icons"][2]
                    is_active = True
                elif current_state == "balanced":
                    icon = control["icons"][1]
                    is_active = False
                else:
                    icon = control["icons"][0]
                    is_active = True
            else:  # Two-state control
                icon = control["icon"][0] if current_state else control["icon"][1]
                is_active = current_state

            button = Button(
                child=Box(
                    orientation="h",
                    spacing=10,
                    children=[
                        Label(
                            label=icon,
                            name="icon-label",
                            style="font-size:32px; margin:0 12px 0 0; padding:12px;",
                        ),
                        Label(
                            label=control["name"],
                            name="name-label",
                            style="font-size:16px; padding:12px;",
                        ),
                    ],
                ),
                on_clicked=control["toggle"],
                name="db-item",
                tooltip_text=f"{control['name']} is {'on' if current_state else 'off'}",
            )
            if is_active:
                button.set_style(
                    "background-color: @surfaceVariant; transition-duration: 0.3s; border-radius:999px;"
                )
            else:
                button.set_style("background-color: transparent; ")

            if i % 2 == 0:
                column1.add(button)
            else:
                column2.add(button)

        parent_box.add(column1)
        parent_box.add(column2)
        self.viewport.add(parent_box)

    def toggle_power_profile(self, *_):
        current_mode = self.check_power_profile_state()
        if current_mode == "performance":
            command = "powerprofilesctl set balanced"
        elif current_mode == "balanced":
            command = "powerprofilesctl set power-saver"
        else:  # Power Saver
            command = "powerprofilesctl set performance"

        exec_shell_command(command)
        self.show_desktop_buttons()

    def check_power_profile_state(self):
        result = exec_shell_command("powerprofilesctl get")
        current_mode = result.strip().lower()  # Ensure uniform casing
        return current_mode

    def toggle_wifi(self, *_):
        state = self.check_wifi_state()
        command = "nmcli radio wifi on" if not state else "nmcli radio wifi off"
        exec_shell_command(command)
        self.show_desktop_buttons()

    def check_wifi_state(self):
        result = exec_shell_command("nmcli radio wifi")
        return "enabled" in result

    def toggle_bluetooth(self, *_):
        state = self.check_bluetooth_state()
        command = "bluetoothctl power on" if not state else "bluetoothctl power off"
        exec_shell_command(command)
        self.show_desktop_buttons()

    def check_bluetooth_state(self):
        result = exec_shell_command("bluetoothctl show")
        return "Powered: yes" in result

    def toggle_dark_mode(self, *_):
        command = os.path.expanduser("~/fabric/assets/scripts/dark-theme.sh --toggle")
        exec_shell_command(command)
        self.show_desktop_buttons()

    def check_dark_mode_state(self):
        result = exec_shell_command(
            "gsettings get org.gnome.desktop.interface color-scheme"
        )
        current_mode = result.strip().replace("'", "")
        return current_mode == "prefer-dark"

    def toggle_idle_mode(self, *_):
        self.inhibit_service.toggle()
        self.show_desktop_buttons()

    def toggle_dnd(self, *_):
        current_state = self.check_dnd_state()
        command = (
            "gsettings set org.gnome.desktop.notifications show-banners true"
            if current_state
            else "gsettings set org.gnome.desktop.notifications show-banners false"
        )
        exec_shell_command(command)
        self.show_desktop_buttons()

    def check_dnd_state(self):
        result = exec_shell_command(
            "gsettings get org.gnome.desktop.notifications show-banners"
        )
        return result.strip() == "false"
