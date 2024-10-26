import psutil
from fabric.utils import invoke_repeater
from fabric.widgets.box import Box
from fabric.widgets.label import Label


class BatteryLabel(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.battery_icon = Label(
            label="󰁹",
            name="symbol",
            # style="font-size: 16px; margin-right: 4px;",
        )
        self.battery_label = Label(
            label="N/A",
            style="font-size: 16px; margin-left: 4px;",
        )

        invoke_repeater(1000, self.update_battery_status, initial_call=True)

        self.children = self.battery_icon, self.battery_label

    def update_battery_status(self):
        battery = psutil.sensors_battery()
        if battery is None:
            self.hide()
            return

        battery_percent = round(battery.percent) if battery else 0.0
        self.battery_label.set_label(f"{(battery_percent or 'N/A')}%")

        is_charging = battery.power_plugged if battery else False

        icons = (
            ["󰢟", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
            if is_charging
            else ["󱃍", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
        )
        index = min(max(battery_percent // 10, 0), 9)

        self.battery_icon.set_label(icons[index])

        if battery_percent == 100:
            self.hide()
        else:
            self.show()

        return True
