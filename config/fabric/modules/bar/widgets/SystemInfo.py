from __init__ import *


class RAMUsage(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.ram_icon = Label(
            label="󰍛",
            style="font-size: 16px; margin-right: 4px;",
        )
        self.ram_label = Label(
            label="N/A%",
            style="font-size: 12px; margin-left: 4px;",
        )

        invoke_repeater(1000, self.update_ram_status, initial_call=True)

        self.children = self.ram_icon, self.ram_label

    def update_ram_status(self):
        ram_percent = int(psutil.virtual_memory().percent)
        self.ram_label.set_label(f"{ram_percent}%")

        return True


class CPUUsage(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.cpu_icon = Label(
            label="󰻠",
            style="font-size: 16px; margin-right: 4px;",
        )
        self.cpu_label = Label(
            label="N/A%",
            style="font-size: 12px; margin-left: 4px;",
        )

        invoke_repeater(1000, self.update_cpu_status, initial_call=True)

        self.children = self.cpu_icon, self.cpu_label

    def update_cpu_status(self):
        cpu_percent = int(psutil.cpu_percent())
        self.cpu_label.set_label(f"{cpu_percent}%")

        return True


class SwapMemoryUsage(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.swap_icon = Label(
            label="󰓡",
            style="font-size: 16px; margin-right: 4px;",
        )
        self.swap_label = Label(
            label="N/A%", style="font-size: 12px; margin-left: 4px;"
        )

        invoke_repeater(1000, self.update_swap_memory_status, initial_call=True)

        self.children = self.swap_icon, self.swap_label

    def update_swap_memory_status(self):
        swap_info = psutil.swap_memory()
        swap_percent = int(swap_info.percent)
        self.swap_label.set_label(f"{swap_percent}%")

        return True
