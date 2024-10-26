import socket

import psutil
from fabric.utils import invoke_repeater
from fabric.widgets.box import Box
from fabric.widgets.label import Label


class Wifi(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.wifi_icon = Label(
            label="󰤭",
            name="symbol",
            # style="font-size: 16px; margin-right: 6px;",
        )

        invoke_repeater(1000, self.update_wifi_status, initial_call=True)

        self.children = (self.wifi_icon,)

    def update_wifi_status(self):
        wifi_on = self.check_wifi_status()

        if wifi_on:
            self.wifi_icon.set_label("󰤥")
        else:
            self.wifi_icon.set_label("󰤭")

        return True

    def check_wifi_status(self):
        for interface, addrs in psutil.net_if_addrs().items():
            if "wlan" in interface or "wifi" in interface:
                if (
                    interface in psutil.net_if_stats()
                    and psutil.net_if_stats()[interface].isup
                ):
                    for addr in addrs:
                        if addr.family in (socket.AF_INET, socket.AF_INET6):
                            return True
        return False
