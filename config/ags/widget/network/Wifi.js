import { ArrowToggleButton, Menu } from "../ToggleButton.js";
const { wifi } = await Service.import("network");
import { WINDOW_NAME } from "./Window.js";

export const NetworkToggle = () =>
  ArrowToggleButton({
    name: "network",
    icon: wifi.bind("icon_name"),
    label: wifi.bind("ssid").as((ssid) => ssid || "Not Connected"),
    connection: [wifi, () => wifi.enabled],
    deactivate: () => (wifi.enabled = false),
    activate: () => {
      wifi.enabled = true;
      wifi.scan();
    },
  });

export const WifiSelection = () =>
  Menu({
    name: "network",
    parentWindowName: WINDOW_NAME,
    icon: wifi.bind("icon_name"),
    title: "Wifi Selection",
    content: [
      Widget.Box({
        vertical: true,
        setup: (self) =>
          self.hook(
            wifi,
            () =>
            (self.children = wifi.access_points.map((ap) =>
              Widget.Button({
                on_clicked: () => {
                  Utils.execAsync(`nmcli device wifi connect ${ap.bssid}`);
                },
                child: Widget.Box({
                  children: [
                    Widget.Icon(ap.iconName),
                    Widget.Label(ap.ssid || ""),
                    Widget.Icon({
                      icon: "object-select-symbolic",
                      hexpand: true,
                      hpack: "end",
                      setup: (self) =>
                        Utils.idle(() => {
                          if (!self.is_destroyed) self.visible = ap.active;
                        }),
                    }),
                  ],
                }),
              }),
            )),
          ),
      }),
    ],
  });
