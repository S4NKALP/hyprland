local modus = "/home/sankalp/.config/Modus"

hl.on("hyprland.start", function()
	local cmds = {
		"uwsm app -- awww-daemon",
		"wl-paste --type text --watch cliphist store",
		"wl-paste --type image --watch cliphist store",
		"pgrep -x hypridle >/dev/null || uwsm app -- hypridle",
		"uwsm app -- $(python " .. modus .. " main.py)",
	}
	for i = 1, #cmds do
		local cmd = cmds[i]
		hl.exec_cmd(cmd)
	end
end)

local fabricSend = "uwsm app -- fabric-cli exec modus "

-- Reload Modus
hl.bind("ALT + SHIFT + R", hl.dsp.exec_cmd("killall modus; cd " .. modus .. " && uwsm app -- uv run main.py"))

-- App Launcher
hl.bind("SUPER + D", hl.dsp.exec_cmd(fabricSend .. '"launcher.toggle()"'))

-- Emoji Selector
hl.bind("SUPER + E", hl.dsp.exec_cmd(fabricSend .. "\"launcher.toggle('em')\""))

-- Clipboard
hl.bind("SUPER + V", hl.dsp.exec_cmd(fabricSend .. "\"launcher.toggle('clip')\""))

-- Wallpaper
hl.bind("SUPER + W", hl.dsp.exec_cmd(fabricSend .. "\"launcher.toggle('wall')\""))

-- Powermenu
hl.bind("SUPER + X", hl.dsp.exec_cmd(fabricSend .. "\"launcher.toggle('pm')\""))

-- ScreenCapture
hl.bind("SUPER + Z", hl.dsp.exec_cmd(fabricSend .. "\"launcher.toggle('sc')\""))

-- Otp
hl.bind("SUPER + O", hl.dsp.exec_cmd(fabricSend .. "\"launcher.toggle('otp')\""))

-- Password Manager
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd(fabricSend .. "\"launcher.toggle('pass')\""))

-- Screenshot region
hl.bind("SUPER + S", hl.dsp.exec_cmd(fabricSend .. "\"launcher.toggle('sc region', external=True)\""))

-- Random Wallpaper
hl.bind("ALT + SHIFT + W", hl.dsp.exec_cmd(fabricSend .. "\"launcher.toggle('wr', external=True)\""))

-- Google Search
hl.bind("SUPER + G", hl.dsp.exec_cmd(fabricSend .. "\"launcher.toggle('gg')\""))

-- Window Switcher
hl.bind("ALT + W", hl.dsp.exec_cmd(fabricSend .. "\"launcher.toggle('win')\""))

-- Tmux
hl.bind("SUPER + T", hl.dsp.exec_cmd(fabricSend .. "\"launcher.toggle('tmux')\""))

-- KB_Layout Switcher
hl.bind("ALT + SPACE", hl.dsp.exec_cmd(fabricSend .. '"switch_keyboard_layout()"'))

hl.layer_rule({
	match = {
		namespace = "fabric",
	},
	no_anim = true,
})

local colors = dofile(modus .. "/config/hypr/colors.lua")

hl.config({
	general = {
		col = {
			active_border = colors.primary,
			inactive_border = colors.surface,
		},
		gaps_in = 2,
		gaps_out = 4,
		border_size = 2,
		layout = "scrolling",
	},
	decoration = {
		blur = {
			enabled = true,
			size = 5,
			passes = 3,
			new_optimizations = true,
			contrast = 1,
			brightness = 1,
		},
		rounding = 14,
		shadow = {
			enabled = true,
			range = 10,
			render_power = 2,
			color = "rgba(0, 0, 0, 0.25)",
		},
	},
	animations = {
		enabled = true,
	},
})

hl.curve("myBezier", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 2.5, bezier = "myBezier", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 2.5, bezier = "myBezier" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.5, bezier = "myBezier" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.5, bezier = "myBezier", style = "slidefade 20%" })
