from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from fabric.widgets.label import Label
from snippets import MaterialIcon


class NotificationManager:
    def __init__(self, launcher):
        self.launcher = launcher
        self.notifications = []

        self.notification_button = self.create_notification_button()
        self.update_notification_button_style()

    def create_notification_button(self):
        button = Button(
            child=MaterialIcon("notifications"),
            h_align="center",
            v_align="center",
            on_clicked=self.show_notification_menu,
        )
        return button

    def add_notification(self, title, message, icon_name="notifications"):
        """Add a new notification."""
        notification = {
            "title": title,
            "message": message,
            "icon_name": icon_name,
        }
        self.notifications.append(notification)
        self.update_notification_button_style()

    def remove_notification(self, index):
        """Remove a notification by index."""
        if 0 <= index < len(self.notifications):
            del self.notifications[index]
        self.update_notification_button_style()

    def clear_notifications(self):
        """Clear all notifications."""
        self.notifications.clear()
        self.update_notification_button_style()

    def update_notification_button_style(self):
        """Update the notification button style based on the notification count."""
        count = len(self.notifications)
        if count > 0:
            style = "background-color: @surfaceVariant; border-radius: 50%;"
            self.notification_button.set_style(style)
            self.notification_button.set_label(str(count))
        else:
            style = "background-color: transparent;"
            self.notification_button.set_style(style)
            self.notification_button.set_label("")

    def show_notification_menu(self, *_):
        """Display the notification menu."""
        viewport = self.launcher.viewport
        viewport.children = []
        notifications_box = Box(orientation="v", spacing=5)

        for index, notification in enumerate(self.notifications):
            notification_button = self.create_notification_button_item(
                notification, index
            )
            notifications_box.add(notification_button)

        viewport.add(notifications_box)

    def create_notification_button_item(self, notification, index):
        """Create a button for an individual notification."""
        return Button(
            child=Box(
                orientation="h",
                spacing=10,
                children=[
                    Image(icon_name=notification["icon_name"], size=32),
                    Box(
                        orientation="v",
                        spacing=2,
                        children=[
                            Label(label=notification["title"], bold=True),
                            Label(label=notification["message"]),
                        ],
                    ),
                ],
            ),
            on_clicked=lambda _, idx=index: self.remove_notification(idx),
            name="notification-item",
        )

    def get_notification_button(self):
        """Get the notification button for the UI."""
        return self.notification_button
