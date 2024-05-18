import { isVertical } from "../../functions/utils.js";
import { configs } from "../../vars.js";
import PanelButton from "../PanelButton.js";
import { WINDOW_NAME } from "./Window.js";
const battery = await Service.import("battery");

export default () =>
  PanelButton({
    window: WINDOW_NAME,
    on_clicked: () => {
      App.toggleWindow(WINDOW_NAME);
    },
    child: Widget.Box({
      class_name: "panel-battery",
      vertical: configs.theme.bar.position.bind().as(isVertical),
      setup: (self) => {
        self.hook(battery, () => {
          self.toggleClassName("charging", battery.charging);
        });
      },
      spacing: 4,
      children: [
        Widget.Icon({
          icon: battery.bind("icon_name"),
        }),
        Widget.Label({
          label: battery.bind("percent").as((p) => `${Math.round(p)}%`),
          visible: battery.bind("charging"),
        }),
      ],
    }),
  });
