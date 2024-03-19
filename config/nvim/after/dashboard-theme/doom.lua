local header_collection = require('plugins.dashboard-theme.headers')
return {
	theme = 'doom',
	config = {
		header = header_collection.dash,
		center = {
			{
				icon = '  ',
				icon_hl = 'Title',
				desc = 'Find File           ',
				desc_hl = 'String',
				key = 'f',
				key_hl = 'Number',
				key_format = ' %s', -- remove default surrounding `[]`
				action = 'Telescope find_files'
			},
			{
				icon = '  ',
				desc = 'Quit',
				key = 'q',
				key_format = ' %s', -- remove default surrounding `[]`
				action = 'qa'
			},
		},
		footer = {}  --your footer
	}
}
