const hyprland = await Service.import("hyprland")
const battery = await Service.import("battery")
const systemtray = await Service.import("systemtray")
const audio = await Service.import("audio")
const network = await Service.import("network")
const { GLib, Gio } = imports.gi;
const encoder = new TextEncoder();
const decoder = new TextDecoder();
import { OpenSettings } from "apps/settings/main.ts";
import { enableClickThrough } from "./misc/clickthrough.js";
import { RoundedCorner } from "./misc/cairo_roundedcorner.js";
import { Client, Workspace } from "types/service/hyprland.js"
import Button from "types/widgets/button.js"
import Icon from "types/widgets/icon.js"
import { FileEnumerator, FileInfo } from "types/@girs/gio-2.0/gio-2.0.cjs"
const mpris = await Service.import("mpris")
const bluetooth = await Service.import("bluetooth")
const { Box, Button, EventBox } = Widget;
import Gtk from "gi://Gtk?version=3.0"
import { MaterialIcon } from "icons.js"


function checkKeymap() {
    const layout = Utils.execAsync(`hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | tail -n1 | cut -c1-2 | tr 'A-Z' 'a-z'`)
        .then(out => { return out })
        .catch(err => { print(err); return "en" });
    return layout;
}

const keyboard_layout = Variable("en")
keyboard_layout.setValue(await checkKeymap())
hyprland.connect("keyboard-layout", (hyprland, keyboardname, layoutname) => {
    keyboard_layout.setValue(layoutname.trim().toLowerCase().substr(0, 2))
})

const MATERIAL_SYMBOL_SIGNAL_STRENGTH = {
    'network-wireless-signal-excellent-symbolic': "signal_wifi_4_bar",
    'network-wireless-signal-good-symbolic': "network_wifi_3_bar",
    'network-wireless-signal-ok-symbolic': "network_wifi_2_bar",
    'network-wireless-signal-weak-symbolic': "network_wifi_1_bar",
    'network-wireless-signal-none-symbolic': "signal_wifi_0_bar",
}

const time = Variable("", {
    poll: [1000, 'date "+%I:%M %p"'],
})

const date = Variable("", {
    poll: [1000, 'date "+%Y-%m-%d"'],
})


function getIconNameFromClass(windowClass: string) {
    let formattedClass = windowClass.replace(/\s+/g, '-').toLowerCase();
    let homeDir = GLib.get_home_dir();
    let systemDataDirs = GLib.get_system_data_dirs().map(dir => dir + '/applications');
    let dataDirs = systemDataDirs.concat([homeDir + '/.local/share/applications']);
    let icon: string | undefined;

    for (let dir of dataDirs) {
        let applicationsGFile = Gio.File.new_for_path(dir);

        let enumerator: FileEnumerator;
        try {
            enumerator = applicationsGFile.enumerate_children('standard::name,standard::type', Gio.FileQueryInfoFlags.NONE, null);
        } catch (e) {
            continue;
        }

        let fileInfo: FileInfo | null;
        while ((fileInfo = enumerator.next_file(null)) !== null) {
            let desktopFile = fileInfo.get_name();
            if (desktopFile.endsWith('.desktop')) {
                let fileContents = GLib.file_get_contents(dir + '/' + desktopFile);
                let matches = /Icon=(\S+)/.exec(decoder.decode(fileContents[1]));
                if (matches && matches[1]) {
                    if (desktopFile.toLowerCase().includes(formattedClass)) {
                        icon = matches[1];
                        break;
                    }
                }
            }
        }

        enumerator.close(null);
        if (icon) break;
    }
    return Utils.lookUpIcon(icon) ? icon : "image-missing";
}

const dispatch = (ws: string) => hyprland.messageAsync(`dispatch workspace ${ws}`).catch(print);


function Workspaces() {
    const activeId = hyprland.active.workspace.bind("id");
    let workspaceButtons = new Map();

    function createWorkspaceButton(id: Number) {
        const button = Widget.Button({
            on_clicked: () => dispatch(`${id}`),
            child: Widget.Label(`${id}`),
            class_name: activeId.as(i => `${i === id ? "active" : ""}`),
        });
        return button;
    }

    function updateWorkspaceButtons(workspaces: Workspace[]): Array<Button<any, any>> {
        workspaces.sort((a, b) => a.id - b.id);

        const updatedButtons = new Map();

        workspaces.forEach(({ id }) => {
            if (workspaceButtons.has(id)) {
                updatedButtons.set(id, workspaceButtons.get(id));
            } else {
                updatedButtons.set(id, createWorkspaceButton(id));
            }
        });
        if (workspaceButtons != updatedButtons)
            workspaceButtons = updatedButtons;

        return Array.from(workspaceButtons.values());
    }

    const workspaceButtonsArray = hyprland.bind("workspaces").as(updateWorkspaceButtons);

    return Widget.EventBox({
        onScrollUp: () => dispatch('+1'),
        onScrollDown: () => dispatch('-1'),
        child: Widget.Box({
            children: workspaceButtonsArray,
            class_name: "workspaces",
        }),
    });
}


