const WINDOW_NAME = "musicplayer";
import popupwindow from './misc/popupwindow.ts';
import Box from 'types/widgets/box.js';
import Gtk from "gi://Gtk?version=3.0";
import GLib from "gi://GLib?version=2.0";

type Track = {
    id: string;
    title: string;
    artist: string;
    url: string; // Assuming we use URLs for identification, but not playback.
};

function MusicPlayerItem(track: Track) {
    let button = Widget.Button({
        class_name: "track_container",
        child: Widget.Label({
            label: `${track.title} - ${track.artist}`,
            class_name: "track_label",
            xalign: 0,
            vpack: "center",
            truncate: "end",
        })
    });

    button.connect('clicked', () => {
        playTrack(track); // Function to handle playback
    });

    return Widget.Box({
        orientation: Gtk.Orientation.VERTICAL,
        children: [
            button,
            Widget.Separator({
                orientation: Gtk.Orientation.HORIZONTAL
            })
        ]
    });
}

async function playTrack(track: Track) {
    try {
        // Placeholder for playing audio via libcanberra or other suitable GTK audio APIs
        GLib.spawn_command_line_async(`canberra-gtk-play -i audio-file-id`);
    } catch (error) {
        console.error(`Error playing track: ${error}`);
    }
}

function MusicPlayerWidget({ width = 500, height = 500, spacing = 12 }) {
    let tracks: Track[] = [
        { id: "1", title: "Track 1", artist: "Artist 1", url: "1" },
        { id: "2", title: "Track 2", artist: "Artist 2", url: "2" },
        { id: "3", title: "Track 3", artist: "Artist 3", url: "3" }
        // Add more tracks as needed
    ];

    let widgets: Box<any, any>[] = tracks.map(track => MusicPlayerItem(track));

    const list = Widget.Box({
        vertical: true,
        spacing,
        children: widgets
    });

    const entry = Widget.Entry({
        hexpand: true,
        class_name: "musicplayer_entry",
        placeholder_text: "Search",

        on_change: ({ text }) => widgets.forEach(item => {
            item.visible = item.attribute.content.match(text ?? "")
        }),
    });

    return Widget.Box({
        vertical: true,
        class_name: "musicplayer_box",
        margin_top: 14,
        margin_right: 14,
        children: [
            entry,
            Widget.Scrollable({
                hscroll: "never",
                css: `min-width: ${width}px;`
                    + `min-height: ${height}px;`,
                child: list,
            }),
        ],
        setup: self => self.hook(App, (_, windowName, visible) => {
            if (windowName !== WINDOW_NAME)
                return;

            if (visible) {
                entry.text = "";
            }
        }),
    });
}

export const musicplayer = popupwindow({
    name: WINDOW_NAME,
    class_name: "musicplayer",
    visible: false,
    keymode: "exclusive",
    child: MusicPlayerWidget({
        width: 500,
        height: 500,
        spacing: 0,
    }),
    anchor: ["bottom", "right"]
});
