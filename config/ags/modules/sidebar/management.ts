
const notifications = await Service.import("notifications")
const network = await Service.import('network')
const powerProfiles = await Service.import('powerprofiles')
import { OpenSettings } from "apps/settings/main.ts";
import { WINDOW_NAME } from "./main.ts"
import { bluetooth_enabled, idle_inhibitor, night_light, screen_recorder } from "variables.ts";
import { MaterialIcon } from "icons.ts";

import Gtk from "gi://Gtk?version=3.0"

const currentPage = Variable(0);



function WifiIndicator() {
    return Widget.Box({
        css: "padding-left: 15px; padding-right: 15px; padding-top: 5px; padding-bottom: 5px;",
        children: [
             MaterialIcon("signal_wifi_4_bar", "20px"),
            Widget.Box({
                visible: network.wifi.bind('enabled'),
                orientation: Gtk.Orientation.VERTICAL,
                children: [
                    Widget.Box([
                        Widget.Label({
                            label: "Internet",
                        }),
                    ]),
                    Widget.Label({
                        label: network.wifi.bind('ssid')
                            .as(ssid => ssid || 'Unknown'),
                        class_name: "ssid",
                        xalign: 0,
                        vpack: "center",
                        truncate: "end",
                    }),
                ]
            }),
            Widget.Label({
                visible: network.wifi.bind('enabled').as(enabled => !enabled),
                label: "Internet",
            }),
            Widget.Box({
                hpack: "end",
                hexpand: true,
                child: MaterialIcon("chevron_right", "20px", {
                    class_name: "material_icon icon arrow"
                })
            })
        ],
    })
}

const WiredIndicator = () => Widget.Box({
    css: "padding-left: 15px; padding-right: 15px; padding-top: 5px; padding-bottom: 5px;",
    children: [
        MaterialIcon("settings_ethernet", "20px"),
        Widget.Label({
            label: "Internet",
        }),
    ]
})


const NetworkIndicator = () => Widget.Stack({
    children: {
        wifi: WifiIndicator(),
        wired: WiredIndicator(),
    },
    shown: network.bind('primary').as(p => p || 'wifi'),
})


function IconAndName({ label, icon, padding = "0.3em", arrow = false }) {
    let box = Widget.Box({
        css: "padding-left: 15px; padding-right: 15px; padding-top: 5px; padding-bottom: 5px;",
        children: [
            MaterialIcon(icon, "20px"),
            Widget.Label({
                label: label,
                justification: "center",
            }),
        ]
    })
    if (arrow) {
        const arrow = Widget.Box({
            hpack: "end",
            hexpand: true,
            child: MaterialIcon("chevron_right", "20px", {
                class_name: "material_icon icon arrow"
            })
        })
        // @ts-ignore
        box.children = [...box.children, arrow]
    }
    return box
}

// for ScreenRecorder
function isScreenRecordingOn() {
    return Utils.execAsync('bash -c "pidof wf-recorder > /dev/null; echo $?"').then(state => {
        return state.trim() == "0";
});
}

let recordingStartTime = null;
let recordingInterval = null;

function formatTime(ms) {
    let totalSeconds = Math.floor(ms / 1000);
    let hours = Math.floor(totalSeconds / 3600);
    let minutes = Math.floor((totalSeconds % 3600) / 60);
    let seconds = totalSeconds % 60;

    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
}

function startRecordingTimer(button) {
    recordingStartTime = Date.now();
    recordingInterval = setInterval(() => {
        let elapsedTime = Date.now() - recordingStartTime;
        button.child = IconAndName({
            label: formatTime(elapsedTime),
            icon: "stop_circle"
        });
    }, 1000);
}

function stopRecordingTimer(button) {
    clearInterval(recordingInterval);
    recordingStartTime = null;
    recordingInterval = null;
    button.label = 'Screen Recorder';
    button.child = IconAndName({
        label: "Screen Recorder",
        icon: "screen_record"
    });
}

