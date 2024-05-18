import { icon, layoutPos, sh } from "../../functions/utils.js";
import { configs } from "../../vars.js";
import PopupWindow from "../PopupWindow.js";
import { Arrow, Menu, Row } from "../ToggleButton.js";
const audio = await Service.import("audio");
const { bar } = configs.theme;

export const WINDOW_NAME = "audio__window";

const VolumeIndicator = (type = "speaker") =>
  Widget.Icon({
    icon: audio[type]
      .bind("icon_name")
      .as((i) => icon(i || "", "microphone-sensitivity-high-symbolic")),
    tooltipText: audio[type]
      .bind("volume")
      .as((vol) => `Volume: ${Math.floor(vol * 100)}%`),
    size: 18,
  });

const VolumeSlider = (type = "speaker") =>
  Widget.Slider({
    hexpand: true,
    draw_value: false,
    on_change: ({ value, dragging }) => {
      if (dragging) {
        audio[type].volume = value;
        audio[type].is_muted = false;
      }
    },
    value: audio[type].bind("volume"),
    class_name: audio[type].bind("is_muted").as((m) => (m ? "muted" : "")),
  });

export const Volume = () =>
  Widget.Box({
    class_name: "volume",
    spacing: 6,
    children: [
      VolumeIndicator("speaker"),
      VolumeSlider("speaker"),
      Widget.Box({
        vpack: "center",
        child: Arrow("sink-selector"),
      }),
      Widget.Box({
        vpack: "center",
        child: Arrow("app-mixer"),
        visible: audio.bind("apps").as((a) => a.length > 0),
      }),
    ],
  });

export const Microphone = () =>
  Widget.Box({
    class_name: "microphone",
    visible: audio.bind("recorders").as((a) => a.length > 0),
    spacing: 6,
    children: [VolumeIndicator("microphone"), VolumeSlider("microphone")],
  });

const MixerItem = (stream) =>
  Widget.Box(
    {
      hexpand: true,
      class_name: "mixer-item horizontal",
    },
    Widget.Icon({
      tooltip_text: stream.bind("name").as((n) => n || ""),
      icon: stream.bind("name").as((n) => {
        return Utils.lookUpIcon(n || "") ? n || "" : "audio-x-generic-symbolic";
      }),
    }),
    Widget.Box(
      { vertical: true },
      Widget.Label({
        xalign: 0,
        truncate: "end",
        max_width_chars: 18,
        label: stream.bind("description").as((d) => d || ""),
      }),
      Widget.Slider({
        hexpand: true,
        draw_value: false,
        value: stream.bind("volume"),
        on_change: ({ value }) => (stream.volume = value),
      }),
    ),
  );

const SinkItem = (stream) =>
  Widget.Button({
    hexpand: true,
    on_clicked: () => (audio.speaker = stream),
    child: Widget.Box({
      children: [
        Widget.Icon({
          icon: icon(stream.icon_name || "", "audio-x-generic-symbolic"),
          tooltip_text: stream.icon_name || "",
        }),
        Widget.Label(
          (stream.description || "").split(" ").slice(0, 4).join(" "),
        ),
        Widget.Icon({
          icon: "audio-x-generic-symbolic",
          hexpand: true,
          hpack: "end",
          visible: audio.speaker.bind("stream").as((s) => s === stream.stream),
        }),
      ],
    }),
  });

const SettingsButton = () =>
  Widget.Button({
    on_clicked: () => {
      sh("pavucontrol");
    },
    hexpand: true,
    child: Widget.Box({
      children: [
        Widget.Icon("emblem-system-symbolic"),
        Widget.Label("Settings"),
      ],
    }),
  });

export const AppMixer = () =>
  Menu({
    parentWindowName: WINDOW_NAME,
    name: "app-mixer",
    icon: "mixer-symbolic",
    title: "App Mixer",
    content: [
      Widget.Box({
        vertical: true,
        class_name: "vertical mixer-item-box",
        children: audio.bind("apps").as((a) => a.map(MixerItem)),
      }),
      Widget.Separator(),
      SettingsButton(),
    ],
  });

export const SinkSelector = () =>
  Menu({
    name: "sink-selector",
    parentWindowName: WINDOW_NAME,
    icon: "audio-headphones-symbolic",
    title: "Sink Selector",
    content: [
      Widget.Box({
        vertical: true,
        children: audio.bind("speakers").as((a) => a.map(SinkItem)),
      }),
      Widget.Separator(),
      SettingsButton(),
    ],
  });

const Container = () =>
  Widget.Box({
    class_names: ["audio__container", "window-content"],
    spacing: 8,
    vertical: true,
    children: [
      Row([Volume], [AppMixer, SinkSelector]),
      Widget.Separator({
        visible: audio.bind("recorders").as((a) => a.length > 0),
      }),
      Microphone(),
    ],
  });

const AudioWindow = () =>
  PopupWindow({
    name: WINDOW_NAME,
    animation: "slide top",
    layout: layoutPos(bar.position.value, "top-right"),
    child: Container(),
  });

export default function() {
  App.addWindow(AudioWindow());

  bar.position.connect("changed", () => {
    App.removeWindow(WINDOW_NAME);
    App.addWindow(AudioWindow());
  });
}
