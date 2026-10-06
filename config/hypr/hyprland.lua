require("configs.monitor_and_env")
require("configs.visuals")
-- require("configs.animations")
require("configs.keybinds")
require("configs.windowrules")
require("configs.startup_apps")
require("configs.misc")

-- Modus configuration
-- dofile("/home/sankalp/.config/Modus/config/hypr/modus.lua")

-- Forma — owns startup services + fabric keybinds (loaded last: wins on dup keys)
dofile("/home/sankalp/Projects/pill/forma/config/forma.lua")

-- local fabricSend = "fabric-cli exec forma"
--
-- hl.bind("SUPER + R", hl.dsp.exec_cmd(fabricSend .. " 'launcher()'"))
-- hl.bind("SUPER + Y", hl.dsp.exec_cmd(fabricSend .. " 'clipboard()'"))
-- hl.bind("SUPER + G", hl.dsp.exec_cmd(fabricSend .. " 'emoji()'"))
-- hl.bind("SUPER + N", hl.dsp.exec_cmd(fabricSend .. " 'link()'"))
-- hl.bind("ALT + W", hl.dsp.exec_cmd(fabricSend .. " 'wallpaper()'"))
-- hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd("pkill -f 'ma[i]n.py'"))
