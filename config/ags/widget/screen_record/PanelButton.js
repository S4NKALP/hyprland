import PanelButton from "../PanelButton.js";
import recorder from "../../services/screen_record.js";
import { configs } from "../../vars.js";
import { isVertical } from "../../functions/utils.js";

export default () =>
  PanelButton({
    on_clicked: () => recorder.stop(),
    visible: recorder.bind("recording"),
    child: Widget.Box({
      vertical: configs.theme.bar.position.bind().as(isVertical),
      children: [
        Widget.Icon("media-record-symbolic"),
        Widget.Label({
          class_name: "timer",
          label: recorder.bind("timer").as((time) => {
            const sec = time % 60;
            const min = Math.floor(time / 60);
            return `${min}:${sec < 10 ? "0" + sec : sec}`;
          }),
          setup: (self) => {
            self.hook(configs.theme.bar.position, () => {
              self.toggleClassName(
                "vert",
                isVertical(configs.theme.bar.position.value),
              );
            });
          },
        }),
      ],
    }),
  });
