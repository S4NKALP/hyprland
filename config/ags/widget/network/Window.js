import PopupWindow from "../PopupWindow.js";
import { WifiSelection, NetworkToggle } from "./Wifi.js";
import { BluetoothDevices, BluetoothToggle } from "./Bluetooth.js";
import { Row } from "../ToggleButton.js";
import { configs } from "../../vars.js";
import { layoutPos } from "../../functions/utils.js";
export const WINDOW_NAME = "network__window";
const { bar } = configs.theme;

const Container = () =>
  Widget.Box({
    class_names: ["network-info__container", "window-content"],
    hexpand: false,
    vertical: true,
    children: [
      Row([NetworkToggle, BluetoothToggle], [WifiSelection, BluetoothDevices]),
    ],
  });

const NetworkWindow = () =>
  PopupWindow({
    name: WINDOW_NAME,
    layout: layoutPos(bar.position.value, "top-right"),
    animation: "slide top",
    child: Container(),
  });

export default function() {
  App.addWindow(NetworkWindow());

  bar.position.connect("changed", () => {
    App.removeWindow(WINDOW_NAME);
    App.addWindow(NetworkWindow());
  });
}
