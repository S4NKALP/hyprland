local mason_status, mason = pcall(require, "mason")

if not mason_status then
	return print("mason Not found!!")
end

local mason_lsp_status, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lsp_status then
	return print("mason-lspconfig Not found!!")
end

mason.setup()
mason_lspconfig.setup({
	ensure_installed = {
		-- Language servers
		"tsserver", -- TypeScript/JavaScript
		"html", -- HTML
		"cssls", -- CSS
		"tailwindcss", -- Tailwind CSS
		"lua_ls", -- Lua
	},
})
