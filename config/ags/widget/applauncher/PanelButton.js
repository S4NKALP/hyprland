import PanelButton from "../PanelButton.js";
import { WINDOW_NAME } from "./Window.js";
import { configs } from "../../vars.js";

export default () =>
  PanelButton({
    window: WINDOW_NAME,
    on_clicked: () => {
      App.toggleWindow(WINDOW_NAME);
    },
    child: configs.theme.bar.launcher_icon.bind().as((icon) => {
      const isGtkIcon = Utils.lookUpIcon(icon);

      if (isGtkIcon) {
        return Widget.Icon({
          icon: icon,
          hpack: "center",
          xalign: 0,
        });
      } else {
        return Widget.Label({
          label: icon,
          hpack: "center",
          xalign: 0,
        });
      }
    }),
  });
