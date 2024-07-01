const WINDOW_NAME = "emoji";
import popupwindow from './misc/popupwindow.ts';
import Box from 'types/widgets/box.js';
import Gtk from "gi://Gtk?version=3.0";
import Gio from 'gi://Gio';

type EmojiObject = {
    emoji: string;
    description: string;
};

let emojisCache: EmojiObject[] = []; // Cache for emojis

async function loadEmojis(filePath: string): Promise<EmojiObject[]> {
    try {
        const file = Gio.File.new_for_path(filePath);
        const [success, contents, etag] = await new Promise<[boolean, Uint8Array | null, string | null]>((resolve, reject) => {
            file.load_contents_async(null, (file, res) => {
                try {
                    resolve(file.load_contents_finish(res));
                } catch (e) {
                    reject(e);
                }
            });
        });

        if (!success || !contents) {
            throw new Error('Failed to load file contents');
        }

        const decoder = new TextDecoder();
        const jsonContent = decoder.decode(contents);

        return JSON.parse(jsonContent) as EmojiObject[];
    } catch (error) {
        throw new Error('Failed to load emojis');
    }
}

function execAsync(command: string): Promise<void> {
    return new Promise((resolve, reject) => {
        const [success, stdout, stderr] = GLib.spawn_command_line_async(command, null);

        if (!success) {
            reject(new Error(`Failed to execute command: ${stderr}`));
        } else {
            resolve();
        }
    });
}

function EmojiItem(entry: EmojiObject) {
    let { emoji, description } = entry;

    let clickCount = 0;
    let button = Widget.Button({
        class_name: "entry_container",
        child: Widget.Label({
            label: `${emoji} ${description}`, // Display emoji and description
            class_name: "entry_label",
            xalign: 0,
            vpack: "center",
            truncate: "end",
        })
    });

    button.connect('clicked', () => {
        clickCount++;
        if (clickCount === 1) {
            App.closeWindow(WINDOW_NAME);

            // Execute wl-copy command asynchronously
            execAsync(`wl-copy '${emoji}'`)
                .then(() => {})
                .catch(() => {});

            clickCount = 0;
        }
    });

    button.connect('focus-out-event', () => {
        clickCount = 0;
    });

    return Widget.Box({
        attribute: { description: description.trim() },
        orientation: Gtk.Orientation.VERTICAL,
        children: [
            button,
            Widget.Separator({
                class_name: "entry_divider",
                orientation: Gtk.Orientation.HORIZONTAL
            })
        ]
    });
}

function debounce(func: Function, wait: number) {
    let timeout: number;
    return function (...args: any[]) {
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(this, args), wait);
    };
}

function Emoji({ width = 500, height = 500, spacing = 12 }) {
    const WINDOW_NAME = "emoji";

    const list = Widget.Box({
        vertical: true,
        spacing,
    });

    const entry = Widget.Entry({
        hexpand: true,
        class_name: "emoji_entry",
        placeholder_text: "Search",
        on_change: debounce(({ text }) => {
            const searchText = (text ?? '').toLowerCase();
            list.children.forEach(item => {
                const description = item.attribute?.description?.toLowerCase() ?? '';
                item.visible = description.includes(searchText);
            });
        }, 300),
    });

    return Widget.Box({
        vertical: true,
        class_name: "emoji_box",
        margin_top: 14,
        margin_right: 14,
        children: [
            entry,
            Widget.Scrollable({
                hscroll: "never",
                css: `min-width: ${width}px; min-height: ${height}px;`,
                child: list,
            }),
        ],
        setup: self => self.hook(App, (_, windowName, visible) => {
            if (windowName !== WINDOW_NAME) return;
            if (visible && emojisCache.length === 0) {
                loadEmojis(`${App.configDir}/assets/emojis.json`)
                    .then(emojis => {
                        emojisCache = emojis;
                        list.children = emojis.map(entry => EmojiItem(entry));
                        entry.text = '';
                    })
                    .catch(error => console.error('Failed to load emojis:', error));
            }
        }),
    });
}

export const emoji = popupwindow({
    name: WINDOW_NAME,
    class_name: "emoji",
    visible: false,
    keymode: "exclusive",
    child: Emoji({
        width: 500,
        height: 500,
        spacing: 0,
    }),
    anchor: ["bottom", "right"]
});
