import json
from typing import Literal


def read_config():
    with open("config.json", "r") as file:
        # Load JSON data into a Python dictionary
        data = json.load(file)
    return data


def format_time(secs):
    mm, _ = divmod(secs, 60)
    hh, mm = divmod(mm, 60)
    return "%d h %02d min" % (hh, mm)


def convert_bytes(bytes: int, to: Literal["kb", "mb", "gb"]):
    multiplier = 1

    if to == "mb":
        multiplier = 2
    elif to == "gb":
        multiplier = 3

    return bytes / (1024**multiplier)
