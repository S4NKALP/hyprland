import os

import setproctitle
from loguru import logger

from fabric import Application
from fabric.utils import get_relative_path, monitor_file
from modules import Bar, Launcher, NotificationPopup, OSDContainer
from services import Brightness, ScreenRecorder


def apply_style(app: Application):
    logger.info("[Main] CSS applied")
    app.set_stylesheet_from_file(get_relative_path("styles/main.css"))


if __name__ == "__main__":
    sc = ScreenRecorder()
    brightness = Brightness()

    logger.disable("fabric.hyprland.widgets")
    bar = Bar()
    launcher = Launcher()
    launcher.hide()
    osd = OSDContainer()
    notif = NotificationPopup()
    app = Application("fabric-bar", bar, launcher, osd)
    setproctitle.setproctitle("quickbar")

    css_file = monitor_file(get_relative_path("styles"))
    _ = css_file.connect("changed", lambda *_: apply_style(app))

    color_css_file = monitor_file(f"/home/{os.getlogin()}/.cache/material/colors.css")
    _ = color_css_file.connect("changed", lambda *_: apply_style(app))

    apply_style(app)

    def quit_fabric():
        app.quit()

    app.run()
