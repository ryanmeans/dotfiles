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
	"alexghergh/nvim-tmux-navigation",

	-- Autocomplete
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/nvim-cmp",

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
	"jose-elias-alvarez/null-ls.nvim",

	{
		"folke/neodev.nvim",
		opts = {},
	},

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

	{
		"folke/tokyonight.nvim",
		lazy = true,
		priority = 1000,
		opts = {},
	},

	{
		"phha/zenburn.nvim",
		lazy = true,
		priority = 1000,
		opts = {},
	},

	{
		"ellisonleao/gruvbox.nvim",
		lazy = true,
		priority = 1000,
	},
}

require("gruvbox").setup {
	terminal_colors = true,
	contrast = "soft",
	italics = {
		strings = false,
		emphasis = false,
		comments = true,
		operators = false,
		folds = false,
	},
}

vim.cmd([[colorscheme gruvbox]])

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

local feedkey = function(key, mode)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
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
