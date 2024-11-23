from dataclasses import dataclass
from typing import Iterator, List

from fabric.audio import Audio
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.widgets.scale import Scale, ScaleMark
from fabric.widgets.wayland import WaylandWindow as Window
from gi.repository import GLib, GObject
from services import Brightness
from snippets import Animator, MaterialIcon


@dataclass
class IconMapping:
    threshold: float
    name: str


class BrightnessIcons:
    MAPPINGS: List[str] = [
        "brightness_1",
        "brightness_2",
        "brightness_3",
        "brightness_4",
        "brightness_5",
        "brightness_6",
        "brightness_7",
    ]
    MAX_BRIGHTNESS: float = 100
    RATIO: float = 1.6


class VolumeIcons:
    MAPPINGS: List[IconMapping] = [
        IconMapping(101, "sound_detection_loud_sound"),
        IconMapping(67, "volume_up"),
        IconMapping(34, "volume_down"),
        IconMapping(1, "volume_mute"),
        IconMapping(0, "volume_off"),
    ]


class AnimatedScale(Scale):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.animator = Animator(
            bezier_curve=(0.34, 1.56, 0.64, 1.0),
            duration=0.8,
            min_value=self.min_value,
            max_value=self.value,
            tick_widget=self,
            notify_value=self._update_scale_value,
        )

    def animate_value(self, value: float) -> None:
        self.animator.pause()
        self.animator.min_value = self.value
        self.animator.max_value = value
        self.animator.play()

    def _update_scale_value(self, provider: any, *_) -> None:
        self.set_value(provider.value)


class BaseOSDContainer(Box):
    def __init__(self, icon_name: str, icon_size: str, **kwargs):
        super().__init__(**kwargs, orientation="h", spacing=12, name="osd-container")
        self.icon = self._create_icon(icon_name, icon_size)
        self.scale = self._create_scale()
        self._setup_layout()

    def _setup_layout(self) -> None:
        self.add(self.icon)
        self.add(self.scale)

    def _create_icon(self, icon_name: str, icon_size: str) -> Label:
        return MaterialIcon(icon_name=icon_name, size=icon_size)

    def _create_scale(self) -> AnimatedScale:
        return AnimatedScale(
            marks=self._create_scale_marks(),
            value=70,
            min_value=0,
            max_value=100,
            increments=(1, 1),
            orientation="h",
        )

    def _create_scale_marks(self) -> Iterator[ScaleMark]:
        return (ScaleMark(value=i) for i in range(1, 100, 10))


class BrightnessOSDContainer(BaseOSDContainer):
    def __init__(self, **kwargs):
        super().__init__(icon_name="brightness_7", icon_size="28px", **kwargs)
        self.brightness_service = Brightness()
        self._setup_handlers()
        self.update_brightness()

    def _setup_handlers(self) -> None:
        self.scale.connect("value-changed", lambda *_: self.update_brightness())
        self.brightness_service.connect("screen", self.on_brightness_changed)

    def update_brightness(self) -> None:
        current_brightness = self.brightness_service.screen_brightness
        if current_brightness != 0:
            normalized_brightness = self._normalize_brightness(current_brightness)
            self._update_ui(normalized_brightness)

    def on_brightness_changed(self, _sender: any, value: float, *_args) -> None:
        normalized_brightness = self._normalize_brightness(value)
        self._update_ui(normalized_brightness)

    def _normalize_brightness(self, brightness: float) -> float:
        return (brightness / self.brightness_service.max_screen) * 100

    def _update_ui(self, brightness: float) -> None:
        self.scale.animate_value(brightness)
        self.update_icon(brightness)

    def update_icon(self, brightness_percentage: float) -> None:
        icon_name = self._calculate_icon_name(brightness_percentage)
        self.icon.set_label(icon_name)

    def _calculate_icon_name(self, brightness_percentage: float) -> str:
        thresholds = [
            BrightnessIcons.MAX_BRIGHTNESS
            / (BrightnessIcons.RATIO ** (len(BrightnessIcons.MAPPINGS) - i - 1))
            for i in range(len(BrightnessIcons.MAPPINGS))
        ]

        for i, threshold in enumerate(thresholds):
            if brightness_percentage < threshold:
                return BrightnessIcons.MAPPINGS[i]

        return BrightnessIcons.MAPPINGS[-1]