function Clock() {
    return Widget.Box({
        orientation: Gtk.Orientation.VERTICAL,
        class_name: "clock",
        children: [
            Widget.Label({
                class_name: "time",
                label: time.bind(),
            }),
            Widget.Label({
                class_name: "date",
                label: date.bind(),
            })
        ],
    })
}


function BatteryLabel() {
    const icon = battery.bind("icon_name");

    const isVisible = battery.bind("percent").as(p => p < 100);

    return Widget.Box({
        class_name: "battery",
        visible: isVisible,
        children: [
            Widget.Icon({ icon }),
            Widget.Label({
                label: battery.bind("percent").as(p => `${p > 0 ? p : 0}%`),
            }),
        ],
    });
}


function SysTray() {
    const items = systemtray.bind("items")
        .as(items => items.map(item => {
            if (item.id.trim() != "nm-applet" && item.id.trim() != "blueman") {
                return Widget.Button({
                    child: Widget.Icon({ icon: item.bind("icon") }),
                    on_primary_click: (_, event) => item.activate(event),
                    on_secondary_click: (_, event) => item.openMenu(event),
                    tooltip_markup: item.bind("tooltip_markup"),
                })
            } else {
                return undefined
            }
        }))

    // @ts-ignore
    return Widget.Box({
        class_name: "tray",
        spacing: 5,
        children: items,
    })
}


function AppLauncher() {
    const button = Widget.Button({
        class_name: "filled_tonal_button awesome_icon",
        on_clicked: () => {
            App.toggleWindow("applauncher")
        },
        child: MaterialIcon("search")
    })

    return button
}





function Wifi() {
    return Widget.Button({
        class_name: "bar_wifi",
        on_primary_click: () => {
            OpenSettings("network")
        },
        on_secondary_click: (_, event) => {
            const nm_applet = systemtray.items.find(item => item.id == "nm-applet")
            if (nm_applet) {
                nm_applet.openMenu(event)
            } else {
                Utils.execAsync("nm-connection-editor").catch(print)
            }
        },
        child: MaterialIcon("signal_wifi_off", "16px"),
        tooltip_text: 'Disabled'
    }).hook(network, self => {
        if (network.wifi.enabled) {
            self.tooltip_text = network.wifi.ssid || 'Unknown';
            self.child.label = MATERIAL_SYMBOL_SIGNAL_STRENGTH[network.wifi.icon_name] || "signal_wifi_off";
        } else {
            self.tooltip_text = 'Disabled'
            self.child.label = "signal_wifi_off";
        }
    })
}



function Bluetooth() {
    return Widget.Button({
        class_name: "bar_bluetooth",
        on_primary_click: () => {
            OpenSettings("bluetooth")
        },
        on_secondary_click: (_, event) => {
            const blueman = systemtray.items.find(item => item.id == "blueman")
            if (blueman) {
                blueman.openMenu(event)
            } else {
                Utils.execAsync("blueman-manager").catch(print)
            }
        },
        child: MaterialIcon("bluetooth_disabled", "18px"),
    }).hook(bluetooth, self => {
        if (bluetooth.enabled) {
            self.child.icon = "bluetooth";
        } else {
            self.child.icon = "bluetooth_disabled";
        }
    })
}

const Applets = () => Widget.Box({
    class_name: "bar_applets",
    spacing: 5,
    children: [
        Bluetooth(),
        Wifi()
    ]
})


function MediaPlayer() {
    let metadata = mpris.players[0]?.metadata;
    const button = Widget.Button({
        class_name: "filled_tonal_button awesome_icon",
        on_primary_click: () => {
            App.toggleWindow("media")
        },
        on_secondary_click: () => {
            Utils.execAsync(["playerctl", "play-pause"]).catch(print)
        },
        child: MaterialIcon("play_circle"),
        visible: false,
        tooltip_text: "Unknown"
    }).hook(mpris, self => {
        if (mpris.players.length > 0) {
            self.visible = true;
            metadata = mpris.players[0]?.metadata;
            if (metadata)
                self.tooltip_text = `${metadata["xesam:artist"]} - ${metadata["xesam:title"]}`;
        } else {
            self.visible = false;
            self.tooltip_text = "Unknown"
            App.closeWindow("media")
        }
    })

    return button
}


function KeyboardLayout() {
    const widget = Widget.Label({
        class_name: "keyboard",
        label: keyboard_layout.bind()
    })
    return widget
}


function OpenSideBar() {
    const button = Widget.Button({
        class_name: "filled_tonal_button awesome_icon",
        on_primary_click: () => {
            App.toggleWindow("sidebar")
        },

        on_secondary_click: () => {
            OpenSettings()
        },
        child: MaterialIcon("dock_to_left")
    })

    return button
}

