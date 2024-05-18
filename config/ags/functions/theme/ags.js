import { isVertical, matugenStringify, posIndex } from "../utils.js";
import { configs } from "../../vars.js";

export const format = (str, four_values = true, px = true) => {
  let splitted = str
    .split(",")
    .map((item) => `${item}${px ? `px` : ""}`.trim());

  let result = splitted.join(" ");
  if (four_values) {
    switch (splitted.length) {
      case 1:
        result = `${splitted[0]} `.repeat(4);
        break;
      case 2:
        result = `${splitted[0]} ${splitted[1]} ${splitted[0]} ${splitted[1]}`;
        break;
      case 3:
        result = `${splitted[0]} ${splitted[1]} ${splitted[2]} ${splitted[1]}`;
        break;
    }
  }

  return result;
};

function switchArray(arr) {
  var temp = arr[0];
  arr[0] = arr[1];
  arr[1] = temp;

  temp = arr[2];
  arr[2] = arr[3];
  arr[3] = temp;

  return arr;
}

export function setScssVariable({
  key = "",
  value = "",
  need_format = true,
  four_values = true,
  bar_pos = configs.theme.bar.position.value,
}) {
  let data = {
    window_margin: "0",
    border_radius: "0",
    bar_border_radius: "0",
    bar_margin: "0",
    workspace_active_width: "30",
    dark_mode: false,
    osd_regular_margin: "0",
    osd_progress_margin: "0",
    bar_opacity: 1.0,
    bar_button_opacity: 1.0,
    panel_button_padding: "0",
    bar_padding: "0",
    bar_shadow: false,
    bar_button_shadow: false,
    bar_button_border_radius: "0",
    system_monitor_margin: "0",
    bar_border: false,
    window_opacity: 0.7,
    window_border: false,
  };

  let idx = [2, 3, 0, 1];

  data.window_margin = format(configs.theme.window.margin.value);
  data.border_radius = format(configs.theme.border_radius.value);
  data.bar_border_radius = format(configs.theme.bar.border_radius.value);
  data.bar_margin = format(configs.theme.bar.margin.value);
  data.dark_mode = configs.theme.dark_mode.value.toString();
  data.workspace_active_width = format(
    configs.theme.bar.workspace_active_width.value,
    false,
  );
  data.osd_regular_margin = format(configs.osd.regular.margin.value);
  data.osd_progress_margin = format(configs.osd.progress.margin.value);
  data.bar_opacity = configs.theme.bar.opacity.value;
  data.bar_button_opacity = configs.theme.bar.button_opacity.value;
  data.bar_shadow = configs.theme.bar.shadow.value;
  data.bar_button_shadow = configs.theme.bar.button_shadow.value;
  data.panel_button_padding = format(configs.theme.bar.button_padding.value);
  data.bar_padding = format(configs.theme.bar.padding.value);
  data.bar_button_border_radius = format(
    configs.theme.bar.button_border_radius.value,
  );
  data.bar_border = configs.theme.bar.border.value;
  data.system_monitor_margin = format(configs.system_monitor.margin.value);
  data.window_opacity = configs.theme.window.opacity.value;
  data.window_border = configs.theme.window.border.value;

  if (isVertical(bar_pos)) {
    data.panel_button_padding = switchArray(
      data.panel_button_padding.split(" "),
    ).join(" ");
  }

  let update = {};
  if (key != "" && value != "") {
    update[key] = need_format ? format(value, four_values) : value;
  }
  let merged = { ...data, ...update };

  merged.window_margin = merged.window_margin.split(" ");
  const tempWindowMargin =
    Number(merged.window_margin[posIndex(bar_pos)].replace("px", "")) / 2;
  merged.window_margin[posIndex(bar_pos)] = `${tempWindowMargin}px`;
  merged.window_margin = merged.window_margin.join(" ");
  merged.bar_margin = merged.bar_margin.split(" ");
  merged.bar_margin[idx[posIndex(bar_pos)]] = `${tempWindowMargin}px`;
  merged.bar_margin = merged.bar_margin.join(" ");

  let result = "";

  Object.entries(merged).forEach(([key, value]) => {
    result += `$${key}: ${value};\n`;
  });

  Utils.writeFile(result, App.configDir + "/style/vars.scss");
}

function setScssColors(theme) {
  Utils.writeFile(
    matugenStringify("${{key}}: {{value}};", theme),
    App.configDir + "/style/colors.scss",
  );
}

export default function setAgs(theme) {
  setScssVariable({});
  setScssColors(theme);
}
