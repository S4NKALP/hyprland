from __init__ import *


class BatteryLabel(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.battery_icon = Label(
            label="󰁹",
            style="font-size: 16px; margin-right: 4px;",
        )
        self.battery_label = Label(
            label="N/A",
            style="font-size: 12px; margin-left: 4px;",
        )

        invoke_repeater(1000, self.update_battery_status, initial_call=True)

        self.children = self.battery_icon, self.battery_label

    def update_battery_status(self):
        battery_percent = round(
            sensor.percent if (sensor := psutil.sensors_battery()) else 0.0
        )
        self.battery_label.set_label(f"{(battery_percent or 'N/A')}%")

        is_charging = bool(
            psutil.sensors_battery().power_plugged
            if psutil.sensors_battery() is not None
            else False
        )
        if is_charging:
            icons = ["󰢟", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
        else:
            icons = ["󱃍", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

        index = min(max(battery_percent // 10, 0), 9)

        self.battery_icon.set_label(icons[index])

        return True
