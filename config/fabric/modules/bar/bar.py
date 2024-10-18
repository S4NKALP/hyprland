from __init__ import *


class Bar(Window):
    def __init__(self):
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

        self.kb_layout = Language(
            formatter=FormattedString(
                "{replace_lang(language)}",
                replace_lang=lambda lang: bulk_replace(
                    lang,
                    (r".*Eng.*", r".*Nep.*"),
                    ("en", "np"),
                    regex=True,
                ),
            ),
            name="kb_layout",
        )

        self.clock = DateTime(
            formatters=["%-I:%M %p %b %-d", "%-I:%M:%S %p %b %-d", "%a %-d %Y"],
            name="datetime",
        )

        self.system_tray = SystemTray(name="tray", spacing=4, icon_size=16)

        self.battery = BatteryLabel(name="battery")

        self.ram = RAMUsage()

        self.cpu = CPUUsage()

        self.swap = SwapMemoryUsage()

        self.wifi = Wifi()

        self.bluetooth = Bluetooth()

        self.TaskBar = TaskBar(name="tray", icon_size=16)

        self.volume = VolumeIndicator()

        self.microphone = MicrophoneIndicator()

        self.system_info = Box(
            name="tray",
            spacing=4,
            children=[
                self.ram,
                self.swap,
                self.cpu,
            ],
        )

        self.logo = Button(
            name="logo",
            child=Label("󰍉"),
            on_clicked=lambda _: exec_shell_command("fabric_send 'luancher.toggle()"),
        )

        self.applets = Box(
            name="applets",
            spacing=4,
            children=[
                self.kb_layout,
                self.bluetooth,
                self.wifi,
                self.volume,
                self.microphone,
            ],
        )
        self.power = PowerMenu()

        self.children = CenterBox(
            name="bar",
            start_children=Box(
                name="modules_left",
                spacing=8,
                orientation="h",
                children=[
                    self.logo,
                    self.TaskBar,
                ],
            ),
            center_children=Box(
                name="modules_center",
                spacing=8,
                orientation="h",
                children=[
                    # self.system_info,
                    self.workspaces,
                ],
            ),
            end_children=Box(
                name="modules_right",
                spacing=8,
                orientation="h",
                children=[
                    self.system_tray,
                    self.battery,
                    self.applets,
                    self.clock,
                    self.power,
                ],
            ),
        )

        self.show_all()
