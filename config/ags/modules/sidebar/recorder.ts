import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import { exec, execAsync } from 'resource:///com/github/Aylur/ags/utils.js';

function isScreenRecordingOn() {
    let state = exec('bash -c "pidof wf-recorder > /dev/null; echo $?"');
    return state == "0";
}

let recordingStartTime = null;
let recordingInterval = null;

function formatTime(ms) {
    let totalSeconds = Math.floor(ms / 1000);
    let hours = Math.floor(totalSeconds / 3600);
    let minutes = Math.floor((totalSeconds % 3600) / 60);
    let seconds = totalSeconds % 60;

    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
}

function startRecordingTimer(button) {
    recordingStartTime = Date.now();
    recordingInterval = setInterval(() => {
        let elapsedTime = Date.now() - recordingStartTime;
        button.label = formatTime(elapsedTime);
    }, 1000);
}

function stopRecordingTimer(button) {
    clearInterval(recordingInterval);
    recordingStartTime = null;
    recordingInterval = null;
    button.label = 'Start Recording';
}

export const ScreenRecordButton = (w, h) => Widget.Button({
    class_name: `control-panel-button`,
    css: `
        min-width: ${w}rem;
        min-height: ${h}rem;
    `,
    on_clicked: (self) => {
        let isRecording = isScreenRecordingOn();

        if (isRecording) {
            stopRecordingTimer(self);
        } else {
            startRecordingTimer(self);
        }

        self.toggleClassName("active-button", !isRecording);
        self.toggleClassName("recording", !isRecording);

        execAsync(['bash', '-c', 'mkdir -p ~/Screenrecordings; pkill wf-recorder; if [ $? -ne 0 ]; then wf-recorder -f ~/Screenrecordings/recording_"$(date +\'%b-%d-%Y-%I:%M:%S-%P\')".mp4 -g "$(slurp)" --pixel-format yuv420p; fi']).catch(logError);
    },
    child: Widget.Icon({
        size: 22,
        icon: "media-record-symbolic",
        setup: self => {
            self.label = 'Start Recording';
        }
    })
});
