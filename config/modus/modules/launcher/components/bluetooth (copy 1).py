from fabric.bluetooth import BluetoothClient, BluetoothDevice
from fabric.utils import remove_handler
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.entry import Entry
from fabric.widgets.label import Label
from fabric.widgets.scrolledwindow import ScrolledWindow
from gi.repository import GLib
from snippets import MaterialIcon

DEVICE_TYPE_ICONS = {
    "headset": "headphones",  # Icon for headset devices
    "headphones": "headphones",  # Icon for audio devices
    "computer": "computer",  # Icon for computer devices
    "phone": "smartphone",  # Icon for phone devices
    "tablet": "tablet",  # Icon for tablet devices
    "keyboard": "keyboard",  # Icon for keyboard devices
    "mouse": "mouse",  # Icon for mouse devices
    "other": "devices",  # Default icon
}

DEVICE_BATTERY_ICONS = {
    "full": "battery_full",  # Full battery
    "medium": "battery_half",  # Medium battery
    "low": "battery_alert",  # Low battery
}


class BluetoothManager(Box):
    def __init__(self, **kwargs):
        super().__init__(
            name="bluetooth-launcher",
            all_visible=False,
            visible=False,
            **kwargs,
        )

        self._arranger_handler = None
        self.device_manager = DeviceManager(self)
        self.viewport = None

        self.search_entry = Entry(
            name="search-entry",
            h_expand=True,
            notify_text=self.handle_search_input,
            on_activate=self.handle_search_input,
        )

        self.toggle_button = Button(
            on_clicked=lambda *_: self.device_manager.bluetooth_client.toggle_power()
        )

        self.device_manager.bluetooth_client.connect(
            "notify::enabled", self.update_toggle_button
        )

        self.header_box = Box(
            name="header-box",
            spacing=10,
            orientation="h",
            children=[
                self.search_entry,
                self.toggle_button,
                Button(
                    child=MaterialIcon("sync"),
                    on_clicked=lambda *_: self.device_manager.bluetooth_client.toggle_scan(),
                ),
            ],
        )

        self.launcher_box = Box(
            name="bluetooth-launcher-box",
            spacing=10,
            orientation="v",
            h_expand=True,
            children=[self.header_box],
        )

        self.add(self.launcher_box)

        self.is_active = False
        self.polling_handler = None

    def update_toggle_button(self, *_):
        icon_name = (
            "bluetooth"
            if self.device_manager.bluetooth_client.enabled
            else "bluetooth_disabled"
        )
        self.toggle_button.children = []
        self.toggle_button.add(MaterialIcon(icon_name))
        self.toggle_button.show_all()

    def open_launcher(self):
        if not self.is_active:
            self.is_active = True
            if not self.viewport:
                self.viewport = Box(name="viewport", spacing=4, orientation="v")
                self.scrolled_window = ScrolledWindow(
                    name="scrolled-window",
                    spacing=10,
                    h_scrollbar_policy="never",
                    v_scrollbar_policy="never",
                    child=self.viewport,
                )
                self.launcher_box.add(self.scrolled_window)

            self.viewport.children = []
            self.device_manager.arrange_viewport()

            self.viewport.show()
            self.search_entry.grab_focus()

            self.start_device_polling()
        else:
            self.device_manager.arrange_viewport()

    def handle_search_input(self, entry, text: str):
        if isinstance(text, str):
            self.device_manager.arrange_viewport(text)

    def start_device_polling(self):
        if not self.polling_handler and self.is_active:
            self.polling_handler = GLib.timeout_add(
                5000, self.device_manager.refresh_devices
            )

    def stop_device_polling(self):
        if self.polling_handler:
            GLib.source_remove(self.polling_handler)
            self.polling_handler = None


