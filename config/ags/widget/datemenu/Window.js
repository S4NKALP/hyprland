import { layoutPos } from "../../functions/utils.js";
import { clock, configs } from "../../vars.js";
import PopupWindow from "../PopupWindow.js";

export const WINDOW_NAME = "datemenu__window";

const { bar } = configs.theme;

const Container = () =>
  Widget.Box({
    vertical: true,
    class_names: ["datemenu__container", "window-content"],
    children: [
      Widget.Label({
        label: clock.bind().as((t) => t.format("%I:%M %p")),
        class_name: "clock",
      }),
      Widget.Label({
        label: clock.bind().as((dt) => dt.format("%d/%m/%Y")),
        class_name: "date",
      }),
      Widget.Calendar(),
    ],
  });

const DateMenuWindow = () =>
  PopupWindow({
    name: WINDOW_NAME,
    layout: layoutPos(bar.position.value, "top-left"),
    animation: "slide top",
    child: Container(),
  });

export default function() {
  App.addWindow(DateMenuWindow());

  bar.position.connect("changed", () => {
    App.removeWindow(WINDOW_NAME);
    App.addWindow(DateMenuWindow());
  });
}
