import { isVertical } from "../../functions/utils.js";
import { clock, configs } from "../../vars.js";
import PanelButton from "../PanelButton.js";
import { WINDOW_NAME } from "./Window.js";

export default () =>
  PanelButton({
    window: WINDOW_NAME,
    // child: Widget.Label({ label: clock.bind().as((t) => t.format("%H:%M")) }),
    child: Widget.Box({
      vertical: configs.theme.bar.position.bind().as(isVertical),
      children: [
        Widget.Label({ label: clock.bind().as((t) => t.format("%I")) }),
        Widget.Label({
          label: ":",
          visible: configs.theme.bar.position
            .bind()
            .as((pos) => !isVertical(pos)),
        }),
        Widget.Label({ label: clock.bind().as((t) => t.format("%M")) }),
        Widget.Label({ label: " " }),
        Widget.Label({ label: clock.bind().as((t) => t.format("%p")) }),
      ],
    }),
    on_clicked: () => {
      App.toggleWindow(WINDOW_NAME);
    },
  });
