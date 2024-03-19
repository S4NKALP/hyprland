local header_collection = require('plugins.dashboard-theme.headers')
return {
	theme = 'doom',
	config = {
		header = header_collection.dash,
		center = {
			{
				icon = '  ',
				icon_hl = 'Title',
				desc = 'New file',
				desc_hl = 'String',
				action = 'ene',
			},
			{
				icon = '  ',
				icon_hl = 'Title',
				desc = 'Find files',
				desc_hl = 'String',
				action = 'Telescope find_files',
			},
			{
				icon = '  ',
				icon_hl = 'Title',
				desc = 'Quit',
				desc_hl = 'String',
				action = 'qa',
			},
		},
		footer = {  "🎉 No Code, No Bug 🎉", ""}  --your footer
	}
}
