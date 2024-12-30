import psutil
from fabric import Fabricator
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from snippets import MaterialIcon


class BatteryLabel(Box):
    ICONS_CHARGING = [
        "battery_charging_20",
        "battery_charging_20",
        "battery_charging_20",
        "battery_charging_30",
        "battery_charging_30",
        "battery_charging_50",
        "battery_charging_60",
        "battery_charging_80",
        "battery_charging_80",
        "battery_charging_90",
        "battery_charging_full",
    ]
    ICONS_NOT_CHARGING = [
        "battery_alert",
        "battery_1_bar",
        "battery_1_bar",
        "battery_2_bar",
        "battery_2_bar",
        "battery_3_bar",
        "battery_4_bar",
        "battery_4_bar",
        "battery_5_bar",
        "battery_6_bar",
        "battery_full",
    ]

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        Fabricator(interval=1000, poll_from=self.update_battery_status)

    def update_battery_status(self, *_):
        battery = psutil.sensors_battery()
        if battery is None:
            self.hide()
            return

        battery_percent = round(battery.percent) if battery else 0.0
        battery_label = Label(label=f"{battery_percent}%")

        is_charging = battery.power_plugged if battery else False
        icons = self.ICONS_CHARGING if is_charging else self.ICONS_NOT_CHARGING

        index = min(max(battery_percent // 10, 0), 10)
        battery_icon = MaterialIcon(icons[index], size=16)

        self.children = (battery_icon, battery_label)

        self.show() if battery_percent < 100 else self.hide()

        return True
