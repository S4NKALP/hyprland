class NetworkSpeedService extends Service {
  static {
    Service.register(
      this,
      {
        "upload-updated": ["float"],
        "download-updated": ["float"],
      },
      {
        "upload-speed": ["float", "r"],
        "download-speed": ["float", "r"],
        interval: ["float", "rw"],
      },
    );
  }

  #interval = 1000;
  #lastTotalDownBytes = 0;
  #lastTotalUpBytes = 0;
  #downloadSpeed = 0;
  #uploadSpeed = 0;

  get interval() {
    return this.#interval;
  }

  set interval(value) {
    this.#interval = value;
  }

  get download_speed() {
    return this.#downloadSpeed;
  }

  get upload_speed() {
    return this.#uploadSpeed;
  }

  constructor() {
    super();

    this.#onChange();
  }

  #onChange() {
    Utils.interval(this.#interval, () => {
      const content = Utils.exec("cat /proc/net/dev");
      const lines = content.split("\n");

      // Caculate the sum of all interfaces' traffic line by line.
      let totalDownBytes = 0;
      let totalUpBytes = 0;

      for (let i = 0; i < lines.length; ++i) {
        const fields = lines[i].trim().split(/\W+/);
        if (fields.length <= 2) {
          continue;
        }

        // Skip virtual interfaces.
        const interfce = fields[0];
        const currentInterfaceDownBytes = Number.parseInt(fields[1]);
        const currentInterfaceUpBytes = Number.parseInt(fields[9]);
        if (
          interfce === "lo" ||
          // Created by python-based bandwidth manager "traffictoll".
          interfce.match(/^ifb[0-9]+/) ||
          // Created by lxd container manager.
          interfce.match(/^lxdbr[0-9]+/) ||
          interfce.match(/^virbr[0-9]+/) ||
          interfce.match(/^br[0-9]+/) ||
          interfce.match(/^vnet[0-9]+/) ||
          interfce.match(/^tun[0-9]+/) ||
          interfce.match(/^tap[0-9]+/) ||
          isNaN(currentInterfaceDownBytes) ||
          isNaN(currentInterfaceUpBytes)
        ) {
          continue;
        }

        totalDownBytes += currentInterfaceDownBytes;
        totalUpBytes += currentInterfaceUpBytes;
      }

      if (this.#lastTotalDownBytes === 0) {
        this.#lastTotalDownBytes = totalDownBytes;
      }
      if (this.#lastTotalUpBytes === 0) {
        this.#lastTotalUpBytes = totalUpBytes;
      }
      this.#downloadSpeed =
        (totalDownBytes - this.#lastTotalDownBytes) / this.#interval;
      this.#uploadSpeed =
        (totalUpBytes - this.#lastTotalUpBytes) / this.#interval;
      this.emit("changed");
      this.notify("download-speed");
      this.notify("upload-speed");
      this.emit("upload-updated", this.#uploadSpeed);
      this.emit("download-updated", this.#downloadSpeed);

      this.#lastTotalDownBytes = totalDownBytes;
      this.#lastTotalUpBytes = totalUpBytes;
    });
  }
}
const service = new NetworkSpeedService();

export default service;
