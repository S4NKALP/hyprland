import { isVertical } from "../../functions/utils.js";
import { configs } from "../../vars.js";

const Text = () =>
  Widget.Label({
    class_name: "splash-text",
    label: Utils.exec("hyprctl splash"),
  });

export default () =>
  Widget.Window({
    name: "hyprsplash__window",
    layer: "bottom",
    anchor: configs.theme.bar.position
      .bind()
      .as((v) => (v === "bottom" ? ["top"] : ["bottom"])),
    margins: configs.theme.window.margin
      .bind()
      .as((v) => v.split(",").map(Number)),
    child: Text(),
  });
