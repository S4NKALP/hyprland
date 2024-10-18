import datetime
import subprocess

from fabric.core.service import Service
from fabric.utils import exec_shell_command
from gi.repository import GLib, Gio
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
        command = ["wayshot", "-f", file_path] if save_copy else ["wayshot", "--stdout"]

        if not fullscreen:
            region = exec_shell_command("slurp").split("\n")
            if region[0] == "selection cancelled":
                return
            command = command + ["-s", region[0]]

        wayshot = subprocess.run(command, check=True, capture_output=True)
        if save_copy:
            exec_shell_command_async(f"bash -c 'wl-copy < {file_path}' ")
            self.send_screenshot_notification_file("file", file_path)
            return
        subprocess.run(["wl-copy"], input=wayshot.stdout, check=False)
        self.send_screenshot_notification_file("stdout")

    def screencast_start(self, fullscreen=False):
        time = datetime.datetime.today().strftime("%Y-%m-%d_%H-%M-%S")
        file_path = self.screenrecord_path + str(time) + ".mp4"
        area = ""
        if fullscreen:
            area = exec_shell_command("slurp")
        command = f"wf-recorder -g {area} -f {file_path} --pixel-format yuv420p"

        exec_shell_command_async(command)

    def screencast_stop(self):
        exec_shell_command_async("killall -INT wf-recorder")
        self.recording = False

    def send_screenshot_notification_file(self, notify_type, file_path=None):
        cmd = ["notify-send"]
        cmd.extend(
            [
                "-A",
                "files=Show in Files",
                "-A",
                "view=View",
                "-A",
                "edit=Edit",
                "-h",
                f"STRING:image-path:{file_path}",
                f"Screenshot {file_path}",
            ]
        ) if notify_type == "file" else ["Screenshot Sent to Clipboard"]

        proc = Gio.Subprocess.new(cmd, Gio.SubprocessFlags.STDOUT_PIPE)

        def do_callback(process: Gio.Subprocess, task: Gio.Task):
            try:
                _, stdout, stderr = process.communicate_utf8_finish(task)
            except Exception:
                logger.error("Failed read notification action")
                return

            out = stdout.strip("\n")

            match out:
                case "files":
                    exec_shell_command_async(f"xdg-open {self.screenshot_path}")
                case "view":
                    exec_shell_command_async(f"xdg-open {file_path}")
                case "edit":
                    exec_shell_command_async(f"swappy -f {file_path}")

        proc.communicate_utf8_async(None, None, do_callback)
