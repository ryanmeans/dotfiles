local builtin = require("telescope.builtin")
-- local themes = require("telescope.themes")
require("telescope").setup {
	pickers = {
		live_grep = {
			previewer = false,
		},
		find_files = {
			previewer = false,
		},
		git_files = {
			previewer = false,
		},
	},

	defaults = {
		mappings = {
			n = {
				["r"] = function()
					builtin.live_grep()
					-- builtin.live_grep(themes.get_ivy {
					-- 	layout_config = {
					-- 		height = 15,
					-- 	},
					-- })
				end,
			},
		},
	},
}

local checked = false
local result = false

local is_git_repo = function()
	if checked == true then
		return result
	end
	vim.fn.system("git rev-parse --is-inside-work-tree 2> /dev/null")
	result = vim.v.shell_error == 0
	return result
end

vim.keymap.set("n", "<C-p>", "", {
	callback = function()
		if is_git_repo() then
			-- builtin.git_files(themes.get_ivy {
			-- 	layout_config = {
			-- 		height = 15,
			-- 	},
			-- 	show_untracked = true,
			-- })
			builtin.git_files {
				show_untracked = true,
			}
		else
			-- builtin.find_files(themes.get_ivy {
			-- 	layout_config = {
			-- 		height = 15,
			-- 	},
			-- })
			builtin.find_files()
		end
	end,
})
vim.keymap.set("n", "<leader>rg", "", {
	callback = function()
		-- builtin.live_grep(themes.get_ivy {
		-- 	layout_config = {
		-- 		height = 15,
		-- 	},
		-- })
		builtin.live_grep()
	end,
})