// Widget
function Page1() {
    return Widget.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 5,
        hexpand: true,
        class_name: "management_box",
        children: [
            Widget.Box({
                orientation: Gtk.Orientation.HORIZONTAL,
                hexpand: true,
                spacing: 2.5,
                children: [
                    Widget.Button({
                        hexpand: true,
                        class_name: network.wifi.bind("enabled")
                            .as(enabled => enabled ? "management_button active" : "management_button"),
                        child: NetworkIndicator(),
                        on_primary_click: () => {
                            network.toggleWifi();
                        },
                        on_secondary_click: () => {
                            App.closeWindow(WINDOW_NAME);
                            App.openWindow("network");
                        }
                    }),
                    Widget.Button({
                        hexpand: true,
                        class_name: bluetooth_enabled.bind()
                            .as(state => state.trim() == "yes" ? "management_button active" : "management_button"
                            ),
                        child: IconAndName({
                            label: "Bluetooth",
                            icon: "bluetooth",
                            arrow: true,
                        }),
                        on_primary_click: () => {
                            Utils.execAsync(`${App.configDir}/scripts/bluetooth.sh --toggle`)
                                .then(out => { bluetooth_enabled.setValue(out) })
                        },
                        on_secondary_click: () => {
                            OpenSettings("bluetooth")
                            App.closeWindow(WINDOW_NAME)
                        }
                    })
                ]
            }),
            Widget.Box({
                orientation: Gtk.Orientation.HORIZONTAL,
                spacing: 2.5,
                hexpand: true,
                children: [
                    Widget.Button({
                        hexpand: true,
                        class_name: idle_inhibitor.bind()
                            .as(bool => bool ? "management_button active" : "management_button"),
                        child: IconAndName({
                            label: "Idle inhibitor",
                            icon: "schedule"
                        }),
                        onClicked: () => {
                            idle_inhibitor.setValue(!idle_inhibitor.value)
                            if (idle_inhibitor.value) Utils.execAsync(['bash', '-c', `pidof wayland-idle-inhibitor.py || ${App.configDir}/scripts/wayland-idle-inhibitor.py`]).catch(print)
                            else Utils.execAsync('pkill -f wayland-idle-inhibitor.py').catch(print);
                        },
                        setup: () => {
                            idle_inhibitor.setValue(!!Utils.exec('pidof wayland-idle-inhibitor.py'));
                        },
                    }),
                    Widget.Button({
                        hexpand: true,
                        class_name: notifications.bind("dnd").as((bool) => {
                            return bool ? "management_button active" : "management_button";
                        }),
                        on_clicked: () => {
                            notifications.dnd = notifications.dnd ? false : true
                        },
                        child: IconAndName({
                            label: "Do Not Disturb",
                            icon: notifications.bind("dnd")
                                .as((bool) => bool ? "do_not_disturb_on" : "do_not_disturb_off")
                        })
                    })
                ]
            }),
            Widget.Box({
                orientation: Gtk.Orientation.HORIZONTAL,
                spacing: 2.5,
                hexpand: true,
                children: [
                    Widget.Button({
                    hexpand: true,
                    class_name: screen_recorder.bind()
                        .as(bool => bool ? "management_button active" : "management_button"),
                    child: IconAndName({
                        label: "Screen Recorder",
                        icon: "screen_record"
                        }),
                        onClicked: (self) => {
                            isScreenRecordingOn().then(isRecording => {
                                if (isRecording) {
                                    stopRecordingTimer(self);
                                    } else {
                                        startRecordingTimer(self);
                                        }
                                        self.toggleClassName("active-button", !isRecording);
                                        self.toggleClassName("recording", !isRecording);
                            Utils.execAsync(['bash', '-c', 'mkdir -p ~/Videos/Screenrecordings; pkill wf-recorder; if [ $? -ne 0 ]; then wf-recorder -f ~/Videos/Screenrecordings/recording_"$(date +\'%b-%d-%Y-%I:%M:%S-%P\')".mp4 -g "$(slurp)" --pixel-format yuv420p; fi'])
                            .catch(logError)
                            .then(() => {
                                isScreenRecordingOn().then(newIsRecording => {
                                    if (!newIsRecording) {
                                    stopRecordingTimer(self);
                                    }
                                });
                            });
                        });
                    },
                    setup: (self) => {
                        isScreenRecordingOn().then(isRecording => {
                            if (isRecording) {
                                startRecordingTimer(self);
                                self.addClassName("active-button");
                                self.addClassName("recording");
                                }
                            });
                        }
                    }),
                    Widget.Button({
                        hexpand: true,
                        class_name: night_light.bind()
                            .as(mode => mode ? "management_button active" : "management_button"),
                        child: IconAndName({
                            label: "Night Light",
                            icon: "nightlight"
                        }),
                        onClicked: () => {
                            night_light.setValue(!night_light.value)
                            Utils.execAsync(`${App.configDir}/scripts/night-light.sh --toggle`)
                                .then(out => {
                                    if (out.trim() == "enabled") night_light.setValue(true)
                                    else if (out.trim() == "disabled") night_light.setValue(false)
                                })
                                .catch(err => {
                                    night_light.setValue(!night_light.value);
                                });
                        },
                        setup: () => {
                            Utils.execAsync(`${App.configDir}/scripts/night-light.sh --get`)
                                .then(out => {
                                    if (out.trim() == "enabled") night_light.setValue(true)
                                    else if (out.trim() == "disabled") night_light.setValue(false)
                                })
                                .catch(print);
                        }
                    })
                ]
            })
        ]
    })
}


