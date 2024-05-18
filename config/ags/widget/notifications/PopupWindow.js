import Notification from "./notifications.js";
// import { configs } from "../../vars.js";

const notifications = await Service.import("notifications");
const transition = 900;
const { timeout, idle } = Utils;

function Animated(id) {
  const n = notifications.getNotification(id);
  const widget = Notification(n);

  const inner = Widget.Revealer({
    transition: "slide_left",
    transition_duration: transition,
    child: widget,
  });

  const outer = Widget.Revealer({
    transition: "slide_down",
    transition_duration: transition,
    child: inner,
  });

  const box = Widget.Box({
    hpack: "end",
    child: outer,
  });

  idle(() => {
    outer.reveal_child = true;
    timeout(transition, () => {
      inner.reveal_child = true;
    });
  });

  return Object.assign(box, {
    dismiss() {
      inner.reveal_child = false;
      timeout(transition, () => {
        outer.reveal_child = false;
        timeout(transition, () => {
          box.destroy();
        });
      });
    },
  });
}

function PopupList() {
  const map = new Map();
  const box = Widget.Box({
    hpack: "end",
    vertical: true,
    spacing: 8,
    css: `min-width: 350px;`,
  });

  function remove(_, id) {
    map.get(id)?.dismiss();
    map.delete(id);
  }

  return box
    .hook(
      notifications,
      (_, id) => {
        if (id !== undefined) {
          if (map.has(id)) remove(null, id);

          if (notifications.dnd) return;

          const w = Animated(id);
          map.set(id, w);
          box.children = [w, ...box.children];
        }
      },
      "notified",
    )
    .hook(notifications, remove, "dismissed")
    .hook(notifications, remove, "closed");
}

export default (monitor = "") => {
  const win = Widget.Window({
    monitor,
    name: `notifications${monitor}`,
    anchor: ["bottom", "right"],
    class_name: "notifications",
    child: Widget.Box({
      css: "padding: 0.1px;",
      child: PopupList(),
    }),
  });

  Object.assign(win, {
    //disable?
    animation: "0",
  });
  return win;
};
