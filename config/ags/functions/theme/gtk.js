import { HOME, configs } from "../../vars.js";
import Gio from "gi://Gio";

const settings = new Gio.Settings({
  schema: "org.gnome.desktop.interface",
});

function setGtkSetting(themeScheme) {
  settings.reset("color-scheme");
  settings.set_string("color-scheme", `prefer-${themeScheme}`);
  settings.set_string(
    "gtk-theme",
    `adw-gtk3${themeScheme == "dark" ? "-dark" : ""}`,
  );
}

export default async function setGtk(theme, themeScheme) {
  if (themeScheme === undefined) {
    themeScheme = configs.theme.dark_mode.value ? "dark" : "light";
  }

  if (theme === undefined) {
    theme = JSON.parse(Utils.readFile(App.configDir + "/colors.json") || "{}")
      .colors[themeScheme];
  }

  const primaryColor = theme.primary;
  const bgColor = theme.background;
  const gtkCss = [
    `accent_bg_color ${primaryColor};`,
    `view_bg_color alpha(${bgColor}, ${configs.theme.window.opacity.value});`,
    `sidebar_bg_color alpha(${bgColor}, ${configs.theme.window.opacity.value});`,
    `headerbar_bg_color ${bgColor};`,
    `popover_bg_color alpha(${bgColor}, ${configs.theme.window.opacity.value});`,
  ];
  Utils.writeFile(
    gtkCss
      .map((vars) => {
        return "@define-color " + vars;
      })
      .join(`\n`),
    HOME + "/.themes/colors.css",
  ).then(() => {
    setGtkSetting(themeScheme);
  });
}
