# desktop_buttons.py

import subprocess
from fabric.widgets.button import Button
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.utils import exec_shell_command
from loguru import logger


class DesktopButtonManager:
    def __init__(self, emoji_viewport):
        self.emoji_viewport = emoji_viewport

    def show_desktop_buttons(self):
        """Display buttons for desktop controls like Wi-Fi, Bluetooth, Dark Mode, etc."""
        self.emoji_viewport.children = []
        row = Box(orientation="h", spacing=10)
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
                "state": lambda: False,  # Modify as needed
            },
            {
                "name": "Do Not Disturb",
                "icon": ("󰂚", "󰂛"),
                "toggle": self.toggle_dnd,
                "state": None,
            },
        ]

        for i, control in enumerate(desktop_controls):
            if control["state"] and callable(control["state"]):
                current_state = control["state"]()
            else:
                current_state = False

            icon = control["icon"][0] if current_state else control["icon"][1]
            button = Button(
                child=Box(
                    orientation="h",
                    spacing=20,
                    children=[
                        Label(
                            label=icon,
                            name="icon-label",
                            style="font-size:32px; margin:0 12px 0 0; padding:12px;",
                        ),
                    ],
                ),
                on_clicked=control["toggle"],
                name="db-item",
                tooltip_text=f"{control['name']} is {'on' if current_state else 'off'}",
            )
            row.add(button)
            if (i + 1) % 8 == 0:
                self.emoji_viewport.add(row)
                row = Box(
                    orientation="h", spacing=10
                )  # New row for next set of buttons

        # Add remaining buttons in last row
        if len(desktop_controls) % 8 != 0:
            self.emoji_viewport.add(row)

    def toggle_wifi(self, *_):
        state = self.check_wifi_state()
        command = "nmcli radio wifi on" if not state else "nmcli radio wifi off"
        exec_shell_command(command)
        logger.info("Toggled Wi-Fi.")

    def check_wifi_state(self):
        result = subprocess.run(
            "nmcli radio wifi", shell=True, capture_output=True, text=True
        )
        return "enabled" in result.stdout

    def toggle_bluetooth(self, *_):
        state = self.check_bluetooth_state()
        command = "bluetoothctl power on" if not state else "bluetoothctl power off"
        exec_shell_command(command)
        logger.info("Toggled Bluetooth.")

    def check_bluetooth_state(self):
        result = exec_shell_command("bluetoothctl show")
        return "Powered: yes" in result

    def toggle_dark_mode(self, *_):
        command = os.path.expanduser("~/fabric/assets/scripts/dark-theme.sh --toggle")
        exec_shell_command(command)
        logger.info("Toggled Dark Mode.")

    def check_dark_mode_state(self):
        result = exec_shell_command(
            "gsettings get org.gnome.desktop.interface color-scheme"
        )
        current_mode = result.strip().replace("'", "")
        return current_mode == "prefer-dark"

    def toggle_idle_mode(self, *_):
        # Add logic for idle mode toggle if needed
        logger.info("Toggled Idle Mode.")

    def toggle_dnd(self, *_):
        current_state = self.check_dnd_state()
        command = (
            "gsettings set org.gnome.desktop.notifications show-banners true"
            if current_state
            else "gsettings set org.gnome.desktop.notifications show-banners false"
        )
        exec_shell_command(command)
        logger.info("Toggled Do Not Disturb.")

    def check_dnd_state(self):
        result = exec_shell_command(
            "gsettings get org.gnome.desktop.notifications show-banners"
        )
        return result.strip() == "false"
