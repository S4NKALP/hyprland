import subprocess
import re


class Inhibit:
    def __init__(self):
        self._id = None

    @property
    def is_inhibit(self):
        """Check if inhibition is active."""
        return self._id is not None

    def _inhibit(self, command, data):
        """Send a command to the DBus service to inhibit or un-inhibit."""
        dbus_command = (
            f"dbus-send --print-reply --dest=org.freedesktop.ScreenSaver "
            f"/org/freedesktop/ScreenSaver org.freedesktop.ScreenSaver.{command} {data}"
        )
        output = subprocess.run(
            dbus_command, shell=True, capture_output=True, text=True
        )

        if command == "Inhibit":
            match = re.search(r"uint32\s+(\d+)", output.stdout)
            return int(match.group(1)) if match else None
        return None

    def toggle(self):
        """Toggle the inhibition state."""
        if self._id is None:
            self._id = self._inhibit("Inhibit", "string:'ags' string:'Manual pause'")
        else:
            self._id = self._inhibit("UnInhibit", f"uint32:{self._id}")

        # Notify that the state has changed
        self.changed("is-inhibit")

    def changed(self, property_name):
        """Notify listeners that a property has changed."""
        print(
            f"Property '{property_name}' changed. Inhibition is now {'active' if self.is_inhibit else 'inactive'}."
        )
