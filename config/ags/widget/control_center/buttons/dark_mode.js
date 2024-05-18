import QsButton from "./qs_button.js";
import { configs } from "../../../vars.js";

export default () =>
  QsButton({
    icon: "night-symbolic",
    label: "Dark Mode",
    setup: (self) => {
      self.hook(configs.theme.dark_mode, () => {
        self.toggleClassName("active", configs.theme.dark_mode.value);
      });
    },
    on_clicked: () => {
      configs.theme.dark_mode.updateValue(!configs.theme.dark_mode.value);
    },
  });
