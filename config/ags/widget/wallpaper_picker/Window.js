import PopupWindow from "../PopupWindow.js";
import FileChooserDialog from "../FileChooserDialog.js";
import { configs } from "../../vars.js";

export const WINDOW_NAME = "wallpaper-picker__window";

function updateWallpaper(path) {
  configs.wallpaper.current.updateValue(getFilename(path));
}

function getWallpaperList(path) {
  const imageFormats = [".jpeg", ".jpg", ".webp", ".png"];
  return Utils.exec(`ls ${path} -1`)
    .split("\n")
    .filter((str) => {
      return imageFormats.some((fmt) => str.endsWith(fmt));
    });
}

function getFilename(str) {
  return str.split("\\").pop().split("/").pop();
}

const WallItem = (folder, wall) =>
  Widget.Button({
    class_name: "item",
    on_clicked: () => {
      updateWallpaper(`${folder}/${wall}`);
    },
    attribute: { wall: `${folder}/${wall}` },
    child: Widget.Box({
      children: [
        Widget.Label({
          class_name: "title",
          label: wall,
          xalign: 0,
          hexpand: true,
          vpack: "center",
          truncate: "end",
        }),
        Widget.Label({
          // icon: "object-select-symbolic",
          label: "󰄬",
          class_name: "checkmark",
          setup: (self) => {
            self.hook(configs.wallpaper.current, (icon) => {
              icon.visible = configs.wallpaper.current.value == wall;
            });
          },
        }),
      ],
    }),
  });

const WallpaperPicker = ({ width = 500, spacing = 12 }) => {
  const list = Widget.Box({
    vertical: true,
    spacing,
    hexpand: true,
  }).hook(configs.wallpaper.folder, (self) => {
    const path = configs.wallpaper.folder.value;
    self.vpack = "start";
    self.children = getWallpaperList(path).map((item) => WallItem(path, item));

    if (self.children.length == 0) {
      self.vpack = "center";
      self.children = [
        Widget.Label({
          hpack: "center",
          label: "There's nothing here.",
          css: "font-size: 14px; font-weight: 600;",
        }),
      ];
    }
  });

  const entry = Widget.Box({
    class_name: "entry-box",
    children: [
      Widget.Icon("search-symbolic"),
      Widget.Entry({
        hexpand: true,
        on_accept: () => {
          const results = list.children.filter((item) => item.visible);
          if (results[0]) {
            updateWallpaper(results[0].attribute.wall);
          }
        },
        on_change: ({ text }) =>
          list.children.forEach((item) => {
            item.visible = getFilename(item.attribute.wall).match(
              text.toLowerCase() ?? "",
            );
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
    class_names: ["wallpaper-picker__container", "window-content"],
    vertical: true,
    vexpand: true,
    children: [
      Widget.Box({
        spacing: 8,
        children: [
          entry,
          Widget.Button({
            class_name: "folder-button",
            on_clicked: () => {
              App.toggleWindow(WINDOW_NAME);
              App.toggleWindow("wall-filechooser");
              return false;
            },
            child: Widget.Icon({ icon: "folder-open-symbolic" }),
          }),
        ],
      }),
      Widget.Label({
        class_name: "path",
        css: `margin-bottom: ${spacing}px`,
        label: configs.wallpaper.folder.bind().as((p) => `Path: ${p}`),
        truncate: "end",
        max_width_chars: 40,
        hpack: "start",
      }),
      Widget.Scrollable({
        hscroll: "never",
        css: `min-width: ${width}px;`,
        vexpand: true,
        child: Widget.Box({ vexpand: true, children: [list] }),
      }),
    ],
  });
};

export const WallpaperPickerWindow = () =>
  PopupWindow({
    name: WINDOW_NAME,
    layout: "right",
    animation: "slide right",
    child: WallpaperPicker({
      width: 300,
      spacing: 12,
    }),
  });

export const FolderChooserWindow = () =>
  FileChooserDialog({
    name: "wall-filechooser",
    action: 2,
    "use-header-bar": false,
    "create-folders": false,
    setup(win) {
      win.on("delete-event", () => {
        win.hide();
        App.toggleWindow(WINDOW_NAME);
        return true;
      });

      win.add_button("Cancel", 2);
      win.add_button("Choose Folder", 1);

      win.on("response", (_, id) => {
        if (id == 2) {
          win.hide();
          App.toggleWindow(WINDOW_NAME);
        } else {
          const choosen = win.get_file();
          if (choosen != null) {
            configs.wallpaper.folder.updateValue(choosen.get_path());
            win.hide();
            App.toggleWindow(WINDOW_NAME);
          }
        }
      });
    },
  });
