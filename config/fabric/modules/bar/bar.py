from fabric.hyprland.widgets import Language, WorkspaceButton, Workspaces
from fabric.system_tray.widgets import SystemTray
from fabric.utils import FormattedString, bulk_replace
from fabric.widgets.box import Box
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.datetime import DateTime
from fabric.widgets.wayland import WaylandWindow as Window
from modules.bar.widgets import (
    BatteryLabel,
    Bluetooth,
    MicrophoneIndicator,
    PowerProfile,
    TaskBar,
    VolumeIndicator,
    Wifi,
)

from .glance import OpenAppsBar


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
        self.workspaces = Workspaces(
            name="workspaces",
            spacing=4,
            buttons=[WorkspaceButton(id=i, label=str(i)) for i in range(1, 11)],
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
        self.system_tray = SystemTray(spacing=4, icon_size=18)

        self.TaskBar = TaskBar(icon_size=18)
        self.volume = VolumeIndicator()
        self.wifi = Wifi()
        self.bluetooth = Bluetooth()
        self.battery = BatteryLabel(name="battery")
        self.microphone = MicrophoneIndicator()
        self.power = PowerProfile()
        self.open_apps_bar = OpenAppsBar()

        self.applets = Box(
            name="applets",
            spacing=4,
            children=[
                self.language,
                self.power,
                self.bluetooth,
                self.wifi,
                self.volume,
                self.microphone,
                # self.battery,
            ],
        )
        self.children = CenterBox(
            name="bar",
            start_children=Box(
                name="start-container",
                spacing=8,
                orientation="h",
                children=self.TaskBar,
            ),
            center_children=Box(
                name="center-container",
                spacing=8,
                orientation="h",
                children=[
                    self.workspaces,
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
