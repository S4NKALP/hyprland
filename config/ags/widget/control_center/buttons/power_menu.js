import { WINDOW_NAME } from "../Window.js";
import { WINDOW_NAME as POWERMENU_WINDOW } from "../../powermenu/PowerMenuWindow.js";
import QsButton from "./qs_button.js";

export default () =>
  QsButton({
    icon: "system-shutdown-symbolic",
    label: "Powermenu",
    on_clicked: () => {
      App.toggleWindow(WINDOW_NAME);
      App.toggleWindow(POWERMENU_WINDOW);
    },
  });
