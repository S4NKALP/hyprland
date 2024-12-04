import os
import subprocess
from typing import Generator, List

import ijson
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.label import Label
from snippets import MaterialIcon


class EmojiManager:
    def __init__(self, launcher):
        self.launcher = launcher
        self.emoji_file_path = os.path.expanduser("~/fabric/assets/emoji.json")

    def load_emojis(self) -> Generator[tuple, None, None]:
        if not os.path.exists(self.emoji_file_path):
            return
        try:
            with open(self.emoji_file_path, "r") as file:
                for emoji_str, item in ijson.kvitems(file, ""):
                    yield emoji_str, item["name"], item["slug"], item["group"]
        except (ijson.JSONError, KeyError, OSError):
            return

    def query_emojis(self, query: str) -> List[tuple]:
        query = query.lower()
        return [
            (emoji_str, name, slug, group)
            for emoji_str, name, slug, group in self.load_emojis()
            if query in name.lower() or query in slug.lower() or query in group.lower()
        ][:48]

    def copy_emoji(self, emoji: tuple):
        subprocess.run(["wl-copy"], input=emoji[0].encode(), check=True)
        self.launcher.set_visible(False)

    def show_emojis(self, viewport, query: str):
        filtered_emojis = self.query_emojis(query)
        self._display_emoji_grid(viewport, filtered_emojis)

    def _display_emoji_grid(self, viewport, emojis: List[tuple]):
        row = Box(orientation="h", spacing=10)
        for emoji in emojis:
            button = self._create_emoji_button(emoji)
            row.add(button)

            if len(row.children) >= 12:
                viewport.add(row)
                row = Box(orientation="h", spacing=10)

        if row.children:
            viewport.add(row)

    def _create_emoji_button(self, emoji: tuple) -> Button:
        return Button(
            child=Label(label=emoji[0], h_pack="start"),
            tooltip_text=f"Copy {emoji[1]}",
            on_clicked=lambda *_: self.copy_emoji(emoji),
            name="emoji-item",
        )

    def get_emoji_buttons(self):
        return MaterialIcon("mood")
