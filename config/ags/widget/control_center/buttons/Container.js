import Dnd from "./dnd.js";
import Wallpaper from "./wallpaper.js";
import DarkMode from "./dark_mode.js";
import Screenshot from "./screenshot.js";
import ScreenRecord from "./screen_record.js";
import ColorPicker from "./color_picker.js";
import MicAccess from "./mic_access.js";
import PowerMenu from "./power_menu.js";

export default () =>
  Widget.Box({
    vertical: true,
    spacing: 8,
    class_name: "qs-buttons",
    homogeneous: true,
    children: [
      Widget.Box({
        spacing: 8,
        homogeneous: true,
        children: [Dnd(), Wallpaper(), DarkMode(), Screenshot()],
      }),
      Widget.Box({
        spacing: 8,
        homogeneous: true,
        children: [ScreenRecord(), ColorPicker(), MicAccess(), PowerMenu()],
      }),
    ],
  });
