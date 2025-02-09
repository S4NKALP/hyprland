from .animator import *
from .custom_image import *
from .icon import *
import json
from gi.repository import GLib


def read_config():
    home_dir = GLib.get_home_dir()
    config_path = f"{home_dir}/dotfiles/modus/assets/config.json"

    with open(config_path, "r") as file:
        # Load JSON data into a Python dictionary
        data = json.load(file)
    return data
