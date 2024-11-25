import os

from fabric.utils import exec_shell_command, exec_shell_command_async
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.label import Label
from loguru import logger
from snippets import MaterialIcon


class PowerMenu:
    def __init__(self, launcher):
        self.launcher = launcher
        self.idle_inhibitor = False
        self.idle_button = Button(
            child=MaterialIcon("schedule"),
            v_align="center",
            on_clicked=self.toggle_idle_inhibitor,
        )
        self.idle_button.set_style(
            "background-color: transparent;min-width:50px; min-height:50px;"
        )

    def toggle_idle_inhibitor(self, *args):
        self.idle_inhibitor = not self.idle_inhibitor
        script_path = os.path.expanduser(
            "~/fabric/assets/scripts/wayland-idle-inhibitor.py"
        )

        if self.idle_inhibitor and not self.check_idle_state():
            exec_shell_command_async(
                ["python3", script_path],
                lambda output: logger.info(f"Idle inhibitor output: {output}"),
            )
            self.idle_button.set_style(
                "background-color: @surfaceVariant; min-width:50px; min-height:50px; border-radius:100px;"
            )
        else:
            exec_shell_command("pkill -f wayland-idle-inhibitor.py")
            self.idle_button.set_style(
                "background-color: transparent;min-width:50px; min-height:50px;"
            )

    def check_idle_state(self):
        return "wayland-idle-inhibitor.py" in exec_shell_command(
            "pidof wayland-idle-inhibitor.py"
        )

    def show_power_menu(self, viewport, query: str = ""):
        viewport.children = []

        power_options = [
            {
                "label": "Shutdown",
                "icon": "power_settings_new",
                "action": self.shutdown,
            },
            {
                "label": "Logout",
                "icon": "logout",
                "action": self.logout,
            },
            {
                "label": "Reboot",
                "icon": "restart_alt",
                "action": self.reboot,
            },
            {
                "label": "Suspend",
                "icon": "sleep",
                "action": self.suspend,
            },
            {
                "label": "Lock",
                "icon": "lock",
                "action": self.lock,
            },
        ]
        if query:
            power_options = [
                option
                for option in power_options
                if query.lower() in option["label"].lower()
            ]

        for option in power_options:
            button = Button(
                child=Box(
                    orientation="h",
                    spacing=10,
                    children=[
                        MaterialIcon(option["icon"], size="28px"),
                        Label(label=option["label"], h_align="start"),
                    ],
                ),
                on_clicked=lambda _, action=option["action"]: action(),
                name="sh-item",
            )
            viewport.add(button)

    def shutdown(self):
        exec_shell_command("systemctl poweroff")

    def reboot(self):
        exec_shell_command("systemctl reboot")

    def suspend(self):
        exec_shell_command("systemctl suspend")

    def logout(self):
        exec_shell_command("hyprctl dispatch logout")

    def lock(self):
        exec_shell_command("hyprlock --immediate")

    def get_power_buttons(self):
        return self.idle_button
