import { WINDOW_NAME } from "../Window.js";
import { WINDOW_NAME as WALLPAPER_PICKER_WINDOW } from "../../wallpaper_picker/Window.js";
import QsButton from "./qs_button.js";

export default () =>
  QsButton({
    icon: "emblem-photos-symbolic",
    label: "Wallpaper",
    on_clicked: () => {
      App.toggleWindow(WINDOW_NAME);
      App.toggleWindow(WALLPAPER_PICKER_WINDOW);
    },
  });
