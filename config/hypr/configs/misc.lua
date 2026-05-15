hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "vertical", action = "workspace" })
hl.gesture({ fingers = 4, direction = "down", action = "float" })

hl.config({
	input = {
		kb_layout = us,
		kb_variant = "",
		kb_model = "",
		-- kb_options = "caps:swapescape",
		kb_rules = "",
		repeat_rate = 50,
		repeat_delay = 300,
		left_handed = 0,

		follow_mouse = 1,

		sensitivity = 0.2,
		accel_profile = "flat",

		touchpad = {
			natural_scroll = 0,
			disable_while_typing = 1,
			clickfinger_behavior = 0,
			middle_button_emulation = 1,
			tap_to_click = 1,
			drag_lock = 0,
		},
		numlock_by_default = true,
	},

	cursor = {
		sync_gsettings_theme = true,
		enable_hyprcursor = false,
		no_hardware_cursors = 0,
	},

	dwindle = {
		preserve_split = true,
		special_scale_factor = 0.95,
	},

	master = {
		new_on_top = true,
		new_status = "master",
		special_scale_factor = 0.95,
	},

	scrolling = {
		explicit_column_widths = "0.5, 0.6, 1.0",
		column_width = 0.6,
		follow_min_visible = 1,
		-- focus_fit_method = 0,
	},

	xwayland = {
		enabled = true,
		force_zero_scaling = true,
		use_nearest_neighbor = true,
	},

	debug = {
		damage_tracking = 2,
		disable_logs = false,
		disable_time = true,
	},

	ecosystem = {
		no_update_news = true,
		no_donation_nag = true,
	},
})
