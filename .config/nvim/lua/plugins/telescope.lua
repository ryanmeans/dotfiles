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

local is_git_repo = function()
	vim.fn.system("git rev-parse --is-inside-work-tree 2> /dev/null")
	return vim.v.shell_error == 0
end

vim.keymap.set("n", "<C-p>", "", {
	callback = function()
		if is_git_repo() then
			builtin.git_files(themes.get_ivy {
				layout_config = {
					height = 15,
				},
			})
		else
			builtin.find_files(themes.get_ivy {
				layout_config = {
					height = 15,
				},
			})
		end
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
