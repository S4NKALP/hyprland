local mainMod = "SUPER"

local terminal = "kitty"
local browser = "zen-browser"
local file_manager = "thunar"

-- Generates layout specific binds to avoid error warnings
local function layout_bind(bind_table)
	return function()
		local layout = hl.get_active_workspace().tiled_layout

		if bind_table[layout] then
			hl.dispatch(bind_table[layout])
		end
	end
end

-- apps launch
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd("uwsm app -- " .. terminal))
hl.bind("ALT + SHIFT + return", hl.dsp.exec_cmd("uwsm app -- " .. terminal), { float = true })
hl.bind("ALT + E", hl.dsp.exec_cmd("uwsm app -- " .. file_manager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("uwsm app -- " .. browser))

-- Increases / Decreases active window by x, y relatively
hl.bind("ALT + SHIFT + Z", hl.dsp.window.resize({ x = -80, y = -75, relative = true }))
hl.bind("ALT + SHIFT + C", hl.dsp.window.resize({ x = 80, y = 75, relative = true }))

hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.window.kill())

-- Toggle fullscreen and center floating window
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + F", function()
	hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
	hl.dispatch(hl.dsp.window.center())
end)

hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock -q")) -- hyprlock
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd("systemctl poweroff")) -- poweroff
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("systemctl reboot")) -- reboot

hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- pseudo tiling

-- Layout column resize
for key, dir in pairs({
	["ALT + SHIFT + F"] = "+conf", -- If scrolling layout, set next column width from config
	[mainMod .. " + SHIFT + W"] = "-conf", -- Scrolling: set previous column width from config
}) do
	hl.bind(key, layout_bind({ scrolling = hl.dsp.layout("colresize " .. dir) }))
end

-- Multi-layout specific binds
for key, val in pairs({
	H = { "swapcol l", "swapsplit", "cycleprev" },
	L = { "swapcol r", "togglesplit", "cyclenext" },
}) do
	hl.bind(
		mainMod .. " + SHIFT + " .. key,
		layout_bind({
			scrolling = hl.dsp.layout(val[1]),
			dwindle = hl.dsp.layout(val[2]),
			monocle = hl.dsp.layout(val[3]),
			master = hl.dsp.layout(val[3]),
		})
	)
end

-- Minimize active window
hl.bind("SUPER + Q", function()
	hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
	hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
	hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
	hl.dispatch(hl.dsp.window.move({ workspace = "special:minimize" }))
	hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
end)

-- Cycle workspaces and Scrolling / Layout
for key, val in pairs({
	D = { "e+1", "+col" },
	A = { "e-1", "-col" },
}) do
	hl.bind("ALT + SHIFT + " .. key, hl.dsp.focus({ workspace = val[1] })) -- Cycle workspace
	hl.bind("ALT + " .. key, hl.dsp.layout("move " .. val[2])) -- Scrolling
end

-- Move, Focus and Resize windows
for key, val in pairs({
	H = { "left", 70, 0 },
	L = { "right", -70, 0 },
	K = { "up", 0, -70 },
	J = { "down", 0, 70 },
}) do
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = val[1] })) -- Move
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = val[1] })) -- Focus
	hl.bind("ALT + SHIFT + " .. key, hl.dsp.window.resize({ x = val[2], y = val[3], relative = true })) -- Resize
end

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 9 do
	hl.bind(mainMod .. "+" .. i, hl.dsp.focus({ workspace = i }))
	hl.bind("ALT + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
	hl.bind(mainMod .. "+ SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Move/resize windows with SUPER + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Audio keys
for key, cmd in pairs({
	AudioRaiseVolume = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+",
	AudioLowerVolume = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",
	AudioMute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
	AudioMicMute = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",
}) do
	hl.bind("XF86" .. key, hl.dsp.exec_cmd(cmd), { locked = true, repeating = true })
end

-- brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("xf86Sleep", hl.dsp.exec_cmd("systemctl suspend"), { locked = true })

-- Playerctl
for key, cmd in pairs({
	AudioNext = "next",
	AudioPause = "play-pause",
	AudioPlay = "play-pause",
	AudioPrev = "previous",
}) do
	hl.bind("XF86" .. key, hl.dsp.exec_cmd("playerctl " .. cmd), { locked = true })
end

