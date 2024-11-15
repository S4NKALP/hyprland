from typing import cast

import gi

gi.require_version("GdkPixbuf", "2.0")
from gi.repository import GdkPixbuf
from loguru import logger

from fabric import Application
from fabric.notifications import (
    Notification,
    NotificationAction,
    NotificationCloseReason,
    Notifications,
)
from fabric.utils import get_relative_path, invoke_repeater
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from fabric.widgets.label import Label
from fabric.widgets.revealer import Revealer
from fabric.widgets.wayland import WaylandWindow

NOTIFICATION_WIDTH = 400
NOTIFICATION_IMAGE_SIZE = 64
NOTIFICATION_TIMEOUT = 5 * 1000  # 10 seconds


class ActionButton(Button):
    def __init__(
        self, action: NotificationAction, action_number: int, total_actions: int
    ):
        self.action = action
        super().__init__(
            label=action.label,
            h_expand=True,
            on_clicked=self.on_clicked,
        )
        if action_number == 0:
            self.add_style_class("start-action")
        elif action_number == total_actions - 1:
            self.add_style_class("end-action")
        else:
            self.add_style_class("middle-action")

    def on_clicked(self, *_):
        self.action.invoke()
        self.action.parent.close("dismissed-by-user")


class NotificationWidget(Box):
    def __init__(self, notification: Notification, **kwargs):
        super().__init__(
            size=(NOTIFICATION_WIDTH, -1),
            name="notification",
            spacing=8,
            orientation="v",
            **kwargs,
        )

        self._notification = notification

        body_container = Box(spacing=4, orientation="h")

        # Use provided image if available, otherwise use "notification-symbolic" icon
        image = (
            Image(
                pixbuf=self._notification.image_pixbuf.scale_simple(
                    NOTIFICATION_IMAGE_SIZE,
                    NOTIFICATION_IMAGE_SIZE,
                    GdkPixbuf.InterpType.BILINEAR,
                ),
                style="border-radius:100px;",
            )
            if self._notification.image_pixbuf
            else Image(
                icon_name="notification-symbolic",
                icon_size=40,
                style="border-radius:100px;",
            )
        )
        body_container.add(image)

        body_container.add(
            Box(
                spacing=4,
                orientation="v",
                children=[
                    Box(
                        orientation="h",
                        children=[
                            Label(
                                label=self._notification.summary,
                                ellipsization="middle",
                            )
                            .build()
                            .add_style_class("summary")
                            .unwrap(),
                        ],
                        h_expand=True,
                        v_expand=True,
                    ).build(
                        lambda box, _: box.pack_end(
                            Button(
                                image=Image(
                                    icon_name="window-close-symbolic",
                                    icon_size=18,
                                ),
                                v_align="center",
                                h_align="end",
                                on_clicked=lambda *_: self._notification.close(),
                            ),
                            False,
                            False,
                            0,
                        )
                    ),
                    Label(
                        label=self._notification.body,
                        line_wrap="word-char",
                        v_align="start",
                        max_chars_width=40,
                        h_align="start",
                    )
                    .build()
                    .add_style_class("body")
                    .unwrap(),
                ],
                h_expand=True,
                v_expand=True,
            )
        )

        self.add(body_container)

        self.add(
            Box(
                spacing=4,
                orientation="h",
                name="notification_action_button",
                children=[
                    ActionButton(action, i, len(self._notification.actions))
                    for i, action in enumerate(self._notification.actions)
                ],
                h_expand=True,
            )
        )

        # Destroy this widget once the notification is closed
        self._notification.connect(
            "closed",
            lambda *_: (
                parent.remove(self) if (parent := self.get_parent()) else None,  # type: ignore
                self.destroy(),
            ),
            invoke_repeater(
                NOTIFICATION_TIMEOUT,
                lambda: self._notification.close("expired"),
                initial_call=False,
            ),
        )


class NotificationRevealer(Revealer):
    def __init__(self, notification: Notification, **kwargs):
        self.not_box = NotificationWidget(notification)
        self._notification = notification
        super().__init__(
            child=Box(
                style="margin: 12px;",
                children=[self.not_box],
            ),
            transition_duration=500,
            transition_type="crossfade",
        )

        self.connect(
            "notify::child-revealed",
            lambda *args: self.destroy() if not self.get_child_revealed() else None,
        )

        self._notification.connect("closed", self.on_resolved)

    def on_resolved(
        self, notification: Notification, closed_reason: NotificationCloseReason
    ):
        logger.info(
            f"Notification {notification.id} resolved with reason: {closed_reason}"
        )
        self.set_reveal_child(False)


class NotificationPopup(WaylandWindow):
    def __init__(self):
        self._server = Notifications()
        self.notifications = Box(
            v_expand=True,
            h_expand=True,
            style="margin: 1px 0px 1px 1px;",
            orientation="v",
            spacing=5,
        )
        self._server.connect("notification-added", self.on_new_notification)

        super().__init__(
            anchor="bottom",
            child=self.notifications,
            layer="overlay",
            all_visible=True,
            visible=True,
            exclusive=False,
        )

    def on_new_notification(self, fabric_notif, id):
        new_box = NotificationRevealer(fabric_notif.get_notification_from_id(id))
        self.notifications.add(new_box)
        new_box.set_reveal_child(True)
