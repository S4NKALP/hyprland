import brightness from "../../services/brightness.js";

export default () =>
  Widget.Box({
    spacing: 6,
    vpack: "center",
    class_name: "brightness-box",
    children: [
      Widget.Icon({ icon: "display-brightness-symbolic", size: 18 }),
      Widget.Slider({
        draw_value: false,
        hexpand: true,
        min: 0.1,
        value: brightness.bind("screen"),
        on_change: ({ value }) => (brightness.screen = value),
      }),
    ],
  });
