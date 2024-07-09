import { cpu_cores, cpu_name, kernel_name, amount_of_ram, gpu_name, cur_uptime } from "variables";
import Gtk from "gi://Gtk?version=3.0";
import { Variable as VariableType } from "types/variable";

type InfoType = {
    cpu: string;
    ram: string;
    swap: string;
    cpu_temp: string;
};

async function SystemInfo(): Promise<InfoType> {
    const cpu_usage = await Utils.execAsync(`${App.configDir}/scripts/system.sh --cpu-usage`)
        .then((str) => String(str))
        .catch((err) => {
            print(err);
            return "0";
        });
    const ram_usage = await Utils.execAsync(`${App.configDir}/scripts/system.sh --ram-usage`)
        .then((str) => String(str))
        .catch((err) => {
            print(err);
            return "0";
        });
    const swap_usage = await Utils.execAsync(`${App.configDir}/scripts/system.sh --swap-usage`)
        .then((str) => String(str))
        .catch((err) => {
            print(err);
            return "0";
        });
    const cpu_temp = await Utils.execAsync(`${App.configDir}/scripts/system.sh --cpu-temp`)
        .then((str) => String(str))
        .catch((err) => {
            print(err);
            return "0";
        });
    return {
        cpu: cpu_usage,
        ram: ram_usage,
        swap: swap_usage,
        cpu_temp: cpu_temp
    };
}

const usage = Variable(
    {
        cpu: "0",
        ram: "0",
        swap: "0",
        cpu_temp: "0"
    } as unknown as Promise<InfoType>,
    {
        poll: [
            1000,
            async () => {
                const result = await SystemInfo().then((result) => result);
                return result;
            }
        ]
    }
);

function checkBacklight() {
    const get = Utils.execAsync(`${App.configDir}/scripts/backlight.sh --get`)
        .then((out) => Number(out.trim()))
        .catch(print);
    return get;
}

function checkBrightness() {
    const get = Utils.execAsync(`${App.configDir}/scripts/brightness.sh --get`)
        .then((out) => Number(out.trim()))
        .catch(print);
    return get;
}

const current_backlight = Variable(100, {
    poll: [500, checkBacklight]
});

const current_brightness = Variable(100, {
    poll: [500, checkBrightness]
});

const Usage = (name: string, var_name: keyof InfoType, class_name: string | undefined) => {
    const usage_progress_bar = Widget.ProgressBar({
        class_name: "usage_bar",
        value: usage.bind().as((usage) => Number(usage[var_name]) / 100)
    });
    const usage_overlay = Widget.Overlay({
        child: usage_progress_bar,
        overlay: Widget.Box({
            hpack: "end",
            vpack: "center",
            class_name: "usage_bar_point"
        })
    });
    const _usage = Widget.Box({
        class_name: `${class_name} usage_box_inner`,
        orientation: Gtk.Orientation.VERTICAL,
        children: [
            Widget.Label({
                label: usage.bind().as((usage) => `${name}: ${usage[var_name]}%`),
                hpack: "start",
                vpack: "center"
            }),
            usage_overlay
        ]
    });

    return _usage;
};

const InfoLabel = (name: string, var_name: keyof InfoType, end: string) => {
    return Widget.Label({
        class_name: "info_label",
        truncate: "end",
        hpack: "start",
        label: usage.bind().as((usage) => `${name}: ${usage[var_name]}${end}`)
    });
};

const InfoLabelString = (name: string, value: string, end: string) => {
    return Widget.Label({
        class_name: "info_label",
        truncate: "end",
        hpack: "start",
        label: `${name}: ${value}${end}`
    });
};

const InfoLabelVariableString = (name: string, value: VariableType<string>, end: string) => {
    return Widget.Label({
        class_name: "info_label",
        truncate: "end",
        hpack: "start",
        label: value.bind().as((value) => `${name}: ${value}${end}`)
    });
};

export function SystemBox() {
    const backlight = Widget.Slider({
        min: 0,
        max: 100,
        draw_value: false,
        class_name: "system_scale backlight",
        // @ts-ignore
        value: current_backlight.bind(),
        on_change: (self) => {
            current_backlight.setValue(Number(self.value));
            Utils.execAsync(`${App.configDir}/scripts/backlight.sh --smooth ${self.value}`).catch(print);
        },
        tooltip_markup: "Backlight"
    });
    const brightness = Widget.Slider({
        min: 0,
        max: 1,
        draw_value: false,
        class_name: "system_scale brightness",
        // @ts-ignore
        value: current_brightness.bind(),
        on_change: (self) => {
            current_brightness.setValue(Number(self.value));
            Utils.execAsync(`${App.configDir}/scripts/brightness.sh --set ${self.value}`).catch(print);
        },
        tooltip_markup: "Brightness"
    });
    const slider_box = Widget.Box({
        orientation: Gtk.Orientation.VERTICAL,
        class_name: "slider_box",
        children: [backlight, brightness]
    });

    const usage_box = Widget.Box({
        orientation: Gtk.Orientation.VERTICAL,
        class_name: "usage_box",
        spacing: 0,
        children: [
            Usage("CPU", "cpu", "cpu_usage"),
            Usage("RAM", "ram", "ram_usage"),
            Usage("SWAP", "swap", "swap_usage")
        ]
    });

    const info_box = Widget.Box({
        orientation: Gtk.Orientation.VERTICAL,
        class_name: "info_box",
        spacing: 0,
        children: [
            InfoLabel("CPU temp", "cpu_temp", "°C"),
            InfoLabelString("CPU name", cpu_name, ""),
            InfoLabelString("CPU cores", cpu_cores, ""),
            InfoLabelString("RAM amount", amount_of_ram, ""),
            InfoLabelString("Kernel", kernel_name, ""),
            InfoLabelString("GPU", gpu_name, ""),
            InfoLabelVariableString("Uptime", cur_uptime, "")
        ],
        vexpand: true
    });

    return Widget.Scrollable({
        child: Widget.Box({
            orientation: Gtk.Orientation.VERTICAL,
            class_name: "system_box",
            spacing: 10,
            children: [slider_box, usage_box, info_box]
        })
    });
}
