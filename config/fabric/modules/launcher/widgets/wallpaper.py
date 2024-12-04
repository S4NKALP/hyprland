import os
import threading
from pathlib import Path

from fabric.utils import exec_shell_command, exec_shell_command_async
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from loguru import logger
from snippets import MaterialIcon


class WallpaperManager:
    IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp"}
    THUMBNAIL_SIZE = "x64"
    THUMBNAIL_ASPECT_RATIO = "1:1"
    WALLPAPER_SCRIPT_PATH = os.path.expanduser("~/dotfiles/hypr/scripts/wallpaper.py")

    def __init__(self):
        self.wallpaper_dir = Path.home() / "Pictures" / "wallpapers"
        self.thumbnail_dir = (
            Path.home() / ".cache" / "fabric" / "thumbnails" / "wallpapers"
        )
        self.thumbnail_dir.mkdir(parents=True, exist_ok=True)
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
            thumbnail_path = self._generate_thumbnail(wallpaper)
            row.add(self._create_wallpaper_thumbnail(thumbnail_path, wallpaper))

            if index % 6 == 0:
                viewport.add(row)
                row = Box(orientation="h", spacing=10, style="margin:5px;")

        if row.children:
            viewport.add(row)

    def _get_wallpapers(self, search_term: str):
        return (
            f
            for f in self.wallpaper_dir.iterdir()
            if f.is_file()
            and f.suffix.lower() in self.IMAGE_EXTENSIONS
            and self._matches_search(f, search_term)
        )

    def _matches_search(self, file, search_term: str):
        return not search_term or search_term.lower() in file.name.lower()

    def _generate_thumbnail(self, wallpaper_path):
        thumbnail_path = self.thumbnail_dir / wallpaper_path.name
        if not thumbnail_path.exists():
            threading.Thread(
                target=self._create_thumbnail,
                args=(wallpaper_path, thumbnail_path),
                daemon=True,
            ).start()
        return thumbnail_path

    def _create_thumbnail(self, wallpaper_path, thumbnail_path):
        logger.debug(f"Generating thumbnail for {wallpaper_path}")
        exec_shell_command_async(
            [
                "magick",
                str(wallpaper_path),
                "-resize",
                self.THUMBNAIL_SIZE,
                "-gravity",
                "Center",
                "-extent",
                self.THUMBNAIL_ASPECT_RATIO,
                str(thumbnail_path),
            ],
            lambda *args: logger.debug(args),
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

    def _thumbnail_style(self, thumbnail_path):
        return (
            f"background-image: url('{thumbnail_path}'); "
            "min-width: 64px; min-height: 64px; "
            "background-repeat: no-repeat; "
            "background-size: cover; background-position: center;"
        )

    def _select_wallpaper(self, wallpaper_path):
        self._apply_wallpaper(wallpaper_path)

    def _apply_wallpaper(self, wallpaper_path):
        self._execute_wallpaper_script("--image", str(wallpaper_path))

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
