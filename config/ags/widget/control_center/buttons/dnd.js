import QsButton from "./qs_button.js";
const notifications = await Service.import("notifications");

export default () =>
  QsButton({
    icon: notifications
      .bind("dnd")
      .as((dnd) => `notifications-${dnd ? "disabled-" : ""}symbolic`),
    label: "DND",
    setup: (self) => {
      self.hook(notifications, () => {
        self.toggleClassName("active", notifications.dnd);
      });
    },
    on_clicked: () => (notifications.dnd = !notifications.dnd),
  });
