import json
import os
from loguru import logger
from fabric.utils import exec_shell_command_async
import subprocess


class EmojiItem:
    def __init__(self, str: str, name: str, slug: str, group: str):
        self.str = str
        self.name = name
        self.slug = slug
        self.group = group


class EmojiService:
    def __init__(self):
        self.emoji = None
        self.load_emojis()

    def load_emojis(self):
        try:
            # Construct the path using os.path.expanduser to handle the '~' correctly
            emoji_path = os.path.expanduser("~/fabric/assets/emoji.json")
            with open(emoji_path, "r") as f:
                data = json.load(f)
                self.emoji = [
                    EmojiItem(str, item["name"], item["slug"], item["group"])
                    for str, item in data.items()
                ]
        except Exception as e:
            logger.error(f"Failed to load emoji data: {e}")
            self.emoji = []

    def get_emojis(self):
        return self.emoji

    def query(self, filter: str):
        if self.emoji is None:
            return []
        return [
            e
            for e in self.emoji
            if filter in e.name or filter in e.slug or filter in e.group
        ][:44]

    def copy(self, emoji_item: EmojiItem):
        try:
            # Use subprocess to run the wl-copy command to copy emoji
            subprocess.run(["wl-copy"], input=emoji_item.str.encode(), check=True)
        except Exception as e:
            logger.error(f"Failed to copy emoji: {e}")


emoji_service = EmojiService()
