import { isVertical } from "../../functions/utils.js";
import { configs } from "../../vars.js";

const hyprland = await Service.import("hyprland");
const dispatch = (ws) => hyprland.messageAsync(`dispatch workspace ${ws}`);

const WorkspaceButton = (ws) =>
  Widget.Button({
    class_name: "workspace-button",
    child: Widget.Label({
      label: getNerdFontIcon(ws.id), // Use a function to get the icon
      class_name: "workspace-icon",
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

function getNerdFontIcon(workspaceId) {
  // Return different icons based on workspaceId
  const icons = {
    1: '  ',
    2: '  ',
    3: '  ',
    4: '  ',
    5: '  ',
    6: '  ',
    7: '  ',
    8: '  ',
    9: ' 󰚌 ',
  };
  return icons[workspaceId] || '  '; // Default icon if workspaceId not found
}

async function fetchWorkspacesFromServer() {
  // Fetch workspaces from a server or other source
  // Example return value
  return await fetch('/api/workspaces').then(response => response.json());
}

function createInitialWorkspaces() {
  // Create an initial set of workspaces
  return [
    { id: 1, name: "Workspace 1" },
    { id: 2, name: "Workspace 2" },
    { id: 3, name: "Workspace 3" },
    { id: 4, name: "Workspace 4" },
    // Add more initial workspaces as needed
  ];
}

export default () => {
  const wsBox = Widget.Box({
    class_names: ["workspace__container"],
    spacing: 4,
    hexpand: false,
    vexpand: false,
    vertical: configs.theme.bar.position.bind().as(isVertical),
    setup: async (self) => {
      // Ensure workspaces array exists and is properly initialized
      if (!hyprland.workspaces || !Array.isArray(hyprland.workspaces)) {
        hyprland.workspaces = []; // Initialize the workspaces array if it doesn't exist
      }

      // Fetch or create workspaces if the array is empty
      if (hyprland.workspaces.length === 0) {
        try {
          hyprland.workspaces = await fetchWorkspacesFromServer();
        } catch (error) {
          console.error("Failed to fetch workspaces from server:", error);
          hyprland.workspaces = createInitialWorkspaces();
        }
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
