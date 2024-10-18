from __init__ import *


class Wifi(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.wifi_icon = Label(
            label="󰤭",
            style="font-size: 16px; ",
        )

        self.wifi_icon.set_tooltip_text("Unknown")

        invoke_repeater(1000, self.update_wifi_status, initial_call=True)

        self.children = (self.wifi_icon,)

    def update_wifi_status(self):
        wifi_name = self.get_connected_wifi_name()
        wifi_on = self.check_wifi_status()

        if wifi_on:
            self.wifi_icon.set_label("󰤥")
            self.wifi_icon.set_tooltip_text(wifi_name)
        else:
            self.wifi_icon.set_label("󰤭")
            self.wifi_icon.set_tooltip_text("Unknown")

        return True

    def check_wifi_status(self):
        for interface, addrs in psutil.net_if_addrs().items():
            if "wlan" in interface or "wifi" in interface:
                if (
                    interface in psutil.net_if_stats()
                    and psutil.net_if_stats()[interface].isup
                ):
                return True
        return False

    def get_connected_wifi_name(self):
        try:
            output = exec_shell_command(
                "nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2"
            )
            for line in output.splitlines():
                if line.startswith("yes:"):
                    return line.split(":")[1]
        except Exception as e:
            print(f"Error retrieving Wi-Fi name: {e}")

        return None
