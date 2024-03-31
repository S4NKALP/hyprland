return {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
        require('dashboard').setup {
            theme = 'hyper',
            shortcut_type = 'letter',
            config = {
                header = { '',

                ' ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ',
                ' ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ',
                ' ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ',
                ' ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ',
                ' ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ',
                ' ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ',
                '',
                },
                week_header = {
                    enable = false
                },
                project = {
                    enable = false,
                    limit = 8,
                    icon = ' ',
                    group = '@function',
                    label = 'Projects',
                    action = 'Telescope find_files cwd='
                },
                mru = {
                    limit = limit,
                    icon = ' ',
                    label = 'Recent (Last ' .. tostring(limit) .. ' files)',
                },
                shortcut = {
                    {
                        desc = '󰊳 Update',
                        group = '@property',
                        action = 'Lazy update',
                        key = 'u'
                    },
                    {
                        icon = ' ',
                        icon_hl = '@variable',
                        desc = 'Files',
                        group = 'Label',
                        action = 'Telescope find_files',
                        key = 'f',
                    },
                    {
                        icon = ' ',
						            desc = 'New file',
                        group = 'DiagnosticOk',
                        action = 'ene',
                        key = 'n'
                    },
                    {
                        icon = ' ',
                        desc = 'Words',
                        group = 'DiagnosticWarn',
                        action = 'Telescope live_grep',
                        key = 'g',
                    },
                    {
                        icon = ' ',
                        desc = 'Quit',
                        group = 'DiagnosticError',
                        action = 'qa',
                        key = 'q'
                    },
                },
            },
        }
    end,
    dependencies = {
        {'nvim-tree/nvim-web-devicons'}
    }
}
