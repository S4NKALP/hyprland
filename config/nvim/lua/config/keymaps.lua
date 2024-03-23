local map = vim.keymap.set
local api = vim.api
local o = vim.opt

local lazy = require("lazy")

-- Search current word
local searching_brave = function()
  vim.fn.system({ "xdg-open", "https://search.brave.com/search?q=" .. vim.fn.expand("<cword>") })
end
map("n", "<leader>?", searching_brave, { noremap = true, silent = true, desc = "Search current word on brave search" })

-- return to dir
map("n", "<leader>pv", vim.cmd.Ex)

-- Exit insert mode without hitting Esc
map("i", "jj", "<Esc>", { desc = "Esc" })

-- End of the word backwards
map("n", "E", "ge")

-- Increment/decrement
map("n", "+", "<C-a>")
map("n", "-", "<C-x>")

-- Tabs
map("n", "]<tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "[<tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "<tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<s-tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
for i = 1, 9 do
  map("n", "<leader><tab>" .. i, "<cmd>tabn " .. i .. "<cr>", { desc = "Tab " .. i })
end

-- Buffers
map("n", "<leader>bf", "<cmd>bfirst<cr>", { desc = "First Buffer" })
map("n", "<leader>ba", "<cmd>blast<cr>", { desc = "Last Buffer" })

-- Center the screen automatically
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Toggle statusline
map("n", "<leader>sl", function()
  if o.laststatus:get() == 0 then
    o.laststatus = 3
  else
    o.laststatus = 0
  end
end, { desc = "Toggle Statusline" })

-- Toggle tabline
map("n", "<leader>u<tab>", function()
  if o.showtabline:get() == 0 then
    o.showtabline = 2
  else
    o.showtabline = 0
  end
end, { desc = "Toggle Tabline" })


-- Shift arrows to select
map('i', '<S-Down>', '<ESC>lvj')
map('v', '<S-Down>', 'j')
map('n', '<S-Down>', 'vj')

map('i', '<S-Up>', '<ESC>vk')
map('v', '<S-Up>', 'k')
map('n', '<S-Up>', 'vk')

map('i', '<S-Right>', '<ESC>vl')
map('v', '<S-Right>', 'l')
map('n', '<S-Right>', 'vl')

map('i', '<S-Left>', '<ESC>vh')
map('v', '<S-Left>', 'h')
map('n', '<S-Left>', 'vh')


-- " Ctrl-C, Ctrl-V option for copy/paste
map('v', '<C-c>', '"+yi')
map('i', '<C-c>', '"+yi')
map('v', '<C-x>', '"+c')
map('v', '<C-v>', 'c<ESC>"+p')
map('i', '<C-v>', '<ESC>"+pa')

-- Comment box
map("n", "]/", "/\\S\\zs\\s*╭<CR>zt", { desc = "Next block comment" })
map("n", "[/", "?\\S\\zs\\s*╭<CR>zt", { desc = "Prev block comment" })

-- U for redo
map("n", "U", "<C-r>", { desc = "Redo" })

-- Move to beginning/end of line
map("n", "<a-h>", "_", { desc = "First character of Line" })
map("n", "<a-l>", "$", { desc = "Last character of Line" })

-- Select & copy to clipboard
map("v", "<C-c>", '"+y', { desc = "Yank to clipboard" })

-- Duplicate paragraph
map('n', '<Leader>p', 'yap<S-}>p', { desc = 'Duplicate Paragraph' })

-- Motion
map("c", "<C-a>", "<C-b>", { desc = "Start Of Line" })
map("i", "<C-a>", "<Home>", { desc = "Start Of Line" })
map("i", "<C-e>", "<End>", { desc = "End Of Line" })

-- Select all text
map("n", "<C-a>", "gg<S-V>G", { desc = "Select all text", silent = true, noremap = true })

-- Paste options
map("v", "p", '"_dP', { desc = "Paste without overwriting" })

-- Delete and change without yanking
map({ "n", "x" }, "<A-d>", '"_d', { desc = "Delete without yanking" })
map({ "n", "x" }, "<A-c>", '"_c', { desc = "Change without yanking" })

-- Deleting without yanking empty line
map("n", "dd", function()
  local is_empty_line = vim.api.nvim_get_current_line():match("^%s*$")
  if is_empty_line then
    return '"_dd'
  else
    return "dd"
  end
end, { noremap = true, expr = true, desc = "Don't yank empty line to clipboard" })

-- Search for highlighted text in buffer
map("v", "//", 'y/<C-R>"<CR>', { desc = "Search for highlighted text" })

-- Visual --
-- Stay in indent mode
map("v", "<", "<gv")
map("v", ">", ">gv")

map({"n", "o", "x"}, "<s-h>", "^", { desc = "Jump to beginning of line" })
map({"n", "o", "x"}, "<s-l>", "g_", { desc = "Jump to end of line" })

-- Copy file paths
map("n", "<leader>cf", "<cmd>let @+ = expand(\"%\")<CR>", { desc = "Copy File Name" })
map("n", "<leader>cp", "<cmd>let @+ = expand(\"%:p\")<CR>", { desc = "Copy File Path" })

-- Dismiss Noice Message
map("n", "<leader>nd", "<cmd>NoiceDismiss<CR>", {desc = "Dismiss Noice Message"})

-- Replace word under cursor across entire buffer
map("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word under cursor" })

-- Replace all instances of highlighted words
map("v", "<leader>rr", '"hy:%s/<C-r>h//g<left><left>')

-- Dashboard
map("n", "<leader>fd", function()
  if Util.has("alpha-nvim") then
    require("alpha").start(true)
  elseif Util.has("dashboard-nvim") then
    vim.cmd("Dashboard")
  end
end, { desc = "Dashboard" })
