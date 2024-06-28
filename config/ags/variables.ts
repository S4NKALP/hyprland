const GLib = imports.gi.GLib;

export const current_wallpaper = Variable(`${GLib.get_home_dir()}/dotfiles/wallpapers/1.jpg`);

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


const wallpaper_cache_file = `${GLib.get_home_dir()}/.cache/current_wallpaper`
Utils.readFileAsync(wallpaper_cache_file)
    .then(out => { current_wallpaper.setValue(out.trim()); })
    .catch(err => {
        Utils.writeFileSync(current_wallpaper.value, wallpaper_cache_file)
    });

Utils.monitorFile(
    wallpaper_cache_file,
    () => {
        Utils.readFileAsync(wallpaper_cache_file)
            .then(out => { current_wallpaper.setValue(out); })
            .catch(print);
    }
)

