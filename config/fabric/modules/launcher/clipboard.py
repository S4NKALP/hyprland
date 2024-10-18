from __init__ import *


class ClipboardManager:
    def __init__(self, launcher):
        self.launcher = launcher
        self.clipboard_history = self.get_clip_history()

    def get_clip_history(self):
        try:
            result = subprocess.run(
                ["cliphist", "list"], capture_output=True, text=True, check=True
            )
            clips = [
                {"text": line.strip(), "id": line.split()[0]}
                for line in result.stdout.splitlines()
                if line.strip()
            ]
            return clips
        except subprocess.CalledProcessError as e:
            print(f"Error fetching clipboard history: {e}")
            return []

    def copy_to_clipboard(self, clip_id: str):
        command = f"cliphist decode {clip_id} | wl-copy"
        try:
            subprocess.run(command, shell=True, check=True)
            print(f"Copied Clip ID {clip_id} to clipboard.")
        except subprocess.CalledProcessError as e:
            print(f"Error copying clip: {e}")

    def show_clipboard_history(self, viewport, query: str):
        filtered_history = [
            item for item in self.clipboard_history if query in item["text"]
        ]

        for item in filtered_history:
            button = Button(
                child=Label(
                    label=item["text"][:55],
                    h_expand=True,
                    v_align="center",
                    h_align="start",
                ),
                on_clicked=lambda _, clip_id=item["id"]: (
                    self.copy_to_clipboard(clip_id),
                    self.launcher.set_visible(False),
                ),
                name="cliphist-item",
            )
            viewport.add(button)
