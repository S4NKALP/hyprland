import os

from loguru import logger

from fabric import Application
from fabric.utils import get_relative_path, monitor_file
from modules import Bar, Launcher, NotificationPopup, OSDContainer
from services import Brightness, ScreenRecorder


def apply_style(app: Application):
    logger.info("[Main] CSS applied")
    app.set_stylesheet_from_file(get_relative_path("style/main.css"))


if __name__ == "__main__":
    sc = ScreenRecorder()
    brightness = Brightness()

    logger.disable("fabric.hyprland.widgets")
    bar = Bar()
    launcher = Launcher()
    launcher.hide()
    systemOverlay = OSDContainer()
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
