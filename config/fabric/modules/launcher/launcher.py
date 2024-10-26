from fabric.utils import get_desktop_applications, idle_add, remove_handler
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.entry import Entry
from fabric.widgets.label import Label
from fabric.widgets.revealer import Revealer
from fabric.widgets.scrolledwindow import ScrolledWindow
from fabric.widgets.wayland import WaylandWindow as Window
from modules.launcher.widgets import (
    ClipboardManager,
    DesktopButtonManager,
    EmojiManager,
    ShellCommandManager,
    WallpaperManager,
    bake_favorite_slot,
    handle_application_search,
)


class Launcher(Window):
    FAVORITE_APPS = [
        "Firefox",
        "Discord",
        "materialgram",
        "Spotify",
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
        self.all_apps = get_desktop_applications()
        self.initialize_managers()
        self.setup_ui()
        self.connect("key-press-event", self.on_key_press)

    def initialize_managers(self):
        self.clipboard_manager = ClipboardManager(self)
        self.emoji_manager = EmojiManager(self)
        self.shell_command_manager = ShellCommandManager(self)
        self.wallpaper_manager = WallpaperManager()
        self.desktop_button_manager = DesktopButtonManager(self.get_viewport())

    def setup_ui(self):
        self.scrolled_window = self.create_scrolled_window()
        self.scrolled_revealer = self.create_revealer()
        self.search_entry = self.create_search_entry()

        launcher_box = Box(
            orientation="v",
            size=(550, 0),
            name="launcher",
            children=[
                Box(spacing=10, orientation="h", children=[self.search_entry]),
                self.get_favorites_box(),
                self.scrolled_revealer,
            ],
        )
        self.add(launcher_box)
        self.show_favorites()
        self.show_all()

    def create_search_entry(self):
        return Entry(
            placeholder="Search.....",
            h_expand=True,
            notify_text=lambda entry, *_: self.debounce_search(entry.get_text()),
            icon_name="preferences-system-search-symbolic",
        )

    def get_favorites_box(self):
        if not hasattr(self, "fav_apps_box"):
            self.fav_apps_box = Box(spacing=10, orientation="h")
        return self.fav_apps_box

    def create_scrolled_window(self):
        return ScrolledWindow(
            name="launcher-scroll",
            child=self.get_viewport(),
            h_scrollbar_policy="never",
            # v_scrollbar_policy="never",
        )

    def create_revealer(self):
        return Revealer(
            child=self.scrolled_window,
            transition_duration=300,
            transition_type="slide-down",
        )

    def get_viewport(self):
        if not hasattr(self, "viewport"):
            self.viewport = Box(spacing=10, orientation="v")
        return self.viewport

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
                self.get_favorites_box().add(bake_favorite_slot(self, app))

    def arrange_viewport(self, query: str = ""):
        self.get_viewport().children = []
        self.scrolled_window.min_content_size = (-1, -1)
        self.scrolled_window.max_content_size = (-1, -1)

        command_handlers = {
            ":em": self.show_emojis,
            ":ch": self.show_clipboard_history,
            ":db": self.show_desktop_buttons,
            ":sh": self.show_shell_commands,
            ":wl": self.show_wallpapers,
        }

        for command, handler in command_handlers.items():
            if query.startswith(command):
                handler(query[len(command) :].strip())
                return

        if query.startswith(":"):
            self.get_favorites_box().set_visible(False)
            self.show_help()
            self.adjust_scrolled_window_size("help")
            self.scrolled_revealer.reveal()
            return

        handle_application_search(self, query)

    def show_desktop_buttons(self, query: str = None):
        self.desktop_button_manager.show_desktop_buttons(query)
        self.adjust_scrolled_window_size("default")
        self.scrolled_revealer.reveal()

    def show_emojis(self, query: str):
        self.emoji_manager.show_emojis(self.get_viewport(), query)
        self.adjust_scrolled_window_size("emoji")
        self.scrolled_revealer.reveal()

    def show_clipboard_history(self, query: str):
        self.clipboard_manager.show_clipboard_history(self.get_viewport(), query)
        self.adjust_scrolled_window_size("default")
        self.scrolled_revealer.reveal()

    def show_shell_commands(self, query: str):
        if not query:
            self.scrolled_revealer.unreveal()
            return
        self.shell_command_manager.show_shell_commands(self.get_viewport(), query)
        self.adjust_scrolled_window_size("default")
        self.scrolled_revealer.reveal()

    def show_wallpapers(self, query: str):
        if query == "random":
            self.wallpaper_manager.apply_wallpaper_random()
        else:
            self.wallpaper_manager.show_wallpaper_thumbnails(self.get_viewport(), query)
        self.adjust_scrolled_window_size("emoji")
        self.scrolled_revealer.reveal()

    def show_help(self):
        help_commands = [
            (":ch", "Copy a clipboard history entry", self.reveal_clipboard_history),
            (":db", "Control System", lambda: self.show_desktop_buttons()),
            (":em", "Copy an emoji", self.reveal_emojis),
            (":sh", "Run a binary", self.reveal_shell_commands),
            (":wl", "Change or show wallpapers", self.reveal_wallpapers),
        ]

        for command, description, action in help_commands:
            button = Button(
                child=self.create_help_button_content(command, description),
                on_clicked=lambda _, cmd=command, act=action: (
                    self.search_entry.set_text(cmd),
                    act(),
                ),
                name="help-item",
            )
            self.get_viewport().add(button)

    def create_help_button_content(self, command, description):
        return Box(
            orientation="h",
            spacing=10,
            children=[
                Label(
                    label=command, h_expand=True, name="command-label", h_align="start"
                ),
                Label(
                    label=description,
                    h_expand=True,
                    name="description-label",
                    h_align="end",
                ),
            ],
        )

    def reveal_clipboard_history(self):
        self.clipboard_manager.show_clipboard_history(self.get_viewport(), "")

    def reveal_emojis(self):
        self.emoji_manager.show_emojis(self.get_viewport(), "")

    def reveal_shell_commands(self):
        self.shell_command_manager.show_shell_commands(self.get_viewport(), "")

    def reveal_wallpapers(self):
        self.wallpaper_manager.show_wallpaper_thumbnails(self.get_viewport(), "")

    def adjust_scrolled_window_size(self, content_type: str):
        if content_type in self.CONTENT_SIZES:
            min_height, max_height = self.CONTENT_SIZES[content_type]
            self.scrolled_window.min_content_size = (-1, min_height)
            self.scrolled_window.max_content_size = (-1, max_height)

    def toggle(self):
        if self.is_visible():
            self.set_visible(False)
        else:
            self.search_entry.set_text("")
            self.set_visible(True)
