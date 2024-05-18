const { microphone } = await Service.import("audio");
import QsButton from "./qs_button.js";

const Icon = () =>
  microphone.is_muted || microphone.stream?.is_muted
    ? "microphone-disabled-symbolic"
    : "microphone-sensitivity-high-symbolic";

export default () =>
  QsButton({
    icon: Utils.watch(Icon(), microphone, Icon),
    label: "Mic Access",
    on_clicked: () => (microphone.is_muted = !microphone.is_muted),
    setup: (self) => {
      self.hook(microphone, () => {
        self.toggleClassName(
          "active",
          !(microphone.is_muted || microphone.stream?.is_muted),
        );
      });
    },
  });
