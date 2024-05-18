import GLib from "gi://GLib?version=2.0";
const hyprland = await Service.import("hyprland");

const substitutes = {
  "transmission-gtk": "transmission",
  "blueberry.py": "blueberry",
  Caprine: "facebook-messenger",
  "Alacritty-symbolic": "terminal-symbolic",
  "com.raggesilver.BlackBox-symbolic": "terminal-symbolic",
  "org.wezfurlong.wezterm-symbolic": "terminal-symbolic",
  "audio-headset-bluetooth": "audio-headphones-symbolic",
  "audio-card-analog-usb": "audio-speakers-symbolic",
  "audio-card-analog-pci": "audio-card-symbolic",
  "preferences-system": "emblem-system-symbolic",
  "com.github.Aylur.ags-symbolic": "controls-symbolic",
  "com.github.Aylur.ags": "controls-symbolic",
};

export function icon(name, fallback = "image-missing-symbolic") {
  if (!name) return fallback || "";

  if (GLib.file_test(name, GLib.FileTest.EXISTS)) return name;

  const icon = substitutes[name] || name;
  if (Utils.lookUpIcon(icon)) return icon;

  return fallback;
}

export const sendBatch = (batch) => {
  const cmd = batch
    .filter((x) => !!x)
    .map((x) => `keyword ${x}`)
    .join("; ");

  hyprland.message(`[[BATCH]]/${cmd}`);
};

export async function sh(cmd) {
  return Utils.execAsync(cmd).catch((err) => {
    console.error(typeof cmd === "string" ? cmd : cmd.join(" "), err);
    return "";
  });
}
export async function bash(strings, ...values) {
  const cmd =
    typeof strings === "string"
      ? strings
      : strings.flatMap((str, i) => str + `${values[i] ?? ""}`).join("");

  return Utils.execAsync(["bash", "-c", cmd]).catch((err) => {
    console.error(cmd, err);
    return "";
  });
}

export function matugenStringify(format, json) {
  let result = "";

  for (let key in json) {
    let value = json[key];
    result += format.replace("{{key}}", key).replace("{{value}}", value) + "\n";
  }

  return result;
}

export function applyCss() {
  const scss = App.configDir + "/style/main.scss";
  const css = TMP + "/style.css";

  sh(`sass ${scss} ${css}`).then(() => {
    App.resetCss();
    App.applyCss(css);
  });
}

const isObject = (item) => {
  return item && typeof item === "object" && !Array.isArray(item);
};

export function deepMerge(target, ...sources) {
  if (!sources.length) return target;
  const source = sources.shift();

  if (isObject(target) && isObject(source)) {
    for (const key in source) {
      if (isObject(source[key])) {
        if (!target[key])
          Object.assign(target, {
            [key]: {},
          });
        deepMerge(target[key], source[key]);
      } else {
        Object.assign(target, {
          [key]: source[key],
        });
      }
    }
  }

  return deepMerge(target, ...sources);
}

export function replacePlaceholders(str, data) {
  if (typeof str !== "string") {
    return str;
  }
  return str.replace(/\{\{(\w+)\}\}/g, (match, key) => {
    return data[key] || match;
  });
}

export function reverseReplace(str, data) {
  for (const key in data) {
    if (data.hasOwnProperty(key)) {
      const value = data[key];
      const regex = new RegExp(value, "g");
      str = str.replace(regex, `{{${key}}}`);
    }
  }
  return str;
}

export function isVertical(pos) {
  return pos === "left" || pos === "right";
}

export const posIndex = (pos) => {
  switch (pos) {
    case "top":
      return 0;
    case "right":
      return 1;
    case "bottom":
      return 2;
    default:
      return 3;
  }
};

export const layoutPos = (pos, layout) => {
  const win = {
    top: {},
    left: {
      "top-right": "bottom-left",
    },
    right: {
      "top-right": "bottom-right",
      "top-left": "top-right",
    },
    bottom: {
      "top-left": "bottom-left",
      "top-right": "bottom-right",
    },
  };

  return win[pos][layout] ?? layout;
};
