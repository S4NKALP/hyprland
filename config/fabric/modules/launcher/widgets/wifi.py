from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from fabric.widgets.label import Label
from services import NetworkClient
from snippets import MaterialIcon


class WifiMenu:
    def __init__(self, launcher):
        self.launcher = launcher
        self.client = NetworkClient()
        self.paired_devices = {}
        self.available_devices = {}

        self.wifi_toggle_button = Button(
            child=MaterialIcon("signal_wifi_4_bar"),
            h_align="center",
            v_align="center",
            on_clicked=self.toggle_wifi,
        )
        self.update_wifi_button_style()

        self.rescan_button = Button(
            child=MaterialIcon("refresh"),
            h_align="center",
            v_align="center",
            on_clicked=self.scan_for_networks,
        )

        self.client.device_ready.connect(self.on_device_added)

    def update_wifi_button_style(self):
        if self.check_wifi_state():
            self.wifi_toggle_button.set_style("background-color: transparent;")
        else:
            self.wifi_toggle_button.set_style(
                "background-color: @surfaceVariant; border-radius:100px; min-height:50px; min-width:50px;"
            )

    def check_wifi_state(self):
        return self.client.wifi_device.enabled if self.client.wifi_device else False

    def show_wifi_menu(self, viewport):
        viewport.children = []

        devices_box = Box(orientation="v", spacing=5)

        # Iterate over the list of available access points
        for ap in self.client.wifi_device.access_points:
            is_connected = ap["ssid"] == self.client.wifi_device.ssid  # Compare SSID

            device_button = Button(
                child=Box(
                    orientation="h",
                    spacing=10,
                    children=[
                        Image(icon_name=ap["icon-name"], size=32),
                        Label(label=ap["ssid"]),  # Show SSID
                        Box(
                            orientation="h",
                            children=[
                                Label(
                                    label="Connected" if is_connected else "",
                                    h_align="end",
                                ),
                            ],
                        ),
                    ],
                ),
                on_clicked=lambda _, ap=ap: (
                    self.connect_to_ap(ap, is_connected),
                    self.launcher.set_visible(False),
                ),
                name="launcher-item",
            )
            devices_box.add(device_button)

        viewport.add(devices_box)

    def connect_to_ap(self, ap, is_connected):
        if not is_connected:
            self.client.connect_wifi_bssid(ap["bssid"])

    def on_device_added(self, client):
        self.show_wifi_menu(self.launcher.viewport)

    def scan_for_networks(self, button):
        self.client.wifi_device.scan()
        self.show_wifi_menu(self.launcher.viewport)

    def toggle_wifi(self, button):
        self.update_wifi_button_style()
        if self.client.wifi_device:
            self.client.wifi_device.toggle_wifi()
        self.show_wifi_menu(self.launcher.viewport)

    def get_wifi_buttons(self):
        return [self.wifi_toggle_button, self.rescan_button]
