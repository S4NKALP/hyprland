from services import WeatherInfo

from fabric.utils import invoke_repeater
from fabric.widgets.box import Box
from fabric.widgets.label import Label


class Weather(Box):
    def __init__(
        self,
        city: str,
        interval: int = 60000,
        enable_tooltip=True,
    ):
        super().__init__(name="tray")
        self.enable_tooltip = enable_tooltip
        self.city = city

        self.weather_service = WeatherInfo()

        self.weather_label = Label(label="weather")
        self.children = self.weather_label

        invoke_repeater(interval, self.update_label, initial_call=True)

    def update_label(self):
        res = self.weather_service.simple_weather_info(city=self.city)
        self.weather_label.set_label(f"{res["icon"]} {res["temperature"]}")

        if self.enable_tooltip:
            self.set_tooltip_text(f"{res["city"]}, {res["condition"]}".strip("'"))
        return True
