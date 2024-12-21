import hashlib
import os

from fabric.utils import exec_shell_command, exec_shell_command_async
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from gi.repository import GdkPixbuf
from loguru import logger

from snippets import MaterialIcon


class WallpaperManager:
    IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp"}
    CACHE_DIR = os.path.expanduser("~/.cache/fabric/thumbnails/wallpapers")
    WALLPAPER_SCRIPT_PATH = os.path.expanduser("~/dotfiles/hypr/scripts/wallpaper.py")

    def __init__(self):
        self.wallpaper_dir = os.path.expanduser("~/Pictures/wallpapers")
        os.makedirs(self.CACHE_DIR, exist_ok=True)
        self.thumbnails = []
        self.theme_toggle_button = self._create_theme_toggle_button()
        self._update_button_style()

    def _create_theme_toggle_button(self):
        return Button(
            child=MaterialIcon("contrast"),
            v_align="center",
            on_clicked=self.toggle_dark_mode,
        )

    def toggle_dark_mode(self, *_):
        exec_shell_command(
            os.path.expanduser("~/fabric/assets/scripts/dark-theme.sh --toggle")
        )
        self._update_button_style()

    def check_dark_mode_state(self):
        result = exec_shell_command(
            "gsettings get org.gnome.desktop.interface color-scheme"
        )
        return result.strip().replace("'", "") == "prefer-dark"

    def _update_button_style(self):
        dark_mode = self.check_dark_mode_state()
        style = (
            "background-color: @surfaceVariant; border-radius:100px; min-height:50px; min-width:50px;"
            if dark_mode
            else "background-color: transparent; border-radius:100px;"
        )
        self.theme_toggle_button.set_style(style)

    def get_cache_path(self, file_name: str) -> str:
        file_hash = hashlib.md5(file_name.encode("utf-8")).hexdigest()
        return os.path.join(self.CACHE_DIR, f"{file_hash}.png")

    def create_thumbnail(self, image_path: str, thumbnail_size=100):
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
            logger.error(f"Error creating thumbnail for {image_path}: {e}")
            return None

    def generate_or_load_thumbnail(self, wallpaper_path):
        cache_path = self.get_cache_path(os.path.basename(wallpaper_path))

        if not os.path.exists(cache_path):
            pixbuf = self.create_thumbnail(wallpaper_path)
            if pixbuf:
                pixbuf.savev(cache_path, "png", [], [])
        return cache_path

    def show_wallpaper_thumbnails(self, viewport, search_term: str = ""):
        wallpapers = list(self._get_wallpapers(search_term))[:24]
        if not wallpapers:
            self._show_no_wallpapers_message(viewport)
            return

        self._display_thumbnails(viewport, wallpapers)

    def _show_no_wallpapers_message(self, viewport):
        viewport.add(
            Box(
                orientation="h",
                style="padding:20px;",
                children=[Button(child="No wallpapers found!", v_align="center")],
            )
        )

    def _display_thumbnails(self, viewport, wallpapers):
        row = Box(orientation="h", spacing=10, style="margin:5px;")

        for index, wallpaper in enumerate(wallpapers, 1):
            thumbnail_path = self.generate_or_load_thumbnail(wallpaper)
            row.add(self._create_wallpaper_thumbnail(thumbnail_path, wallpaper))

            if index % 6 == 0:
                viewport.add(row)
                row = Box(orientation="h", spacing=10, style="margin:5px;")

        if row.children:
            viewport.add(row)

    def _get_wallpapers(self, search_term: str):
        return (
            os.path.join(self.wallpaper_dir, file_name)
            for file_name in os.listdir(self.wallpaper_dir)
            if os.path.isfile(os.path.join(self.wallpaper_dir, file_name))
            and os.path.splitext(file_name)[1].lower() in self.IMAGE_EXTENSIONS
            and self._matches_search(file_name, search_term)
        )

    def _matches_search(self, file_name, search_term: str):
        return not search_term or search_term.lower() in file_name.lower()

    def _thumbnail_style(self, thumbnail_path):
        return (
            f"background-image: url('{thumbnail_path}'); "
            "min-width: 64px; min-height: 64px; "
            "background-repeat: no-repeat; "
            "background-size: cover; background-position: center;"
        )

    def _create_wallpaper_thumbnail(self, thumbnail_path, wallpaper_path):
        return Button(
            child=Box(
                orientation="h",
                h_align="center",
                v_align="center",
                style=self._thumbnail_style(thumbnail_path),
            ),
            h_align="start",
            v_align="center",
            name="wall-item",
            on_clicked=lambda _: self._select_wallpaper(wallpaper_path),
        )

    def _select_wallpaper(self, wallpaper_path):
        self._apply_wallpaper(wallpaper_path)

    def _apply_wallpaper(self, wallpaper_path):
        self._execute_wallpaper_script("--image", wallpaper_path)

    def apply_wallpaper_random(self):
        self._execute_wallpaper_script("-R")

    def _execute_wallpaper_script(self, *args):
        try:
            exec_shell_command_async(
                ["python3", self.WALLPAPER_SCRIPT_PATH, *args],
                lambda output: logger.info(f"Wallpaper script output: {output}"),
            )
        except Exception as e:
            logger.error(f"Error executing wallpaper script: {e}")

    def get_wallpaper_buttons(self):
        return self.theme_toggle_button
