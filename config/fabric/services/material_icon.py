# material_icon.py

from fabric.widgets.label import Label

def MaterialIcon(icon_name: str, size: str = "24px", props: dict = None):
    label_props = {
        "label": icon_name,      # Directly use the provided icon name
        "name": "material_icon",
        "style": f"font-size: {size}; ",  # Set font family for Material Icons
        "h_align": "center",       # Align horizontally
        "v_align": "center"        # Align vertically
    }

    if props:
        label_props.update(props)

    return Label(**label_props)

