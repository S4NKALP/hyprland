require("configs.monitor_and_env")
require("configs.visuals")
-- require("configs.animations")
require("configs.keybinds")
require("configs.windowrules")
require("configs.startup_apps")
require("configs.misc")


dofile("/home/sankalp/.config/Modus/config/hypr/modus.lua")

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- $(python /home/sankalp/.config/Modus/main.py)")
end)