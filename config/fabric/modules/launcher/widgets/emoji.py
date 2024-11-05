import json
import os
import subprocess

from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.label import Label


class EmojiItem:
    def __init__(self, str: str, name: str, slug: str, group: str):
        self.str = str
        self.name = name
        self.slug = slug
        self.group = group


class EmojiManager:
    def __init__(self, launcher):
        self.launcher = launcher
        self.emojis = None  # Delay loading until first use
        self.query_cache = {}

    def load_emojis(self):
        if self.emojis is None:
            emoji_path = os.path.expanduser("~/fabric/assets/emoji.json")
            try:
                with open(emoji_path, "r") as f:
                    data = json.load(f)
                    self.emojis = [
                        EmojiItem(str, item["name"], item["slug"], item["group"])
                        for str, item in data.items()
                    ]
            except Exception as e:
                print(f"Error loading emojis: {e}")
                self.emojis = []

    def query_emojis(self, query: str):
        # Return cached results if available
        if query in self.query_cache:
            return self.query_cache[query]

        self.load_emojis()  # Ensure emojis are loaded

        filtered_emojis = [
            e
            for e in self.emojis
            if query in e.name or query in e.slug or query in e.group
        ][:44]

        # Cache the results
        self.query_cache[query] = filtered_emojis
        return filtered_emojis

    def copy_emoji(self, emoji: EmojiItem):
        subprocess.run(["wl-copy"], input=emoji.str.encode(), check=True)
        self.launcher.set_visible(False)

    def show_emojis(self, viewport, query: str):
        filtered_emojis = self.query_emojis(query)
        row = Box(orientation="h", spacing=10)

        for emoji_item in filtered_emojis:
            button = self.bake_emoji_slot(emoji_item)
            row.add(button)

            if len(row.children) >= 11:
                viewport.add(row)
                row = Box(orientation="h", spacing=10)

        if row.children:
            viewport.add(row)

    def bake_emoji_slot(self, emoji: EmojiItem, **kwargs) -> Button:
        return Button(
            child=Label(label=emoji.str, h_pack="start"),
            tooltip_text=f"Copy {emoji.name}",
            on_clicked=lambda *_: self.copy_emoji(emoji),
            name="emoji-item",
            **kwargs,
        )
