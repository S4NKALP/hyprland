from fabric.utils import exec_shell_command, invoke_repeater
from fabric.widgets.box import Box
from fabric.widgets.label import Label

PROFILE_ICONS = {
    "power-saver": "󰡳",
    "balanced": None,
    "performance": "󰡴",
}


class PowerProfile(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.profile_icon = Label(
            label="󰡳",
            name="symbol",
            # style="font-size: 16px; margin-right: 4px;",
        )

        invoke_repeater(1000, self.update_power_profile, initial_call=True)

        self.children = (self.profile_icon,)

    def update_power_profile(self):
        profile = self.get_power_profile()
        self.update_icon(profile)
        return True

    def get_power_profile(self):
        result = exec_shell_command("powerprofilesctl get")
        return result.strip() if result else "power-saver"

    def update_icon(self, profile):
        if profile in ["power-saver", "performance"]:
            icon = PROFILE_ICONS[profile]
            self.profile_icon.set_label(icon)
            self.profile_icon.show()
        else:
            self.profile_icon.hide()
