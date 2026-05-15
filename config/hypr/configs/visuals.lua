-- Visuals
hl.config({
	general = {
		allow_tearing = false,
		resize_on_border = false,
		no_focus_fallback = true,
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		enable_swallow = true,
		swallow_regex = "^(kitty|zen-browser)$",
		vrr = 2,
		animate_manual_resizes = false,
		mouse_move_focuses_monitor = true,
		disable_splash_rendering = true,
	},

	gestures = {
		workspace_swipe_distance = 1000,
		workspace_swipe_min_speed_to_force = 1000,
		workspace_swipe_direction_lock = false,
		workspace_swipe_create_new = true,
		workspace_swipe_cancel_ratio = 0.1,
	},
})
