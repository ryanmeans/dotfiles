local baddir = function()
	print("You must start nvim in a directory with a valid .pangea-sos file")
end

local invalid_cfg = {
	show_fs = baddir,
	open = baddir,
	save = baddir,
	list = baddir,
}

local cwd = vim.loop.cwd()
if not vim.loop.fs_stat(cwd .. "/.pangea-sos") then
	return invalid_cfg
end

local fd = vim.loop.fs_open(cwd .. "/.pangea-sos", "r", 0400)
if fd == nil then
	return invalid_cfg
end

local cfg = vim.fn.json_decode(vim.loop.fs_read(fd, 1024, -1))
vim.loop.fs_close(fd)

if cfg == nil or cfg.token == nil or cfg.base_url == nil then
	return invalid_cfg
end

local post = require("plenary").curl.post
local get = require("plenary").curl.get

local sos_token = cfg.token
local base_url = cfg.base_url

vim.cmd([[hi PangeaSOSFolder guifg=lightblue ctermfg=lightblue]])

-- local base_url = "https://store.dev.aws.pangea.cloud"

local list = function()
	local opts = {
		body = "{}",
		headers = {
			content_type = "application/json",
			authorization = "Bearer " .. sos_token,
		},
	}
	return post(base_url .. "/v1beta/list", opts)
end

local _to_fs_tree = function(objects)
	local collected = {}

	for _, obj in ipairs(objects) do
		if obj.type == "file" then
			if collected[obj.folder] == nil then
				collected[obj.folder] = { obj }
			else
				table.insert(collected[obj.folder], obj)
			end
		end
	end

	local fs_tree = {
		files = {},
		folders = {},
	}

	for folder_path, files in pairs(collected) do
		local cur = fs_tree
		for part in string.gmatch(folder_path, "[^/]+") do
			if cur.folders[part] == nil then
				cur.folders[part] = {
					files = {},
					folders = {},
				}
			end

			cur = cur.folders[part]
		end
		cur.files = files
	end

	return fs_tree
end

local show_fs = function()
	local response = list()
	if response.status ~= 200 then
		print("Failed to get files from sos")
	end
	local body = vim.fn.json_decode(response.body)
	local fs_tree = _to_fs_tree(body.result.objects)
	return fs_tree
end

local open = function()
	local fs_tree = show_fs()
	local bufnr = vim.api.nvim_create_buf(false, true)

	local pad = function(n)
		local s = ""
		for i = 1, n do
			s = s .. " "
		end
		return s
	end

	local lookup = {}
	-- Use this for highlighting later
	local directories = {}

	local write_tree
	write_tree = function(depth, line, dir)
		for name, folder in pairs(dir.folders) do
			vim.api.nvim_buf_set_lines(bufnr, line, line + 1, false, { pad(depth) .. name })
			lookup[line] = folder
			table.insert(directories, { line = line, pos = 1 + string.len(pad(depth)), len = string.len(name) })
			line = line + 1
			line = write_tree(depth + 1, line, folder)
		end

		for _, file in pairs(dir.files) do
			vim.api.nvim_buf_set_lines(bufnr, line, line + 1, false, { pad(depth) .. file.name })
			lookup[line] = file
			line = line + 1
		end

		return line
	end

	local lines = vim.fn.max { write_tree(0, 0, fs_tree), 1 }

	local width = vim.fn.winwidth(0)
	local height = vim.fn.winheight(0)
	local winnr = vim.api.nvim_open_win(bufnr, true, {
		title = "Pangea SOS",
		title_pos = "center",
		relative = "editor",
		width = 40,
		height = lines,
		col = (width - 40) * 0.5,
		row = (height - lines) * 0.5,
		style = "minimal",
		border = "rounded",
	})

	-- vim.cmd([[hi PangeaSOSFolder guifg=lightblue ctermfg=lightblue]])
	-- Set highlighting
	for _, folder in pairs(directories) do
		vim.fn.matchaddpos("PangeaSOSFolder", { folder.line + 1 })
	end

	local close = function()
		vim.api.nvim_win_close(winnr, true)
	end

	-- Switch current buffer to new file
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", "", {
		callback = function()
			local r, _ = unpack(vim.api.nvim_win_get_cursor(winnr))
			-- I _think_ it's correct to close the window here?
			-- We are going to be immediately switching the underlying buffer with
			-- the new file
			close()
			local obj = lookup[r - 1]
			local opts = {
				body = vim.fn.json_encode {
					-- Aesthetically, I'd prefer multipart download, but this is so stupidly
					-- simple to work with that there isn't much of a reason not to
					transfer_method = "dest-url",
					id = obj.id,
				},
				headers = {
					content_type = "application/json",
					authorization = "Bearer " .. sos_token,
				},
			}
			local resp = post(base_url .. "/v1beta/get", opts)
			local body = vim.fn.json_decode(resp.body)
			local url = body.result.dest_url

			local path
			if obj.folder ~= "/" then
				local dir = string.sub(obj.folder, 2)
				vim.cmd("silent!!mkdir -p " .. dir)
				path = dir .. "/" .. obj.name
			else
				path = obj.name
			end

			get(url, { output = path })
			vim.cmd("e " .. path)
		end,
	})

	-- Gracefully close window
	vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "", {
		callback = close,
	})

	vim.api.nvim_create_autocmd({ "WinLeave", "InsertEnter" }, {
		buffer = bufnr,
		callback = close,
	})
end

local save = function()
	local fpath = vim.api.nvim_buf_get_name(0)
	-- I don't know why this is + 2, it just ends up being that way
	-- probably relating to 1 indexing and needing to strip out one extra "/" at the start
	local relpath = string.sub(fpath, string.len(vim.loop.cwd()) + 2)

	local resp = post(base_url .. "/v1beta/put", {
		headers = {
			content_type = "multipart/form-data",
			authorization = "Bearer " .. sos_token,
		},
		-- Use "raw" over "form" to preserve the order of the arguments
		raw = {
			"-F",
			vim.fn.printf('request={"transfer_method":"multipart","path":"%s"};type=application/json', relpath),
			"-F",
			vim.fn.printf("upload=@%s;type=application/octet-stream", relpath),
		},
	})
	return resp
end

return {
	show_fs = show_fs,
	list = list,
	open = open,
	save = save,
}
