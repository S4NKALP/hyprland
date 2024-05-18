import brightness from "../../services/brightness.js";
import { icon } from "../../functions/utils.js";
import { configs } from "../../vars.js";
import Progress from "./Progress.js";
const WINDOW_NAME = "osd__window";
const DELAY = 3000;

const audio = await Service.import("audio");

const Container = (vertical) => {
  const indicator = Widget.Icon({
    class_name: "icon",
    size: 40,
    vpack: "end",
    hpack: "start",
  });

  const progress = Progress({
    vertical,
    width: vertical ? 40 : 200,
    height: vertical ? 260 : 40,
    child: indicator,
  });

  let count = 0;
  function show(value, icon) {
    indicator.icon = icon;
    progress.setValue(value);
    App.openWindow(WINDOW_NAME);
    count++;
    Utils.timeout(DELAY, () => {
      count--;

      if (count === 0) App.closeWindow(WINDOW_NAME);
    });
  }

  const box = Widget.Box({
    class_name: "osd progress",
    children: [progress],
    setup: (self) => {
      self.hook(configs.osd.progress.brightness, () => {
        self.hook(
          brightness,
          () => {
            if (configs.osd.progress.brightness.value)
              show(brightness.screen, "display-brightness-symbolic");
          },
          "notify::screen",
        );
      });

      self.hook(configs.osd.progress.volume, () => {
        self.hook(
          audio.speaker,
          () => {
            if (configs.osd.progress.volume.value)
              show(
                audio.speaker.volume,
                icon(audio.speaker.icon_name || "", "audio-x-generic-symbolic"),
              );
          },
          "notify::volume",
        );
      });
    },
  });

  return box;
};

export default () => {
  const win = Widget.Window({
    name: WINDOW_NAME,
    click_through: true,
    anchor: configs.osd.progress.position.bind().as((v) => v.split(" ")),
    visible: false,
    layer: "overlay",
    child: configs.osd.progress.vertical.bind().as(Container),
  });

  return win;
};
