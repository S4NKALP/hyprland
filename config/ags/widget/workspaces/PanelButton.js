import { isVertical } from "../../functions/utils.js";
import { configs } from "../../vars.js";

const hyprland = await Service.import("hyprland");
const dispatch = (ws) => hyprland.messageAsync(`dispatch workspace ${ws}`);

const WorkspaceButton = (ws) =>
  Widget.Button({
    class_name: "workspace-button",
    child: Widget.Box({
      class_name: "fill",
      hexpand: false,
      setup: (self) => {
        self.hook(configs.theme.bar.position, () => {
          self.toggleClassName(
            "vert",
            isVertical(configs.theme.bar.position.value),
          );
          self.toggleClassName(
            "hort",
            !isVertical(configs.theme.bar.position.value),
          );
        });
      },
    }),
    vpack: "center",
    hpack: "center",
    onClicked: () => dispatch(ws.id),
    setup: (self) => {
      self.hook(hyprland, () => {
        self.toggleClassName("active", hyprland.active.workspace.id == ws.id);
        self.toggleClassName(
          "occupied",
          hyprland.getWorkspace(ws.id)?.windows > 0,
        );
      });
    },
  });

// Within the default function:
export default () => {
  const wsBox = Widget.Box({
    class_names: ["workspace__container"],
    spacing: 4,
    hexpand: false,
    vexpand: false,
    vertical: configs.theme.bar.position.bind().as(isVertical),
    setup: (self) => {
      // Ensure workspaces array exists
      if (!hyprland.workspaces) {
        hyprland.workspaces = []; // Initialize the workspaces array if it doesn't exist
      }

      // Fetch or create workspaces if the array is empty
      if (hyprland.workspaces.length === 0) {
        // For example:
        // hyprland.workspaces = await fetchWorkspacesFromServer();
        // or
        // hyprland.workspaces = createInitialWorkspaces();
      }

      // Update the workspace buttons whenever there's a change in workspaces
      self.hook(
        hyprland,
        () => {
          // Clear existing buttons
          self.children = [];

          // Map existing workspaces to buttons
          self.children = hyprland.workspaces.map(WorkspaceButton);
        },
        "notify::workspaces",
      );
    },
  });
  return Widget.EventBox({
    child: wsBox,
  });
};
