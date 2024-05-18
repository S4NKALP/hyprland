import setAgs from "./ags.js";
import setHyprland from "./hyprland.js";
import setGtk from "./gtk.js";
import Gio from "gi://Gio";
import { applyCss, sh } from "../utils.js";
import { configs } from "../../vars.js";

export function setTheme() {
  let colors = Utils.readFile(App.configDir + "/colors.json");

  if (colors === "") {
    sh(`matugen color hex "#282828" --json hex`).then((out) => {
      colors = out;
      Utils.writeFile(
        JSON.stringify(JSON.parse(out), null, 2),
        App.configDir + "/colors.json",
      ).catch(print);
    });
  }
  const themeJson = JSON.parse(colors || "{}");
  const themeMode = configs.theme.dark_mode.value ? "dark" : "light";
  const theme = themeJson["colors"][themeMode];
  const harmonizedColors = themeJson.harmonized_colors;

  setAgs(theme);
  setHyprland(theme);
  setGtk(theme, themeMode);
}

function monitorTheme() {
  Utils.monitorFile(App.configDir + "/colors.json", (_, eventType) => {
    if (eventType === Gio.FileMonitorEvent.CHANGES_DONE_HINT) {
      setTheme();
    }
  });
  Utils.monitorFile(App.configDir + "/style/", applyCss);
}

export default function initTheme() {
  monitorTheme();
  setTheme();
}