function Page2() {
    return Widget.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 5,
        hexpand: true,
        class_name: "management_box",
        children: [
            Widget.Box({
                orientation: Gtk.Orientation.HORIZONTAL,
                spacing: 2.5,
                children: [
                    Widget.Button({
                        hexpand: true,
                        class_name: "management_button",
                        child: IconAndName({
                            label: "Color picker",
                            icon: "colorize",
                            arrow: true,
                        }),
                        on_primary_click: () => {
                            App.closeWindow(WINDOW_NAME);
                            Utils.execAsync("sleep 0.5")
                                .then(() =>
                                    Utils.execAsync("hyprpicker -a").catch(print)
                                )
                                .catch(print);
                        }
                    }),
                    Widget.Button({
                        hexpand: true,
                        class_name: "management_button",
                        child: Widget.Box({
                            children: [
                                IconAndName({
                                    icon: powerProfiles.bind('active_profile').as(profile => {
                                        switch (profile) {
                                        case 'balanced':
                                            return 'balance';
                                        case 'performance':
                                            return 'bolt';
                                        default:
                                        return 'eco';
                                        }
                                        })
                                }),
                                Widget.Label({
                                    label: powerProfiles.bind('active_profile').as(x => x.toUpperCase())
                                })
                            ]
                        }),
                        on_clicked: () => {
                            switch (powerProfiles.active_profile) {
                                case 'balanced':
                                    powerProfiles.active_profile = 'performance';
                                    break;
                                case 'power-saver':
                                    powerProfiles.active_profile = 'balanced';
                                    break;
                                default:
                                    powerProfiles.active_profile = 'power-saver';
                                    break;
                            }
                        }
                    }),
                ]
            }),
            Widget.Box({
                orientation: Gtk.Orientation.HORIZONTAL,
                spacing: 2.5,
                hexpand: true,
                children: [
                    Widget.Button({
                        hexpand: true,
                        class_name: "management_button",
                        child: IconAndName({
                            label: "Settings",
                            icon: "settings",
                            arrow: true,
                        }),
                        on_primary_click: () => {
                            OpenSettings()
                            App.closeWindow(WINDOW_NAME);
                        }
                    }),
                    Widget.Box({
                        hexpand: true,
                        class_name: "management_button",
                        child: IconAndName({
                        label: "soon",
                        icon: "",
                        })
                    })
                ]
            }),
        ]
    })
}

const createDotButton = (index: number) => Widget.Button({
    label: '',
    onClicked: () => currentPage.setValue(index),
    class_name: currentPage.bind().as(v => v == index ? "dotbutton active" : "dotbutton"),
    hexpand: false,
});


export function Management() {
    let pages = {
        "page1": Page1(),
        "page2": Page2()
    }
    const numberOfPages = Object.keys(pages).length;
    const pageNames = Array.from({ length: numberOfPages }, (_, i) => `page${i + 1}`);

    const stack = Widget.Stack({
        children: pages,
        // @ts-ignore
        shown: currentPage.bind().as(v => `page${v + 1}`),
        transition: "slide_left_right",
        transitionDuration: 200,
    })
    const dotButtons = pageNames.map((_, index) => createDotButton(index));
    return Widget.EventBox({
        onScrollUp: () => currentPage.setValue((currentPage.value + 1) % numberOfPages),
        onScrollDown: () => {
            if (currentPage.value - 1) {
                currentPage.setValue(numberOfPages - 1)
                return
            }
            currentPage.setValue(currentPage.value - 1);
        },
        child: Widget.Box({
            orientation: Gtk.Orientation.VERTICAL,
            children: [
                stack,
                Widget.Box({
                    children: dotButtons,
                    class_name: "dotbuttons_box",
                    hpack: "center",
                })
            ]
        })
    })
}
