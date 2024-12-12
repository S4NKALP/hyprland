from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from fabric.widgets.label import Label


def handle_application_search(launcher, query: str):
    if not query.strip():
        launcher.additional_box.set_visible(True)
        return

    launcher.additional_box.set_visible(False)
    filtered_apps = [
        app
        for app in launcher.all_apps
        if query.casefold()
        in (
            (app.display_name or "")
            + " "
            + (app.name or "")
            + " "
            + (app.generic_name or "")
        ).casefold()
    ]

    if filtered_apps:
        launcher.viewport.children = [
            bake_application_slot(launcher, app) for app in filtered_apps[:6]
        ]
        launcher.scrolled_revealer.reveal()
    else:
        launcher.scrolled_revealer.unreveal()


def bake_application_slot(launcher, app, **kwargs) -> Button:
    return Button(
        child=Box(
            orientation="h",
            spacing=10,
            children=[
                Image(pixbuf=app.get_icon_pixbuf(), h_align="start", size=62),
                Box(
                    orientation="v",
                    spacing=10,
                    children=[
                        Label(
                            label=app.display_name or "Unknown",
                            h_expand=True,
                            name="title",
                            v_align="center",
                            h_align="start",
                        ),
                        Label(
                            label=app.description or "",
                            name="description",
                            h_expand=True,
                            v_align="center",
                            justification="left",
                            line_wrap="char",
                        ),
                    ],
                ),
            ],
        ),
        name="app-item",
        on_clicked=lambda *_: (app.launch(), launcher.set_visible(False)),
        **kwargs,
    )
