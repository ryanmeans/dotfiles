require("mason").setup {}
require("mason-lspconfig").setup {}

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

-- Provide nvim api information for lua
require("neodev").setup {}
require("lspconfig").lua_ls.setup {
	settings = {
		Lua = {
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
	},

	on_attach = function(client)
		client.server_capabilities.semanticTokensProvider = nil
		client.server_capabilities.documentFormattingProvider = nil
		client.server_capabilities.documentRangeFormattingProvider = nil
	end,
}

require("lspconfig").cmake.setup {}
require("lspconfig").clangd.setup {
	on_attach = function(client)
		client.server_capabilities.semanticTokensProvider = nil
		client.server_capabilities.documentFormattingProvider = nil
		client.server_capabilities.documentRangeFormattingProvider = nil
	end,
}

require("lspconfig").gopls.setup {}
require("lspconfig").terraformls.setup {
	on_attach = function(client)
		client.server_capabilities.semanticTokensProvider = nil
	end,
}

require("lspconfig").pyright.setup {
	python = {
		analysis = {
			logLevel = "Trace",
		},
	},
}

require("lspconfig").tsserver.setup {}

require("lspconfig").zls.setup {
	on_attach = function(client)
		client.server_capabilities.semanticTokensProvider = nil
	end,
}

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
