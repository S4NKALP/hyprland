import { configPath } from "../services/configuration.js";
import { HOME, configs } from "../vars.js";
import { replacePlaceholders as rep } from "./utils.js";
import Gio from "gi://Gio";

//sorry (?)

export default function() {
  const wallpaper = configs.wallpaper;
  const theme = configs.theme;
  const bar = theme.bar;
  const osd = configs.osd;
  const sysmonitor = configs.system_monitor;
  const window = theme.window;

  Utils.monitorFile(configPath, (file, type) => {
    // Monitor non Utils.writeFile event
    if (type === Gio.FileMonitorEvent.ATTRIBUTE_CHANGED) {
      const configJson = JSON.parse(Utils.readFile(file.get_path()) || "{}");
      const wallpaperJson = configJson.wallpaper;
      const themeJson = configJson.theme;
      const windowJson = themeJson.window;
      const barJson = themeJson.bar;
      const osdJson = configJson.osd;
      const sysmonitorJson = configJson.system_monitor;

      if (wallpaper.folder.value != rep(wallpaperJson.folder, { home: HOME }))
        wallpaper.folder.setValue(rep(wallpaperJson.folder, { home: HOME }));

      if (wallpaper.current.value != wallpaperJson.current)
        wallpaper.current.setValue(wallpaperJson.current);

      if (theme.dark_mode.value != themeJson.dark_mode)
        theme.dark_mode.setValue(themeJson.dark_mode);

      if (window.margin.value != windowJson.margin)
        window.margin.setValue(windowJson.margin);

      if (window.opacity.value != windowJson.opacity)
        window.opacity.setValue(windowJson.opacity);

      if (window.border.value != windowJson.border)
        window.border.setValue(windowJson.border);

      if (theme.border_radius.value != themeJson.border_radius)
        theme.border_radius.setValue(themeJson.border_radius);

      if (bar.position.value != barJson.position)
        bar.position.setValue(barJson.position);

      if (bar.border.value != barJson.border)
        bar.border.setValue(barJson.border);

      if (bar.opacity.value != barJson.opacity)
        bar.opacity.setValue(barJson.opacity);

      if (bar.button_opacity.value != barJson.button_opacity)
        bar.button_opacity.setValue(barJson.button_opacity);

      if (bar.shadow.value != barJson.shadow)
        bar.shadow.setValue(barJson.shadow);

      if (bar.button_padding.value != barJson.button_padding)
        bar.button_padding.setValue(barJson.button_padding);

      if (bar.button_spacing.value != barJson.button_spacing)
        bar.button_spacing.setValue(barJson.button_spacing);

      if (bar.button_shadow.value != barJson.button_shadow)
        bar.button_shadow.setValue(barJson.button_shadow);

      if (bar.button_border_radius.value != barJson.button_border_radius)
        bar.button_border_radius.setValue(barJson.button_border_radius);

      if (bar.margin.value != barJson.margin)
        bar.margin.setValue(barJson.margin);

      if (bar.padding.value != barJson.padding)
        bar.padding.setValue(barJson.padding);

      if (bar.border_radius.value != barJson.border_radius)
        bar.border_radius.setValue(barJson.border_radius);

      if (bar.launcher_icon.value != barJson.launcher_icon)
        bar.launcher_icon.setValue(barJson.launcher_icon);

      if (bar.workspace_active_width.value != barJson.workspace_active_width)
        bar.workspace_active_width.setValue(barJson.workspace_active_width);

      if (osd.progress.position.value != osdJson.progress.position)
        osd.progress.position.setValue(osdJson.progress.position);

      if (osd.regular.position.value != osdJson.regular.position)
        osd.regular.position.setValue(osdJson.regular.position);

      if (osd.progress.vertical.value != osdJson.progress.vertical)
        osd.progress.vertical.setValue(osdJson.progress.vertical);

      if (osd.regular.vertical.value != osdJson.regular.vertical)
        osd.regular.vertical.setValue(osdJson.regular.vertical);

      if (osd.regular.margin.value != osdJson.regular.margin)
        osd.regular.margin.setValue(osdJson.regular.margin);

      if (osd.progress.margin.value != osdJson.progress.margin)
        osd.progress.margin.setValue(osdJson.progress.margin);

      if (osd.regular.capslock.value != osdJson.regular.capslock)
        osd.regular.capslock.setValue(osdJson.regular.capslock);

      if (osd.regular.mic.value != osdJson.regular.mic)
        osd.regular.mic.setValue(osdJson.regular.mic);

      if (osd.progress.brightness.value != osdJson.progress.brightness)
        osd.progress.brightness.setValue(osdJson.progress.brightness);

      if (osd.progress.volume.value != osdJson.progress.volume)
        osd.progress.volume.setValue(osdJson.progress.volume);

      if (sysmonitor.position.value != sysmonitorJson.position)
        sysmonitor.position.setValue(sysmonitorJson.position);

      if (sysmonitor.margin.value != sysmonitorJson.margin)
        sysmonitor.margin.setValue(sysmonitorJson.margin);
    }
  });
}
