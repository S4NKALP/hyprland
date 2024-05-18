const network = await Service.import("network");
const bluetooth = await Service.import("bluetooth");
import { isVertical } from "../../functions/utils.js";
import { configs } from "../../vars.js";
import PanelButton from "../PanelButton.js";
import { WINDOW_NAME } from "./Window.js";

const WifiIndicator = () =>
  Widget.Icon().hook(network, (self) => {
    const icon = network[network.primary || "wifi"]?.icon_name;
    self.icon = icon || "";
    self.visible = !!icon;
  });

const BluetoothIndicator = () =>
  Widget.Icon("bluetooth-active-symbolic").hook(bluetooth, (self) => {
    self.visible = bluetooth.enabled;
  });

export default () =>
  PanelButton({
    window: WINDOW_NAME,
    child: Widget.Box({
      spacing: 4,
      vertical: configs.theme.bar.position.bind().as(isVertical),
      children: [WifiIndicator(), BluetoothIndicator()],
    }),
    on_clicked: () => {
      App.toggleWindow(WINDOW_NAME);
    },
  });
