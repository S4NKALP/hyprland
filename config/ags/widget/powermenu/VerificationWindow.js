import powermenu from "../../services/powermenu.js";
import PopupWindow from "../PopupWindow.js";

const WINDOW_NAME = "verification__window";

const Container = () =>
  Widget.Box({
    class_names: ["verification__container", "window-content"],
    vertical: true,
    children: [
      Widget.Box({
        class_name: "text-box",
        vertical: true,
        children: [
          Widget.Label({
            class_name: "title",
            label: powermenu.bind("title"),
          }),
          Widget.Label({
            class_name: "desc",
            label: "Are you sure?",
          }),
        ],
      }),
      Widget.Box({
        class_name: "buttons",
        vexpand: true,
        vpack: "end",
        homogeneous: true,
        spacing: 6,
        children: [
          Widget.Button({
            child: Widget.Label("No"),
            on_clicked: () => App.toggleWindow(WINDOW_NAME),
            setup: (self) =>
              self.hook(App, (_, name, visible) => {
                if (name === WINDOW_NAME && visible) self.grab_focus();
              }),
          }),
          Widget.Button({
            child: Widget.Label("Yes"),
            on_clicked: () => Utils.exec(powermenu.cmd),
          }),
        ],
      }),
    ],
  });

export default () =>
  PopupWindow({
    name: WINDOW_NAME,
    exclusivity: "ignore",
    child: Container(),
  });
