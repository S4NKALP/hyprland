import PopupWindow from "../PopupWindow.js";
const { query } = await Service.import("applications");
export const WINDOW_NAME = "applauncher__window";

const AppItem = (app) =>
  Widget.Button({
    class_name: "item",
    on_clicked: () => {
      App.closeWindow(WINDOW_NAME);
      app.launch();
    },
    attribute: { app },
    child: Widget.Box({
      children: [
        Widget.Icon({
          icon: app.icon_name || "",
          size: 30,
        }),
        Widget.Label({
          class_name: "title",
          label: app.name,
          xalign: 0,
          vpack: "center",
          truncate: "end",
        }),
      ],
    }),
  });

const Container = ({ width = 500, height = 500, spacing = 12 }) => {
  let applications = query("").map(AppItem);

  const list = Widget.Box({
    vertical: true,
    children: applications,
    spacing,
  });

  function repopulate() {
    applications = query("").map(AppItem);
    list.children = applications;
  }

  const entry = Widget.Box({
    class_name: "entry-box",
    children: [
      Widget.Icon({ icon: "search-symbolic" }),
      Widget.Entry({
        hexpand: true,
        on_accept: () => {
          const results = applications.filter((item) => item.visible);
          if (results[0]) {
            App.toggleWindow(WINDOW_NAME);
            results[0].attribute.app.launch();
          }
        },
        on_change: ({ text }) =>
          applications.forEach((item) => {
            item.visible = item.attribute.app.match(text ?? "");
          }),
        setup: (self) =>
          self.hook(App, (_, windowName, visible) => {
            if (windowName !== WINDOW_NAME) return;
            if (visible) {
              self.text = "";
              self.grab_focus();
            }
          }),
      }),
    ],
  });

  return Widget.Box({
    vertical: true,
    class_names: ["applauncher__container", "window-content"],
    children: [
      entry,
      Widget.Scrollable({
        hscroll: "never",
        css: `min-width: ${width}px;` + `min-height: ${height}px;`,
        child: list,
      }),
    ],
    setup: (self) =>
      self.hook(App, (_, windowName, visible) => {
        if (windowName !== WINDOW_NAME) return;
        if (visible) {
          repopulate();
        }
      }),
  });
};

export default () =>
  PopupWindow({
    name: WINDOW_NAME,
    animation: "popin 80%",
    child: Container({ height: 350, width: 350 }),
  });
