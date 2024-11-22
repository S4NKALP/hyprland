from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from fabric.widgets.label import Label


def handle_application_search(launcher, query: str):
    query = query.strip()
    if not query:
        launcher.fav_apps_box.set_visible(True)
        launcher.additional_box.set_visible(True)
        launcher.scrolled_revealer.unreveal()
        return

    launcher.fav_apps_box.set_visible(False)
    launcher.additional_box.set_visible(False)
    filtered_apps = filter_apps_by_query(launcher.all_apps, query)

    if filtered_apps:
        limited_apps = filtered_apps[:6]
        launcher.viewport.children = [
            bake_application_slot(launcher, app) for app in limited_apps
        ]
        launcher.scrolled_revealer.reveal()
    else:
        launcher.scrolled_revealer.unreveal()


def filter_apps_by_query(all_apps, query: str):
    query_casefold = query.casefold()
    return [
        app
        for app in all_apps
        if query_casefold in build_app_search_string(app).casefold()
    ]


def build_app_search_string(app):
    return " ".join(filter(None, [app.display_name, app.name, app.generic_name]))


def bake_favorite_slot(launcher, app, **kwargs) -> Button:
    return Button(
        child=Image(pixbuf=app.get_icon_pixbuf(), size=68),
        name="fav-item",
        tooltip_text=app.description,
        on_clicked=lambda *_: (app.launch(), launcher.set_visible(False)),
        **kwargs,
    )


def bake_application_slot(launcher, app, **kwargs) -> Button:
    return Button(
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
