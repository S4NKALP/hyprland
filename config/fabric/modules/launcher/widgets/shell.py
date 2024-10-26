from fabric.widgets.button import Button
from fabric.widgets.label import Label
from services.sh import Sh


class ShellCommandManager:
    def __init__(self, launcher):
        self.sh_instance = Sh()
        self.launcher = launcher  # Store reference to Launcher

    def show_shell_commands(self, viewport, search_query: str):
        if not search_query:
            return

        def on_query_done(results):
            if not results:
                return

            for bin in results:
                button = Button(
                    child=Label(
                        label=bin,
                        h_expand=True,
                        v_align="center",
                        h_align="start",
                    ),
                    on_clicked=lambda _, cmd=bin: (
                        self.execute_command(cmd),  # Execute command and close launcher
                    ),
                    name="sh-item",
                )
                viewport.add(button)

        # Reload shell command list and query
        self.sh_instance.reload()
        results = Sh.query(search_query)
        on_query_done(results)

    def execute_command(self, cmd: str):
        try:
            Sh.run(cmd)  # Run the shell command
            self.launcher.set_visible(False)  # Close the launcher after execution
        except Exception as e:
            logger.error(f"Error executing command: {e}")
