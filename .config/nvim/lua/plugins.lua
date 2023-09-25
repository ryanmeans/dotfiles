local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	}
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
	"alexghergh/nvim-tmux-navigation",

	-- Autocomplete
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/nvim-cmp",

	"nvim-treesitter/nvim-treesitter",
	"nvim-treesitter/nvim-treesitter-textobjects",
	{
		"numToStr/Comment.nvim",
		lazy = false,
	},

	-- LSPs
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"neovim/nvim-lspconfig",
	"jose-elias-alvarez/null-ls.nvim",

	{
		"folke/neodev.nvim",
		opts = {},
	},

	"nvim-lua/plenary.nvim",
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.3",
		requires = { { "nvim-lua/plenary.nvim" } },
	},

	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
}

vim.cmd([[colorscheme tokyonight-moon]])

require("nvim-tmux-navigation").setup {
	keybindings = {
		left = "<C-h>",
		down = "<C-j>",
		up = "<C-k>",
		right = "<C-l>",
		last_active = "<C-\\>",
		next = "<C-Space>",
	},
}

-- Vim CMP
local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp = require("cmp")

require("cmp").setup {
	enabled = true,

	sources = {
		{ name = "path" },
		{ name = "nvim_lsp", keyword_length = 1 },
		{ name = "buffer", keyword_length = 3 },
	},

	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = {
		["<C-e>"] = cmp.mapping.abort(),

		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
			elseif has_words_before() then
			else
				fallback()
			end
		end, { "i", "s" }),

		["<S-Tab>"] = cmp.mapping(function()
			if cmp.visible() then
				cmp.select_prev_item()
			end
		end, { "i", "s" }),
	},

	["<CR>"] = cmp.mapping(function(fallback)
		if cmp.visible() then
			cmp.mapping.confirm { select = true }
		else
			fallback()
		end
	end, { "i", "s" }),

	["<C-y>"] = cmp.mapping(function(fallback)
		if cmp.visible() then
			cmp.mapping.confirm { select = true }
		else
			fallback()
		end
	end, { "i", "s" }),
}

-- Tree Sitter
-- NOTE: Some language servers ALSO do highlighting,
-- so, make sure those don't conflict
---@diagnostic disable-next-line
require("nvim-treesitter.configs").setup {
	highlight = {
		enable = true,
	},

	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["af"] = "@function.outer",
			},
		},
	},
}

---@diagnostic disable-next-line
require("Comment").setup {
	mapps = {
		extra = false,
	},
}

local builtin = require("telescope.builtin")
local themes = require("telescope.themes")
require("telescope").setup {
	defaults = {
		mappings = {
			n = {
				["r"] = function()
					builtin.live_grep(themes.get_ivy {
						layout_config = {
							height = 15,
						},
					})
				end,
			},
		},
	},
}

vim.keymap.set("n", "<C-p>", "", {
	callback = function()
		builtin.find_files(themes.get_ivy {
			layout_config = {
				height = 15,
			},
		})
	end,
})
vim.keymap.set("n", "<leader>rg", "", {
	callback = function()
		builtin.live_grep(themes.get_ivy {
			layout_config = {
				height = 15,
			},
		})
	end,
})
