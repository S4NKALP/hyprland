export const Padding = (name) =>
  Widget.EventBox({
    hexpand: true,
    vexpand: true,
    can_focus: false,
    child: Widget.Box({}),
    setup: (w) => w.on("button-press-event", () => App.toggleWindow(name)),
  });

const Layout = (name, child) => ({
  center: () =>
    Widget.CenterBox(
      {},
      Padding(name),
      Widget.CenterBox({ vertical: true }, Padding(name), child, Padding(name)),
      Padding(name),
    ),
  top: () =>
    Widget.CenterBox(
      {},
      Padding(name),
      Widget.Box({ vertical: true }, child, Padding(name)),
      Padding(name),
    ),
  right: () =>
    Widget.Box(
      {},
      Padding(name),
      Widget.Box(
        {
          hexpand: false,
          vertical: true,
        },
        child,
      ),
    ),
  "top-right": () =>
    Widget.Box(
      {},
      Padding(name),
      Widget.Box(
        {
          hexpand: false,
          vertical: true,
        },
        child,
        Padding(name),
      ),
    ),
  "top-center": () =>
    Widget.Box(
      {},
      Padding(name),
      Widget.Box(
        {
          hexpand: false,
          vertical: true,
        },
        child,
        Padding(name),
      ),
      Padding(name),
    ),
  "top-left": () =>
    Widget.Box(
      {},
      Widget.Box(
        {
          hexpand: false,
          vertical: true,
        },
        child,
        Padding(name),
      ),
      Padding(name),
    ),
  "bottom-left": () =>
    Widget.Box(
      {},
      Widget.Box(
        {
          hexpand: false,
          vertical: true,
        },
        Padding(name),
        child,
      ),
      Padding(name),
    ),
  "bottom-center": () =>
    Widget.Box(
      {},
      Padding(name),
      Widget.Box(
        {
          hexpand: false,
          vertical: true,
        },
        Padding(name),
        child,
      ),
      Padding(name),
    ),
  "bottom-right": () =>
    Widget.Box(
      {},
      Padding(name),
      Widget.Box(
        {
          hexpand: false,
          vertical: true,
        },
        Padding(name),
        child,
      ),
    ),
});

export default ({
  name,
  child,
  animation = "popin 80%",
  layout = "center",
  ...props
}) => {
  const win = Widget.Window({
    name,
    visible: false,
    layer: "overlay",
    keymode: "exclusive",
    anchor: ["top", "bottom", "right", "left"],
    child: Layout(name, child)[layout](),
    setup: (w) => w.keybind("Escape", () => App.closeWindow(name)),
    ...props,
  });
  Object.assign(win, {
    animation: animation,
  });

  return win;
};
