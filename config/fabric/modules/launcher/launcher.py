import time

import psutil
from fabric.utils import (
    get_desktop_applications,
    idle_add,
    invoke_repeater,
    remove_handler,
)
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.entry import Entry
from fabric.widgets.label import Label
from fabric.widgets.revealer import Revealer
from fabric.widgets.scrolledwindow import ScrolledWindow
from fabric.widgets.wayland import WaylandWindow as Window
from modules.launcher.widgets import (
    BluetoothMenu,
    ClipboardManager,
    EmojiManager,
    PowerMenu,
    ShellCommandManager,
    WallpaperManager,
    WifiMenu,
    bake_favorite_slot,
    handle_application_search,
)
from snippets import get_profile_picture_path, read_config, username


class Launcher(Window):
    def __init__(self, **kwargs):
        self.FAVORITE_APPS = self.load_favorite_apps()
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
        self.uptime_label = Label(
            label=self.get_current_uptime(), style="margin-left: 60px;"
        )
        self.setup_ui()
        self.connect("key-press-event", self.on_key_press)
        self.update_uptime_label()

    def load_favorite_apps(self):
        config = read_config()
        return config.get("favorite_apps", [])

    def initialize_managers(self):
        self.clipboard_manager = ClipboardManager(self, self.get_viewport())
        self.emoji_manager = EmojiManager(self)
        self.shell_command_manager = ShellCommandManager(self)
        self.wallpaper_manager = WallpaperManager()
        self.power_menu = PowerMenu(self)
        self.bluetooth_menu = BluetoothMenu(self)
        self.network_menu = WifiMenu(self)

    def setup_ui(self):
        self.scrolled_window = self.create_scrolled_window()
        self.scrolled_revealer = self.create_revealer()
        self.search_entry = self.create_search_entry()
        self.additional_box = self.create_additional_box()
        self.search_box = Box(spacing=10, orientation="h", children=[self.search_entry])

        launcher_box = Box(
            orientation="v",
            size=(580, 0),
            name="launcher",
            children=[
                self.search_box,
                self.get_favorites_box(),
                self.additional_box,
                self.scrolled_revealer,
            ],
        )
        self.add(launcher_box)
        self.show_favorites()
        self.show_all()

    def create_additional_box(self):
        return Box(
            orientation="h",
            spacing=10,
            children=[
                Box(
                    name="profile-pic",
                    style=f"background-image: url(\"file://{get_profile_picture_path() or ''}\")",
                ),
                Label(label=username()),
                self.uptime_label,
            ],
        )

    def get_current_uptime(self):
        uptime = time.time() - psutil.boot_time()
        uptime_hours, remainder = divmod(uptime, 3600)
        uptime_minutes, _ = divmod(remainder, 60)
        return (
            f"Up: {int(uptime_hours)} {'hours' if uptime_hours != 1 else 'hour'}, "
            f"{int(uptime_minutes)} {'minutes' if uptime_minutes != 1 else 'minute'}"
        )

    def update_uptime_label(self):
        self.uptime_label.set_label(self.get_current_uptime())
        invoke_repeater(
            60 * 1000, lambda: self.uptime_label.set_label(self.get_current_uptime())
        )

    def create_search_entry(self):
        entry = Entry(
            placeholder="Search.....",
            h_expand=True,
            notify_text=lambda entry, *_: self.debounce_search(entry.get_text()),
        )
        entry.set_icon_from_icon_name(0, "preferences-system-search-symbolic")
        return entry

    def get_favorites_box(self):
        if not hasattr(self, "fav_apps_box"):
            self.fav_apps_box = Box(spacing=10, orientation="h")
        return self.fav_apps_box

    def create_scrolled_window(self):
        return ScrolledWindow(
            name="launcher-scroll",
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

    def show_favorites(self):
        for app_name in self.FAVORITE_APPS:
            app = next((a for a in self.all_apps if a.name == app_name), None)
            if app:
                self.get_favorites_box().add(bake_favorite_slot(self, app))

    def arrange_viewport(self, query: str = ""):
        self.get_viewport().children = []

        command_handlers = {
            ":em": self.show_emojis,
            ":ch": self.show_clipboard_history,
            ":sh": self.show_shell_commands,
            ":wl": self.show_wallpapers,
            ":p": self.show_powermenu,
            ":bt": self.show_bluetooth_settings,
            ":nw": self.show_network,
        }

        for command, handler in command_handlers.items():
            if query.startswith(command):
                handler(query[len(command) :].strip())
                return

        if query.startswith(":"):
            self.get_favorites_box().set_visible(False)
            self.additional_box.set_visible(False)
            self.show_help(query[1:])
            self.scrolled_revealer.reveal()
            return

        handle_application_search(self, query)

    def show_network(self, *_):
        self.network_menu.show_wifi_menu(self.viewport)
        self.scrolled_revealer.reveal()

    def show_emojis(self, query: str):
        self.emoji_manager.show_emojis(self.get_viewport(), query)
        self.scrolled_revealer.reveal()

    def show_clipboard_history(self, query: str):
        self.clipboard_manager.show_clipboard_history(self.get_viewport(), query)
        self.scrolled_revealer.reveal()

    def show_powermenu(self, query: str = ""):
        self.power_menu.show_power_menu(self.get_viewport(), query)
        self.scrolled_revealer.reveal()

    def show_shell_commands(self, query: str):
        if not query:
            self.scrolled_revealer.unreveal()
            return
        self.shell_command_manager.show_shell_commands(self.get_viewport(), query)
        self.scrolled_revealer.reveal()

    def show_wallpapers(self, query: str):
        if query == "random":
            self.wallpaper_manager.apply_wallpaper_random()
        else:
            self.wallpaper_manager.show_wallpaper_thumbnails(self.get_viewport(), query)
        self.scrolled_revealer.reveal()

    def show_bluetooth_settings(self, *_):
        self.bluetooth_menu.show_bluetooth_menu(self.viewport)
        self.scrolled_revealer.reveal()

    def show_help(self, query: str):
        help_commands = [
            (":bt", "Bluetooth"),
            (":ch", "Copy a clipboard history entry"),
            (":em", "Copy an emoji"),
            (":p", "Shutdown and go sleepy time"),
            (":sh", "Run executables from PATH"),
            (":wl", "Set the wallpaper"),
            (":nw", "List of available wifi networks"),
        ]

        filtered_help = [
            (command, description)
            for command, description in help_commands
            if query.lower() in command[1:].lower()
        ]

        for command, description in filtered_help:
            button = Button(
                child=self.create_help_button_content(command, description),
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

    def toggle(self):
        self.set_visible(not self.is_visible())
