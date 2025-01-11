from fabric.widgets.box import Box
from fabric.widgets.button import Button
from gi.repository import GLib

from snippets import MaterialIcon


class PowerMenu(Box):
    def __init__(self, **kwargs):
        super().__init__(
            name="power-menu",
            orientation="h",
            spacing=10,
            v_align="center",
            h_align="center",
            v_expand=True,
            h_expand=True,
            visible=True,
            **kwargs,
        )

        self.btn_lock = Button(
            name="power-menu-button",
            child=MaterialIcon("lock", 50),
            on_clicked=self.lock,
        )

        self.btn_suspend = Button(
            name="power-menu-button",
            child=MaterialIcon("sleep", 50),
            on_clicked=self.suspend,
        )

        self.btn_logout = Button(
            name="power-menu-button",
            child=MaterialIcon("logout", 50),
            on_clicked=self.logout,
        )

        self.btn_reboot = Button(
            name="power-menu-button",
            child=MaterialIcon("restart_alt", 50),
            on_clicked=self.reboot,
        )

        self.btn_shutdown = Button(
            name="power-menu-button",
            child=MaterialIcon("power_settings_new", 50),
            on_clicked=self.poweroff,
        )

        self.buttons = [
            self.btn_lock,
            self.btn_suspend,
            self.btn_logout,
            self.btn_reboot,
            self.btn_shutdown,
        ]

        for button in self.buttons:
            self.add(button)

        self.show_all()

    def close_menu(self):
        GLib.spawn_command_line_async("fabric-cli exec quickbar 'launcher.close()'")

    def lock(self, *_):
        GLib.spawn_command_line_async("hyprlock --immediate")
        self.close_menu()

    def suspend(self, *_):
        GLib.spawn_command_line_async("systemctl suspend")
        self.close_menu()

    def logout(self, *_):
        GLib.spawn_command_line_async("hyprctl dispatch exit")
        self.close_menu()

    def reboot(self, *_):
        GLib.spawn_command_line_async("systemctl reboot")
        self.close_menu()

    def poweroff(self, *_):
        GLib.spawn_command_line_async("systemctl poweroff")
        self.close_menu()
