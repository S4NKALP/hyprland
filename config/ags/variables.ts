const GLib = imports.gi.GLib;

export const screen_recorder = Variable(false);
export const idle_inhibitor = Variable(false);
export const night_light = Variable(false);
export const bluetooth_enabled = Variable('off', {
    poll: [1000, `${App.configDir}/scripts/bluetooth.sh --get`]
})


export const icons = {
    'performance': ' ',
    'balanced': ' ',
    'power-saver': '󰡵 '
};
