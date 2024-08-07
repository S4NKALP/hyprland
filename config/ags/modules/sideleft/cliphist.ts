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
    }
}

async function showImagePreview(id, format, width, height) {
    try {
        const file = await Utils.execAsync(`${App.configDir}/scripts/cliphist.sh --save-by-id ${id}`);
        const _widthPx = Number(width);
        const heightPx = Number(height);
        const maxWidth = 400;
        const widthPx = (_widthPx / heightPx) * 150;

        let css = `background-image: url("${file}");`;

        if (widthPx > maxWidth) {
            const newHeightPx = (150 / widthPx) * maxWidth;
            css += `min-height: ${newHeightPx}px; min-width: ${maxWidth}px;`;
        } else {
            css += `min-height: 150px; min-width: ${widthPx}px;`;
        }

        return css;
    } catch (error) {
        return '';
    }
}

function ClipHistItem(entry) {
    const [id, ..._content] = entry.split("\t");
    const content = _content.join(" ").trim();
    const matches = content.match(/\[\[ binary data (\d+) (KiB|MiB) (\w+) (\d+)x(\d+) \]\]/);
    let _show_image = false;

    let clickCount = 0;
    const button = Widget.Button({
        class_name: "clip_container",
        child: Widget.Box({
            children: [
                Widget.Label({ label: id, class_name: "clip_id", xalign: 0, vpack: "center" }),
                Widget.Label({ label: "・", class_name: "dot_divider", xalign: 0, vpack: "center" }),
                Widget.Label({ label: content, class_name: "clip_label", xalign: 0, vpack: "center", truncate: "end" })
            ]
        })
    });

    button.connect("clicked", async () => {
        try {
            clickCount++;
            if (clickCount === 2) {
                App.closeWindow(WINDOW_NAME);
                await Utils.execAsync(`${App.configDir}/scripts/cliphist.sh --copy-by-id ${id}`);
                clickCount = 0;
            }
        } catch (error) {
        }
    });

    button.connect("focus-out-event", () => {
        clickCount = 0;
    });

    if (matches) {
        const format = matches[3];
        const width = matches[4];
        const height = matches[5];
        if (format === "png") {
            button.toggleClassName("with_image", true);
            button.connect("clicked", async () => {
                if (!_show_image) {
                    const css = await showImagePreview(id, format, width, height);
                    const box = button.child;
                    box.children[2].destroy();
                    const icon = Widget.Box({
                        vpack: "center",
                        css: css,
                        class_name: "preview"
                    });
                    box.children = [...box.children, icon];
                    _show_image = true;
                }
            });
        }
    }

    return Widget.Box({
        attribute: { content: content },
        orientation: Gtk.Orientation.VERTICAL,
        children: [
            button,
            Widget.Separator({
                class_name: "clip_divider",
                orientation: Gtk.Orientation.HORIZONTAL
            })
        ]
    });
}

export const cliphist = () => {
    const list = Widget.Box({ vertical: true, vexpand: true });
    const loadingIndicator = Widget.Label({
        label: "Loading...",
        class_name: "loading"
    });
    list.children = [loadingIndicator];

    async function repopulate() {
        try {
            const entries = await getClipboardHistory();
            list.children = [];

            if (entries.length > 0) {
                list.children = entries.map(ClipHistItem);
            }
        } catch (error) {
            list.children = [Widget.Label({
                label: "Error loading history",
                class_name: "error_loading"
            })];
        }
    }

    repopulate();

    const entry = Widget.Entry({
        hexpand: true,
        class_name: "cliphistory_entry",
        placeholder_text: "Search",
        on_change: async ({ text }) => {
            const searchText = text.toLowerCase();

            if (searchText.trim() === '/clear') {
                await clearClipboardHistory();
                await repopulate();
                entry.text = '';
            } else {
                list.children.forEach((item) => {
                    item.visible = item.attribute.content.toLowerCase().includes(searchText);
                });
            }
        }
    });

    const searchBox = Widget.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        children: [entry]
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
