import GLib from "gi://GLib";
import Conf from "./services/configuration.js";
import { cpWallpaper } from "./functions/wallpaper.js";
import { setTheme } from "./functions/theme/init.js";
import { setScssVariable } from "./functions/theme/ags.js";
import { sendBatch } from "./functions/utils.js";
import { setGapsOut } from "./functions/theme/hyprland.js";
import { isVertical } from "./functions/utils.js";
import setGtk from "./functions/theme/gtk.js";

export const HOME = Utils.HOME;

export const clock = Variable(GLib.DateTime.new_now_local(), {
  poll: [1000, () => GLib.DateTime.new_now_local()],
});

export const capsLockState = Variable(
  Utils.exec(`brightnessctl -d input3::capslock g`),
);

const divide = ([total, free]) => free / total;

export const cpu = Variable(0, {
  poll: [
    2000,
    "top -b -n 1",
    (out) =>
      divide([
        100,
        out
          .split("\n")
          .find((line) => line.includes("Cpu(s)"))
          .split(/\s+/)[1]
          .replace(",", "."),
      ]),
  ],
});

export const ram = Variable(0, {
  poll: [
    2000,
    "free",
    (out) =>
      divide(
        out
          .split("\n")
          .find((line) => line.includes("Mem:"))
          .split(/\s+/)
          .splice(1, 2),
      ),
  ],
});

export const configs = {
  wallpaper: {
    folder: Conf("wallpaper.folder", () => null, { home: HOME }),
    current: Conf("wallpaper.current", (self) => {
      cpWallpaper(self.value);
    }),
  },
  theme: {
    dark_mode: Conf("theme.dark_mode", setTheme),
    border_radius: Conf("theme.border_radius", (self) => {
      setScssVariable({
        key: "border_radius",
        value: self.value,
      });
      sendBatch([`decoration:rounding ${self.value.split(",")[0].trim()}`]);
    }),
    window: {
      margin: Conf("theme.window.margin", (self) => {
        setScssVariable({
          key: "window_margin",
          value: self.value,
        });
        setGapsOut();
      }),
      opacity: Conf("theme.window.opacity", (self) => {
        setScssVariable({
          key: "window_opacity",
          value: self.value,
          need_format: false,
        });
        setGtk();
      }),
      border: Conf("theme.window.border", (self) => {
        setScssVariable({
          key: "window_border",
          value: self.value,
          need_format: false,
        });
      }),
    },
    bar: {
      position: Conf("theme.bar.position", (self) => {
        sendBatch([
          ...App.windows.flatMap(
            (win) =>
              `layerrule animation ${win.animation === "slide top" ? `slide ${self.value}` : win.animation}, ${win.name}`,
          ),
          `animation workspaces,1,7,menu_decel,${isVertical(self.value) ? `slidevert` : "slide"}`,
        ]);
        setGapsOut();
        setScssVariable({ bar_pos: self.value });
      }),
      border: Conf("theme.bar.border", (self) => {
        setScssVariable({
          key: "bar_border",
          value: self.value,
          need_format: false,
        });
      }),
      opacity: Conf("theme.bar.opacity", (self) => {
        setScssVariable({
          key: "bar_opacity",
          value: self.value,
          need_format: false,
        });
      }),
      button_opacity: Conf("theme.bar.button_opacity", (self) => {
        setScssVariable({
          key: "bar_button_opacity",
          value: self.value,
          need_format: false,
        });
      }),
      shadow: Conf("theme.bar.shadow", (self) => {
        setScssVariable({
          key: "bar_shadow",
          value: self.value,
          need_format: false,
        });
      }),
      button_padding: Conf("theme.bar.button_padding", (self) => {
        setScssVariable({ key: "panel_button_padding", value: self.value });
      }),
      button_spacing: Conf("theme.bar.button_spacing"),
      button_shadow: Conf("theme.bar.button_shadow", (self) => {
        setScssVariable({
          key: "bar_button_shadow",
          value: self.value,
          need_format: false,
        });
      }),
      button_border_radius: Conf("theme.bar.button_border_radius", (self) => {
        setScssVariable({
          key: "bar_button_border_radius",
          value: self.value,
        });
      }),
      margin: Conf("theme.bar.margin", (self) => {
        setScssVariable({ key: "bar_margin", value: self.value });
      }),
      padding: Conf("theme.bar.padding", (self) => {
        setScssVariable({ key: "bar_padding", value: self.value });
      }),
      border_radius: Conf("theme.bar.border_radius", (self) => {
        setScssVariable({ key: "bar_border_radius", value: self.value });
      }),
      launcher_icon: Conf("theme.bar.launcher_icon"),
      workspace_active_width: Conf(
        "theme.bar.workspace_active_width",
        (self) => {
          setScssVariable({
            key: "workspace_active_width",
            value: self.value,
            need_format: true,
            four_values: false,
          });
        },
      ),
    },
  },
  osd: {
    regular: {
      position: Conf("osd.regular.position"),
      vertical: Conf("osd.regular.vertical"),
      margin: Conf("osd.regular.margin", (self) => {
        setScssVariable({ key: "osd_regular_margin", value: self.value });
      }),
      capslock: Conf("osd.regular.capslock"),
      mic: Conf("osd.regular.mic"),
    },
    progress: {
      position: Conf("osd.progress.position"),
      vertical: Conf("osd.progress.vertical"),
      margin: Conf("osd.progress.margin", (self) => {
        setScssVariable({ key: "osd_progress_margin", value: self.value });
      }),
      brightness: Conf("osd.progress.brightness"),
      volume: Conf("osd.progress.volume"),
    },
  },
  system_monitor: {
    position: Conf("system_monitor.position"),
    margin: Conf("system_monitor.margin", (self) => {
      setScssVariable("system_monitor_margin", self.value);
    }),
  },
};
