import { capsLockState, configs } from "../../vars.js";

const { microphone } = await Service.import("audio");
const WINDOW_NAME = "osd__capslock";
const DELAY = 3000;

const Container = () => {
  const indicator = Widget.Icon({
    class_name: "icon",
    size: 60,
    vpack: "start",
  });

  const label = Widget.Label({});

  let count = 0;
  function show(label_text, icon) {
    indicator.icon = icon;
    label.label = label_text;
    App.openWindow(WINDOW_NAME);
    count++;
    Utils.timeout(DELAY, () => {
      count--;

      if (count === 0) App.closeWindow(WINDOW_NAME);
    });
  }

  const box = Widget.Box({
    class_name: "osd regular",
    vertical: configs.osd.regular.vertical.bind(),
    children: [indicator, label],
    spacing: 6,
    setup: (self) => {
      self.hook(configs.osd.regular.capslock, () => {
        self.hook(capsLockState, () => {
          const value = capsLockState.value;
          const icon = `capslock-${value === "1" ? "enabled" : "disabled"}-symbolic`;
          if (configs.osd.regular.capslock.value)
            show(`Capslock ${value === "1" ? "On" : "Off"}`, icon);
        });
      });

      self.hook(configs.osd.regular.mic, () => {
        if (configs.osd.regular.mic.value) {
          self.hook(microphone, () => {
            const value = microphone.is_muted;
            const icon = `microphone-${value ? "disabled" : "sensitivity-high"}-symbolic`;

            if (configs.osd.regular.mic.value)
              show(`Mic ${!value ? "On" : "Off"}`, icon);
          });
        }
      });
    },
  });

  // box.hook(capsLockState, () => {
  //   const value = capsLockState.value;
  //   const icon = `capslock-${value === "1" ? "enabled" : "disabled"}-symbolic`;
  //   if (configs.osd.regular.capslock.value)
  //     show(`Capslock ${value === "1" ? "On" : "Off"}`, icon);
  // });
  //
  // box.hook(microphone, () => {
  //   const value = microphone.is_muted;
  //   const icon = `microphone-${value ? "disabled" : "sensitivity-high"}-symbolic`;
  //
  //   if (configs.osd.regular.mic.value)
  //     show(`Capslock ${value === "1" ? "On" : "Off"}`, icon);
  // });

  return box;
};

export default () => {
  const win = Widget.Window({
    name: WINDOW_NAME,
    click_through: true,
    anchor: configs.osd.regular.position.bind().as((v) => v.split(" ")),
    visible: false,
    layer: "overlay",
    child: Container(),
    // setup: (self) => {
    //   self.child = Container();
    //   self.hook(configs.osd.regular.capslock, () => {
    //     self.child = Container();
    //   });
    //
    //   self.hook(microphone, () => {
    //     self.child = Container();
    //   });
    // },
  });
  // Object.assign(win, {
  //   animation: "popin 100%",
  // });
  return win;
};
