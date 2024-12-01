import json
import os
import subprocess
from typing import Generator, List

from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.label import Label
from snippets import MaterialIcon


class EmojiItem:
    def __init__(self, emoji_str: str, name: str, slug: str, group: str):
        self.str = emoji_str
        self.name = name
        self.slug = slug
        self.group = group


class EmojiManager:
    def __init__(self, launcher):
        self.launcher = launcher
        self.emojis: List[EmojiItem] = []
        self.query_cache: dict = {}

    def load_emojis(self) -> Generator[EmojiItem, None, None]:
        emoji_path = os.path.expanduser("~/fabric/assets/emoji.json")
        if not os.path.exists(emoji_path):
            return

        try:
            with open(emoji_path, "r") as file:
                data = json.load(file)
                for emoji_str, item in data.items():
                    yield EmojiItem(
                        emoji_str, item["name"], item["slug"], item["group"]
                    )
        except (json.JSONDecodeError, OSError):
            return

    def get_emojis(self) -> List[EmojiItem]:
        if not self.emojis:
            self.emojis = list(self.load_emojis())
        return self.emojis

    def query_emojis(self, query: str) -> List[EmojiItem]:
        if query in self.query_cache:
            return self.query_cache[query]

        emojis = self.get_emojis()
        filtered_emojis = [
            emoji
            for emoji in emojis
            if query.lower() in emoji.name.lower()
            or query.lower() in emoji.slug.lower()
            or query.lower() in emoji.group.lower()
        ][:48]

        self.query_cache[query] = filtered_emojis
        return filtered_emojis

    def copy_emoji(self, emoji: EmojiItem):
        subprocess.run(["wl-copy"], input=emoji.str.encode(), check=True)
        self.launcher.set_visible(False)

    def show_emojis(self, viewport, query: str):
        filtered_emojis = self.query_emojis(query)
        self._display_emoji_grid(viewport, filtered_emojis)

    def _display_emoji_grid(self, viewport, emojis: List[EmojiItem]):
        row = Box(orientation="h", spacing=10)
        for emoji in emojis:
            button = self._create_emoji_button(emoji)
            row.add(button)

            if len(row.children) >= 12:
                viewport.add(row)
                row = Box(orientation="h", spacing=10)

        if row.children:
            viewport.add(row)

    def _create_emoji_button(self, emoji: EmojiItem) -> Button:
        return Button(
            child=Label(label=emoji.str, h_pack="start"),
            tooltip_text=f"Copy {emoji.name}",
            on_clicked=lambda *_: self.copy_emoji(emoji),
            name="emoji-item",
        )

    def get_emoji_buttons(self):
        return MaterialIcon("mood")
