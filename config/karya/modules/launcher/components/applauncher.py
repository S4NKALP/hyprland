from collections.abc import Iterator
import operator
from fabric.utils import DesktopApp, get_desktop_applications, idle_add, remove_handler
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.entry import Entry
from fabric.widgets.label import Label
from fabric.widgets.scrolledwindow import ScrolledWindow
from gi.repository import GLib
from snippets import MaterialIcon, read_config
from fabric.widgets.image import Image


class AppLauncher(Box):
    def __init__(self, **kwargs):
        super().__init__(
            name="app-launcher",
            visible=False,
            all_visible=False,
            **kwargs,
        )
        self._arranger_handler: int = 0
        self._all_apps = get_desktop_applications()
        self.config = read_config()

        self.viewport = Box(name="viewport", spacing=4, orientation="v")
        self.search_entry = Entry(
            name="search-entry",
            h_expand=True,
            notify_text=self.handle_search_input,
            on_activate=lambda entry, *_: self.on_search_entry_activate(
                entry.get_text()
            ),
        )
        self.scrolled_window = ScrolledWindow(
            name="scrolled-window",
            spacing=10,
            h_scrollbar_policy="never",
            v_scrollbar_policy="never",
            child=self.viewport,
        )

        self.header_box = Box(
            name="header_box",
            orientation="h",
            children=[self.search_entry],
        )

        self.launcher_box = Box(
            name="launcher-box",
            h_expand=True,
            orientation="v",
            children=[
                self.header_box,
                self.scrolled_window,
            ],
        )

        self.resize_viewport()
        self.add(self.launcher_box)
        self.show_all()

    def open_launcher(self):
        self.viewport.children = []
        self._all_apps = get_desktop_applications()
        self.arrange_viewport()
        self.search_entry.grab_focus()

    def close_launcher(self, *_):
        remove_handler(self._arranger_handler) if self._arranger_handler else None
        self.viewport.children = []
        GLib.spawn_command_line_async("fabric-cli exec karya 'launcher.close()'")

    def handle_search_input(self, entry, *_):
        text = entry.get_text().strip()
        commands = self.config.get("commands", {})

        if text in commands:
            command = commands[text]
            GLib.spawn_command_line_async(f"fabric-cli exec karya '{command}'")
            self.search_entry.set_text("")
        else:
            self.arrange_viewport(text)

    def resize_viewport(self):
        self.scrolled_window.set_min_content_width(
            self.viewport.get_allocation().width  # type: ignore
        )
        return False

    def arrange_viewport(self, query: str = ""):
        remove_handler(self._arranger_handler) if self._arranger_handler else None
        self.viewport.children = []

        if not query.strip():
            return False

        filtered_apps = iter(
            [
                app
                for app in self._all_apps
                if query.casefold()
                in (
                    (app.display_name or "")
                    + (" " + app.name + " ")
                    + (app.generic_name or "")
                ).casefold()
            ][:6]
        )
        should_resize = operator.length_hint(filtered_apps) == len(self._all_apps)

        self._arranger_handler = idle_add(
            lambda *args: self.add_next_application(*args)
            or (self.resize_viewport() if should_resize else False),
            filtered_apps,
            pin=True,
        )

        return False

    def add_next_application(self, apps_iter: Iterator[DesktopApp]):
        if not (app := next(apps_iter, None)):
            return False

        self.viewport.add(self.bake_application_slot(app))
        return True

    def bake_application_slot(self, app: DesktopApp, **kwargs) -> Button:
        return Button(
            name="launcher-app",
            child=Box(
                orientation="h",
                children=[
                    Image(
                        pixbuf=app.get_icon_pixbuf(size=32),
                        h_align="start",
                        name="launcher-app-icon",
                    ),
                    Label(
                        label=app.display_name or "Unknown",
                        v_align="center",
                        h_align="center",
                    ),
                    Box(h_expand=True),
                ],
            ),
            tooltip_text=app.description,
            on_clicked=lambda *_: (app.launch(), self.close_launcher()),
            **kwargs,
        )
