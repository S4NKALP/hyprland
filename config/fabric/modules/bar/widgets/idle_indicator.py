from fabric.utils import exec_shell_command
from fabric.widgets.box import Box
from gi.repository import GLib
from snippets import MaterialIcon


class IdleIndicator(Box):
    ICON_IDLE = "schedule"

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.idle_icon = self.create_idle_icon()

        self.check_idle_status()

        GLib.timeout_add(1000, self.check_idle_status)

        self.children = (self.idle_icon,)

    def create_idle_icon(self):
        return MaterialIcon(self.ICON_IDLE, size="16px")

    def check_idle_status(self):
        try:
            output = exec_shell_command("pidof wayland-idle-inhibitor.py")
            output_str = str(output) if output is not None else ""
            is_idle = bool(output_str.strip())

            self.update_idle_status(is_idle)
        except Exception as e:
            print(f"Error checking idle status: {e}")
            self.update_idle_status(False)

        return True

    def update_idle_status(self, is_idle):
        if is_idle:
            self.idle_icon.set_label(self.ICON_IDLE)
            self.idle_icon.set_visible(True)
        else:
            self.idle_icon.set_visible(False)
