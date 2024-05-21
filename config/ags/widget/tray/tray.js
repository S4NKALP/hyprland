const systemtray = await Service.import("systemtray")

export default () => Widget.Box({
    class_name: "tray",
    children: systemtray.bind("items").as(
        items => items.map(item => Widget.Button({
            child: Widget.Icon({icon: item.bind("icon")}),
            on_primary_click: (_, event) => item.activate(event),
            on_secondary_click: (_, event) => item.openMenu(event),
            tooltip_markup: item.bind("tooltip_markup"),
        }))
    ),
    setup: self => self.hook(systemtray, self => {
        self.visible = self.children.length > 0
    })
})
