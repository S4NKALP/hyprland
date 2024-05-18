export default ({ icon, label, ...rest }) =>
  Widget.Button({
    class_name: "qs-button",
    tooltip_text: label,
    child: Widget.Box({
      vertical: true,
      spacing: 4,
      children: [
        Widget.Icon({
          icon: icon,
          size: 18,
        }),
        Widget.Label({
          class_name: "label",
          label: label,
          maxWidthChars: 9,
          wrap: true,
          truncate: "end",
        }),
      ],
    }),
    ...rest,
  });
