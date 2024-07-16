const WINDOW_NAME = "cliphist";
import popupwindow from "./misc/popupwindow.ts";
import Box from "types/widgets/box.js";
import Gtk from "gi://Gtk?version=3.0";
const { Gio } = imports.gi;

type EntryObject = {
    original: string;
    text: string;
    index: number;
};

async function getClipboardHistory(): Promise<EntryObject[]> {
    try {
        const process = new Gio.Subprocess({
            argv: ['bash', '-c', 'cliphist list | iconv -f UTF-8 -t UTF-8//IGNORE'],
            flags: Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE
        });

        process.init(null);

        const [success, stdout, stderr] = process.communicate_utf8(null, null);
        if (!success) {
            return [];
        }

        const sanitizedOutput = stdout.replace(/[^\u0000-\u007F]/g, "");

        return sanitizedOutput
            .split("\n")
            .filter((line) => line.trim() !== "")
            .map((entry) => {
                const [index, text] = entry.split("\t").map((s) => s.trim());
                return { original: entry, text, index: Number(index) };
            });
    } catch {
        return [];
    }
}

async function copyById(id: number) {
    try {
        const entry = await Utils.execAsync(`cliphist decode ${id}`);

        const process = new Gio.Subprocess({
            argv: ['bash', '-c', `echo "${entry.trim()}" | wl-copy`],
            flags: Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE
        });

        process.init(null);
        process.communicate_utf8(null, null);
    } catch {}
}

function ClipHistItem(entry: EntryObject) {
    let clickCount = 0;
    const button = Widget.Button({
        class_name: "clip_container",
        child: Widget.Box({
            children: [
                Widget.Label({
                    label: entry.index.toString(),
                    class_name: "clip_id",
                    xalign: 0,
                    vpack: "center"
                }),
                Widget.Label({
                    label: "・",
                    class_name: "dot_divider",
                    xalign: 0,
                    vpack: "center"
                }),
                Widget.Label({
                    label: entry.text,
                    class_name: "clip_label",
                    xalign: 0,
                    vpack: "center",
                    truncate: "end"
                })
            ]
        })
    });

    button.connect("clicked", async () => {
        clickCount++;
        if (clickCount === 1) {
            App.closeWindow(WINDOW_NAME);
            await copyById(entry.index);
            clickCount = 0;
        }
    });

    button.connect("focus-out-event", () => {
        clickCount = 0;
    });

    return Widget.Box({
        attribute: { content: entry.text },
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

function ClipHistWidget({ width = 500, height = 500, spacing = 12 }) {
    let widgets: Box<any, any>[];

    const list = Widget.Box({
        vertical: true,
        spacing
    });

    async function repopulate() {
        const clipHistItems = await getClipboardHistory();
        widgets = clipHistItems.map((item) => ClipHistItem(item));
        list.children = widgets;
    }

    const entry = Widget.Entry({
        hexpand: true,
        class_name: "cliphistory_entry",
        placeholder_text: "Search",
        on_change: ({ text }) => {
            const searchText = text.toLowerCase();
            widgets.forEach((item) => {
                const content = item.attribute.content.toLowerCase();
                item.visible = content.includes(searchText);
            });
        }
    });

    return Widget.Box({
        vertical: true,
        class_name: "cliphistory_box",
        margin_top: 14,
        margin_right: 14,
        children: [
            entry,
            Widget.Separator(),
            Widget.Scrollable({
                hscroll: "never",
                css: `min-width: ${width}px; min-height: ${height}px;`,
                child: list
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
}

export const cliphist = popupwindow({
    name: WINDOW_NAME,
    class_name: "cliphistory",
    visible: false,
    keymode: "exclusive",
    child: ClipHistWidget({
        width: 500,
        height: 500,
        spacing: 0
    }),
    anchor: ["bottom", "right"]
});
