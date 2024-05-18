import QsButton from "./qs_button.js";
import { WINDOW_NAME } from "../Window.js";
import recorder from "../../../services/screen_record.js";

export default () => {
  const menu = Widget.Menu({
    hpack: "start",
    children: [
      Widget.MenuItem({
        hexpand: true,
        on_activate: () => {
          App.toggleWindow(WINDOW_NAME);
          Utils.timeout(200, () => {
            recorder.screenshot(true);
          });
        },
        child: Widget.Label("Full", {
          hexpand: true,
          xalign: 0,
          justification: "left",
        }),
      }),
      Widget.MenuItem({
        hexpand: true,
        on_activate: () => {
          App.toggleWindow(WINDOW_NAME);
          recorder.screenshot();
        },
        child: Widget.Label("Partial", {
          hexpand: true,
          xalign: 0,
          justification: "left",
        }),
      }),
    ],
  });
  return QsButton({
    icon: "gnome-screenshot-symbolic",
    label: "Screenshot",
    on_primary_click: (_, event) => {
      menu.popup_at_pointer(event);
    },
  });
};
