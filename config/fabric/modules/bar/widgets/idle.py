from fabric.widgets.box import Box
from fabric.widgets.label import Label
from services.inhibit import Inhibit  # Importing Inhibit from the services module


class IdleIndicator(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.inhibit_service = Inhibit()  # Use the imported Inhibit service
        self.idle_icon = Label(
            label="󰅐",  # Icon symbol for idle/inhibit indication
            name="symbol",
        )

        # Add the idle icon as a child widget
        self.children = (self.idle_icon,)

        # Check the initial inhibition state and update the icon visibility
        self.update_idle_status()

    def update_idle_status(self):
        """Update the idle status based on inhibition state."""
        print(
            f"Inhibition state: {self.inhibit_service.is_inhibit}"
        )  # Debugging output

        if self.inhibit_service.is_inhibit:
            self.idle_icon.set_visible(True)  # Show the idle icon when inhibited
        else:
            self.idle_icon.set_visible(False)  # Hide the idle icon when not inhibited

    def toggle_idle(self):
        """Toggle the idle state by interacting with the inhibit service."""
        self.inhibit_service.toggle()  # Toggle the inhibition state
        self.update_idle_status()  # Refresh the icon visibility
