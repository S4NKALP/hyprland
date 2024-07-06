import { MaterialIcon } from "icons";

const { GLib } = imports.gi;

const lock_command = `hyprlock`;
const logout_command = `loginctl kill-session $XDG_SESSION_ID`;
const shutdown_command = `systemctl poweroff`;
const reboot_command = `systemctl reboot`;
const suspend_command = `systemctl suspend`;

function LockButton({ icon, ...props }) {
    let clickCount = 0;
    let button = Widget.Button({
        tooltip_text: "Lock",
        child: MaterialIcon(icon, "20px"),
        class_name: "outline_button",
        ...props
    });

    button.connect("clicked", () => {
        clickCount++;
        if (clickCount === 2) {
            Utils.execAsync(lock_command).catch(print);
            clickCount = 0;
        }
    });

    button.connect("focus-out-event", () => {
        clickCount = 0;
    });

    return button;
}

function SuspendButton({ icon, ...props }) {
    let clickCount = 0;
    let button = Widget.Button({
        tooltip_text: "Suspend",
        child: MaterialIcon(icon, "20px"),
        class_name: "outline_button",
        ...props
    });

    button.connect("clicked", () => {
        clickCount++;
        if (clickCount === 2) {
            Utils.execAsync(`mpc -q pause`).catch();
            Utils.execAsync(`playerctl pause`).catch();
            Utils.execAsync(suspend_command).catch();
            clickCount = 0;
        }
    });

    button.connect("focus-out-event", () => {
        clickCount = 0;
    });

    return button;
}

function LogoutButton({ icon, ...props }) {
    let clickCount = 0;
    let button = Widget.Button({
        tooltip_text: "Logout",
        child: MaterialIcon(icon, "20px"),
        class_name: "outline_button",
        ...props
    });

    button.connect("clicked", () => {
        clickCount++;
        if (clickCount === 2) {
            Utils.execAsync(logout_command).catch();
            clickCount = 0;
        }
    });

    button.connect("focus-out-event", () => {
        clickCount = 0;
    });

    return button;
}

function RebootButton({ icon, ...props }) {
    let clickCount = 0;
    let button = Widget.Button({
        tooltip_text: "Reboot",
        child: MaterialIcon(icon, "20px"),
        class_name: "outline_button",
        ...props
    });

    button.connect("clicked", () => {
        clickCount++;
        if (clickCount === 2) {
            Utils.execAsync(reboot_command).catch();
            clickCount = 0;
        }
    });

    button.connect("focus-out-event", () => {
        clickCount = 0;
    });

    return button;
}

function ShutdownButton({ icon, ...props }) {
    let clickCount = 0;
    let button = Widget.Button({
        tooltip_text: "Shutdown",
        child: MaterialIcon(icon, "20px"),
        class_name: "outline_button",
        ...props
    });

    button.connect("clicked", () => {
        clickCount++;
        if (clickCount === 2) {
            Utils.execAsync(shutdown_command).catch();
            clickCount = 0;
        }
    });

    button.connect("focus-out-event", () => {
        clickCount = 0;
    });

    return button;
}

export function Buttons() {
    return Widget.Box({
        class_name: "sidebar_buttons",
        hexpand: true,
        spacing: 5,
        children: [
            LockButton({
                icon: "lock",
                hexpand: true
            }),
            SuspendButton({
                icon: "clear_night",
                hexpand: true
            }),
            LogoutButton({
                icon: "logout",
                hexpand: true
            }),
            RebootButton({
                icon: "restart_alt",
                hexpand: true
            }),
            ShutdownButton({
                icon: "power_settings_new",
                hexpand: true
            })
        ]
    });
}
