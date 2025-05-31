require("mason").setup {}
-- require("mason-lspconfig").setup {}

local null_ls = require("null-ls")
null_ls.setup {
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.cmake_format,
		null_ls.builtins.formatting.clang_format,
		-- null_ls.builtins.formatting.black.with {
		-- 	extra_args = { "--line-length", "120" },
		-- },
	},
}

local function lsp_enable(server, config)
	vim.lsp.enable(server)
	if config then
		vim.lsp.config(server, config)
	end
end

vim.lsp.config("*", {
	on_attach = function(client)
		-- TreeSitter is just better for this
		client.server_capabilities.semanticTokenProvider = nil
	end,
})

lsp_enable("lua_ls", {
	settings = {
		completion = {
			callSnippet = "Replace",
		},
		workspace = {
			checkThirdParty = false,
		},
		telemetry = {
			enable = false,
		},
	},

	on_attach = function(client)
		client.server_capabilities.documentFormattingProvider = nil
		client.server_capabilities.documentRangeFormattingProvider = nil
	end,
})

lsp_enable("pyright")
lsp_enable("cmake")
lsp_enable("clangd", {
	on_attach = function(client)
		client.server_capabilities.documentFormattingProvider = nil
		client.server_capabilities.documentRangeFormattingProvider = nil
	end,
})
lsp_enable("gopls")
lsp_enable("terraformls")
lsp_enable("ts_ls")
lsp_enable("zls")

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",

	callback = function()
		local bufmap = function(mode, lhs, rhs)
			local opts = { buffer = true }
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		local cmd = function(s)
			return "<cmd>lua vim.lsp.buf." .. s .. "()<cr>"
		end

		bufmap("n", "K", cmd("hover"))
		bufmap("n", "gd", cmd("definition"))
		bufmap("n", "gD", cmd("declaration"))
		bufmap("n", "gi", cmd("implementation"))
		bufmap("n", "go", cmd("type_definition"))
		bufmap("n", "gr", cmd("references"))
		bufmap("n", "gs", cmd("signature_help"))
		bufmap("n", "rn", cmd("rename"))
	end,
})
