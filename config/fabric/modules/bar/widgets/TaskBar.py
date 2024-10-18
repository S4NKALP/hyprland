from __init__ import *


class PagerClient(TypedDict):
    title: str
    initialClass: str
    mapped: bool
    hidden: bool
    address: str


class TaskBar(Box):
    def __init__(self, icon_size: int = 16, **kwargs):
        super().__init__(orientation="h", spacing=6, **kwargs)
        self.connection = get_hyprland_connection()
        self.icon_size = icon_size
        self.icon_theme = Gtk.IconTheme.get_default()
        self.displayed_classes = set()

        self.set_visible(False)

        if self.connection.ready:
            self.render_with_delay()
        else:
            self.connection.connect("event::ready", lambda *_: self.render_with_delay())

        for event in (
            "activewindow",
            "openwindow",
            "closewindow",
            "changefloatingmode",
        ):
            self.connection.connect("event::" + event, lambda *_: self.render(None))

    def render_with_delay(self, *_):
        GLib.timeout_add(100, self.render)

    def render(self, *_):
        self.children = []
        self.displayed_classes.clear()

        clients = self.fetch_clients()

        visible_clients = [
            client for client in clients if client["mapped"] and not client["hidden"]
        ]

        if visible_clients:
            for client in visible_clients:
                window_class = client["initialClass"].lower()
                if window_class not in self.displayed_classes:
                    icon = self.bake_window_icon(window_class)

                    button = Button(image=icon, tooltip_text=client["title"])

                    button.connect(
                        "button-press-event", self.on_icon_click, client["address"]
                    )

                    self.add(button)
                    self.displayed_classes.add(window_class)

            self.set_visible(True)
            self.show_all()
        else:
            self.set_visible(False)

    def on_icon_click(self, widget, event, address):
        command = ["hyprctl", "dispatch", "focuswindow", f"address:{address}"]
        subprocess.run(command, check=True)

    def fetch_clients(self) -> list[PagerClient]:
        return json.loads(self.connection.send_command("j/clients").reply.decode())

    def bake_window_icon(
        self, window_class: str, fallback_icon: str = "image-missing"
    ) -> Image:
        # First, try to get the icon from the desktop entry
        icon_name = self.get_icon_from_desktop_entry(window_class)

        if icon_name:
            pixbuf = self.load_icon(icon_name)
        else:
            # Fallback to the icon theme if not found
            pixbuf = self.load_icon(window_class, fallback_icon)

        return Image(pixbuf=pixbuf, size=self.icon_size)

    def get_icon_from_desktop_entry(self, window_class: str) -> str:
        desktop_files = glob.glob("/usr/share/applications/*.desktop")
        for desktop_file in desktop_files:
            with open(desktop_file, "r") as f:
                for line in f:
                    if line.startswith("Name="):
                        app_name = line.split("=", 1)[1].strip().lower()
                        if window_class in app_name:
                            # If a matching app name is found, return the Icon
                            for line in f:
                                if line.startswith("Icon="):
                                    return line.split("=", 1)[1].strip()
        return None

    def load_icon(
        self, icon_name: str, fallback_icon: str = "image-missing"
    ) -> GdkPixbuf.Pixbuf:
        try:
            pixbuf = self.icon_theme.load_icon(
                icon_name,
                self.icon_size,
                Gtk.IconLookupFlags.FORCE_SIZE,
            )
        except Exception:
            pixbuf = self.icon_theme.load_icon(
                fallback_icon,
                self.icon_size,
                Gtk.IconLookupFlags.FORCE_SIZE,
            )
        return pixbuf
