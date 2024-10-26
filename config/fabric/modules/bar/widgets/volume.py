from fabric.audio.service import Audio
from fabric.utils import exec_shell_command, invoke_repeater
from fabric.widgets.box import Box
from fabric.widgets.button import Button


class VolumeIndicator(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        audio_service = Audio()

        self.audio_service = audio_service
        self.volume_icon = Button(
            label="󰖁",
            style="margin-left:6px; font-size:18px;",
            # name="symbol",
        )

        # Connect mouse button events to handle clicks
        self.volume_icon.connect("button-press-event", self.on_button_press)

        self.audio_service.connect("changed", self.update_volume_status)
        invoke_repeater(1000, self.update_volume_status, initial_call=True)
        self.children = (self.volume_icon,)

    def on_button_press(self, widget, event):
        if event.button == 1:
            self.on_clicked()
        elif event.button == 3:
            self.on_right_clicked()
        elif event.button == 2:
            self.on_middle_clicked()

    def on_right_clicked(self):
        exec_shell_command("pavucontrol")

    def on_clicked(self):
        current_stream = self.audio_service.speaker
        if current_stream:
            current_stream.muted = not current_stream.muted
            self.update_volume_status()

    # def on_middle_clicked(self):
    #     exec_shell_command("pavucontrol")

    def update_volume_status(self, *args):
        current_stream = self.audio_service.speaker
        if current_stream:
            volume_level = current_stream.volume
            is_muted = current_stream.muted

            if is_muted:
                self.volume_icon.set_label("󰖁")
            else:
                if volume_level == 0:
                    self.volume_icon.set_label("󰝟")
                elif volume_level <= 33:
                    self.volume_icon.set_label("󰕿")
                elif volume_level <= 66:
                    self.volume_icon.set_label("󰖀")
                else:
                    self.volume_icon.set_label("󰕾")

        return True
