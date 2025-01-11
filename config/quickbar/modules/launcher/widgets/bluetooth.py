from fabric.bluetooth import BluetoothClient, BluetoothDevice
from fabric.utils import remove_handler
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.entry import Entry
from fabric.widgets.label import Label
from fabric.widgets.scrolledwindow import ScrolledWindow
from gi.repository import Gdk, GLib
from snippets import MaterialIcon


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
            placeholder="Search Devices...",
            h_expand=True,
            notify_text=self.handle_search_input,
            on_activate=self.handle_search_input,
        )

        self.header_box = Box(
            name="header-box",
            spacing=10,
            orientation="h",
            children=[
                self.search_entry,
                Button(
                    name="power-button",
                    child=MaterialIcon("bluetooth"),
                    tooltip_text="Toggle Bluetooth",
                    on_clicked=self.device_manager.toggle_bluetooth,
                ),
                Button(
                    name="scan-button",
                    child=MaterialIcon("sync"),
                    tooltip_text="Scan for Devices",
                    on_clicked=self.device_manager.toggle_scan,
                ),
                Button(
                    name="close-button",
                    child=MaterialIcon("close"),
                    tooltip_text="Exit",
                    on_clicked=self.close_launcher,
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

    def close_launcher(self):
        self.is_active = False
        if self.viewport:
            self.viewport.children = []

        self.stop_device_polling()
        GLib.spawn_command_line_async("fabric-cli exec quickbar 'launcher.close()'")

    def handle_search_input(self, entry, text: str):
        if isinstance(text, str):
            if text.lower() == ":bt":
                self.open_launcher()
            else:
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

    def refresh_devices(self):
        if self.launcher.is_active:  # Only refresh devices if Bluetooth section is open
            self.arrange_viewport()
        return True

    def toggle_bluetooth(self):
        self.bluetooth_client.toggle_power()
        self.arrange_viewport()

    def toggle_scan(self):
        self.bluetooth_client.toggle_scan()
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

        return sorted(
            devices, key=lambda d: (not d.paired, d.name or "Unknown Device")
        )[:48]

    def connect_device(self, device: BluetoothDevice):
        device.set_connecting(not device.connected)

    def bake_device_slot(self, device: BluetoothDevice, **kwargs) -> Box:
        status_icon = MaterialIcon("link" if device.connected else "link_off")

        return Box(
            name="device-slot",
            spacing=10,
            orientation="h",
            children=[
                Label(
                    label=device.name or "Unknown Device",
                    h_align="start",
                    h_expand=True,
                ),
                status_icon,
                Button(
                    name="connect-button",
                    child=MaterialIcon(
                        "bluetooth_connected"
                        if device.connected
                        else "bluetooth_searching"
                    ),
                    tooltip_text="Disconnect" if device.connected else "Connect",
                    on_clicked=lambda *_: self.connect_device(device),
                ),
            ],
            **kwargs,
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
