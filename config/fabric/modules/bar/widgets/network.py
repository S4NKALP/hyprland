import psutil
from fabric.utils import invoke_repeater
from fabric.widgets.box import Box
from icon import MaterialIcon
import subprocess

class Network(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.update_interval = 5000
        self.last_status = None
        invoke_repeater(self.update_interval, self.update_network_status, initial_call=True)

    def update_network_status(self):
        current_status = self.get_network_status()
        if current_status != self.last_status:
            self.update_icon(current_status)
            self.last_status = current_status
        return True

    def update_icon(self, current_status):
        self.icon_label = MaterialIcon(current_status, size="16px")
        self.children = (self.icon_label,)

    def get_network_status(self):
        if self.is_ethernet_connected():
            return "network_ethernet"
        if self.is_wifi_connected():
            return self.get_wifi_strength_icon()
        return "signal_wifi_off"

    def get_wifi_strength_icon(self):
        wifi_strength = self.check_wifi_strength()

        return self.wifi_signal_icon(wifi_strength)

    def wifi_signal_icon(self, strength):
        if strength is None or strength <= -100:
            return "signal_wifi_0_bar"
        if strength > -50:
            return "signal_wifi_4_bar"
        if strength > -60:
            return "network_wifi_3_bar"
        if strength > -70:
            return "network_wifi_2_bar"
        return "network_wifi_1_bar"

    def check_wifi_strength(self):
        try:
            result = subprocess.run(['iwconfig'], capture_output=True, text=True)
            for line in result.stdout.splitlines():
                if 'Signal level' in line:
                    signal_level = line.split('Signal level=')[1].split(' ')[0]
                    return int(signal_level.strip().replace('dBm', ''))
            return None
        except Exception:
            return None

    def is_wifi_connected(self):
        return any(self._is_interface_up(interface, ["wlan", "wifi"]) for interface in psutil.net_if_addrs())

    def is_ethernet_connected(self):
        return any(self._is_interface_up(interface, ["eth"]) for interface in psutil.net_if_addrs())

    def _is_interface_up(self, interface, keywords):
        if any(substring in interface.lower() for substring in keywords):
            return psutil.net_if_stats().get(interface, {}).isup
        return False