function TaskBar() {
    let globalWidgets: Button<Icon<any>, any>[] = [];

    function Clients(clients: Client[]) {
        const currentClientIds = clients.map(client => client.pid);
        globalWidgets = globalWidgets.filter(widget => currentClientIds.includes(widget.attribute.pid));

        clients.forEach(item => {
            let widget = globalWidgets.find(w => w.attribute.pid === item.pid);
            if (item.class == "kitty") {
                return;
            }
            if (widget) {
                widget.tooltip_markup = item.title;
            } else {
                let icon: string | undefined;
                if (item.class == "com.github.Aylur.ags") {
                    if (item.initialTitle == "Settings") {
                        icon = "emblem-system-symbolic"
                    }
                    else if (item.initialTitle == "Emoji Picker") {
                        icon = "face-smile-symbolic"
                    }
                }
                else
                    icon = getIconNameFromClass(item.class)
                widget = Widget.Button({
                    attribute: { pid: item.pid },
                    child: Widget.Icon({ icon: icon }),
                    tooltip_markup: item.title,
                });
                globalWidgets.push(widget);
            }
        });
if (globalWidgets.length === 0) {
            const desktopWidget = Widget.Button({
                attribute: { pid: 'desktop' },
                child: Widget.Icon({ icon: "desktop-icon" }),
                tooltip_markup: "Desktop",
            });
            globalWidgets.push(desktopWidget);
        }
        return globalWidgets;
    }

    return Widget.Box({
        class_name: "tray",
        spacing: 5,
        children: hyprland.bind("clients").as(Clients),
    })
}

function volumeIndicator() {
    return Widget.EventBox({
        onScrollUp: () => audio.speaker.volume += 0.01,
        onScrollDown: () => audio.speaker.volume -= 0.01,
        class_name: "filled_tonal_button volume_box",
        child: Widget.Button({
            on_primary_click: () => Utils.execAsync("pavucontrol").catch(print),
            on_secondary_click: () => audio.speaker.is_muted = !audio.speaker.is_muted,
            child: Widget.Box({
                children: [
                    MaterialIcon("volume_off", "20px").hook(audio.speaker, self => {
                        const vol = audio.speaker.volume * 100;
                        const icon = [
                            [101, 'sound_detection_loud_sound'],
                            [67, 'volume_up'],
                            [34, 'volume_down'],
                            [1, 'volume_mute'],
                            [0, 'volume_off'],
                        ].find(([threshold]) => Number(threshold) <= vol)?.[1];
                        if (audio.speaker.is_muted)
                            self.label = "volume_off";
                        else
                            self.label = String(icon!);
                        self.tooltip_text = `Volume ${Math.floor(vol)}%`;
                    }),
                    Widget.Label({
                        label: audio.speaker.bind("volume").as(volume => `${Math.floor(volume * 100)}%`),
                    })
                ]
            })

        })
    })
}


function Left() {
    return Widget.Box({
        // margin_left: 15,
        class_name: "modules-left",
        hpack: "start",
        spacing: 8,
        children: [
            AppLauncher(),
            MediaPlayer(),
            TaskBar()
        ],
    })
}


function Center() {
    return Widget.Box({
        class_name: "modules-center",
        hpack: "center",
        spacing: 8,
        children: [
            Workspaces(),
        ],
    })
}


function Right() {
    return Widget.Box({
        // margin_right: 15,
        class_name: "modules-right",
        hpack: "end",
        spacing: 8,
        children: [
            volumeIndicator(),
            KeyboardLayout(),
            BatteryLabel(),
            SysTray(),
            Applets(),
            Clock(),
            OpenSideBar()
        ],
    })
}


export const Bar = async (monitor = 0) => {
    return Widget.Window({
        name: `bar-${monitor}`,
        class_name: "bar",
        monitor,
        //anchor: ["top", "left", "right"],
        anchor: ["bottom", "left", "right"],
        exclusivity: "exclusive",
        child: Widget.CenterBox({
            start_widget: Left(),
            center_widget: Center(),
            end_widget: Right(),
        }),

    })
}

export const BarCornerTopLeft = (monitor = 0) => Widget.Window({
    monitor,
    name: `bar_corner_tl${monitor}`,
    class_name: "transparent",
    layer: 'top',
    //anchor: ['top', 'left'],
    anchor: ['bottom', 'left'],
    exclusivity: 'normal',
    visible: true,
    //child: RoundedCorner('top_left', { className: 'corner', }),
    child: RoundedCorner('bottom_left', { className: 'corner', }),
    setup: enableClickThrough,
});

export const BarCornerTopRight = (monitor = 0) => Widget.Window({
    monitor,
    name: `bar_corner_tr${monitor}`,
    class_name: "transparent",
    layer: 'top',
    //anchor: ['top', 'right'],
    anchor: ['bottom', 'right'],
    exclusivity: 'normal',
    visible: true,
    //child: RoundedCorner('top_right', { className: 'corner', }),
    child: RoundedCorner('bottom_right', { className: 'corner', }),
    setup: enableClickThrough,
});

