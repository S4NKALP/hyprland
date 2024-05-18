export default ({ window = "", child, setup, ...rest }) =>
  Widget.Button({
    child: Widget.Box({ hpack: "center", child }),
    setup: (self) => {
      let open = false;

      self.toggleClassName("panel-button");
      self.toggleClassName(window);

      self.hook(App, (_, win, visible) => {
        if (win !== window) return;

        if (open && !visible) {
          open = false;
          self.toggleClassName("active", false);
        }

        if (visible) {
          open = true;
          self.toggleClassName("active");
        }
      });

      if (setup) setup(self);
    },
    ...rest,
  });
