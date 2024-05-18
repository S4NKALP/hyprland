// import { initTheme, initWallpaper, setWallpaper } from "./functions/theme.js";
import initWallpaper from "./functions/wallpaper.js";
import watchConfiguration from "./functions/monitor_configuration.js";
import initHyprland from "./functions/hyprland/init.js";
import initTheme from "./functions/theme/init.js";
import globals from "./functions/globals.js";
import { setupWindows } from "./windows.js";

export default function() {
  globals();
  setupWindows();
  initWallpaper();
  initTheme();
  initHyprland();
  watchConfiguration();
}
