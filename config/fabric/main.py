import os

from loguru import logger

from fabric import Application
from fabric.utils import get_relative_path, monitor_file
from modules.bar.bar import Bar
from modules.launcher.launcher import Launcher
from modules.notifications import NotificationPopup
from modules.osd import SystemOSD
from services.brightness import Brightness
from services.screen_record import ScreenRecorder


def apply_style(app: Application):
    logger.info("[Main] CSS applied")
    app.set_stylesheet_from_file(get_relative_path("style/main.css"))
    # app.set_stylesheet_from_file(f"/home/{os.getlogin()}/.cache/material/colors.css")


if __name__ == "__main__":
    sc = ScreenRecorder()
    brightness = Brightness()

    logger.disable("fabric.hyprland.widgets")
    bar = Bar()
    launcher = Launcher()
    launcher.hide()
    systemOverlay = SystemOSD()
    notif = NotificationPopup()
    app = Application(
        "fabric-bar",
        bar,
        launcher,
        notif,
        systemOverlay,
    )
    # Monitor main.css file for changes
    main_css_file = monitor_file(get_relative_path("style/main.css"))
    main_css_file.connect("changed", lambda *args: apply_style(app))

    # Monitor colors.css file for changes
    color_css_file = monitor_file(f"/home/{os.getlogin()}/.cache/material/colors.css")
    color_css_file.connect("changed", lambda *args: apply_style(app))

    apply_style(app)

    def quit_fabric():
        app.quit()

    app.run()
