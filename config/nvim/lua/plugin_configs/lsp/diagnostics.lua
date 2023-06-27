-- Icons for diagnostics
local signs = { Error = "", Warn = "", Hint = "💡", Info = "🔥" }

for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
	virtual_text = {
		prefix = "●",
	},

	update_in_insert = false,
	float = {
		source = "always", --Or 'if_many'
	},
})

-- Disable virtual text for diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = false,
})
