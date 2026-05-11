-- Monitors

hl.monitor({
	output = "eDP-1",
	mode = "1920x1080@144",
	position = "auto",
	scale = 1,
})

-- Env Vars

for key, val in pairs({
	XCURSOR_SIZE = "6",
	CLUTTER_BACKEND = "wayland",
	GDK_BACKEND = "wayland,x11,*",
	QT_QPA_PLATFORM = "wayland;xcb",
	QT_AUTO_SCREEN_SCALE_FACTOR = "1",
	QT_WAYLAND_DISABLE_WINDOWDECORATION = "1",
	QT_QPA_PLATFORMTHEME = "qt6ct",
	SDL_VIDEODRIVER = "wayland",
	GDK_SCALE = "1",
	QT_SCALE_FACTOR = "1",
	MOZ_ENABLE_WAYLAND = "1",
	ELECTRON_OZONE_PLATFORM_HINT = "auto",
	ELECTRON_ARGS = "--enable-features=UseOzonePlatform --ozone-platform=wayland",

	-- nvidia
	GBM_BACKEND = "nvidia-drm",
	__GLX_VENDOR_LIBRARY_NAME = "nvidia",
	LIBVA_DRIVER_NAME = "nvidia",
}) do
	hl.env(key, val)
end
