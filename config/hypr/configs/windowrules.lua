local function apply_rule(rule)
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
		apply_rule({ match = { class = pattern }, tag = "+" .. tag })
	end
end

-- Manual Tags
apply_rule({ match = { xdg_tag = "^(proton-game)$" }, tag = "+games" })
apply_rule({ match = { title = "^([Ll]utris)$" }, tag = "+gamestore" })
apply_rule({ match = { title = "(Kvantum Manager)" }, tag = "+settings" })
apply_rule({ match = { class = "(xdg-desktop-portal-gtk)" }, tag = "+settings" })

-- 2. Size Presets
local size = {
	tiny = "(monitor_w*0.2) (monitor_h*0.2)",
	auth = "(monitor_w*0.35) (monitor_h*0.35)",
	calc = "(monitor_w*0.55) (monitor_h*0.45)",
	mid = "(monitor_w*0.6) (monitor_h*0.6)",
	wide = "(monitor_w*0.6) (monitor_h*0.65)",
	tall = "(monitor_w*0.6) (monitor_h*0.7)",
	large = "(monitor_w*0.7) (monitor_h*0.6)",
}

-- 3. Behavioral Rules
local window_rules = {
	-- Floating Only
	{
		match = { class = "^([Zz]oom|onedriver|onedriver-launcher|mpv|com.github.rafostar.Clapper|[Qq]alculate-gtk)$" },
		float = true,
	},
	{
		match = { class = "(codium|codium-url-handler|VSCodium)", title = "negative:(.*codium.*|.*VSCodium.*)" },
		float = true,
	},
	{ match = { class = "^(com.heroicgameslauncher.hgl)$", title = "negative:(Heroic Games Launcher)" }, float = true },
	{ match = { class = "^([Ss]team)$", title = "negative:^([Ss]team)$" }, float = true },
	{ match = { class = "([Tt]hunar)", title = "negative:(.*[Tt]hunar.*)" }, float = true, center = true },

	-- Floating + Centered
	{ match = { title = "^(Authentication Required)$" }, float = true, center = true },
	{ match = { class = "^(hyprland-donate-screen)$" }, float = true, center = true },

	-- Floating + Centered + Sized
	{
		match = {
			class = "^(xfce-polkit|mate-polkit|polkit-mate-authentication-agent-1)$",
			title = "^(Authentication required|Authentication Required)$",
		},
		float = true,
		center = true,
		size = size.auth,
	},
	{ match = { title = "^(Add Folder to Workspace|Save As)$" }, float = true, center = true, size = size.large },
	{ match = { initial_title = "(Open Files)" }, float = true, size = size.large },
	{ match = { class = "^(yad)$" }, float = true, center = true, size = size.tiny },
	{ match = { class = "^(nvidia-settings|Bitwarden|hyprpwcenter)$" }, float = true, center = true, size = size.mid },
	{ match = { class = "^(com.github.wwmm.easyeffects)$" }, float = true, center = true, size = size.wide },
	{ match = { class = "^([Ff]erdium)$" }, float = true, center = true, size = size.tall },
	{ match = { class = "(org.gnome.Calculator|qalculate-gtk)" }, float = true, center = true, size = size.calc },

	-- Picture-in-Picture
	{
		match = { title = "^[Pp]icture-in-[Pp]icture$" },
		float = true,
		move = "72% 7%",
		opacity = "0.95 0.75",
		pin = true,
		keep_aspect_ratio = true,
		size = "(monitor_w*0.3) (monitor_h*0.3)",
	},

	-- Just Centered
	{ match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" }, center = true },
	{ match = { class = "^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$" }, center = true },
	{ match = { class = "^(nm-connection-editor)$" }, center = true },
	{ match = { class = "^(nm-applet)$", title = "^(Wi-Fi Network Authentication Required)$" }, center = true },

	-- Focus & Workspace
	{ match = { title = "^(wind.*)$" }, no_initial_focus = true },
	{ match = { class = "^([Tt]hunar)$" }, workspace = 4 },
	{ match = { tag = "browser" }, workspace = 3 },

	-- Idle Inhibit
	{ match = { fullscreen = true }, idle_inhibit = "fullscreen" },
	{ match = { class = ".*" }, idle_inhibit = "fullscreen" }, -- covers all windows when fullscreen
}

for _, rule in ipairs(window_rules) do
	apply_rule(rule)
end

-- 4. Layer Rules
local layer_rules = {
	{ match = { namespace = "^(hyprpicker|selection|noanim|fabric)$" }, no_anim = true },
	{ match = { namespace = "gtk-layer-shell" }, ignore_alpha = 0 },
	{
		name = "modus",
		match = {
			namespace = "^lock$|^modus-.*",
		},
		blur = true,
		no_anim = true,
		ignore_alpha = 0,
		blur_popups = true,
	},
}

for _, rule in ipairs(layer_rules) do
	if hl.layer_rule then
		hl.layer_rule(rule)
	end
end
