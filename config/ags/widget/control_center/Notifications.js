import Notification from "../notifications/notifications.js";

const notifications = await Service.import("notifications");
const notifs = notifications.bind("notifications");

const Animated = (n) =>
  Widget.Revealer({
    transition_duration: 200,
    transition: "slide_left",
    child: Notification(n),
    setup: (self) =>
      Utils.timeout(200, () => {
        if (!self.is_destroyed) self.reveal_child = true;
      }),
  });

const ClearButton = () =>
  Widget.Button({
    onClicked: () => notifications.clear(),
    child: Widget.Icon({
      icon: notifications
        .bind("notifications")
        .as((n) => `user-trash-${n.length > 0 ? "full-" : ""}symbolic`),
    }),
  });

const Header = () =>
  Widget.Box({
    class_name: "header",
    children: [
      Widget.Label({ label: "Notifications", xalign: 0, hexpand: true }),
      ClearButton(),
    ],
  });

const NotificationList = () => {
  const map = new Map();
  const box = Widget.Box({
    vertical: true,
    children: notifications.notifications.map((n) => {
      const w = Animated(n);
      map.set(n.id, w);
      return w;
    }),
    visible: notifs.as((n) => n.length > 0),
  });

  function remove(_, id) {
    const n = map.get(id);
    if (n) {
      n.reveal_child = false;
      Utils.timeout(200, () => {
        n.destroy();
        map.delete(id);
      });
    }
  }

  return box.hook(notifications, remove, "closed").hook(
    notifications,
    (_, id) => {
      if (id !== undefined) {
        if (map.has(id)) remove(null, id);

        const n = notifications.getNotification(id);

        const w = Animated(n);
        map.set(id, w);
        box.children = [w, ...box.children];
      }
    },
    "notified",
  );
};

const Placeholder = () =>
  Widget.Box({
    class_name: "placeholder",
    vertical: true,
    vpack: "center",
    hpack: "center",
    vexpand: true,
    hexpand: true,
    visible: notifs.as((n) => n.length === 0),
    children: [
      Widget.Icon("notifications-disabled-symbolic"),
      Widget.Label("Your inbox is empty"),
    ],
  });

export default ({ width = 250, height = 100 }) =>
  Widget.Box({
    class_name: "notifications__container",
    css: `min-width: ${width}px; min-height: ${height}px;`,
    vertical: true,
    children: [
      Header(),
      Widget.Scrollable({
        vexpand: true,
        hscroll: "never",
        class_name: "notification-scrollable",
        child: Widget.Box({
          class_name: "notification-list vertical",
          vertical: true,
          children: [NotificationList(), Placeholder()],
        }),
      }),
    ],
  });
