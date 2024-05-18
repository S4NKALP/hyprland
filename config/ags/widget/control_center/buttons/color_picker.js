import QsButton from "./qs_button.js";
import { WINDOW_NAME } from "../Window.js";

const wlCopy = (color) => Utils.execAsync(["wl-copy", color]).catch(print);

export default () =>
  QsButton({
    label: "Color Picker",
    icon: "color-select-symbolic",
    on_clicked: () => {
      App.toggleWindow(WINDOW_NAME);
      Utils.timeout(200, () => {
        Utils.execAsync("hyprpicker")
          .then((color) => {
            if (!color) return;

            wlCopy(color);
            Utils.notify({
              iconName: "color-select-symbolic",
              summary: "Color Picker",
              body: color,
              timeout: 5000,
            });
          })
          .catch(print);
      });
    },
  });
