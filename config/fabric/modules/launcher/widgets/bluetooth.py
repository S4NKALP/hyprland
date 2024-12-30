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

        self.bt_button = self.create_bluetooth_button()
        self.scan_button = self.create_scan_button()
        self.update_bt_button_style()

    def create_bluetooth_button(self):
        button = Button(
            child=MaterialIcon("bluetooth"),
            h_align="center",
            v_align="center",
            on_clicked=self.bt_toggle,
        )
        return button

    def create_scan_button(self):
        return Button(
            child=MaterialIcon("refresh"),
            h_align="center",
            v_align="center",
            on_clicked=lambda *_: self.client.toggle_scan(),
        )

    def bt_toggle(self, *_):
        self.client.toggle_power()
        self.update_bt_button_style()

    def update_bt_button_style(self):
        style = (
            "background-color: transparent;"
            if self.client.enabled
            else "background-color: @surfaceVariant; border-radius:100px; min-height: 50px; min-width: 50px;"
        )
        self.bt_button.set_style(style)

    def show_bluetooth_menu(self, viewport):
        viewport.children = []
        devices_box = Box(orientation="v", spacing=5)

        # Combine paired and available devices
        all_devices = {**self.paired_devices, **self.available_devices}
        for address, device in all_devices.items():
            device_button = self.create_device_button(device)
            devices_box.add(device_button)

        viewport.add(devices_box)

    def create_device_button(self, device):
        connection_status = "Connected" if device.connected else ""
        return Button(
            child=Box(
                orientation="h",
                spacing=10,
                children=[
                    Image(icon_name=device.icon_name, size=32),
                    Label(label=device.name),
                    Label(label=connection_status, h_align="end"),
                ],
            ),
            on_clicked=lambda _, device=device: self.connect_to_device(device),
            name="launcher-item",
        )

    def connect_to_device(self, device):
        device.set_connecting(True)
        self.show_bluetooth_menu(self.launcher.viewport)

    def on_device_added(self, client, address):
        if device := client.get_device(address):
            if device.paired:
                self.paired_devices[address] = device
            else:
                self.available_devices[address] = device

            self.show_bluetooth_menu(self.launcher.viewport)

    def get_bluetooth_buttons(self):
        return [self.bt_button, self.scan_button]
