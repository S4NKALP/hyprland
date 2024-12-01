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
        self.binaries = set()  # Use a set to store unique binaries
        self.reload_binaries()

    def reload_binaries(self):
        paths = os.getenv("PATH", "").split(":")
        self.binaries = set()

        for path in paths:
            self.binaries.update(self.list_binaries_in_path(path))

        # Write unique binaries to the cache file
        with open(BINS, "w") as f:
            f.write("\n".join(self.binaries))

    def list_binaries_in_path(self, path):
        if not os.path.exists(path):
            return []
        try:
            return [
                entry
                for entry in os.listdir(path)
                if os.access(os.path.join(path, entry), os.X_OK)
            ]
        except OSError:
            return []

    def show_shell_commands(self, viewport, search_query: str):
        if not search_query:
            return

        results = self.query_binaries(search_query)
        self.display_results(viewport, results)

    def query_binaries(self, filter_str: str):
        # Use a generator to filter binaries on demand
        filtered_bins = (cmd for cmd in self.binaries if filter_str in cmd)
        return list(dict.fromkeys(filtered_bins))[:16]  # Deduplicate and limit to 16

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

    def get_shell_buttons(self):
        return MaterialIcon("terminal")
