import powermenu from "../../services/powermenu.js";
import PopupWindow from "../PopupWindow.js";

export const WINDOW_NAME = "powermenu__window";

const icons = {
  lock: "system-lock-screen-symbolic",
  sleep: "weather-clear-night-symbolic",
  reboot: "system-reboot-symbolic",
  logout: "system-log-out-symbolic",
  shutdown: "system-shutdown-symbolic",
};

const SysButton = (action, label) =>
  Widget.Button({
    on_clicked: () => powermenu.action(action),
    child: Widget.Box({
      vertical: true,
      class_name: "system-button",
      children: [
        Widget.Icon(icons[action]),
        Widget.Label({
          label,
        }),
      ],
    }),
  });

const Container = () =>
  Widget.Box({
    class_names: ["powermenu__container", "window-content"],
    spacing: 6,
    homogeneous: true,
    children: [
      SysButton("lock", "Lock"),
      SysButton("sleep", "Sleep"),
      SysButton("logout", "Log Out"),
      SysButton("reboot", "Reboot"),
      SysButton("shutdown", "Shutdown"),
    ],
  });

export default () =>
  PopupWindow({
    name: WINDOW_NAME,
    exclusivity: "ignore",
    child: Container(),
  });
