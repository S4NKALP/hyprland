import {
  FolderChooserWindow,
  WallpaperPickerWindow,
} from "./widget/wallpaper_picker/Window.js";
import AppLauncherWindow from "./widget/applauncher/Window.js";
import HyprsplashWindow from "./widget/hyprsplash/Window.js";
import NotificationPopupWindow from "./widget/notifications/PopupWindow.js";
import VerificationWindow from "./widget/powermenu/VerificationWindow.js";
import PowerMenuWindow from "./widget/powermenu/PowerMenuWindow.js";
import SystemMonitorWindow from "./widget/system_monitor/Window.js";
import ProgressOsd from "./widget/osd/ProgressOsd.js";
import RegularOsd from "./widget/osd/RegularOsd.js";
import SetupDatemenuWindow from "./widget/datemenu/Window.js";
import SetupAudioWindow from "./widget/audio/Window.js";
import SetupNetworkWindow from "./widget/network/Window.js";
import SetupBatteryWindow from "./widget/battery/Window.js";
import SetupControlCenterWindow from "./widget/control_center/Window.js";
import SetupBarWindow from "./widget/bar/Window.js";
import Tray from "./widget/tray/tray.js";

App.addIcons(`${App.configDir}/assets`);

export function setupWindows() {
  SetupDatemenuWindow();
  SetupAudioWindow();
  SetupNetworkWindow();
  SetupBatteryWindow();
  SetupControlCenterWindow();
  SetupBarWindow();
  Tray();
}

export default [
  WallpaperPickerWindow(),
  FolderChooserWindow(),
  AppLauncherWindow(),
  NotificationPopupWindow(),
  PowerMenuWindow(),
  VerificationWindow(),
  //HyprsplashWindow(),
  SystemMonitorWindow(),
  ProgressOsd(),
  RegularOsd(),
];
