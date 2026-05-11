local function apply_window_rule(rule)
	if hl.window_rule then
		hl.window_rule(rule)
	end
end

-- 1. Tag Assignments (Class regex -> Tag)
local tags = {
	browser = {
		"^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$",
		"^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$",
		"^(chrome-.+-Default)$",
		"^([Cc]hromium)$",
		"^([Mm]icrosoft-edge(-stable|-beta|-dev|-unstable))$",
		"^([Bb]rave-browser(-beta|-dev|-unstable)?)$",
		"^([Tt]horium-browser|[Cc]achy-browser)$",
		"^(zen-alpha|zen|zen-browser)$",
	},
	notif = { "^(swaync-control-center|swaync-notification-window|swaync-client|class)$" },
	terminal = { "^(ghostty|wezterm|Alacritty|kitty|Kitty)$" },
	email = {
		"^([Tt]hunderbird|org.mozilla.Thunderbird)$",
		"^(eu.betterbird.Betterbird)$",
		"^(org.gnome.Evolution)$",
	},
	projects = {
		"^(codium|codium-url-handler|VSCodium)$",
		"^(VSCode|code|code-url-handler)$",
		"^(jetbrains-.+)$",
		"^(dev.zed.Zed|antigravity)$",
	},
	screenshare = { "^(com.obsproject.Studio)$" },
	im = {
		"^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$",
		"^([Ff]erdium)$",
		"^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$",
		"^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop|materialgram)$",
		"^(teams-for-linux)$",
		"^(im.riot.Riot|Element)$",
	},
	games = { "^(gamescope)$", "^(steam_app_\\d+)$" },
	gamestore = { "^([Ss]team)$", "^(com.heroicgameslauncher.hgl)$" },
	["file-manager"] = { "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$", "^(app.drey.Warp)$" },
	wallpaper = { "^([Ww]aytrogen)$" },
	multimedia = { "^([Aa]udacious)$" },
	multimedia_video = { "^([Mm]pv|vlc)$" },
	settings = {
		"^(wihotspot(-gui)?)$",
		"^([Bb]aobab|org.gnome.[Bb]aobab)$",
		"^(gnome-disks|wihotspot(-gui)?)$",
		"^(file-roller|org.gnome.FileRoller)$",
		"^(nm-applet|nm-connection-editor|blueman-manager)$",
		"^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$",
		"^(qt5ct|qt6ct|[Yy]ad|nwg-look)$",
		"^(org.kde.polkit-kde-authentication-agent-1)$",
		"^([Rr]ofi)$",
		"^(btrfs-assistant)$",
		"^(timeshift-gtk)$",
	},
	viewer = {
		"^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$",
		"^(evince|zathura)$",
		"^(eog|org.gnome.Loupe|imv|imv-dir)$",
	},
}

for tag, patterns in pairs(tags) do
	for _, pattern in ipairs(patterns) do
		apply_window_rule({ match = { class = pattern }, tag = "+" .. tag })
	end
end

-- Manual Tags/Rules
apply_window_rule({ match = { xdg_tag = "^(proton-game)$" }, tag = "+games" })
apply_window_rule({ match = { title = "^([Ll]utris)$" }, tag = "+gamestore" })
apply_window_rule({ match = { title = "^(ROG Control)$" }, tag = "+settings" })
apply_window_rule({ match = { title = "(Kvantum Manager)" }, tag = "+settings" })
apply_window_rule({ match = { class = "(xdg-desktop-portal-gtk)" }, tag = "+settings" })

