from __init__ import *


class WallpaperManager:
    def __init__(self):
        self.wallpaper_dir = Path.home() / "Pictures" / "wallpapers"
        self.thumbnail_dir = (
            Path.home() / ".cache" / "fabric" / "thumbnails" / "wallpaper"
        )
        self.thumbnail_dir.mkdir(parents=True, exist_ok=True)

    def show_wallpaper_thumbnails(self, viewport, search_term: str = ""):
        wallpapers = [
            f
            for f in self.wallpaper_dir.iterdir()
            if f.is_file() and f.suffix.lower() in [".png", ".jpg", ".jpeg", ".webp"]
        ]

        if search_term:
            wallpapers = [
                wallpaper
                for wallpaper in wallpapers
                if search_term.lower() in wallpaper.name.lower()
            ]

        viewport.children = []
        row = Box(orientation="h", spacing=10)

        for i, wallpaper in enumerate(wallpapers):
            thumbnail_path = self.generate_thumbnail(wallpaper)
            thumbnail_button = self.create_wallpaper_thumbnail(
                thumbnail_path, wallpaper
            )
            row.add(thumbnail_button)

            if (i + 1) % 8 == 0:
                viewport.add(row)
                row = Box(orientation="h", spacing=10)

        if row.children:
            viewport.add(row)

    def generate_thumbnail(self, wallpaper_path):
        thumbnail_path = self.thumbnail_dir / wallpaper_path.name
        if not thumbnail_path.exists():
            exec_shell_command_async(
                [
                    "magick",
                    str(wallpaper_path),
                    "-resize",
                    "x36",
                    "-gravity",
                    "Center",
                    "-extent",
                    "1:1",
                    str(thumbnail_path),
                ],
                lambda output: logger.info("Thumbnail created successfully!"),
            )
        return thumbnail_path

    def create_wallpaper_thumbnail(self, thumbnail_path, wallpaper_path):
        thumbnail_box = Box(
            orientation="h",
            h_align="center",
            v_align="center",
            style=f"background-image: url('{thumbnail_path}'); min-width: 36px; min-height: 36px; background-repeat: no-repeat; background-size: cover; background-position: center;",
        )
        button = Button(
            child=thumbnail_box,
            h_align="start",
            v_align="center",
            name="wall-item",
            on_clicked=lambda _: self.select_wallpaper(wallpaper_path),
        )
        return button

    def select_wallpaper(self, wallpaper_path):
        logger.info(f"Selected wallpaper: {wallpaper_path}")
        self.apply_wallpaper(wallpaper_path)

    def apply_wallpaper(self, wallpaper_path):
        script_path = os.path.expanduser("~/dotfiles/hypr/scripts/wallpaper.py")
        try:
            exec_shell_command_async(
                ["python3", script_path, "--image", str(wallpaper_path)],
                lambda output: logger.info(f"{output}"),
            )
            logger.info(f"Wallpaper applied: {wallpaper_path}")
        except Exception as e:
            logger.error(f"Error applying wallpaper: {e}")

    def apply_wallpaper_random(self):
        script_path = os.path.expanduser("~/dotfiles/hypr/scripts/wallpaper.py")
        try:
            exec_shell_command_async(
                ["python3", script_path, "-R"],
                lambda output: logger.info(f"{output}"),
            )
            logger.info("Random wallpaper applied.")
        except Exception as e:
            logger.error(f"Error applying random wallpaper: {e}")
