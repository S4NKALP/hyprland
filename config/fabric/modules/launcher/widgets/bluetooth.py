from fabric.bluetooth import BluetoothClient
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from fabric.widgets.label import Label
from snippets import MaterialIcon


class BluetoothMenu:
    def __init__(self, launcher):
        self.launcher = launcher
        self.client = BluetoothClient(on_device_added=self.on_device_added)
        self.paired_devices = {}
        self.available_devices = {}

        self.bt_button = Button(
            child=MaterialIcon("bluetooth"),
            h_align="center",
            v_align="center",
            on_clicked=self.bt_toggle,
        )
        self.update_bt_button_style()

        self.scan_button = Button(
            child=MaterialIcon("refresh"),
            h_align="center",
            v_align="center",
            on_clicked=lambda *_: self.client.toggle_scan(),
            style=" min-height:50px; min-width:50px;",
        )

    def bt_toggle(self, *args):
        self.update_bt_button_style()
        self.client.toggle_power()

    def update_bt_button_style(self):
        if self.client.enabled:
            self.bt_button.set_style(
                "background-color: transparent; min-height: 50px; min-width: 50px;"
            )
        else:
            self.bt_button.set_style(
                "background-color: @surfaceVariant;  min-height: 50px; min-width: 50px;"
            )

    def show_bluetooth_menu(self, viewport):
        viewport.children = []

        devices_box = Box(orientation="v", spacing=5)

        # Add paired devices to the paired devices box
        for address, device in self.paired_devices.items():
            device_button = Button(
                child=Box(
                    orientation="h",
                    spacing=10,
                    children=[
                        Image(icon_name=device.icon_name, size=32),
                        Label(label=device.name),  # Show the device name
                        Box(
                            orientation="h",
                            children=[
                                Label(
                                    label=" "
                                    + ("Connected" if device.connected else ""),
                                    h_align="end",
                                ),
                            ],
                        ),
                    ],
                ),
                on_clicked=lambda _, device=device: self.connect_to_device(device),
                name="sh-item",
            )
            devices_box.add(device_button)

        # Add available devices to the available devices box
        for address, device in self.available_devices.items():
            device_button = Button(
                child=Box(
                    orientation="h",
                    spacing=10,
                    children=[
                        Image(icon_name=device.icon_name, size=32),
                        Label(label=device.name),  # Show the device name
                        Box(
                            orientation="h",
                            children=[
                                Label(
                                    label="",
                                ),
                            ],
                        ),
                    ],
                ),
                on_clicked=lambda _, device=device: self.connect_to_device(device),
                name="sh-item",
            )
            devices_box.add(device_button)

        viewport.add(devices_box)

    def connect_to_device(self, device):
        device.set_connecting(True)
        self.show_bluetooth_menu(self.launcher.viewport)

    def on_device_added(self, client, address):
        if not (device := client.get_device(address)):
            return

        if device.paired:
            self.paired_devices[address] = device
        else:
            self.available_devices[address] = device

        self.show_bluetooth_menu(self.launcher.viewport)

    def get_bluetooth_buttons(self):
        return [self.bt_button, self.scan_button]