-- 3. Floating, Centered, and Sized Rules
local simple_rules = {
	{ match = { class = "([Zz]oom|onedriver|onedriver-launcher)" }, float = true },
	{ match = { class = "^(mpv|com.github.rafostar.Clapper)$" }, float = true },
	{ match = { class = "^([Qq]alculate-gtk)$" }, float = true },
	{ match = { title = "^(Authentication Required)$" }, float = true, center = true },
	{
		match = {
			class = "^(xfce-polkit|mate-polkit|polkit-mate-authentication-agent-1)$",
			title = "^(Authentication required|Authentication Required)$",
		},
		float = true,
		center = true,
		size = "(monitor_w*0.35) (monitor_h*0.35)",
	},
	{ match = { class = "(codium|codium-url-handler|VSCodium)", title = "negative:(.*codium.*|.*VSCodium.*)" }, float = true },
	{ match = { class = "^(com.heroicgameslauncher.hgl)$", title = "negative:(Heroic Games Launcher)" }, float = true },
	{ match = { class = "^([Ss]team)$", title = "negative:^([Ss]team)$" }, float = true },
	{
		match = { title = "^(Add Folder to Workspace)$" },
		float = true,
		center = true,
		size = "(monitor_w*0.7) (monitor_h*0.6)",
	},
	{ match = { title = "^(Save As)$" }, float = true, center = true, size = "(monitor_w*0.7) (monitor_h*0.6)" },
	{ match = { initial_title = "(Open Files)" }, float = true, size = "(monitor_w*0.7) (monitor_h*0.6)" },
	{ match = { class = "^(yad)$" }, float = true, center = true, size = "(monitor_w*0.2) (monitor_h*0.2)" },
	{ match = { class = "^(hyprland-donate-screen)$" }, float = true, center = true },
	{ match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" }, center = true },
	{ match = { class = "^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$" }, center = true },
	{ match = { class = "^(nm-connection-editor)$" }, center = true },
	{ match = { class = "^(nm-applet)$", title = "^(Wi-Fi Network Authentication Required)$" }, center = true },
	{ match = { fullscreen = true }, idle_inhibit = "fullscreen" },
	{ match = { fullscreen = 1 }, idle_inhibit = "fullscreen" },
	{ match = { class = ".*" }, idle_inhibit = "fullscreen" },
	{ match = { title = ".*" }, idle_inhibit = "fullscreen" },
	{ match = { class = "^(gedit|org.gnome.TextEditor|mousepad)$" }, opacity = "0.8 0.7" },
	{ match = { class = "^(deluge)$" }, opacity = "0.9 0.8" },
	{ match = { class = "^(seahorse)$" }, opacity = "0.9 0.8" },
	{ match = { class = "^(jetbrains-.*)$" }, no_initial_focus = true },
	{ match = { title = "^(wind.*)$" }, no_initial_focus = true },
	{ match = { class = "^([Tt]hunar)$" }, workspace = 4 },
}

for _, rule in ipairs(simple_rules) do
	apply_window_rule(rule)
end

-- 4. Named/Complex Rules
local special_rules = {
	{
		name = "Picture-in-Picture",
		match = { title = "^[Pp]icture-in-[Pp]icture$" },
		float = true,
		move = "72% 7%",
		opacity = "0.95 0.75",
		pin = true,
		keep_aspect_ratio = true,
		size = "(monitor_w*0.3) (monitor_h*0.3)",
	},
	{
		name = "NVIDIA Settings",
		match = {
			class = "^(nvidia-settings)$",
			title = "^(NVIDIA Settings)$",
			initial_class = "^(nvidia-settings)$",
			initial_title = "^(NVIDIA Settings)$",
		},
		float = true,
		center = true,
		size = "(monitor_w*0.6) (monitor_h*0.6)",
	},
	{
		name = "Ferdium",
		match = { class = "^([Ff]erdium)$" },
		float = true,
		center = true,
		size = "(monitor_w*0.6) (monitor_h*0.7)",
	},
	{
		name = "Calculators",
		match = { class = "(org.gnome.Calculator|qalculate-gtk)" },
		float = true,
		center = true,
		size = "(monitor_w*0.55) (monitor_h*0.45)",
	},
	{
		name = "Thunar Dialogs",
		match = { class = "([Tt]hunar)", title = "negative:(.*[Tt]hunar.*)" },
		float = true,
		center = true,
	},
	{
		name = "Bitwarden",
		match = {
			class = "^(Bitwarden)$",
			title = "^(Bitwarden)$",
			initial_class = "^(Bitwarden)$",
			initial_title = "^(Bitwarden)$",
		},
		float = true,
		center = true,
		size = "(monitor_w*0.6) (monitor_h*0.6)",
	},
	{
		name = "hyprland audio panel",
		match = {
			class = "^(hyprpwcenter)$",
			title = "^(Pipewire Control Center)$",
			initial_class = "^(hyprpwcenter)$",
			initial_title = "^(Pipewire Control Center)$",
		},
		float = true,
		center = true,
		size = "(monitor_w*0.6) (monitor_h*0.6)",
	},
	{
		name = "EasyEffects",
		match = {
			class = "^(com.github.wwmm.easyeffects)$",
			title = "^(Easy Effects)$",
			initial_class = "^(com.github.wwmm.easyeffects)$",
			initial_title = "^(Easy Effects)$",
		},
		float = true,
		center = true,
		size = "(monitor_w*0.6) (monitor_h*0.65)",
	},
	{
		name = "Floating Terminal",
		match = { title = "^(float_kitty)$" },
		float = true,
		center = true,
		size = "(monitor_w*0.6) (monitor_h*0.6)",
	},
}

for _, rule in ipairs(special_rules) do
	apply_window_rule(rule)
end

-- 5. Layer Rules
local layer_rules = {
	{ match = { namespace = "hyprpicker" }, no_anim = true },
	{ match = { namespace = "selection" }, no_anim = true },
	{ match = { namespace = "noanim" }, no_anim = true },
	{ match = { namespace = "fabric" }, no_anim = true },
	{ match = { namespace = "gtk-layer-shell" }, ignore_alpha = 0 },
}

for _, rule in ipairs(layer_rules) do
	if hl.layer_rule then
		hl.layer_rule(rule)
	end
end
