import psutil
from fabric.utils import invoke_repeater
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.label import Label
from fabric.widgets.overlay import Overlay
from fabric.widgets.circularprogressbar import CircularProgressBar
from icon import MaterialIcon  # Import your updated MaterialIcon function

class HardwareUsage(Button):
    HARDWARE_ITEMS = [
        ("CPU", "settings_motion_mode"),          # Pass the Material icon name directly
        ("Swap", "swap_horiz"),
        ("RAM", "memory"),
    ]

    def __init__(self):
        super().__init__(child=self._create_content())
        invoke_repeater(1000, self._update_labels)

    def _create_content(self):
        self.box = Box(orientation="h", name="tray")
        self.progress_bars = {}
        self.labels = {}
        self.icons = {}

        for hardware, icon_name in self.HARDWARE_ITEMS:
            self.progress_bars[hardware] = self._create_progress_bar()
            self.labels[hardware] = Label(style="font-size:14px; margin: 4px;")
            self.icons[hardware] = MaterialIcon(icon_name, size="16px")
            self._pack_items(hardware)

        return self.box

    def _create_progress_bar(self):
        return CircularProgressBar(name="progress", pie=True, size=30)

    def _pack_items(self, hardware):
        overlay = Overlay(child=self.progress_bars[hardware], overlays=self.icons[hardware])
        self.box.pack_start(overlay, False, False, 0)
        self.box.pack_start(self.labels[hardware], False, False, 0)

    def _update_labels(self):
        usages = self._get_hardware_usages()
        self._update_progress_bars(usages)

    def _get_hardware_usages(self):
        return {
            "CPU": round(psutil.cpu_percent()),
            "RAM": round(psutil.virtual_memory().percent),
            "Swap": round(psutil.swap_memory().percent),
        }

    def _update_progress_bars(self, usages):
        for hardware, usage in usages.items():
            self.progress_bars[hardware].value = usage / 100
            self.labels[hardware].set_label(f"{usage}%")
            self.progress_bars[hardware].set_tooltip_text(f"{hardware} Usage: {usage}%")

