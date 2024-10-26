import gi
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.image import Image

from .icon_resolver import IconResolver

gi.require_version("Glace", "0.1")
from gi.repository import Glace


class OpenAppsBar(Box):
    def __init__(self):
        self.client_buttons = {}
        super().__init__(spacing=10)
        self.icon_resolver = IconResolver()
        self._manager = Glace.Manager()
        self._manager.connect("client-added", self.on_client_added)

    def on_active_window(self, _, event):
        print(event.data)
        print(self.client_buttons)
        # client_buttons[]

    def on_client_added(self, _, client: Glace.Client):
        client_image = Image()
        client_button = Button(
            name="panel-button",
            image=client_image,
            on_button_press_event=lambda *_: client.activate(),
        )
        self.client_buttons[client.get_id()] = client_button

        client.connect(
            "notify::app-id",
            lambda *_: [
                client_image.set_from_pixbuf(
                    self.icon_resolver.get_icon_pixbuf(client.get_app_id(), 24)
                ),
                print(client.get_id()),
            ],
        )

        client.connect(
            "notify::activated",
            lambda *_: (
                client_button.add_style_class("activated")
                if client.get_activated()
                else client_button.remove_style_class("activated")
            ),
        )
        client.bind_property("title", client_button, "tooltip-text", 0)
        client.connect("close", lambda *_: self.remove(client_button))
        self.add(client_button)
