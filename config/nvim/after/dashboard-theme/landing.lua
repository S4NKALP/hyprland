local header_collection = require('plugins.dashboard-theme.headers')

return {
			theme = 'hyper',
			change_to_vcs_root = true,
			shortcut_type = 'number',
			hide = {
				statusline = true,    -- hide statusline default is true
				tabline = true,      -- hide the tabline
				winbar  = true,      -- hide winbar
			},
			config = {
				header = header_collection.default,
				week_header = {
					enable = false,
				},
				packages = { enable = true }, -- show how many plugins neovim loaded
				project = { enable = false },
				mru = { },
				shortcut = {
					{
						icon = ' ',
						desc = 'New file',
						group = 'DiagnosticOk',
						action = 'ene',
						key = 'e'
					},
					{
						icon = ' ',
						desc = 'Open notes',
						group = 'DiagnosticWarn',
						action = 'Neorg index',
						key = 'n'
					},
					{
						icon = ' ',
						desc = 'Files',
						group = 'DiagnosticInfo',
						action = 'Telescope find_files',
						key = 'f',
					},
					{
						icon = ' ',
						desc = 'Words',
						group = 'DiagnosticWarn',
						action = 'Telescope live_grep',
						key = 'g',
					},
					{
						icon = ' ',
						desc = 'Todo',
						group = 'DiagnosticOk',
						action = 'TodoTelescope',
						key = 't',
					},
					{ icon = '󰚰 ', desc = 'Update', group = '@property', action = 'Lazy update', key = 'u' },
					{ icon = ' ', desc = 'Quit', group = 'DiagnosticError', action = 'qa', key = 'q' },
				},
			},
		}

