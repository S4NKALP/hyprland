import QsButton from "./qs_button.js";
import recorder from "../../../services/screen_record.js";
import { WINDOW_NAME } from "../Window.js";

export default () =>
  QsButton({
    icon: "video-symbolic",
    label: "Screen Record",
    on_clicked: () => {
      App.toggleWindow(WINDOW_NAME);
      if (recorder.recording) {
        recorder.stop();
      } else {
        recorder.start();
      }
    },
    setup: (self) => {
      self.hook(recorder, () => {
        self.toggleClassName("active", recorder.recording);
      });
    },
  });
