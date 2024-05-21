import { configs } from "../../vars.js";
import { isVertical, posIndex, sendBatch } from "../utils.js";
import { format } from "./ags.js";

export default function setHyprland(theme) {
  const bgColor = theme.background.replace("#", "");
  const primaryColor = theme.primary.replace("#", "");
  let margin = format(configs.theme.window.margin.value, true, false);
  margin = margin.split(" ");
  const marginValue = Number(
    margin[posIndex(configs.theme.bar.position.value)],
  );
  margin[posIndex(configs.theme.bar.position.value)] = `${marginValue / q}`;
  margin = margin.join(", ");
  sendBatch([
    `decoration:col.shadow rgb(${bgColor})`,
    `decoration:rounding ${configs.theme.border_radius.value.split(",")[0].trim()}`,
    `general:col.active_border rgb(${primaryColor})`,
    `general:gaps_out ${margin}`,
    `animation workspaces,1,7,menu_decel,${isVertical(configs.theme.bar.position.value) ? `slidevert` : "slide"}`,
  ]);
}

export function setGapsOut() {
  const bar_pos = configs.theme.bar.position.value;
  const value = configs.theme.window.margin.value;
  let margin = format(value, true, false);
  margin = margin.split(" ");
  const marginValue = Number(margin[posIndex(bar_pos)]);
  margin[posIndex(bar_pos)] = `${marginValue / 2}`;
  margin = margin.join(", ");

  sendBatch([`general:gaps_out ${margin}`]);
}
