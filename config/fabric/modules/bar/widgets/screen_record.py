from fabric import Fabricator
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from services import ScreenRecorder
from snippets import MaterialIcon


class ScreenRecordButton(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.recorder = ScreenRecorder()
        self.record_icon_button = self.create_record_icon()

        Fabricator(interval=1000, poll_from=self.update_recording_status)

        self.children = (self.record_icon_button,)

    def create_record_icon(self):
        icon = MaterialIcon("screen_record", size="16px")
        button = Button(child=icon, on_clicked=self.stop_recording)
        button.icon_widget = icon
        return button

    def stop_recording(self, *_):
        self.recorder.screencast_stop()
        self.update_recording_status()

    def update_recording_status(self, *_):
        if self.recorder.recording:
            self.record_icon_button.icon_widget.set_label("screen_record")

        return True
