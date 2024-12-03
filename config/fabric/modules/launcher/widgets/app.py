from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from fabric.widgets.label import Label


def handle_application_search(launcher, query: str):
    query = query.strip()
    # Reveal the full app list if the query is empty
    if not query:
        launcher.additional_box.set_visible(True)
        launcher.scrolled_revealer.unreveal()
        return

    # Hide full app list and search through the available apps
    launcher.additional_box.set_visible(False)
    filtered_apps = [
        app
        for app in launcher.all_apps
        if query.casefold()
        in (
            " ".join(filter(None, [app.display_name, app.name, app.generic_name]))
        ).casefold()
    ]

    # Display filtered apps or hide the search results view if no matches
    if filtered_apps:
        launcher.viewport.children = [
            Button(
                child=Box(
                    orientation="h",
                    spacing=10,
                    children=[
                        Image(pixbuf=app.get_icon_pixbuf(), h_align="start", size=68),
                        Box(
                            orientation="v",
                            spacing=10,
                            children=[
                                Label(
                                    name="title",
                                    label=app.display_name or "Unknown",
                                    h_align="start",
                                    v_align="center",
                                ),
                                Label(
                                    name="description",
                                    label=app.description or "",
                                    justification="left",
                                    line_wrap="char",
                                    v_align="center",
                                ),
                            ],
                        ),
                    ],
                ),
                name="app-item",
                on_clicked=lambda *_: (app.launch(), launcher.set_visible(False)),
            )
            for app in filtered_apps[:6]  # Limit to 6 apps
        ]
        launcher.scrolled_revealer.reveal()
    else:
        launcher.scrolled_revealer.unreveal()
