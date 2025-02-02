import hashlib
import json
import os

from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.entry import Entry
from fabric.widgets.scrolledwindow import ScrolledWindow
from gi.repository import GdkPixbuf, GLib, Gtk
from snippets import MaterialIcon
from fabric.utils import exec_shell_command, get_relative_path


class WallpaperSelector(Box):
    CACHE_DIR = os.path.expanduser("~/.cache/fabric/wallpapers")
    SETTINGS_FILE = os.path.expanduser("~/dotfiles/.settings/settings.json")

    SCHEMES = {
        "TonalSpot": "tonalSpot",
        "Expressive": "expressive",
        "FruitSalad": "fruitSalad",
        "Monochrome": "monochrome",
        "Rainbow": "rainbow",
        "Vibrant": "vibrant",
        "Neutral": "neutral",
        "Fidelity": "fidelity",
        "Content": "content",
    }

    def __init__(self, **kwargs):
        super().__init__(name="wallpapers", spacing=4, orientation="v", **kwargs)

        self.wallpapers_dir = os.path.expanduser("~/Pictures/wallpapers")
        os.makedirs(self.CACHE_DIR, exist_ok=True)

        self.files = [f for f in os.listdir(self.wallpapers_dir) if self._is_image(f)]
        self.thumbnails = []

        self._init_viewport()
        self._init_search_entry()
        self._init_scheme_dropdown()
        self._init_layout()

        self._start_thumbnail_thread()
        self.show_all()

    def _init_viewport(self):
        self.viewport = Gtk.IconView()
        self.viewport.set_model(Gtk.ListStore(GdkPixbuf.Pixbuf, str))
        self.viewport.set_pixbuf_column(0)
        self.viewport.set_text_column(1)
        self.viewport.set_item_width(0)
        self.viewport.connect("item-activated", self.on_wallpaper_selected)

        self.scrolled_window = ScrolledWindow(
            name="scrolled-window",
            spacing=10,
            h_expand=True,
            v_expand=True,
            child=self.viewport,
        )

    def _init_search_entry(self):
        self.search_entry = Entry(
            name="search-entry",
            h_expand=True,
            notify_text=lambda entry, *_: self.arrange_viewport(entry.get_text()),
        )

    def _init_scheme_dropdown(self):
        self.scheme_dropdown = Gtk.ComboBoxText()
        self.scheme_dropdown.set_name("scheme-dropdown")
        self.scheme_dropdown.set_tooltip_text("Select color scheme")

        for display_name, scheme_id in sorted(self.SCHEMES.items()):
            self.scheme_dropdown.append(scheme_id, display_name)

        self.scheme_dropdown.set_active_id("tonalSpot")
        self.scheme_dropdown.connect("changed", self.on_scheme_changed)

        initial_icon = "light_mode" if not self.check_dark_mode_state() else "dark_mode"
        self.toggle_button = Button(
            child=MaterialIcon(initial_icon),
            name="toggle-launcher-button",
            on_clicked=self.toggle_dark_mode,
        )

        self.dropdown_box = Box(
            name="dropdown-box",
            orientation="h",
            children=[
                self.scheme_dropdown,
                MaterialIcon("keyboard_arrow_down"),
            ],
        )

    def _init_layout(self):
        self.header_box = Box(
            name="header-box",
            spacing=10,
            orientation="h",
            children=[self.search_entry, self.dropdown_box, self.toggle_button],
        )

        self.add(self.header_box)
        self.add(self.scrolled_window)

    def arrange_viewport(self, query: str = ""):
        self.viewport.get_model().clear()
        filtered_thumbnails = [
            (thumb, name)
            for thumb, name in self.thumbnails
            if query.casefold() in name.casefold()
        ]

        filtered_thumbnails.sort(key=lambda x: x[1].lower())

        for pixbuf, file_name in filtered_thumbnails:
            self.viewport.get_model().append([pixbuf, file_name])

    def toggle_dark_mode(self, *_):
        GLib.spawn_command_line_async(
            f"bash {get_relative_path('../../../assets/scripts/dark-theme.sh --toggle')}"
        )
        icon_name = "dark_mode" if not self.check_dark_mode_state() else "light_mode"
        if self.toggle_button.get_child():
            self.toggle_button.remove(self.toggle_button.get_child())
        self.toggle_button.add(MaterialIcon(icon_name))
        self.toggle_button.show_all()

    def check_dark_mode_state(self):
        result = exec_shell_command(
            "gsettings get org.gnome.desktop.interface color-scheme"
        )
        return result.strip().replace("'", "") == "prefer-dark"

    def on_wallpaper_selected(self, iconview, path):
        model = iconview.get_model()
        file_name = model[path][1]
        full_path = os.path.join(self.wallpapers_dir, file_name)
        selected_scheme = self.scheme_dropdown.get_active_id()
        home_dir = GLib.get_home_dir()
        command = (
            f"python -O {home_dir}/dotfiles/hypr/scripts/wallpaper.py -I {full_path}"
        )
        GLib.spawn_command_line_async(command)
        self.update_scheme(selected_scheme)

    def on_scheme_changed(self, combo):
        scheme_id = combo.get_active_id()
        display_name = next(
            name for name, id in self.SCHEMES.items() if id == scheme_id
        )
        print(f"Color scheme selected: {display_name} ({scheme_id})")
        self.update_scheme(scheme_id)

        home_dir = GLib.get_home_dir()
        color_generator = os.path.join(home_dir, "dotfiles/material-colors/generate.py")
        try:
            command = f'python -O {color_generator} -R --scheme "{scheme_id}"'
            GLib.spawn_command_line_async(command)
            print(f"Applied color scheme: {display_name}")
        except Exception as e:
            print(f"Failed to apply color scheme: {e}")

    def update_scheme(self, scheme: str):
        try:
            with open(self.SETTINGS_FILE, "r") as f:
                settings = json.loads(f.read())

            settings["generation-scheme"] = scheme

            with open(self.SETTINGS_FILE, "w") as f:
                json.dump(settings, f, indent=2)
        except Exception as error:
            print(f"Failed to update generation-scheme in settings.json: {error}")

    def _start_thumbnail_thread(self):
        thread = GLib.Thread.new("thumbnail-loader", self._preload_thumbnails, None)

    def _preload_thumbnails(self, _data):
        for file_name in sorted(self.files):
            full_path = os.path.join(self.wallpapers_dir, file_name)
            cache_path = self._get_cache_path(file_name)

            if not os.path.exists(cache_path):
                pixbuf = self._create_thumbnail(full_path)
                if pixbuf:
                    pixbuf.savev(cache_path, "png", [], [])
            else:
                pixbuf = GdkPixbuf.Pixbuf.new_from_file(cache_path)

            if pixbuf:
                GLib.idle_add(self._add_thumbnail_to_view, pixbuf, file_name)

    def _add_thumbnail_to_view(self, pixbuf, file_name):
        self.thumbnails.append((pixbuf, file_name))
        self.viewport.get_model().append([pixbuf, file_name])
        return False

    def _create_thumbnail(self, image_path: str, thumbnail_size=96):
        try:
            pixbuf = GdkPixbuf.Pixbuf.new_from_file(image_path)
            width, height = pixbuf.get_width(), pixbuf.get_height()
            if width > height:
                new_width = thumbnail_size
                new_height = int(height * (thumbnail_size / width))
            else:
                new_height = thumbnail_size
                new_width = int(width * (thumbnail_size / height))
            return pixbuf.scale_simple(
                new_width, new_height, GdkPixbuf.InterpType.BILINEAR
            )
        except Exception as e:
            print(f"Error creating thumbnail for {image_path}: {e}")
            return None

    def _get_cache_path(self, file_name: str) -> str:
        file_hash = hashlib.md5(file_name.encode("utf-8")).hexdigest()
        return os.path.join(self.CACHE_DIR, f"{file_hash}.png")

    @staticmethod
    def _is_image(file_name: str) -> bool:
        return file_name.lower().endswith(
            (".png", ".jpg", ".jpeg", ".bmp", ".gif", ".webp")
        )
