from fabric.utils import exec_shell_command
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.label import Label
from snippets import MaterialIcon


class PowerMenu:
    def __init__(self, launcher):
        self.launcher = launcher

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

    def icon_button(self):
        return Button(
            child=MaterialIcon("power_settings_new"),
        )
