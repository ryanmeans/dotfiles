vim.opt.number = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

local trim_whitespace = function()
	local v = vim.fn.winsaveview()
	vim.cmd([[keepp %s/\s\+$//e]])
	---@diagnostic disable-next-line
	vim.fn.winrestview(v)
end

-- Call LSP Format, if available
vim.api.nvim_create_autocmd("BufWrite", {
	callback = function(ev)
		local clients = vim.lsp.get_active_clients {
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

require("plugins")
require("lsp")
