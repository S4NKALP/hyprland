import os
import subprocess

from fabric import Fabricator
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from fabric.widgets.label import Label
from snippets import MaterialIcon


class ClipboardManager:
    def __init__(self, launcher, viewport):
        self.launcher = launcher
        self.viewport = viewport
        self.clipboard_history = []
        self._initialize_clipboard_watcher()

    def _initialize_clipboard_watcher(self):
        self.wl_paste_watcher = Fabricator(
            poll_from="wl-paste --watch echo", stream=True, interval=-1
        )
        self.wl_paste_watcher.connect(
            "changed", lambda *_: self.update_clipboard_history()
        )

    def get_clip_history(self):
        try:
            result = subprocess.run(
                ["cliphist", "list"], capture_output=True, text=True, check=True
            )
            return self._parse_clip_history(result.stdout)
        except subprocess.CalledProcessError:
            return []

    def _parse_clip_history(self, output):
        return [
            {"content": line.strip(), "id": line.split()[0]}
            for line in output.splitlines()
            if line.strip()
        ][:10]

    def update_clipboard_history(self):
        new_history = self.get_clip_history()
        if new_history != self.clipboard_history:
            self.clipboard_history = new_history
            self.refresh_ui()

    def refresh_ui(self):
        self._clear_viewport()
        self.show_clipboard_history(self.viewport)

    def _clear_viewport(self):
        for child in self.viewport.children:
            self.viewport.remove(child)

    def run_command(self, command, input_data=None):
        try:
            input_data = self._ensure_bytes(input_data)
            return subprocess.run(
                command, input=input_data, capture_output=True, check=True
            )
        except subprocess.CalledProcessError:
            return None

    def _ensure_bytes(self, input_data):
        if input_data and not isinstance(input_data, bytes):
            return input_data.encode()  # Ensure input data is in bytes
        return input_data

    def copy_by_id(self, clip_id: str):
        command = f"cliphist decode {clip_id} | wl-copy"
        try:
            subprocess.run(command, shell=True, check=True)
        except subprocess.CalledProcessError:
            pass

    def save_cache_file(self, clip_id: str):
        output_file = f"/tmp/cliphist/{clip_id}.png"
        os.makedirs("/tmp/cliphist/", exist_ok=True)

        result = self.run_command(["cliphist", "decode", clip_id])
        if result:
            self._write_to_cache(output_file, result.stdout)
            return output_file
        return None

    def _write_to_cache(self, output_file, data):
        with open(output_file, "wb") as f:
            f.write(data)

    def show_clipboard_history(self, viewport, query=""):
        filtered_history = self._filter_clip_history(query)
        for item in filtered_history:
            self.add_clipboard_item(viewport, item)

    def _filter_clip_history(self, query):
        return [item for item in self.clipboard_history if query in item["content"]]

    def add_clipboard_item(self, viewport, item):
        if "png" in item["content"]:
            self._add_image_button(viewport, item)
        else:
            self._add_text_button(viewport, item)

    def _add_image_button(self, viewport, item):
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

    def _add_text_button(self, viewport, item):
        label_button = Button(
            child=Label(
                label=item["content"][:55],  # Truncate text for display
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

    def icon_button(self):
        return Button(
            child=MaterialIcon("content_paste"),
        )
