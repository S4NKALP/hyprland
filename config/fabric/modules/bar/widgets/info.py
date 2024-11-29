import psutil
from fabric import Fabricator
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.circularprogressbar import CircularProgressBar
from fabric.widgets.label import Label
from fabric.widgets.overlay import Overlay
from snippets import MaterialIcon


class HardwareUsage(Button):
    HARDWARE_ITEMS = [
        ("CPU", "settings_motion_mode"),
        ("Swap", "swap_horiz"),
        ("RAM", "memory_alt"),
        ("Temp", "thermometer"),
    ]

    def __init__(self):
        super().__init__(child=self._initialize_content())
        Fabricator(poll_from=self._refresh_hardware_usage, interval=1000)

    def _initialize_content(self):
        self.box = Box(orientation="h", name="tray")
        self.progress_bars = {}
        self.labels = {}
        self.icons = {}

        for hardware, icon_name in self.HARDWARE_ITEMS:
            self._create_hardware_item(hardware, icon_name)

        return self.box

    def _create_hardware_item(self, hardware, icon_name):
        self.progress_bars[hardware] = self._create_progress_bar()
        self.labels[hardware] = self._create_label()
        self.icons[hardware] = self._create_icon(icon_name)

        overlay = Overlay(
            child=self.progress_bars[hardware], overlays=self.icons[hardware]
        )
        self.box.pack_start(overlay, False, False, 0)
        self.box.pack_start(self.labels[hardware], False, False, 0)

    def _create_progress_bar(self):
        return CircularProgressBar(
            name="progress", line_style="round", line_width=1, size=30
        )

    def _create_label(self):
        return Label(style="font-size:14px; margin: 4px;")

    def _create_icon(self, icon_name):
        return MaterialIcon(icon_name, size="16px")

    def _refresh_hardware_usage(self, *_):
        usages = self._retrieve_hardware_data()
        self._update_hardware_display(usages)
        return True

    @staticmethod
    def _get_device_temperature():
        try:
            temps = psutil.sensors_temperatures()
            if "coretemp" in temps:
                return temps["coretemp"][0].current
            elif "cpu_thermal" in temps:
                return temps["cpu_thermal"][0].current
            return None
        except Exception:
            return None

    def _retrieve_hardware_data(self):
        return {
            "CPU": round(psutil.cpu_percent()),
            "RAM": round(psutil.virtual_memory().percent),
            "Swap": round(psutil.swap_memory().percent),
            "Temp": self._get_device_temperature(),
        }

    def _update_hardware_display(self, usages):
        for hardware, usage in usages.items():
            if usage is None:
                usage = 0
                self.labels[hardware].set_label("N/A")
            else:
                usage = int(usage)

            self.progress_bars[hardware].value = usage / 100
            self.labels[hardware].set_label(f"{usage}")
            self.progress_bars[hardware].set_tooltip_text(f"{hardware} Usage: {usage}%")
