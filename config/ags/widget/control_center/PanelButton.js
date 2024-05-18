import PanelButton from "../PanelButton.js";
import { WINDOW_NAME } from "./Window.js";
const notifications = await Service.import("notifications");

const NotificationIcon = () =>
  Widget.Icon({
    class_name: "panel-control-center",
    setup: (self) => {
      self.hook(notifications, () => {
        self.toggleClassName("empty", notifications.notifications.length == 0);
        self.icon = notifications.dnd
          ? "notifications-disabled-symbolic"
          : "notifications-symbolic";
      });
    },
  });

export default () =>
  PanelButton({
    window: WINDOW_NAME,
    child: NotificationIcon(),
    on_clicked: () => {
      App.toggleWindow(WINDOW_NAME);
    },
  });
