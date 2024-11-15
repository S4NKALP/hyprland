from fabric.utils import bulk_connect, exec_shell_command_async
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.eventbox import EventBox
from fabric.widgets.label import Label
from fabric.widgets.revealer import Revealer


class PowerMenu(EventBox):
    def __init__(self):
        super().__init__(name="power-event")

        icons_map = {
            "power-lock": "",
            "power-suspend": "",
            "power-logout": "",
            "power-reboot": "",
            "power-shutdown": "",
        }

        self.buttons = {
            name: Button(name=name, child=Label(label=f"{icon}"))
            for name, icon in icons_map.items()
        }

        self.power_box = Box(
            name="power-box",
            orientation="h",
            children=[
                self.buttons[name]
                for name in [
                    "power-lock",
                    "power-suspend",
                    "power-logout",
                    "power-reboot",
                ]
            ],
        )

        self.accept_button = Button(name="accept", child=Label(label="✔"))
        self.cancel_button = Button(name="cancel", child=Label(label="✘"))

        self.revealer_buttons_box = Box(
            name="confirm-box",
            orientation="h",
            children=[self.accept_button, self.cancel_button],
        )

        self.revealer = Revealer(
            name="power-revealer",
            transition_type="slide-right",
            transition_duration=300,
            child=self.power_box,
            reveal_child=False,
        )

        self.shutdown_box = Box(
            name="shutdown-box",
            orientation="h",
            children=[self.buttons["power-shutdown"]],
        )

        self.super_box = Box(
            name="super-box",
            orientation="h",
            children=[self.revealer, self.shutdown_box],
        )

        self.confirm_revealer = Revealer(
            name="confirm-revealer",
            transition_type="slide-right",
            transition_duration=300,
            child=self.revealer_buttons_box,
            reveal_child=False,
        )

        self.full_power = Box(
            name="full-power",
            orientation="h",
            children=[self.super_box, self.confirm_revealer],
        )

        self.add(self.full_power)
        self.buttons["self"] = self
        self.current_command = None
        self.confirmation_active = False

        for btn in self.buttons.values():
            bulk_connect(
                btn,
                {
                    "button-press-event": self.on_button_press,
                    "enter-notify-event": self.on_button_hover,
                    "leave-notify-event": self.on_button_unhover,
                },
            )

        self.accept_button.connect("button-press-event", self.on_accept_press)
        self.cancel_button.connect("button-press-event", self.on_cancel_press)

    def on_button_hover(self, button, event):
        if button == self and not self.confirmation_active:
            self.revealer.set_reveal_child(True)

    def on_button_unhover(self, button, event):
        if button == self and not self.confirmation_active:
            self.revealer.set_reveal_child(False)

    def on_button_press(self, button, event):
        commands = {
            self.buttons["power-lock"]: "hyprlock",
            self.buttons[
                "power-suspend"
            ]: "hyprctl dispatch exec hyprlock && systemctl suspend",
            self.buttons["power-logout"]: "hyprctl dispatch exit",
            self.buttons["power-reboot"]: "systemctl reboot",
            self.buttons["power-shutdown"]: "systemctl poweroff",
        }
        if button in commands:
            if button != self.buttons["power-lock"]:
                self.current_command = commands[button]
                self.revealer.set_reveal_child(False)
                self.confirm_revealer.set_reveal_child(True)
                self.shutdown_box.hide()
                self.confirmation_active = True

            else:
                exec_shell_command_async(commands[button], lambda *_: None)
        return True

    def on_accept_press(self, button, event):
        if self.current_command:
            exec_shell_command_async(self.current_command, lambda *_: None)
            self.current_command = None
            self.confirm_revealer.set_reveal_child(False)
            self.revealer.set_reveal_child(True)
            self.shutdown_box.show()
            self.confirmation_active = False

        return True

    def on_cancel_press(self, button, event):
        self.current_command = None
        self.confirm_revealer.set_reveal_child(False)
        self.revealer.set_reveal_child(True)
        self.shutdown_box.show()
        self.confirmation_active = False

        return True
