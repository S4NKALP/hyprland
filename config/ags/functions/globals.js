import recorder from "../services/screen_record.js";
import brightness from "../services/brightness.js";
import { capsLockState, configs } from "../vars.js";
import GLib from "gi://GLib";

export default function globals() {
  globalThis.TMP = GLib.get_tmp_dir() + "/ags";
  Utils.ensureDirectory(TMP);
  globalThis.recorder = recorder;
  globalThis.brightness = brightness;
  globalThis.update_capslock = () => {
    Utils.exec(`brightnessctl -d input3::capslock g`, (stdout) => {
      capsLockState.setValue(stdout);
    });
  };
  globalThis.moveBar = (pos) => {
    configs.theme.bar.position.updateValue(pos);
  };
}
