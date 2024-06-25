import Gtk from "gi://Gtk?version=3.0"
import { timeout } from "resource:///com/github/Aylur/ags/utils.js";
import { Variable as VariableType } from "types/variable";
const systemtray = await Service.import("systemtray")

type AccessPoint = {
    bssid: string | null;
    address: string | null;
    lastSeen: number;
    ssid: string | null;
    active: boolean;
    strength: number;
    frequency: number;
    iconName: string | undefined;
};

const network = await Service.import("network")

const _scan_timer = Variable(undefined, {
    poll: [15000, WifiScan]
})


const network_state = {
    "unavailable": "Device is unavailable",
    "disconnected": "Device is disconnected",
    "prepare": "Preparing to connect...",
    "config": "Configuring connection...",
    "need_auth": "Authentication required...",
    "ip_config": "Obtaining IP address...",
    "ip_check": "Verifying IP address...",
    "secondaries": "Setting up secondary connections...",
    "activated": "Connected",
    "deactivating": "Disconnecting...",
    "failed": "Connection failed"
};

const saved_networks: VariableType<string[]> = Variable([], {
    poll: [5000, () => {
        const _saved = Utils.exec(`${App.configDir}/scripts/network.sh --saved`);
        return _saved.split("\n")
    }]
})

function WifiScan() {
    network.wifi.scan()
    // await Utils.execAsync("nmcli device wifi rescan").catch(print)
    return undefined
}


const WifiNetwork = (access_point: AccessPoint) => {
    const is_saved = saved_networks.value.includes(access_point.ssid!);
    const connected = access_point.ssid == network.wifi.ssid;
    return Widget.Button({
        class_name: "wifi_network",
        on_primary_click: () => {
            if (!connected)
                Utils.execAsync(`nmcli device wifi connect '${access_point.ssid}'`)
                    .catch(print);
            else if (is_saved)
                Utils.execAsync(`${App.configDir}/scripts/network.sh --edit ${access_point.ssid}`)
                    .catch(print);
        },
        on_secondary_click: () => {
            if(!connected && is_saved)
                Utils.execAsync(`${App.configDir}/scripts/network.sh --edit ${access_point.ssid}`)
                    .catch(print);
        },
        child: Widget.Box({
            class_name: "wifi_network_box",
            children: [
                Widget.Icon({
                    icon: access_point.iconName,
                    size: 20
                }),
                // @ts-ignore
                Widget.Box({
                    vertical: true,
                    children: [
                        Widget.Label({
                            class_name: "title",
                            label: access_point.ssid,
                            hpack: "start"
                        }),
                        (connected)
                            ? Widget.Label({
                                class_name: "description",
                                label: network_state[network.wifi.state],
                                hpack: "start"
                            })
                            : (is_saved)
                                ? Widget.Label({
                                    class_name: "description",
                                    label: "Saved",
                                    hpack: "start"
                                })
                                : undefined
                    ]
                })
            ]
        }),

        setup: self => {
            self.toggleClassName("active", connected);
        }
    })
}


const WifiToggle = () => {
    const box = Widget.Box({
        class_name: "wifi_toggle",
        children: [
            Widget.Box({
                vertical: true,
                hexpand: true,
                children: [
                    Widget.Label({
                        hpack: "start",
                        class_name: "title",
                        label: "Wi-Fi"
                    }),
                    Widget.Label({
                        hpack: "start",
                        class_name: "description",
                        label: "Find and connect to Wi-Fi networks"
                    })
                ]
            }),
            Widget.Switch({
                vexpand: false,
                valign: Gtk.Align.CENTER,
                hpack: "end",
                on_activate(self) {
                    timeout(5, () => {
                        if (network.wifi.enabled != self.active)
                            network.wifi.enabled = self.active
                    })
                },
                active: Variable(false, {
                    poll: [500, () => network.wifi.enabled]
                }).bind()
            })
        ]
    })
    return box
}

function WifiList() {
    return Widget.Box({
        vertical: true,
        attribute: {
            'updateNetworks': (self) => {
                const accessPoints = network.wifi?.access_points || [];
                const current_ssid = network.wifi?.ssid;
                self.children = Object.values(accessPoints.reduce((a, accessPoint) => {
                    if (!a[accessPoint.ssid!]) {
                        a[accessPoint.ssid!] = accessPoint;
                        // @ts-ignore
                        a[accessPoint.ssid!].active |= accessPoint.active!;
                    }

                    return a;
                    // @ts-ignore
                }, {})).sort((a: AccessPoint, b: AccessPoint) => {
                    if (a.ssid === current_ssid) return -1;
                    if (b.ssid === current_ssid) return 1;
                    return 0;
                    // @ts-ignore
                }).map((n: AccessPoint) => WifiNetwork(n));
            },
        },
        className: 'wifi_list',
        setup: (self) => self.hook(network, self.attribute.updateNetworks),
    })
}

const nm_applet_required = () => Widget.Box({
    class_name: "error_container",
    visible: false,
    hexpand: true,
    child: Widget.Label({
        label: "Requires running nm-applet for authorization when connecting!",
        hpack: "start",
        vpack: "center"
    }),
    setup: self => {
        self.hook(systemtray, () => {
            const nm_applet = systemtray.items.find(item => item.id == "nm-applet")
            if (nm_applet)
                self.visible = false;
            else
                self.visible = true;
        })
    }
})

export function Network() {
    WifiScan()
    const box = Widget.Box({
        vertical: true,
        children: [
            nm_applet_required(),
            WifiToggle(),
            WifiList()
        ],
    })
    return Widget.Scrollable({
        hscroll: "never",
        child: box,
        vexpand: true
    })
}