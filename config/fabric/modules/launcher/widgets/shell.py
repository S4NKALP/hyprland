import os
import subprocess

from fabric.widgets.button import Button
from fabric.widgets.label import Label

CACHE_DIR = os.getenv(
    "XDG_CACHE_HOME", os.path.join(os.path.expanduser("~"), ".cache", "fabric")
)
BINS_PATH = os.path.join(CACHE_DIR, "binaries")


class ShellCommandManager:
    def __init__(self, launcher):
        self.launcher = launcher
        self.reload_binaries()

    def reload_binaries(self):
        """Reload the binaries from the PATH environment variable."""
        paths = os.getenv("PATH", "").split(":")
        unique_bins = set()

        for path in paths:
            unique_bins.update(self.list_binaries_in_path(path))

        self.save_binaries_to_cache(unique_bins)

    def list_binaries_in_path(self, path):
        if not os.path.exists(path):
            return []
        try:
            return (
                subprocess.check_output(f"ls {path}", shell=True, text=True)
                .strip()
                .splitlines()
            )
        except subprocess.CalledProcessError:
            return []

    def save_binaries_to_cache(self, binaries):
        with open(BINS_PATH, "w") as f:
            f.write("\n".join(binaries))

    def show_shell_commands(self, viewport, search_query: str):
        if not search_query:
            return

        results = self.query_binaries(search_query)
        self.display_results(viewport, results)

    def query_binaries(self, filter_str):
        try:
            with open(BINS_PATH) as f:
                return [line.strip() for line in f if filter_str in line][:16]
        except FileNotFoundError:
            return []

    def display_results(self, viewport, results):
        for command in results:
            button = Button(
                child=Label(
                    label=command,
                    v_align="center",
                    h_align="start",
                ),
                on_clicked=lambda _, cmd=command: self.execute_command(cmd),
                name="sh-item",
            )
            viewport.add(button)

    def execute_command(self, cmd: str):
        try:
            output = subprocess.check_output(cmd, shell=True, text=True)
            print(output)
        except subprocess.CalledProcessError as e:
            print(e.output)
        finally:
            self.launcher.set_visible(False)
