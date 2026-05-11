from pathlib import Path

from fabric.core.service import Property, Service, Signal
from fabric.utils import GLib, logger, monitor_file, time

import config.data as data
from services import on_config_change
from utils.functions import read_json_file, run_command, write_json_file

HYPRCTL_BIN = "hyprctl"


class KeyboardLayout(Service):
    """Service to manage keyboard layout switching and monitoring."""

    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    @staticmethod
    def get_initial():
        if KeyboardLayout._instance is None:
            KeyboardLayout._instance = KeyboardLayout()
        return KeyboardLayout._instance

    @Signal
    def layout_changed(self, layout: str) -> None:
        """Signal emitted when keyboard layout changes."""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.layout_file = Path(data.CACHE_DIR) / "kb_layout"
        self.layout_json_file = Path(data.CACHE_DIR) / "kb_layout.json"
        self._last_layout = None

        self.layout_file.parent.mkdir(parents=True, exist_ok=True)

        self._init_layout_json()

        # Monitor the layout file for changes
        current = self._read_layout()
        self._write_layout(current)
        self.file_monitor = monitor_file(str(self.layout_file), initial_call=True)
        self.file_monitor.connect("changed", self._on_file_changed)
        self._last_layout = current

        on_config_change(self._on_config_change)

    def _on_config_change(self, new_config, old_config):
        old_kb_layout = old_config.get("keyboard_layout", {})
        new_kb_layout = new_config.get("keyboard_layout", {})

        if old_kb_layout.get("layouts") != new_kb_layout.get("layouts"):
            new_layouts = new_kb_layout.get("layouts")
            if new_layouts and new_layouts != self.layouts:
                self.layouts = new_layouts
                current_layout = self._read_layout()
                self.current_index = (
                    self.layouts.index(current_layout)
                    if current_layout in self.layouts
                    else 0
                )
                if self.current_index >= len(self.layouts):
                    self.current_index = 0
                self._save_layout_json()
                new_current = self.layouts[self.current_index]
                if new_current != current_layout:
                    self._write_layout(new_current)
                logger.info(f"Layouts reloaded from config: {self.layouts}")

    def _init_layout_json(self):
        config_layouts = data.DATA().get("keyboard_layouts")

        json_data = read_json_file(self.layout_json_file)
        if json_data:
            saved_layouts = json_data.get("layouts", config_layouts)
            self.layouts = (
                config_layouts if saved_layouts != config_layouts else saved_layouts
            )
            self.current_index = json_data.get("current_index", 0)
            if self.current_index >= len(self.layouts):  # pyright: ignore[reportArgumentType]
                self.current_index = 0
        else:
            self.layouts = config_layouts
            self.current_index = 0
            self._save_layout_json()

    def _save_layout_json(self):
        write_json_file(
            {
                "layouts": self.layouts,
                "current_index": self.current_index,
            },
            self.layout_json_file,
        )

    def _on_file_changed(self, monitor, file, *args):
        # Small delay to ensure file write is complete
        GLib.timeout_add(50, self._reload_layout)
        return False

    def _reload_layout(self):
        new_layout = self._read_layout()
        if new_layout != self._last_layout:
            self._last_layout = new_layout
            self.emit("layout_changed", new_layout)
        return False

    def _read_layout(self) -> str:
        json_data = read_json_file(self.layout_json_file)
        if json_data:
            layouts = json_data.get("layouts", [])
            current_index = json_data.get("current_index", 0)
            return (
                layouts[current_index]
                if layouts and 0 <= current_index < len(layouts)
                else "us"
            )
        return "us"

    def _write_layout(self, layout: str) -> None:
        self.layout_file.parent.mkdir(parents=True, exist_ok=True)
        self.layout_file.write_text(layout, encoding="utf-8")

    def switch_to_next(self) -> bool:
        self.current_index = (self.current_index + 1) % len(self.layouts)
        new_layout = self.layouts[self.current_index]

        layouts_str = ",".join(self.layouts)
        run_command(
            [HYPRCTL_BIN, "keyword", "input:kb_layout", layouts_str],
            timeout=2,
        )

        time.sleep(0.1)

        run_command(
            [HYPRCTL_BIN, "switchxkblayout", "all", "next"],
            timeout=1,
        )

        self._save_layout_json()
        self._write_layout(new_layout)
        return True

    @Property(str, "readable")
    def current_layout(self) -> str:
        return self._read_layout()
