-- Keybinds

local terminal = "kitty"
local filemanager = "thunar"
local telegram = "materialgram"
local browser = "zen-browser"

local mainMod = "SUPER"

hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.window.kill())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + F", function()
	hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
	hl.dispatch(hl.dsp.window.center())
end)

-- Testing
hl.bind(
	"ALT + F12",
	hl.dsp.exec_cmd(
		'notify-send \'Test notification\' "Here\'s a really long message to test truncation and wrapping\\nYou can middle click or flick this notification to dismiss it!" -a \'terminal\' -A "Test1=I got it!" -A "Test2=Another action"'
	)
)
hl.bind("ALT + Equal", hl.dsp.exec_cmd("notify-send 'hmm' ${SLURP_ARGS}"))

local message_cmd =
	'notify-send "Hello" "FIRE IN THE HOLE‼️🗣️🔥🕳️" -i "/home/sankalp/.face.icon" -A "🗣️" -A "🔥" -A "🕳️" -a "Source Code"'
hl.bind(mainMod .. "+ ALT + N", hl.dsp.exec_cmd(message_cmd))

hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(terminal))
hl.bind("ALT + SHIFT + return", hl.dsp.exec_cmd(terminal .. " --title float_kitty --single-instance"))
hl.bind("ALT + E", hl.dsp.exec_cmd("uwsm app -- " .. filemanager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("uwsm app -- " .. browser))
hl.bind("ALT + T", hl.dsp.exec_cmd("uwsm app -- " .. telegram))

hl.bind(mainMod .. " + SHIFT + Y", hl.dsp.exec_cmd("grimblast save active ~/Pictures/Screenshots/"))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock -q"))
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd("systemctl poweroff"))
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("systemctl reboot"))

hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.layout("togglesplit"))

-- Cycle through existing workspaces
hl.bind("ALT + SHIFT + D", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + SHIFT + A", hl.dsp.focus({ workspace = "e-1" }))

-- Scrolling / Layout
hl.bind("ALT + D", hl.dsp.layout("move +col"))
hl.bind("ALT + A", hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.layout("swapcol l"))


-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move window --
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

-- Focus to different window --
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
	hl.bind("SHIFT + ALT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop keys
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("xf86Sleep", hl.dsp.exec_cmd("systemctl suspend"), { locked = true })

-- Playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
