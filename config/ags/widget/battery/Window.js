import { layoutPos } from "../../functions/utils.js";
import { configs } from "../../vars.js";
import PopupWindow from "../PopupWindow.js";

const powerProfiles = await Service.import("powerprofiles");
const battery = await Service.import("battery");
export const WINDOW_NAME = "battery__window";
const { bar } = configs.theme;

function formatTimeUntilCharged(seconds) {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);

  let result = "";
  if (hours > 0) {
    result += hours + " hour";
    if (hours > 1) result += "s";
  }
  if (minutes > 0) {
    if (result !== "") result += " ";
    result += minutes + " minute";
    if (minutes > 1) result += "s";
  }

  return result;
}
const TimeRemaining = () =>
  Widget.Label({
    class_name: "time-remaining",
    hpack: "start",
    label: Utils.merge(
      [battery.bind("time-remaining"), battery.bind("charging")],
      (tr, charging) => {
        const hoursMinutes = formatTimeUntilCharged(tr);

        if (charging) {
          return hoursMinutes === ""
            ? "Charging..."
            : `${hoursMinutes} until fully charged`;
        } else {
          return hoursMinutes === ""
            ? "Not charging"
            : `About ${hoursMinutes} left`;
        }
      },
    ),
  });

const Item = (profile) =>
  Widget.Button({
    class_name: "item",
    on_clicked: () => {
      powerProfiles.active_profile = profile;
    },
    setup: (self) => {
      self.hook(powerProfiles, (btn) => {
        btn.toggleClassName("active", powerProfiles.active_profile == profile);
      });
    },
    child: Widget.Box({
      hexpand: true,
      spacing: 6,
      vpack: "center",
      hpack: "center",
      children: [
        Widget.Icon({ icon: `power-profile-${profile}-symbolic`, size: 16 }),
      ],
    }),
  });

const PowerProfileContainer = () =>
  Widget.Box({
    vertical: true,
    class_name: "power-profile__container",
    children: [
      Widget.Label({
        hpack: "start",
        label: "Power Profile",
      }),
      Widget.Box({
        spacing: 6,
        vertical: false,
        homogeneous: true,
        setup: (self) => {
          self.hook(powerProfiles, (box) => {
            box.children = powerProfiles.profiles.map((profile) =>
              Item(profile.Profile),
            );
          });
        },
      }),
    ],
  });

const PercentLabel = () =>
  Widget.Box({
    halign: "start",
    children: [
      Widget.Label({
        class_name: "percent",
        label: battery.bind("percent").as((p) => `${Math.round(p)}%`),
      }),
    ],
  });

const LevelBar = () =>
  Widget.Overlay({
    child: Widget.LevelBar({
      bar_mode: "discrete",
      max_value: 10,
      value: battery.bind("percent").as((p) => p / 10),
    }),
    overlays: [PercentLabel()],
  });

const BatteryInfo = () =>
  Widget.Box({
    class_name: "battery-info__container",
    vertical: true,
    children: [LevelBar(), TimeRemaining()],
  });

const Container = () =>
  Widget.Box({
    class_names: ["battery-popup__container", "window-content"],
    vertical: true,
    hexpand: false,
    children: [BatteryInfo(), PowerProfileContainer()],
  });

const BatteryWindow = () =>
  PopupWindow({
    name: WINDOW_NAME,
    animation: "slide top",
    layout: layoutPos(bar.position.value, "top-right"),
    child: Container(),
  });

export default function() {
  App.addWindow(BatteryWindow());

  bar.position.connect("changed", () => {
    App.removeWindow(WINDOW_NAME);
    App.addWindow(BatteryWindow());
  });
}
