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
    handle_application_search,
)
from snippets import (
    MaterialIcon,
    get_current_uptime,
    get_profile_picture_path,
    read_config,
    username,
)


class Launcher(Window):
    def __init__(self, **kwargs):
        self.config = read_config()
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
            label=get_current_uptime(), style="margin-left: 60px;"
        )
        self.commands = self.config.get("commands", [])
        self.command_map = self.build_command_map()
        self.setup_ui()
        self.connect("key-press-event", self.on_key_press)
        self.update_uptime_label()

    def initialize_managers(self):
        self.clipboard_manager = ClipboardManager(self, self.get_viewport())
        self.emoji_manager = EmojiManager(self)
        self.shell_command_manager = ShellCommandManager(self)
        self.wallpaper_manager = WallpaperManager()
        self.power_menu = PowerMenu(self)
        self.bluetooth_menu = BluetoothMenu(self)
        self.network_menu = WifiMenu(self)

    def setup_ui(self):
        self.default_button = Button(
            child=MaterialIcon("grid_view"),
            h_align="center",
            v_align="center",
        )
        self.scrolled_window = self.create_scrolled_window()
        self.scrolled_revealer = self.create_revealer()
        self.search_entry = self.create_search_entry()
        self.additional_box = self.create_additional_box()
        self.search_box = Box(
            spacing=10,
            orientation="h",
            children=[self.search_entry, self.default_button],
        )
        launcher_box = Box(
            orientation="v",
            name="launcher",
            children=[
                self.search_box,
                self.additional_box,
                self.scrolled_revealer,
            ],
        )
        self.add(launcher_box)
        self.show_all()

    def create_search_entry(self):
        entry = Entry(
            placeholder="Type ':' to list subcommands",
            h_expand=True,
            notify_text=lambda entry, *_: self.debounce_search(entry.get_text()),
        )
        entry.set_icon_from_icon_name(0, "preferences-system-search-symbolic")
        return entry

    def create_scrolled_window(self):
        return ScrolledWindow(
            name="launcher-scroll",
            style="  transition: min-height 50s cubic-bezier(0.42, 0, 0.58, 1);",
            child=self.get_viewport(),
            h_scrollbar_policy="never",
            v_scrollbar_policy="never",
        )

    def create_revealer(self):
        return Revealer(
            style="  transition: min-height 50s cubic-bezier(0.42, 0, 0.58, 1);",
            child=self.scrolled_window,
            transition_type="crossfade",
        )

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

    def get_viewport(self):
        if not hasattr(self, "viewport"):
            self.viewport = Box(spacing=10, orientation="v")
        return self.viewport

    def update_uptime_label(self):
        self.uptime_label.set_label(get_current_uptime())
        invoke_repeater(
            60 * 1000, lambda: self.uptime_label.set_label(get_current_uptime())
        )

    def build_command_map(self):
        return {cmd["command"]: cmd["handler"] for cmd in self.commands}

    def debounce_search(self, query: str):
        if hasattr(self, "_arranger_handler"):
            remove_handler(self._arranger_handler)
        self._arranger_handler = idle_add(self.arrange_viewport, query, pin=True)

    def arrange_viewport(self, query: str = ""):

        self.get_viewport().children = []
        dynamic_buttons = []
        for command, handler_name in self.command_map.items():
            if query.startswith(command):
                handler = getattr(self, handler_name, None)
                if handler:
                    handler(query[len(command) :].strip())
                    return

        if query.startswith(":"):
            self.additional_box.set_visible(False)
            self.update_dynamic_button([self.default_button])
            self.show_help(query[1:])
            self.scrolled_revealer.reveal()
            return
        handle_application_search(self, query)

    def update_dynamic_button(self, new_buttons):
        if not isinstance(new_buttons, list):
            new_buttons = [new_buttons]
        for child in self.search_box.children[1:]:
            self.search_box.remove(child)
        for new_button in new_buttons:
            self.search_box.add(new_button)

    def on_key_press(self, widget, event):
        from gi.repository import Gdk

        if self.is_visible() and event.keyval == Gdk.KEY_Escape:
            self.set_visible(False)
            return True
        return False

    def load_commands(self):
        return {cmd["command"]: cmd["description"] for cmd in self.commands}

    def show_help(self, query: str):
        filtered_help = [
            (command, description)
            for command, description in self.load_commands().items()
            if query.lower() in command[1:].lower()
        ]

        if not filtered_help:
            return
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
        if self.is_visible():
            self.update_dynamic_button(self.default_button)
            self.search_entry.set_text("")
            self.search_entry.grab_focus()

    def show_network(self, *_):
        self.network_menu.show_wifi_menu(self.viewport)
        dynamic_buttons = self.network_menu.get_wifi_buttons()
        self.update_dynamic_button(dynamic_buttons)
        self.scrolled_revealer.reveal()

    def show_emojis(self, query: str):
        self.emoji_manager.show_emojis(self.get_viewport(), query)
        dynamic_buttons = self.emoji_manager.get_emoji_buttons()
        self.update_dynamic_button(dynamic_buttons)
        self.scrolled_revealer.reveal()

    def show_clipboard_history(self, query: str):
        self.clipboard_manager.show_clipboard_history(self.get_viewport(), query)
        dynamic_buttons = self.clipboard_manager.get_clipboard_buttons()
        self.update_dynamic_button(dynamic_buttons)
        self.scrolled_revealer.reveal()

    def show_powermenu(self, query: str = ""):
        self.power_menu.show_power_menu(self.get_viewport(), query)
        dynamic_buttons = self.power_menu.get_power_buttons()
        self.update_dynamic_button(dynamic_buttons)
        self.scrolled_revealer.reveal()

    def show_shell_commands(self, query: str):
        if not query:
            dynamic_buttons = self.shell_command_manager.get_shell_buttons()
            self.update_dynamic_button(dynamic_buttons)
            self.scrolled_revealer.unreveal()
            return
        self.shell_command_manager.show_shell_commands(self.get_viewport(), query)
        dynamic_buttons = self.shell_command_manager.get_shell_buttons()
        self.update_dynamic_button(dynamic_buttons)
        self.scrolled_revealer.reveal()

    def show_wallpapers(self, query: str):
        if query == "random":
            self.wallpaper_manager.apply_wallpaper_random()
        else:
            self.wallpaper_manager.show_wallpaper_thumbnails(self.get_viewport(), query)
        dynamic_buttons = self.wallpaper_manager.get_wallpaper_buttons()
        self.update_dynamic_button(dynamic_buttons)
        self.scrolled_revealer.reveal()

    def show_bluetooth_settings(self, *_):
        self.bluetooth_menu.show_bluetooth_menu(self.viewport)
        dynamic_buttons = self.bluetooth_menu.get_bluetooth_buttons()
        self.update_dynamic_button(dynamic_buttons)
        self.scrolled_revealer.reveal()
