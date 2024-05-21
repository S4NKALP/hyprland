import BatteryPanelButton from "../battery/PanelButton.js";
import DatePanelButton from "../datemenu/PanelButton.js";
import NetworkSpeedIndicator from "../network_speed/PanelButton.js";
import AppLauncherPanelButton from "../applauncher/PanelButton.js";
import WorkspacesPanelButton from "../workspaces/PanelButton.js";
import ClientPanelButton from "../client/PanelButton.js";
import ControlCenterPanelButton from "../control_center/PanelButton.js";
import ScreenRecordPanelButton from "../screen_record/PanelButton.js";
import NetworkPanelButton from "../network/PanelButton.js";
import AudioPanelButton from "../audio/PanelButton.js";
import Tray from "../tray/tray.js";
import { configs } from "../../vars.js";
import { isVertical } from "../../functions/utils.js";
const hyprland = await Service.import("hyprland");

const WINDOW_NAME = "bar__window";

const getAnchor = () => ({
  left: ["left", "top", "bottom"],
  right: ["right", "top", "bottom"],
  top: ["top", "left", "right"],
  bottom: ["bottom", "left", "right"],
});

const startChildren = () => [
  AppLauncherPanelButton(),
  DatePanelButton(),
  WorkspacesPanelButton(),
];

const start = () =>
  Widget.Box({
    class_name: "start",
    spacing: configs.theme.bar.button_spacing.bind(),
    vertical: configs.theme.bar.position.bind().as(isVertical),
    // vpack: configs.theme.bar.position
    //   .bind()
    //   .as((pos) => (pos === "left" ? "end" : "fill")),
    vexpand: true,

    // children: configs.theme.bar.position
    //   .bind()
    //   .as((pos) =>
    //     pos === "left" ? startChildren().reverse() : startChildren(),
    //   ),
    children: startChildren(),
  });

const center = () =>
  Widget.Box({
    children: [ClientPanelButton()],
    vertical: configs.theme.bar.position.bind().as(isVertical),
  });

const endChildren = () => [
  Tray(),
  ScreenRecordPanelButton(),
  NetworkSpeedIndicator(),
  NetworkPanelButton(),
  AudioPanelButton(),
  BatteryPanelButton(),
  ControlCenterPanelButton(),
];

const end = () =>
  Widget.Box({
    class_name: "end",
    spacing: configs.theme.bar.button_spacing.bind(),
    hpack: "end",
    // vpack: configs.theme.bar.position
    //   .bind()
    //   .as((pos) => (pos === "left" ? "start" : "end")),
    vpack: "end",
    vertical: configs.theme.bar.position.bind().as(isVertical),
    children: endChildren(),
    // children: configs.theme.bar.position
    //   .bind()
    //   .as((pos) => (pos === "left" ? endChildren().reverse() : endChildren())),
  });

const BarWindow = () => {
  const win = Widget.Window({
    name: "bar__window",
    exclusivity: "exclusive",
    visible: false,
    anchor: configs.theme.bar.position.bind().as((pos) => getAnchor()[pos]),
    // anchor,
    child: Widget.CenterBox({
      vertical: configs.theme.bar.position.bind().as(isVertical),
      class_names: ["bar__container", "window-content"],
      start_widget: start(),
      // start_widget: configs.theme.bar.position
      //   .bind()
      //   .as((p) => (p === "left" ? end() : start())),
      center_widget: center(),
      // end_widget: configs.theme.bar.position
      //   .bind()
      //   .as((p) => (p === "left" ? start() : end())),
      end_widget: end(),
    }),
  });

  Object.assign(win, {
    animation: `slide`,
  });

  return win;
};

export default function() {
  App.addWindow(BarWindow());
  Utils.timeout(100, () => {
    App.openWindow(WINDOW_NAME);
  });

  configs.theme.bar.position.connect("changed", (self) => {
    App.toggleWindow(WINDOW_NAME);
    Utils.timeout(300, () => {
      App.removeWindow(WINDOW_NAME);
      App.addWindow(BarWindow());
      Utils.timeout(100, () => {
        hyprland.message(
          `keyword layerrule animation slide ${self.value}, ${WINDOW_NAME}`,
        );
        App.openWindow(WINDOW_NAME);
      });
    });
  });
}
