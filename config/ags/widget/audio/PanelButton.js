import "../PanelButton.js";
import PanelButton from "../PanelButton.js";
import { WINDOW_NAME } from "./Window.js";
const audio = await Service.import("audio");

const icons = {
  muted: "audio-volume-muted-symbolic",
  low: "audio-volume-low-symbolic",
  medium: "audio-volume-medium-symbolic",
  high: "audio-volume-high-symbolic",
  overamplified: "audio-volume-overamplified-symbolic",
};

export default () =>
  PanelButton({
    window: WINDOW_NAME,
    on_scroll_up: () => (audio.speaker.volume += 0.02),
    on_scroll_down: () => (audio.speaker.volume -= 0.02),
    on_clicked: () => {
      App.toggleWindow(WINDOW_NAME);
    },
    child: Widget.Icon().hook(audio.speaker, (self) => {
      const vol = audio.speaker.is_muted ? 0 : audio.speaker.volume;
      const { muted, low, medium, high, overamplified } = icons;
      const cons = [
        [101, overamplified],
        [67, high],
        [34, medium],
        [1, low],
        [0, muted],
      ];
      self.icon = cons.find(([n]) => n <= vol * 100)?.[1] || "";
    }),
  });
