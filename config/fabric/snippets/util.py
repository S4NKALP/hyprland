import json
import os
import time

import psutil
from gi.repository import GLib
from loguru import logger


def read_config():
    home_dir = GLib.get_home_dir()
    config_path = f"{home_dir}/fabric/assets/config.json"

    with open(config_path, "r") as file:
        # Load JSON data into a Python dictionary
        data = json.load(file)
    return data


def get_profile_picture_path() -> str | None:
    path = os.path.expanduser("~/Pictures/Other/face.jpg")
    if not os.path.exists(path):
        path = os.path.expanduser("~/.face")
    if not os.path.exists(path):
        logger.warning(
            "can't fetch a user profile picture, add a profile picture image at ~/.face or at ~/Pictures/Other/profile.jpg"
        )
        path = None
    return path


def get_current_uptime():
    uptime = time.time() - psutil.boot_time()
    uptime_hours, remainder = divmod(uptime, 3600)
    uptime_minutes, _ = divmod(remainder, 60)
    return (
        f"Up: {int(uptime_hours)} {'hours' if uptime_hours != 1 else 'hour'}, "
        f"{int(uptime_minutes)} {'minutes' if uptime_minutes != 1 else 'minute'}"
    )


def username():
    return os.getlogin().title()
