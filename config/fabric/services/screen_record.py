import datetime
import subprocess

from fabric.core.service import Service
from fabric.utils import exec_shell_command
from gi.repository import Gio, GLib
from loguru import logger


def exec_shell_command_async(cmd: str) -> bool:
    if isinstance(cmd, str):
        try:
            GLib.spawn_command_line_async(cmd)
            return True
        except ValueError:
            return False
    else:
        return False


class ScreenRecorder(Service):
    # __gsignals__ = SignalContainer(

    # )
    def __init__(self, **kwargs):
        self.screenshot_path = GLib.get_home_dir() + "/Pictures/Screenshots/"
        self.screenrecord_path = GLib.get_home_dir() + "/Videos/Screencasting/"
        self.recording = False
        super().__init__(**kwargs)

    def screenshot(self, fullscreen=False, save_copy=True):
        time = datetime.datetime.today().strftime("%Y-%m-%d_%H-%M-%S")
        file_path = self.screenshot_path + str(time) + ".png"
        command = (
            ["grimblast", "copysave", "screen", file_path]
            if save_copy
            else ["grimblast", "copy" "screen"]
        )
        if not fullscreen:
            command[2] = "area"
        try:
            subprocess.run(command, check=True)
            self.send_screenshot_notification(
                file_path=file_path if file_path else None,
            )
        except Exception as e:
            logger.error(f"[SCREENSHOT] Failed to run command: {command}")

    def screencast_start(self, fullscreen=False):
        time = datetime.datetime.today().strftime("%Y-%m-%d_%H-%M-%S")
        file_path = self.screenrecord_path + str(time) + ".mp4"
        area = ""
        if fullscreen:
            area = exec_shell_command("slurp")
        command = f"wf-recorder -g {area} -f {file_path}"

        exec_shell_command_async(command)

    def screencast_stop(self):
        exec_shell_command_async("killall -INT wf-recorder")
        self.recording = False

    def send_screenshot_notification(self, file_path=None):
        cmd = ["notify-send"]
        cmd.extend(
            [
                "-A",
                "files=Show in Files",
                "-A",
                "view=View",
                "-A",
                "edit=Edit",
                "-i",
                "camera-photo-symbolic",
                "-a",
                "Fabric Screenshot Utility",
                "-h",
                f"STRING:image-path:{file_path}",
                "Screenshot Saved",
                f"Saved Screenshot at {file_path}",
            ]
            if file_path
            else ["Screenshot Sent to Clipboard"]
        )

        proc: Gio.Subprocess = Gio.Subprocess.new(cmd, Gio.SubprocessFlags.STDOUT_PIPE)

        def do_callback(process: Gio.Subprocess, task: Gio.Task):
            try:
                _, stdout, stderr = process.communicate_utf8_finish(task)
            except Exception:
                logger.error(
                    f"[SCREENSHOT] Failed read notification action with error {stderr}"
                )
                return

            match stdout.strip("\n"):
                case "files":
                    exec_shell_command_async(f"xdg-open {self.screenshot_path}")
                case "view":
                    exec_shell_command_async(f"xdg-open {file_path}")
                case "edit":
                    exec_shell_command_async(f"swappy -f {file_path}")

        proc.communicate_utf8_async(None, None, do_callback)