class DeviceManager:
    def __init__(self, launcher):
        self.launcher = launcher
        self.bluetooth_client = BluetoothClient(
            on_device_added=self.on_device_added,
            on_device_removed=self.on_device_removed,
        )
        self._cached_devices = []

    def refresh_devices(self, *_):
        if self.launcher.is_active:  # Only refresh devices if Bluetooth section is open
            self.arrange_viewport()
        return True

    def toggle_bluetooth(self, *_):
        self.bluetooth_client.toggle_power()
        self.arrange_viewport()

    def on_device_added(self, client: BluetoothClient, address: str):
        if device := client.get_device(address):
            self._cached_devices.append(device)
            self.refresh_viewport()

    def on_device_removed(self, client: BluetoothClient, address: str):
        self._cached_devices = [
            device for device in self._cached_devices if device.address != address
        ]
        self.refresh_viewport()

    def refresh_viewport(self):
        GLib.idle_add(self.arrange_viewport)

    def query_devices(self, query: str = "") -> list:
        devices = []
        query = query.lower()

        for device in self._cached_devices:
            name = device.name or "Unknown Device"
            if query in name.lower():
                devices.append(device)

        # Sort connected devices first, then unconnected ones based on signal strength
        return sorted(
            devices,
            key=lambda d: (
                not d.connected,
                not d.paired,
                d.rssi if hasattr(d, "rssi") else 0,
            ),
        )[:48]

    def get_battery_status(self, device: BluetoothDevice) -> str:
        if not device.connected:
            return "not-connected"

        battery_level = device.battery_level if device.battery_level > 0 else None
        battery_percentage = (
            device.battery_percentage if device.battery_percentage > 0 else None
        )

        if battery_level is None and battery_percentage is None:
            return "low"  # Show low if no battery info is available

        if battery_percentage is not None:
            if battery_percentage >= 75:
                return "full"
            elif battery_percentage >= 30:
                return "medium"
            else:
                return "low"

        # Fallback to battery level if percentage is unavailable
        if battery_level is not None:
            if battery_level >= 75:
                return "full"
            elif battery_level >= 30:
                return "medium"
            else:
                return "low"

        return "low"

    def connect_device(self, device: BluetoothDevice):
        device.set_connecting(not device.connected)

    def bake_device_slot(self, device: BluetoothDevice, **kwargs) -> Box:
        device_type = device.type.lower()  # Ensure device type is in lowercase
        icon_name = DEVICE_TYPE_ICONS.get(
            device_type, "devices"
        )  # Default to 'bluetooth'

        status_icon = MaterialIcon("link" if device.connected else "link_off")

        # Only show battery icon for connected devices
        if device.connected:
            battery_status = self.get_battery_status(device)
            battery_icon = MaterialIcon(
                DEVICE_BATTERY_ICONS.get(battery_status, "battery_alert")
            )
        else:
            battery_icon = None  # No battery icon for non-connected devices

        device_slot_children = [
            MaterialIcon(icon_name),
            Label(
                label=device.name or "Unknown Device",
                h_align="start",
                h_expand=True,
            ),
            battery_icon,
            status_icon,
            Button(
                name="connect-button",
                child=MaterialIcon(
                    "bluetooth_connected" if device.connected else "bluetooth_searching"
                ),
                tooltip_text="Disconnect" if device.connected else "Connect",
                on_clicked=lambda *_: self.connect_device(device),
            ),
        ]

        device_slot_children = [
            child for child in device_slot_children if child is not None
        ]

        return Box(
            name="device-slot",
            spacing=10,
            orientation="h",
            children=device_slot_children,
        )

    def arrange_viewport(self, query: str = ""):
        if not self.launcher.viewport:
            return

        (
            remove_handler(self.launcher._arranger_handler)
            if self.launcher._arranger_handler
            else None
        )
        self.launcher.viewport.children = []

        filtered_devices = self.query_devices(query)

        # Show available (unpaired) devices first, followed by paired devices
        if available_devices := [d for d in filtered_devices if not d.paired]:
            for device in available_devices:
                self.launcher.viewport.add(self.bake_device_slot(device))

        if paired_devices := [d for d in filtered_devices if d.paired]:
            for device in paired_devices:
                self.launcher.viewport.add(self.bake_device_slot(device))

        if not filtered_devices:
            self.launcher.viewport.add(
                Label(
                    label="No devices found" if not query else "No matching devices",
                    name="empty-label",
                    h_align="center",
                )
            )
