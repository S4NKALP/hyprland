-- Startup

hl.on("hyprland.start", function()
	local cmds = {
		"dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
		"gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Ice",
		"hyprctl setcursor Bibata-Modern-Ice 6",
		"/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
		"udiskie",
	}

	for i = 1, #cmds do
		local cmd = cmds[i]
		hl.exec_cmd(cmd)
	end
end)
