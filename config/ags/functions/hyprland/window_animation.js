import { sendBatch } from "../utils.js";
import { configs } from "../../vars.js";

export default function windowAnimation() {
  sendBatch(
    App.windows
      .filter((win) => !!win.animation)
      .map(
        (win) =>
          `layerrule animation ${win.animation === "slide top" ? `slide ${configs.theme.bar.position.value}` : win.animation}, ${win.name}`,
      ),
  );
}
