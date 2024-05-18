import { isVertical } from "../../functions/utils.js";
import networkspeed from "../../services/network_speed.js";
import { configs } from "../../vars.js";
import PanelButton from "../PanelButton.js";

// networkspeed.interval = 3000;

const NetworkSpeedLabel = (inMB = true) =>
  Widget.Label({ class_name: "label" })
    .hook(networkspeed, (self) => {
      let downloadSpeed = networkspeed.download_speed;
      let uploadSpeed = networkspeed.upload_speed;
      let speed = downloadSpeed >= uploadSpeed ? downloadSpeed : uploadSpeed;
      if (inMB) {
        speed = (speed / 1000).toFixed(2);
      }
      const unit = downloadSpeed >= uploadSpeed ? "" : "";
      self.label = `${speed} ${unit}`;
    })
    .hook(configs.theme.bar.position, (self) => {
      self.toggleClassName(
        "vert",
        isVertical(configs.theme.bar.position.value),
      );
    });

export default () =>
  PanelButton({
    class_name: "network-speed",
    child: Widget.Box({
      vertical: true,
      children: [
        NetworkSpeedLabel(),
        Widget.Label({ class_name: "unit", label: "MB/s" }),
      ],
    }),
  });
