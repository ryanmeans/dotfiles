local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	print(lazypath)
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
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	-- "alexghergh/nvim-tmux-navigation",
	"numToStr/Navigator.nvim",

	-- Autocomplete
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-buffer",
	{
		"hrsh7th/nvim-cmp",
		opts = function(_, opts)
			opts.sources = opts.sources or {}
			table.insert(opts.sources, {
				name = "lazydev",
				group_index = 0,
			})
		end,
	},

	"nvim-treesitter/nvim-treesitter",
	"nvim-treesitter/playground",
	"nvim-treesitter/nvim-treesitter-textobjects",
	{
		"numToStr/Comment.nvim",
		lazy = false,
	},

	-- LSPs
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"neovim/nvim-lspconfig",
	"nvimtools/none-ls.nvim",
	{ "towolf/vim-helm", ft = "helm" },

	-- {
	-- 	"folke/neodev.nvim",
	-- 	opts = {},
	-- },

	{
		"tpope/vim-fugitive",
		lazy = false,
	},

	"nvim-lua/plenary.nvim",
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.3",
		requires = { { "nvim-lua/plenary.nvim" } },
	},

	"mfussenegger/nvim-dap",

	-- {
	-- 	"folke/tokyonight.nvim",
	-- 	lazy = true,
	-- 	priority = 1000,
	-- 	opts = {},
	-- },
	--
	-- {
	-- 	"phha/zenburn.nvim",
	-- 	lazy = true,
	-- 	priority = 1000,
	-- 	opts = {},
	-- },

	-- {
	-- 	"ellisonleao/gruvbox.nvim",
	-- 	lazy = true,
	-- 	priority = 1000,
	-- },

	{
		"RRethy/base16-nvim",
		lazy = true,
		priority = 1000,
	},
}
--
-- require("gruvbox").setup {
-- 	terminal_colors = true,
-- 	contrast = "soft",
-- 	italics = {
-- 		strings = false,
-- 		emphasis = false,
-- 		comments = true,
-- 		operators = false,
-- 		folds = false,
-- 	},
-- }

-- vim.cmd([[colorscheme gruvbox]])

local cfg = {
	base00 = 0,
	base01 = 18,
	base02 = 19,
	base03 = 8,
	base04 = 20,
	base05 = 7,
	base06 = 21,
	base07 = 15,
	base08 = 9,
	base09 = 16,
	base0A = 11,
	base0B = 2,
	base0C = 6,
	base0D = 4,
	base0E = 5,
	base0F = 17,
}

require("base16-colorscheme").setup {
	-- Unused
	base00 = "#16161D",
	base01 = "#2c313c",
	base02 = "#3e4451",
	base03 = "#6c7891",
	base04 = "#565c64",
	base05 = "#abb2bf",
	base06 = "#9a9bb3",
	base07 = "#c5c8e6",
	base08 = "#e06c75",
	base09 = "#d19a66",
	base0A = "#e5c07b",
	base0B = "#98c379",
	base0C = "#56b6c2",
	base0D = "#0184bc",
	base0E = "#c678dd",
	base0F = "#a06949",
	cterm00 = cfg.base00,
	cterm01 = cfg.base01,
	cterm02 = cfg.base02,
	cterm03 = cfg.base03,
	cterm04 = cfg.base04,
	cterm05 = cfg.base05,
	cterm06 = cfg.base06,
	cterm07 = cfg.base07,
	cterm08 = cfg.base08,
	cterm09 = cfg.base09,
	cterm0A = cfg.base0A,
	cterm0B = cfg.base0B,
	cterm0C = cfg.base0C,
	cterm0D = cfg.base0D,
	cterm0E = cfg.base0E,
	cterm0F = cfg.base0F,
}

local highlights = {
	Search = { link = "Visual" },
	IncSearch = { link = "Search" },
	Delimiter = { link = "Normal" },
	["@punctuation.delimiter"] = { link = "Normal" },
	NormalFloat = { ctermfg = cfg.base05, ctermbg = cfg.base01 },

	CmpItemAbbr = { fg = cfg.base05 },
}

for group, opts in pairs(highlights) do
	vim.api.nvim_set_hl(0, group, opts)
end

require("Navigator").setup {}
vim.keymap.set({ "n", "t" }, "<C-h>", "<CMD>NavigatorLeft<CR>")
vim.keymap.set({ "n", "t" }, "<C-j>", "<CMD>NavigatorDown<CR>")
vim.keymap.set({ "n", "t" }, "<C-k>", "<CMD>NavigatorUp<CR>")
vim.keymap.set({ "n", "t" }, "<C-l>", "<CMD>NavigatorRight<CR>")

-- Vim CMP
local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local cmp = require("cmp")
require("cmp").setup {
	enabled = true,

	sources = {
		{ name = "path" },
		{ name = "nvim_lsp", keyword_length = 1 },
		{ name = "buffer", keyword_length = 3, priority = -10000 },
	},

	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},

	---@diagnostic disable-next-line
	completion = {
		autocomplete = false,
	},

	preselect = cmp.PreselectMode.None,

	mapping = {
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s" }),

		-- Force completion without any text present
		["<C-Tab>"] = cmp.mapping(function()
			if cmp.visible() then
				cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
			elseif has_words_before() then
				cmp.complete()
			else
				cmp.complete()
			end
		end, { "i", "s" }),

		["<S-Tab>"] = cmp.mapping(function()
			if cmp.visible() then
				cmp.select_prev_item()
			elseif vim.fn["vsnip#jumpable"](-1) == 1 then
				feedkey("<Plug>(vsnip-jump-prev)", "")
			end
		end, { "i", "s" }),

		["<C-y>"] = cmp.mapping.confirm { select = true },
	},
}

-- Tree Sitter
-- NOTE: Some language servers ALSO do highlighting,
-- so, make sure those don't conflict
---@diagnostic disable-next-line
require("nvim-treesitter.configs").setup {
	indent = {
		enable = true,
	},

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

local plenary = require("plenary")
