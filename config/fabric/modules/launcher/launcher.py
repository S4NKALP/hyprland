from fabric.utils import get_desktop_applications, idle_add, remove_handler
from fabric.widgets.box import Box
from fabric.widgets.entry import Entry
from fabric.widgets.revealer import Revealer
from fabric.widgets.scrolledwindow import ScrolledWindow
from fabric.widgets.wayland import WaylandWindow as Window
from modules.launcher.widgets import (
    ClipboardManager,
    DesktopButtonManager,
    EmojiManager,
    ShellCommandManager,
    WallpaperManager,
    handle_application_search,
)


class Launcher(Window):
    COMMAND_ICONS = {
        "/e": "face-smile-symbolic",
        "/c": "edit-copy-symbolic",
        "/d": "applications-system-symbolic",
        "/s": "utilities-terminal-symbolic",
        "/w": "image-symbolic",
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
        self.clipboard_manager = ClipboardManager(self, self.get_viewport())
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
                self.scrolled_revealer,
            ],
        )
        self.add(launcher_box)
        self.show_all()

    def create_search_entry(self):
        self.entry = Entry(
            placeholder="Search.....",
            h_expand=True,
            notify_text=lambda entry, *_: self.debounce_search(entry.get_text()),
        )
        return self.entry

    def create_scrolled_window(self):
        return ScrolledWindow(
            child=self.get_viewport(),
            h_scrollbar_policy="never",
            v_scrollbar_policy="never",
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

    def arrange_viewport(self, query: str = ""):
        self.clear_viewport()
        command_handlers = {
            "/e": self.show_emojis,
            "/c": self.show_clipboard_history,
            "/d": self.show_desktop_buttons,
            "/s": self.show_shell_commands,
            "/w": self.show_wallpapers,
        }

        for command, handler in command_handlers.items():
            if query.startswith(command):
                self.handle_command(command, query, handler)
                return

        self.reset_search_icon()
        handle_application_search(self, query)

    def clear_viewport(self):
        # Clear the children of the viewport
        self.get_viewport().children = []

    def handle_command(self, command: str, query: str, handler):
        icon_name = self.get_command_icon(command)
        self.entry.set_icon_from_icon_name(0, icon_name)
        handler(query[len(command) :].strip())
        self.scrolled_revealer.reveal()

    def get_command_icon(self, command: str) -> str:
        return self.COMMAND_ICONS.get(command, "")

    def reset_search_icon(self):
        self.entry.set_icon_from_icon_name(0, "preferences-system-search-symbolic")

    def show_desktop_buttons(self, query: str):
        self.desktop_button_manager.show_desktop_buttons(query)

    def show_emojis(self, query: str):
        self.emoji_manager.show_emojis(self.get_viewport(), query)

    def show_clipboard_history(self, query: str):
        self.clipboard_manager.show_clipboard_history(self.get_viewport(), query)

    def show_shell_commands(self, query: str):
        if not query:
            self.scrolled_revealer.unreveal()
            return
        self.shell_command_manager.show_shell_commands(self.get_viewport(), query)

    def show_wallpapers(self, query: str):
        if query == "random":
            self.wallpaper_manager.apply_wallpaper_random()
        else:
            self.wallpaper_manager.show_wallpaper_thumbnails(self.get_viewport(), query)

    def toggle(self):
        self.set_visible(not self.is_visible())
        if self.is_visible():
            self.search_entry.set_text("")
            self.search_entry.grab_focus()
