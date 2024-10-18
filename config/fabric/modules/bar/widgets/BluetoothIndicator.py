from __init__ import *


class Bluetooth(Gtk.Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.bluetooth_client = BluetoothClient()
        self.bluetooth_icon = Label(
            label="󰂲",
            style="font-size: 16px;",
        )

        self.bluetooth_client.connect("changed", self.update_bluetooth_status)
        self.update_bluetooth_status()
        self.add(self.bluetooth_icon)

    def update_bluetooth_status(self, *args):
        if self.bluetooth_client.enabled:
            self.bluetooth_icon.set_label("󰂯")
        else:
            self.bluetooth_icon.set_label("󰂲")

    def on_destroy(self):
        self.bluetooth_client.disconnect("changed", self.update_bluetooth_status)
