import operator
from collections.abc import Iterator

from fabric.utils import DesktopApp, get_desktop_applications, idle_add, remove_handler
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.entry import Entry
from fabric.widgets.label import Label
from fabric.widgets.scrolledwindow import ScrolledWindow
from gi.repository import Gdk, GLib
from snippets import MaterialIcon


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

        self.viewport = Box(name="viewport", spacing=4, orientation="v")
        self.search_entry = Entry(
            name="search-entry",
            placeholder="Search Applications...",
            h_expand=True,
            notify_text=lambda entry, *_: self.handle_search_input(entry.get_text()),
            on_activate=lambda entry, *_: self.on_search_entry_activate(
                entry.get_text()
            ),
            on_button_press_event=print,
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
            spacing=10,
            orientation="h",
            children=[
                self.search_entry,
                Button(
                    name="close-button",
                    child=MaterialIcon("close"),
                    tooltip_text="Exit",
                    on_clicked=lambda *_: self.close_launcher(),
                ),
            ],
        )

        self.launcher_box = Box(
            name="launcher-box",
            spacing=10,
            h_expand=True,
            orientation="v",
            children=[
                self.header_box,
                self.scrolled_window,
            ],
        )

        self.add(self.launcher_box)
        self.connect("key-press-event", self.on_key_press_event)
        self.show_all()

    def close_launcher(self):
        self.viewport.children = []
        GLib.spawn_command_line_async("fabric-cli exec quickbar 'launcher.close()'")

    def open_launcher(self):
        self._all_apps = get_desktop_applications()
        self.arrange_viewport()

    def on_key_press_event(self, widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.close_launcher()

    def arrange_viewport(self, query: str = ""):
        remove_handler(self._arranger_handler) if self._arranger_handler else None
        self.viewport.children = []

        if not query.strip():
            return False

        filtered_apps = sorted(
            [
                app
                for app in self._all_apps
                if query.casefold()
                in (
                    (app.display_name or "")
                    + (" " + app.name + " ")
                    + (app.generic_name or "")
                ).casefold()
            ],
            key=lambda app: (app.display_name or "").casefold(),
        )

        filtered_apps = filtered_apps[:6]

        self._arranger_handler = idle_add(
            lambda *args: self.add_next_application(*args),
            iter(filtered_apps),
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
            name="app-slot-button",
            child=Box(
                name="app-slot-box",
                orientation="h",
                spacing=10,
                children=[
                    Label(
                        name="app-label",
                        label=app.display_name or "Unknown",
                        ellipsization="end",
                        v_align="center",
                        h_align="center",
                    ),
                ],
            ),
            tooltip_text=app.description,
            on_clicked=lambda *_: (app.launch(), self.close_launcher()),
            **kwargs,
        )

    def handle_search_input(self, text: str):
        if text.strip() == ":wp":
            GLib.spawn_command_line_async(
                "fabric-cli exec quickbar 'launcher.open(\"wallpapers\")'"
            )
            self.search_entry.set_text("")
        elif text.strip() == ":em":
            GLib.spawn_command_line_async(
                "fabric-cli exec quickbar 'launcher.open(\"emoji\")'"
            )
        elif text.strip() == ":ch":
            GLib.spawn_command_line_async(
                "fabric-cli exec quickbar 'launcher.open(\"cliphist\")'"
            )
        elif text.strip() == ":td":
            GLib.spawn_command_line_async(
                "fabric-cli exec quickbar 'launcher.open(\"todo\")'"
            )

        else:
            self.arrange_viewport(text)
