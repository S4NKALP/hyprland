export const opened = Variable("");

export const Row = (toggles, menus) =>
  Widget.Box({
    vertical: true,
    children: [
      Widget.Box({
        homogeneous: true,
        class_name: "row horizontal",
        spacing: 6,
        children: toggles.map((w) => w()),
      }),
      ...menus.map((w) => w()),
    ],
  });

export const Arrow = (name, activate) => {
  let deg = 0;
  let iconOpened = false;
  const icon = Widget.Icon("pan-end-symbolic").hook(opened, () => {
    if (
      (opened.value === name && !iconOpened) ||
      (opened.value !== name && iconOpened)
    ) {
      const step = opened.value === name ? 10 : -10;
      iconOpened = !iconOpened;
      for (let i = 0; i < 9; ++i) {
        Utils.timeout(15 * i, () => {
          deg += step;
          icon.setCss(`-gtk-icon-transform: rotate(${deg}deg);`);
        });
      }
    }
  });

  return Widget.Button({
    child: icon,
    class_name: "arrow",
    on_clicked: () => {
      opened.value = opened.value === name ? "" : name;
      if (typeof activate === "function") activate();
    },
  });
};

export const ArrowToggleButton = ({
  name,
  icon,
  label,
  activate,
  deactivate,
  activateOnArrow = true,
  connection: [service, condition],
}) =>
  Widget.Box({
    class_name: "toggle-button",
    setup: (self) =>
      self.hook(service, () => {
        self.toggleClassName("active", condition());
      }),
    children: [
      Widget.Button({
        child: Widget.Box({
          hexpand: true,
          children: [
            Widget.Icon({
              class_name: "icon",
              size: 18,
              icon,
            }),
            Widget.Label({
              class_name: "label",
              max_width_chars: 10,
              truncate: "end",
              label,
            }),
          ],
        }),
        on_clicked: () => {
          if (condition()) {
            deactivate();
            if (opened.value === name) opened.value = "";
          } else {
            activate();
          }
        },
      }),
      Arrow(name, activateOnArrow && activate),
    ],
  });

export const Menu = ({ parentWindowName, name, icon, title, content }) => {
  App.connect("window-toggled", (_, name, visible) => {
    if (name === parentWindowName && !visible)
      Utils.timeout(500, () => (opened.value = ""));
  });

  return Widget.Revealer({
    transition: "slide_down",
    reveal_child: opened.bind().as((v) => v === name),
    child: Widget.Box({
      class_names: ["menu", name],
      vertical: true,
      children: [
        Widget.Box({
          class_name: "title-box",
          children: [
            Widget.Icon({
              class_name: "icon",
              icon,
            }),
            Widget.Label({
              class_name: "title",
              truncate: "end",
              label: title,
            }),
          ],
        }),
        Widget.Separator(),
        Widget.Box({
          vertical: true,
          class_name: "content vertical",
          children: content,
        }),
      ],
    }),
  });
};
