import os
import subprocess

from fabric.widgets.button import Button
from fabric.widgets.label import Label
from snippets import MaterialIcon

CACHE_DIR = os.getenv(
    "XDG_CACHE_HOME", os.path.join(os.path.expanduser("~"), ".cache", "fabric")
)
BINS = os.path.join(CACHE_DIR, "binaries")


class ShellCommandManager:
    def __init__(self, launcher):
        self.launcher = launcher
        self.reload_binaries()

    def reload_binaries(self):
        paths = os.getenv("PATH", "").split(":")
        bins = []

        for path in paths:
            bins.extend(self.list_binaries_in_path(path))

        unique_bins = set(bins)
        with open(BINS, "w") as f:
            f.write("\n".join(unique_bins))

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

    def show_shell_commands(self, viewport, search_query: str):
        if not search_query:
            return

        results = self.query_binaries(search_query)
        self.display_results(viewport, results)

    def query_binaries(self, filter_str):
        try:
            result = subprocess.check_output(
                f"cat {BINS} | fzf -f {filter_str} | head -n 16", shell=True, text=True
            )
            return list(dict.fromkeys(result.splitlines()))  # Deduplicate results
        except subprocess.CalledProcessError:
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

    def icon_button(self):
        return Button(
            child=MaterialIcon("terminal"),
        )
