import urllib.request


class WeatherInfo:
    def simple_weather_info(self, city: str):
        try:
            url = f"http://wttr.in/{city.capitalize()}?format='%l,%c,%t,%C'"
            contents = urllib.request.urlopen(url).read().decode("utf-8")

            data = str(contents).split(",")
            return {
                "city": data[0].strip(),
                "icon": data[1].strip(),
                "temperature": data[2].strip(),
                "condition": data[3].strip(),
            }
        except Exception as e:
            return {"error": str(e)}
