import os

import setproctitle
from loguru import logger

from fabric import Application
from fabric.utils import get_relative_path, monitor_file
from modules.bar.bar import Bar
from modules.launcher.launcher import Launcher
from modules.notification_popup import NotificationPopup
from modules.osd import OSDContainer
from services import ScreenRecorder

logger.disable("fabric.hyprland.widgets")


def apply_style(app: Application):
    logger.info("[Main] CSS applied")
    app.set_stylesheet_from_file(get_relative_path("styles/main.css"))


if __name__ == "__main__":
    sc = ScreenRecorder()
    bar = Bar()
    osd = OSDContainer()
    notif = NotificationPopup()
    launcher = Launcher()
    launcher.hide()

    app = Application(
        "quickbar",
        bar,
        launcher,
        osd,
    )
    setproctitle.setproctitle("quickbar")

    css_file = monitor_file(get_relative_path("styles"))
    _ = css_file.connect("changed", lambda *_: apply_style(app))

    color_css_file = monitor_file(f"/home/{os.getlogin()}/.cache/material/colors.css")
    _ = color_css_file.connect("changed", lambda *_: apply_style(app))

    apply_style(app)

    app.run()
