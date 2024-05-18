import { configs, HOME } from "../vars.js";
import { sh } from "./utils.js";
import { generateColor } from "./theme/matugen.js";
import Gio from "gi://Gio";

export function cpWallpaper(filename) {
  const folder = configs.wallpaper.folder.value;
  const path = folder + "/" + filename;
  sh(`cp ${path} ${HOME}/.config/background`);
}

export function setWallpaper(path) {
  generateColor(path);
  sh([
    "swww",
    "img",
    "--transition-type",
    "any",
    "--transition-fps",
    "60",
    path,
  ]);
}

export default function initWallpaper() {
  Utils.monitorFile(`${HOME}/.config/background/`, (file, eventType) => {
    if (eventType === Gio.FileMonitorEvent.CHANGES_DONE_HINT) {
      setWallpaper(file.get_path());
    }
  });

  sh("swww-daemon --format xrgb");
}