class AudioOSDContainer(BaseOSDContainer):
    __gsignals__ = {
        "volume-changed": (GObject.SIGNAL_RUN_FIRST, GObject.TYPE_NONE, ()),
    }

    def __init__(self, **kwargs):
        super().__init__(icon_name="volume_up", icon_size="29px", **kwargs)
        self.audio = Audio()
        self._setup_handlers()
        self.sync_with_audio()

    def _setup_handlers(self) -> None:
        self.scale.connect("value-changed", self.on_volume_changed)
        self.audio.connect("notify::speaker", self.on_audio_speaker_changed)

    def sync_with_audio(self) -> None:
        if self.audio.speaker:
            volume = round(self.audio.speaker.volume)
            self._update_ui(volume)

    def on_volume_changed(self, *_) -> None:
        if self.audio.speaker:
            volume = self.scale.value
            if 1 <= volume <= 100:
                self.audio.speaker.set_volume(volume)
                self._update_ui(volume)
                self.emit("volume-changed")

    def on_audio_speaker_changed(self, *_) -> None:
        if self.audio.speaker:
            self.audio.speaker.connect("notify::volume", self.update_volume)
            self.update_volume()

    def update_volume(self, *_) -> None:
        if self.audio.speaker and not self.is_hovered():
            volume = round(self.audio.speaker.volume)
            self._update_ui(volume)

    def _update_ui(self, volume: int) -> None:
        self.scale.set_value(volume)
        self.update_icon(volume)

    def update_icon(self, volume: int) -> None:
        icon_name = self._get_volume_icon(volume)
        self.icon.set_label(icon_name)

    def _get_volume_icon(self, volume: int) -> str:
        for mapping in VolumeIcons.MAPPINGS:
            if volume >= mapping.threshold:
                return mapping.name


class OSDContainer(Window):
    def __init__(self, **kwargs):
        self.audio_container = AudioOSDContainer()
        self.brightness_container = BrightnessOSDContainer()
        self.is_initial_display = True
        self.last_activity_time = GLib.get_monotonic_time()

        self.main_box = self._create_main_box()
        super().__init__(
            **kwargs,
            layer="overlay",
            anchor="bottom",
            exclusive=False,
            focusable=False,
            child=self.main_box,
            visible=True,
        )
        self._initialize()

    def _create_main_box(self) -> Box:
        return Box(
            orientation="v",
            spacing=13,
            children=[self.audio_container, self.brightness_container],
        )

    def _initialize(self) -> None:
        self._setup_containers()
        self._setup_event_handlers()
        self._setup_timers()

    def _setup_containers(self) -> None:
        self.audio_container.set_visible(True)
        self.brightness_container.set_visible(True)

    def _setup_event_handlers(self) -> None:
        self.audio_container.audio.connect("notify::speaker", self.show_audio)
        self.brightness_container.brightness_service.connect(
            "screen", self.show_brightness
        )
        self.audio_container.connect("volume-changed", self.show_audio)

    def _setup_timers(self) -> None:
        GLib.timeout_add_seconds(1, self._check_inactivity)
        GLib.timeout_add_seconds(1, self._end_initial_display)

    def _end_initial_display(self) -> bool:
        self.is_initial_display = False
        self._hide_all()
        return False

    def _hide_all(self) -> None:
        self.set_visible(False)
        self.audio_container.set_visible(False)
        self.brightness_container.set_visible(False)

    def show_audio(self, *_) -> None:
        if not self.is_initial_display:
            self._show_container(show_audio=True)

    def show_brightness(self, *_) -> None:
        if not self.is_initial_display:
            self._show_container(show_audio=False)

    def _show_container(self, show_audio: bool) -> None:
        self.audio_container.set_visible(show_audio)
        self.brightness_container.set_visible(not show_audio)
        self.set_visible(True)
        self._reset_inactivity_timer()

    def _reset_inactivity_timer(self) -> None:
        self.last_activity_time = GLib.get_monotonic_time()

    def _check_inactivity(self) -> bool:
        current_time = GLib.get_monotonic_time()
        if (
            not self.is_initial_display
            and (current_time - self.last_activity_time) / 1_000_000 >= 2
        ):
            self.set_visible(False)
        return True
