from __init__ import *


class EmojiManager:
    def __init__(self, launcher):
        self.emoji_service = EmojiService()
        self.launcher = launcher

    def query_emojis(self, query: str):
        return self.emoji_service.query(query)

    def copy_emoji(self, emoji: EmojiItem):
        self.emoji_service.copy(emoji)
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
