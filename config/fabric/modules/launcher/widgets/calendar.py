from fabric.widgets.box import Box
from fabric.widgets.button import Button
from snippets import GtkCalendar, MaterialIcon


class Calendar:
    def __init__(self, launcher):
        self.launcher = launcher
        self.today_button = Button(
            child=MaterialIcon("event_available"),
            v_align="center",
        )

    def show_calendar_menu(self, viewport):
        viewport.children = []

        calendar_container = Box(
            name="calendar",
            children=GtkCalendar(h_expand=True),
        )

        viewport.add(calendar_container)

    def get_calendar_buttons(self):
        return self.today_button
