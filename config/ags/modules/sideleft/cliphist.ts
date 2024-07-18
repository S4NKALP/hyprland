import Gtk from "gi://Gtk?version=3.0";
const { Gio } = imports.gi;
const GLib = imports.gi.GLib;
import Box from "types/widgets/box";
import { WINDOW_NAME } from "modules/sideleft/main";

async function getClipboardHistory() {
    try {
        const process = new Gio.Subprocess({
            argv: ['bash', '-c', `${App.configDir}/scripts/cliphist.sh --get`],
            flags: Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE
        });

        process.init(null);
        const [success, stdout] = await process.communicate_utf8(null, null);
        if (!success) return [];

        return stdout.split("\n").filter(line => line.trim() !== "");
    } catch (error) {
        return [];
    }
}

async function clearClipboardHistory() {
    try {
        const process = new Gio.Subprocess({
            argv: ['bash', '-c', 'cliphist wipe'],
            flags: Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE
        });

        process.init(null);
        await process.communicate_utf8(null, null);
    } catch (error) {
        // Handle error silently or log to a file if needed
    }
}

async function copyById(id) {
    try {
        const command = `${App.configDir}/scripts/cliphist.sh --copy-by-id ${id}`;
        const entry = await Utils.execAsync(command);

        if (!entry) return;

        const process = new Gio.Subprocess({
            argv: ['bash', '-c', `echo "${entry.trim()}" | wl-copy`],
            flags: Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE
        });

        process.init(null);
        await process.communicate_utf8(null, null);
    } catch (error) {
        // Handle error silently or log to a file if needed
    }
}

function ClipHistItem(entry) {
    const [id, ...content] = entry.split("\t");
    let clickCount = 0;
    const button = Widget.Button({
        class_name: "clip_container",
        child: Widget.Box({
            children: [
                Widget.Label({ label: id, class_name: "clip_id", xalign: 0, vpack: "center" }),
                Widget.Label({ label: "・", class_name: "dot_divider", xalign: 0, vpack: "center" }),
                Widget.Label({ label: content.join(" ").trim(), class_name: "clip_label", xalign: 0, vpack: "center", truncate: "end" })
            ]
        })
    });

    button.connect("clicked", async () => {
        try {
            clickCount++;
            if (clickCount === 2) {
                await copyById(id);
                App.closeWindow(WINDOW_NAME);
                clickCount = 0;
            }
        } catch (error) {
            // Handle error silently or log to a file if needed
        }
    });

    button.connect("focus-out-event", () => {
        clickCount = 0;
    });

    return Widget.Box({
        attribute: { content: content.join(" ").trim() },
        orientation: Gtk.Orientation.VERTICAL,
        children: [
            button,
            Widget.Separator({ class_name: "clip_divider", orientation: Gtk.Orientation.HORIZONTAL })
        ]
    });
}

export const cliphist = () => {
    const list = Widget.Box({ vertical: true, vexpand: true });
    const loadingIndicator = Widget.Label({ label: "Loading...", class_name: "loading" });
    list.children = [loadingIndicator];

    async function repopulate() {
        try {
            const entries = await getClipboardHistory();
            list.children = []; // Clear loading indicator

            if (entries.length > 0) {
                list.children = entries.map(ClipHistItem);
            }

        } catch (error) {
            list.children = [Widget.Label({ label: "Error loading history", class_name: "error_loading" })];
        }
    }

    repopulate();

    const entry = Widget.Entry({
        hexpand: true,
        class_name: "cliphistory_entry",
        placeholder_text: "Search",
        on_change: ({ text }) => {
            const searchText = text.toLowerCase();
            list.children.forEach((item) => {
                item.visible = item.attribute.content.toLowerCase().includes(searchText);
            });
        }
    });

    const clearButton = Widget.Button({
        label: "Clear",
        class_name: "clear_history_button",
        on_clicked: async () => {
            await clearClipboardHistory();
            repopulate();
        }
    });

    const searchBox = Widget.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        children: [
            entry,
            clearButton
        ]
    });

    return Widget.Box({
        vertical: true,
        class_name: "cliphistory_box",
        margin_top: 14,
        margin_right: 14,
        children: [
            searchBox,
            Widget.Separator(),
            Widget.Scrollable({
                hscroll: "never",
                child: list,
                vexpand: true
            })
        ],
        setup: (self) =>
            self.hook(App, (_, windowName, visible) => {
                if (windowName !== WINDOW_NAME) return;

                if (visible) {
                    repopulate();
                    entry.text = "";
                }
            })
    });
};
