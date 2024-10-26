from fabric.audio.service import Audio
from fabric.widgets.box import Box
from fabric.widgets.label import Label


class MicrophoneIndicator(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        audio_service = Audio()
        self.audio_service = audio_service
        self.microphone_icon = Label(
            label="󰍭",
            name="symbol",
            # style="font-size: 16px; margin-left:4px;",
        )

        self.audio_service.connect("microphone_changed", self.update_microphone_status)

        self.update_microphone_status()

        self.children = (self.microphone_icon,)

    def update_microphone_status(self, *args):
        current_microphone = self.audio_service.microphone
        if current_microphone:
            is_muted = current_microphone.muted

            if is_muted:
                self.microphone_icon.set_visible(True)
            else:
                self.microphone_icon.set_visible(False)

        return True
