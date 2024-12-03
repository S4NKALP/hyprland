from fabric.hyprland.widgets import Language
from fabric.system_tray.widgets import SystemTray
from fabric.utils import FormattedString, bulk_replace
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.datetime import DateTime
from fabric.widgets.wayland import WaylandWindow as Window
from modules.bar.widgets import Bluetooth  # SystemTray,
from modules.bar.widgets import (
    BatteryLabel,
    IdleIndicator,
    MicrophoneIndicator,
    Network,
    PowerProfile,
    SystemInfo,
    TaskBar,
    VolumeIndicator,
    workspace,
)


class Bar(Window):
    def __init__(
        self,
    ):
        super().__init__(
            layer="top",
            anchor="left bottom right",
            exclusivity="auto",
            visible=False,
            all_visible=False,
        )
        self.language = Language(
            formatter=FormattedString(
                "{replace_lang(language)}",
                replace_lang=lambda lang: bulk_replace(
                    lang,
                    (r".*Eng.*", r".*Nep.*"),
                    ("en", "np"),
                    regex=True,
                ),
            ),
        )

        self.date_time = DateTime(formatters=["%-I:%M 󰧞 %a %d %b"], name="datetime")
        self.system_tray = SystemTray(name="tray", spacing=4, icon_size=18)
        self.taskbar = TaskBar()
        self.volume = VolumeIndicator()
        self.network = Network()
        self.bluetooth = Bluetooth()
        self.battery = BatteryLabel(name="battery")
        self.microphone = MicrophoneIndicator()
        self.power = PowerProfile()
        self.workspaces = Button(child=workspace, name="workspaces")
        self.info = SystemInfo()
        self.idle = IdleIndicator()
        self.applets = Box(
            name="applets",
            spacing=4,
            children=[
                self.language,
                self.power,
                self.bluetooth,
                self.network,
                self.volume,
                self.microphone,
                self.idle,
            ],
        )

        self.children = CenterBox(
            name="bar",
            start_children=Box(
                name="start-container",
                spacing=8,
                orientation="h",
                children=[
                    self.workspaces,
                    self.info,
                ],
            ),
            center_children=Box(
                name="center-container",
                spacing=8,
                orientation="h",
                children=[
                    self.taskbar,
                ],
            ),
            end_children=Box(
                name="end-container",
                spacing=8,
                orientation="h",
                children=[
                    self.system_tray,
                    self.battery,
                    self.applets,
                    self.date_time,
                ],
            ),
        )

        self.show_all()
