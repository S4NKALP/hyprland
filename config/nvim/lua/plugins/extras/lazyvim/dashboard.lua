return {
	'nvimdev/dashboard-nvim',
	dependencies = {
		'kyazdani42/nvim-web-devicons'
	},
	enabled = true,
	config = function()
		-- local theme = require('plugins.dashboard-theme.landing')
		-- local theme = require('plugins.dashboard-theme.minimal')
		-- local theme = require('plugins.dashboard-theme.doom')
		local theme = require('plugins.dashboard-theme.hyper')
		require('dashboard').setup (theme)
	end,
}
