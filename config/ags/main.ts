"use strict";
// Import
import Gdk from 'gi://Gdk';
// widgets
import { Bar, BarCornerTopLeft, BarCornerTopRight } from './modules/bar.ts';
import { Bar } from './modules/bar.ts';
import { Notifications } from "./modules/notificationPopups.ts"
import { applauncher } from "./modules/applauncher.js"
import { media } from "./modules/media.ts"
import { cliphist } from "./modules/cliphist.ts"
import {} from 'apps/emoji/main.ts';
import { sidebar } from "./modules/sidebar/main.ts"
import { cheatsheet } from './modules/cheatsheet.ts';
import {} from 'apps/settings/main.ts';
import Window from 'types/widgets/window';
const GLib = imports.gi.GLib;


const range = (length: number, start = 1) => Array.from({ length }, (_, i) => i + start);
function forMonitors(widget: (index: number) => Window<any, any>): Window<any, any>[] {
    const n = Gdk.Display.get_default()?.get_n_monitors() || 1;
    return range(n, 0).map(widget).flat(1);
}
function forMonitorsAsync(widget: (index: number) => Promise<Window<any, any>>) {
    const n = Gdk.Display.get_default()?.get_n_monitors() || 1;
    return range(n, 0).forEach((n) => widget(n).catch(print))
}

const Windows = () => [
    forMonitors(Notifications),
    forMonitors(BarCornerTopLeft),
    forMonitors(BarCornerTopRight),
    media,
    applauncher,
    cliphist,
    cheatsheet,
    sidebar,
];

const CLOSE_ANIM_TIME = 210;
const closeWindowDelays = {};
for (let i = 0; i < (Gdk.Display.get_default()?.get_n_monitors() || 1); i++) {
    closeWindowDelays[`osk${i}`] = CLOSE_ANIM_TIME;
}

App.config({
    windows: Windows().flat(1),
    // @ts-ignore
    closeWindowDelay: closeWindowDelays,
    onConfigParsed: function () {
    },
});

function ReloadCSS() {
    App.resetCss()
    // Utils.execAsync(`cp -f -r ${GLib.get_home_dir()}/dotfiles/material-colors/generated/svg/ ${App.configDir}/`).catch(print)
    App.applyCss(`${App.configDir}/style.css`)
    App.applyCss(`${App.configDir}/style-apps.css`)
}

function ReloadGtkCSS() {
    App.applyCss(`${GLib.get_home_dir()}/.config/gtk-3.0/gtk.css`)
    ReloadCSS()
}

Utils.monitorFile(
    `${App.configDir}/style.css`,
    ReloadCSS
)

Utils.monitorFile(
    `${App.configDir}/style-apps.css`,
    ReloadCSS
)

Utils.monitorFile(
    `${GLib.get_home_dir()}/.cache/material/colors.json`,
    ReloadCSS
)

Utils.monitorFile(
    `${GLib.get_home_dir()}/.config/gtk-3.0/gtk.css`,
    ReloadGtkCSS
)
forMonitorsAsync(Bar)
ReloadGtkCSS()
