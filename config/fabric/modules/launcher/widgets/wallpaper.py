import os
from pathlib import Path

from loguru import logger

from fabric.utils import exec_shell_command_async
from fabric.widgets.box import Box
from fabric.widgets.button import Button


class WallpaperManager:
    def __init__(self):
        self.wallpaper_dir = Path.home() / "Pictures" / "wallpapers"
        self.thumbnail_dir = (
            Path.home() / ".cache" / "fabric" / "thumbnails" / "wallpaper"
        )
        self.thumbnail_dir.mkdir(parents=True, exist_ok=True)

    def show_wallpaper_thumbnails(self, viewport, search_term: str = ""):
        wallpapers = self._get_wallpapers(search_term)[:24]
        self._populate_viewport(viewport, wallpapers)

    def _get_wallpapers(self, search_term: str):
        return [
            f
            for f in self.wallpaper_dir.iterdir()
            if f.is_file()
            and f.suffix.lower() in {".png", ".jpg", ".jpeg", ".webp"}
            and (not search_term or search_term.lower() in f.name.lower())
        ]

    def _populate_viewport(self, viewport, wallpapers):
        viewport.children.clear()
        row = Box(orientation="h", spacing=10)

        for i, wallpaper in enumerate(wallpapers):
            thumbnail_path = self._generate_thumbnail(wallpaper)
            thumbnail_button = self._create_wallpaper_thumbnail(
                thumbnail_path, wallpaper
            )
            row.add(thumbnail_button)

            if (i + 1) % 8 == 0:
                viewport.add(row)
                row = Box(orientation="h", spacing=10)

        if row.children:
            viewport.add(row)

    def _generate_thumbnail(self, wallpaper_path):
        thumbnail_path = self.thumbnail_dir / wallpaper_path.name
        if not thumbnail_path.exists():
            self._create_thumbnail(wallpaper_path, thumbnail_path)
        return thumbnail_path

    def _create_thumbnail(self, wallpaper_path, thumbnail_path):
        exec_shell_command_async(
            [
                "magick",
                str(wallpaper_path),
                "-resize",
                "x32",
                "-gravity",
                "Center",
                "-extent",
                "1:1",
                str(thumbnail_path),
            ],
            lambda *args: logger.debug(args),
        )

    def _create_wallpaper_thumbnail(self, thumbnail_path, wallpaper_path):
        thumbnail_box = Box(
            orientation="h",
            h_align="center",
            v_align="center",
            style=self._thumbnail_style(thumbnail_path),
        )
        return Button(
            child=thumbnail_box,
            h_align="start",
            v_align="center",
            name="wall-item",
            on_clicked=lambda _: self._select_wallpaper(wallpaper_path),
        )

    def _thumbnail_style(self, thumbnail_path):
        return (
            f"background-image: url('{thumbnail_path}'); "
            "min-width: 32px; min-height: 32px; "
            "background-repeat: no-repeat; "
            "background-size: cover; background-position: center;"
        )

    def _select_wallpaper(self, wallpaper_path):
        logger.info(f"Selected wallpaper: {wallpaper_path}")
        self._apply_wallpaper(wallpaper_path)

    def _apply_wallpaper(self, wallpaper_path):
        self._execute_wallpaper_script("--image", str(wallpaper_path))

    def apply_wallpaper_random(self):
        self._execute_wallpaper_script("-R")

    def _execute_wallpaper_script(self, *args):
        script_path = os.path.expanduser("~/dotfiles/hypr/scripts/wallpaper.py")
        try:
            exec_shell_command_async(
                ["python3", script_path, *args],
                lambda output: logger.info(f"{output}"),
            )
            logger.info(f"Wallpaper applied with args: {args}")
        except Exception as e:
            logger.error(f"Error applying wallpaper: {e}")
