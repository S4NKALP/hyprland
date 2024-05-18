const options = {
  lock: "hyprlock",
  sleep: "systemctl suspend",
  reboot: "systemctl reboot",
  logout: "pkill -u user",
  shutdown: "shutdown now",
};

class PowerMenu extends Service {
  static {
    Service.register(
      this,
      {},
      {
        title: ["string"],
        cmd: ["string"],
      },
    );
  }

  #title = "";
  #cmd = "";

  get title() {
    return this.#title;
  }

  get cmd() {
    return this.#cmd;
  }

  action(action) {
    [this.#cmd, this.#title] = {
      lock: [options.lock, "Lock"],
      sleep: [options.sleep, "Sleep"],
      reboot: [options.reboot, "Reboot"],
      logout: [options.logout, "Log Out"],
      shutdown: [options.shutdown, "Shutdown"],
    }[action];

    this.notify("cmd");
    this.notify("title");
    this.emit("changed");
    App.closeWindow("powermenu__window");
    App.openWindow("verification__window");
  }

  // readonly shutdown = () => {
  //   this.action("shutdown")
  // }
}

const powermenu = new PowerMenu();
export default powermenu;
