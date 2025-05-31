vim.opt.number = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.g.mapleader = ","
vim.cmd([[set background=dark]])

vim.cmd([[se notermguicolors]])

-- vim.lsp.set_log_level("DEBUG")

local trim_whitespace = function()
	local v = vim.fn.winsaveview()
	vim.cmd([[keepp %s/\s\+$//e]])
	---@diagnostic disable-next-line
	vim.fn.winrestview(v)
end

-- Call LSP Format, if available
vim.api.nvim_create_autocmd("BufWrite", {
	callback = function(ev)
		local clients = vim.lsp.get_clients {
			bufnr = ev.buf,
		}

		if #clients > 0 then
			-- TODO: can this spit out errors if the server can't format?
			vim.lsp.buf.format()
		else
			trim_whitespace()
		end
	end,
})

if os.getenv("WSL_DISTRO_NAME") then
	vim.g.clipboard = {
		name = "wsl",
		copy = {
			["+"] = "win32yank.exe -i --crlf",
			["*"] = "win32yank.exe -i --crlf",
		},
		paste = {
			["+"] = "win32yank.exe -o --lf",
			["*"] = "win32yank.exe -o --lf",
		},
	}
end

function P(x)
	print(vim.inspect(x))
end

vim.diagnostic.config {
	severity_sort = true,
	virtual_text = true,
}

require("plugins")
require("plugins.telescope")
require("lsp")

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false

vim.api.nvim_set_keymap("n", "<Leader><CR>", "za", { noremap = true })
vim.api.nvim_set_keymap("n", "<Leader>n", "", {
	callback = function()
		vim.diagnostic.goto_next()
	end,
})
vim.api.nvim_set_keymap("n", "<Leader>p", "", {
	callback = function()
		vim.diagnostic.goto_prev()
	end,
})

-- Menu
vim.cmd([[aunmenu PopUp.How-to\ disable\ mouse]])
-- vim.cmd([[aunmenu PopUp.-1-]])
vim.cmd([[amenu PopUp.Set\ Breakpoint :lua require('dap').toggle_breakpoint()<CR>]])
-- vim.cmd([[nmenu PopUp.Set\ Breakpoint\ And\ Run <nop>]])
