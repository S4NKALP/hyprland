import { icon } from "../../functions/utils.js";
import { configs } from "../../vars.js";
import PanelButton from "../PanelButton.js";

const hyprland = await Service.import("hyprland");
const apps = await Service.import("applications");

const ClientIcon = () =>
  Widget.Icon({
    icon: hyprland.active.bind("client").as((client) => {
      const app = apps.list.find((app) => app.match(client.class));
      return icon(
        (client.class === "" ? "desktop" : app?.icon_name) + "-symbolic",
        app?.icon_name,
      );
    }),
  });

export default () =>
  PanelButton({
    tooltip_text: hyprland.active.client
      .bind("class")
      .as((v) => (v === "" ? "Desktop" : v)),
    child: Widget.Box({
      spacing: 4,
      vpack: "center",
      children: [
        ClientIcon(),
        Widget.Label({
          vpack: "center",
          label: hyprland.active.client
            .bind("title")
            .as((t) =>
              t === ""
                ? "Desktop"
                : t.includes("Mozilla")
                  ? "Mozilla Firefox"
                  : t,
            ),
          visible: configs.theme.bar.position
            .bind()
            .as((p) => (p !== "left") & (p !== "right")),
        }),
      ],
    }),
  });
