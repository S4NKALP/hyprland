import os
import subprocess
from typing import List

from fabric import Fabricator
from fabric.utils import remove_handler
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.entry import Entry
from fabric.widgets.image import Image
from fabric.widgets.label import Label
from fabric.widgets.scrolledwindow import ScrolledWindow
from gi.repository import GLib
from snippets import MaterialIcon


class Cliphist(Box):
    def __init__(self, **kwargs):
        super().__init__(
            name="cliphist-launcher",
            all_visible=False,
            visible=False,
            **kwargs,
        )

        self._arranger_handler = 0
        self.cliphist_manager = CliphistManager(self)
        self.viewport = None

        self.search_entry = Entry(
            name="search-entry",
            placeholder="Search cliphist...",
            h_expand=True,
            notify_text=lambda entry, *_: self.handle_search_input(entry.get_text()),
            on_activate=lambda entry, *_: self.handle_search_input(entry.get_text()),
        )

        self.header_box = Box(
            name="header-box",
            spacing=10,
            orientation="h",
            children=[
                self.search_entry,
                Button(
                    name="close-button",
                    child=MaterialIcon("close"),
                    tooltip_text="Exit",
                    on_clicked=lambda *_: self.close_launcher(),
                ),
            ],
        )

        self.launcher_box = Box(
            name="cliphist-launcher-box",
            spacing=10,
            orientation="v",
            h_expand=True,
            children=[self.header_box],
        )

        self.add(self.launcher_box)

    def open_launcher(self):
        if not self.viewport:
            self.viewport = Box(name="viewport", spacing=4, orientation="v")
            self.scrolled_window = ScrolledWindow(
                name="scrolled-window",
                spacing=10,
                h_scrollbar_policy="never",
                v_scrollbar_policy="never",
                child=self.viewport,
            )
            self.launcher_box.add(self.scrolled_window)

        self.viewport.children = []
        self.cliphist_manager.arrange_viewport()

        self.viewport.show()
        self.search_entry.grab_focus()

    def close_launcher(self):
        GLib.spawn_command_line_async("fabric-cli exec quickbar 'launcher.close()'")

    def handle_search_input(self, text: str):
        self.cliphist_manager.arrange_viewport(text)


class CliphistManager:
    def __init__(self, launcher):
        self.launcher = launcher
        self.cliphist_history = []

        self.wl_paste_watcher = Fabricator(
            poll_from="wl-paste --watch echo", stream=True, interval=-1
        )
        self.wl_paste_watcher.connect(
            "changed", lambda *_: self.update_cliphist_history()
        )

    def get_clip_history(self) -> List[dict]:
        try:
            result = subprocess.run(
                ["cliphist", "list"], capture_output=True, text=True, check=True
            )
            return self._parse_clip_history(result.stdout)
        except subprocess.CalledProcessError as e:
            print(f"Error fetching cliphist history: {e}")
            return []

    def _parse_clip_history(self, output: str) -> List[dict]:
        items = []
        for line in output.splitlines():
            if line.strip():
                parts = line.strip().split(maxsplit=1)
                if len(parts) == 2:
                    items.append({"id": parts[0], "content": parts[1]})
        return items[:16]

    def copy_clip(self, clip_id: str):
        try:
            decode_result = subprocess.run(
                ["cliphist", "decode", clip_id], capture_output=True, check=True
            )
            subprocess.run(["wl-copy"], input=decode_result.stdout, check=True)
            self.launcher.close_launcher()
        except subprocess.CalledProcessError as e:
            print(f"Error copying clip {clip_id}: {e}")

    def save_cache_file(self, clip_id: str) -> str:
        output_file = f"/tmp/cliphist/{clip_id}.png"
        os.makedirs("/tmp/cliphist/", exist_ok=True)

        try:
            decode_result = subprocess.run(
                ["cliphist", "decode", clip_id], capture_output=True, check=True
            )

            with open(output_file, "wb") as f:
                f.write(decode_result.stdout)

            return output_file
        except (subprocess.CalledProcessError, IOError) as e:
            print(f"Error saving cache file for clip {clip_id}: {e}")
            return None

    def query_clips(self, query: str = "") -> List[dict]:
        if not query.strip():
            return self.get_clip_history()

        filtered_clips = [
            item
            for item in self.get_clip_history()
            if query.lower() in item["content"].lower()
        ]
        return filtered_clips

    def bake_clip_slot(self, item: dict) -> Button:
        if "png" in item["content"].lower():
            return self._create_image_button(item)
        return self._create_text_button(item)

    def _create_image_button(self, item: dict) -> Button:
        output_file = self.save_cache_file(item["id"])
        if output_file and os.path.exists(output_file):
            button = Button(
                h_align="start",
                child=Image(file=output_file),
                on_clicked=lambda _, clip_id=item["id"]: self.copy_clip(clip_id),
                name="clip-img-item",
            )
            button.set_style(f"background-image: url('{output_file}');")
            return button
        return None

    def _create_text_button(self, item: dict) -> Button:
        return Button(
            child=Label(
                label=item["content"][:55]
                + ("..." if len(item["content"]) > 55 else ""),
                h_expand=True,
                v_align="center",
                h_align="start",
            ),
            on_clicked=lambda _, clip_id=item["id"]: self.copy_clip(clip_id),
            name="clip-item",
        )

    def update_cliphist_history(self):
        self.cliphist_history = self.get_clip_history()
        if self.launcher.viewport:
            self.arrange_viewport()

    def arrange_viewport(self, query: str = ""):
        if not self.launcher.viewport:
            return

        if self.launcher._arranger_handler:
            remove_handler(self.launcher._arranger_handler)

        self.launcher.viewport.children = []
        filtered_clips = self.query_clips(query)

        for clip in filtered_clips:
            button = self.bake_clip_slot(clip)
            if button:
                self.launcher.viewport.add(button)
