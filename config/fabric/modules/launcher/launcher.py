from __init__ import *


class Launcher(Window):
    FAVORITE_APPS = [
        "Firefox",
        "Discord",
        "materialgram",
        "kitty",
        "Neovim",
        "Thunar File Manager",
    ]

    CONTENT_SIZES = {
        "emoji": (180, 180),
        "help": (220, 220),
        "default": (437, 437),
    }

    def __init__(self, **kwargs):
        super().__init__(
            layer="top",
            anchor="center",
            exclusivity="none",
            keyboard_mode="on-demand",
            visible=False,
            all_visible=False,
            **kwargs,
        )
        self.initialize_managers()
        self.setup_ui()
        self.connect("key-press-event", self.on_key_press)

    def initialize_managers(self):
        self.clipboard_manager = ClipboardManager(self)
        self.emoji_manager = EmojiManager(self)
        self.shell_command_manager = ShellCommandManager(self)
        self.wallpaper_manager = WallpaperManager()
        self.all_apps = get_desktop_applications()

    def setup_ui(self):
        self.fav_apps_box = self.create_favorites_box()
        self.viewport = Box(spacing=10, orientation="v")
        self.scrolled_window = ScrolledWindow(
            name="appmenu-scroll", child=self.viewport
        )
        self.scrolled_revealer = Revealer(
            child=self.scrolled_window, transition_duration=500
        )
        self.search_entry = self.create_search_entry()

        self.add(
            Box(
                orientation="v",
                size=(550, 0),
                name="launcher",
                children=[
                    Box(spacing=10, orientation="h", children=[self.search_entry]),
                    self.fav_apps_box,
                    self.scrolled_revealer,
                ],
            )
        )

        self.show_favorites()
        self.show_all()

    def create_search_entry(self):
        entry = Entry(
            placeholder="Search.....",
            h_expand=True,
            notify_text=lambda entry, *_: self.debounce_search(entry.get_text()),
        )
        entry.set_icon_from_icon_name(0, "preferences-system-search-symbolic")
        return entry

    def create_favorites_box(self):
        return Box(spacing=10, orientation="h")

    def on_key_press(self, widget, event):
        from gi.repository import Gdk

        if self.is_visible() and event.keyval == Gdk.KEY_Escape:
            self.set_visible(False)
            return True
        return False

    def debounce_search(self, query: str):
        if hasattr(self, "_arranger_handler"):
            remove_handler(self._arranger_handler)
        self._arranger_handler = idle_add(self.arrange_viewport, query, pin=True)

    def show_favorites(self):
        for app_name in self.FAVORITE_APPS:
            app = next((a for a in self.all_apps if a.name == app_name), None)
            if app:
                self.fav_apps_box.add(bake_favorite_slot(self, app))

    def arrange_viewport(self, query: str = ""):
        self.viewport.children = []
        self.scrolled_window.min_content_size = (-1, -1)
        self.scrolled_window.max_content_size = (-1, -1)

        command_handlers = {
            ":em": self.show_emojis,
            ":ch": self.show_clipboard_history,
            ":sh": self.show_shell_commands,
            ":wl": self.show_wallpapers,
        }

        for command, handler in command_handlers.items():
            if query.startswith(command):
                handler(query[len(command) :].strip())
                return

        if query.startswith(":"):
            self.fav_apps_box.set_visible(False)
            self.show_help()
            self.adjust_scrolled_window_size("help")
            self.scrolled_revealer.reveal()
            return

        handle_application_search(self, query)

    def show_emojis(self, query: str):
        self.emoji_manager.show_emojis(self.viewport, query)
        self.adjust_scrolled_window_size("emoji")
        self.scrolled_revealer.reveal()

    def show_clipboard_history(self, query: str):
        self.clipboard_manager.show_clipboard_history(self.viewport, query)
        self.adjust_scrolled_window_size("default")
        self.scrolled_revealer.reveal()

    def show_shell_commands(self, query: str):
        if not query:
            self.scrolled_revealer.unreveal()
            return
        self.shell_command_manager.show_shell_commands(self.viewport, query)
        self.adjust_scrolled_window_size("default")
        self.scrolled_revealer.reveal()

    def show_wallpapers(self, query: str):
        if query == "random":
            self.wallpaper_manager.apply_wallpaper_random()
        else:
            self.wallpaper_manager.show_wallpaper_thumbnails(self.viewport, query)
        self.adjust_scrolled_window_size("emoji")
        self.scrolled_revealer.reveal()

    def show_help(self):
        help_commands = [
            (":ch", "Copy a clipboard history entry", self.reveal_clipboard_history),
            (":em", "Copy an emoji", self.reveal_emojis),
            (":sh", "Run a binary", self.reveal_shell_commands),
            (":wl", "Change or show wallpapers", self.reveal_wallpapers),
        ]

        for command, description, action in help_commands:
            button = Button(
                child=Box(
                    orientation="h",
                    spacing=10,
                    children=[
                        Label(
                            label=command,
                            h_expand=True,
                            name="command-label",
                            h_align="start",
                        ),
                        Label(
                            label=description,
                            h_expand=True,
                            name="description-label",
                            h_align="end",
                        ),
                    ],
                ),
                on_clicked=lambda _, cmd=command, act=action: (
                    self.search_entry.set_text(cmd),
                    act(),
                ),
                name="help-item",
            )
            self.viewport.add(button)

    def reveal_clipboard_history(self):
        self.clipboard_manager.show_clipboard_history(self.viewport, "")

    def reveal_emojis(self):
        self.emoji_manager.show_emojis(self.viewport, "")

    def reveal_shell_commands(self):
        self.shell_command_manager.show_shell_commands(self.viewport, "")

    def reveal_wallpapers(self):
        self.wallpaper_manager.show_wallpaper_thumbnails(self.viewport, "")

    def adjust_scrolled_window_size(self, content_type: str):
        if content_type in self.CONTENT_SIZES:
            min_height, max_height = self.CONTENT_SIZES[content_type]
            self.scrolled_window.min_content_size = (-1, min_height)
            self.scrolled_window.max_content_size = (-1, max_height)

    def toggle(self):
        self.set_visible(not self.is_visible())
