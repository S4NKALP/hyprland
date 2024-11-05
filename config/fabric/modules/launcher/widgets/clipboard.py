import os
import subprocess

from gi.repository import GLib

from fabric.widgets.button import Button
from fabric.widgets.image import Image
from fabric.widgets.label import Label


class ClipboardManager:
    def __init__(self, launcher, viewport):
        self.launcher = launcher
        self.viewport = viewport
        self.clipboard_history = []
        self.update_clipboard_history()
        self.refresh_ui()
        GLib.timeout_add(10000, self.update_clipboard_history)

    def get_clip_history(self):
        try:
            result = subprocess.run(
                ["cliphist", "list"], capture_output=True, text=True, check=True
            )
            return [
                {"text": line.strip(), "id": line.split()[0]}
                for line in result.stdout.splitlines()
                if line.strip()
            ][:10]
        except subprocess.CalledProcessError:
            return []

    def update_clipboard_history(self):
        new_history = self.get_clip_history()
        if new_history != self.clipboard_history:
            self.clipboard_history = new_history
            self.refresh_ui()
        return True

    def refresh_ui(self):
        for child in self.viewport.children:
            self.viewport.remove(child)
        self.show_clipboard_history(self.viewport, "")

    def run_command(self, command, input_data=None):
        try:
            if input_data is not None:
                input_data = input_data.encode()
            return subprocess.run(
                command, input=input_data, capture_output=True, check=True
            )
        except subprocess.CalledProcessError:
            return None

    def copy_by_id(self, clip_id: str):
        result = self.run_command(["cliphist", "decode", clip_id])
        if result:
            self.run_command(["wl-copy"], input=result.stdout)

    def clear_clipboard(self):
        self.run_command(["cliphist", "wipe"])

    def save_cache_file(self, clip_id: str):
        output_file = f"/tmp/cliphist/{clip_id}.png"
        os.makedirs("/tmp/cliphist/", exist_ok=True)

        result = self.run_command(["cliphist", "decode", clip_id])
        if result:
            with open(output_file, "wb") as f:
                f.write(result.stdout)
            return output_file
        return None

    def clear_tmp(self):
        self.run_command(["rm", "-rf", "/tmp/cliphist/*"])

    def show_clipboard_history(self, viewport, query: str):
        filtered_history = [
            item for item in self.clipboard_history if query in item["text"]
        ]
        for item in filtered_history:
            self.add_clipboard_item(viewport, item)

    def add_clipboard_item(self, viewport, item):
        if "png" in item["text"]:
            self.add_image_button(viewport, item)
        else:
            self.add_label_button(viewport, item)

    def add_image_button(self, viewport, item):
        output_file = self.save_cache_file(item["id"])
        if output_file and os.path.exists(output_file):
            image_button = Button(
                h_align="start",
                child=Image(file=output_file),
                on_clicked=lambda _, clip_id=item["id"]: self.handle_clip_click(
                    clip_id
                ),
                name="cliphist-img-item",
            )
            image_button.set_style(f"background-image: url('{output_file}');")
            viewport.add(image_button)
            # GLib.timeout_add(3000, lambda: self.cleanup_file(output_file))

    def add_label_button(self, viewport, item):
        label_button = Button(
            child=Label(
                label=item["text"][:55],
                h_expand=True,
                v_align="center",
                h_align="start",
            ),
            on_clicked=lambda _, clip_id=item["id"]: self.handle_clip_click(clip_id),
            name="cliphist-item",
        )
        viewport.add(label_button)

    def handle_clip_click(self, clip_id):
        self.copy_by_id(clip_id)
        self.launcher.set_visible(False)

    def cleanup_file(self, file_path):
        try:
            os.remove(file_path)
        except FileNotFoundError:
            pass
