-- Misc

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "vertical", action = "workspace" })
hl.gesture({ fingers = 4, direction = "down", action = "float" })

hl.config({
	input = {
		kb_layout = us,
		kb_variant = "",
		kb_model = "",
		kb_options = "",
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

	dwindle = {
		preserve_split = true,
		smart_resizing = true,
		use_active_for_splits = true,
		smart_split = false,
		default_split_ratio = 1.0,
		split_bias = 0,
		precise_mouse_move = false,
		special_scale_factor = 0.8,
	},

	master = {
		new_status = "slave",
		new_on_top = false,
		new_on_active = "none",
		orientation = "left",
		mfact = 0.55,
		slave_count_for_center_master = 2,
		center_master_fallback = "left",
		smart_resizing = true,
		drop_at_cursor = true,
		always_keep_position = false,
	},

	scrolling = {
		column_width = 0.50,
		fullscreen_on_one_column = true,
		direction = "right",
		follow_focus = true,
	},

	debug = {
		disable_logs = false,
	},
})
