local M = {}

local scnvim = require"scnvim"
local send2sc = scnvim.send
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local settings = {}

-- Defualt settings
settings.keymaps = {
	toggle = "<space>",
	send = "<C-E>"
}

settings.position = "50%"
settings.width = "50%"
settings.height = "50%"

local function register_commands()
	vim.cmd[[
	command! SCratch lua require('sc-scratchpad').open()
	]]
end

local function register_global_keymaps()

	-- Toggle scratchpad
	vim.api.nvim_set_keymap("n", settings.keymaps.toggle, ":SCratch<CR>", {})
end

local function set_popup_maps(popup)

	local keymap_callback_func = function(bufnr)
		local window = vim.api.nvim_get_current_win()
		vim.api.nvim_win_close(window, true)
	end

	popup:map("n", settings.keymaps.send, keymap_callback_func, { noremap = true })
	popup:map("i", settings.keymaps.send, keymap_callback_func, { noremap = true })
	popup:map("n", settings.keymaps.toggle, keymap_callback_func, { noremap = true })

	-- Make sure that scnvim's post window toggle doesn't interfere
	-- @FIXME: This is hacky and should be done in a more reliable fashion compatible with
	vim.api.nvim_buf_del_keymap(popup.bufnr, "n", "<CR>")

end

-- Turn lines into one long text
local function flatten_lines(lines_table, keep_linebreaks)
	local outstring = ""
	for _, line in pairs(lines_table) do
		outstring = outstring .. line
		if keep_linebreaks then
			outstring = outstring .. "\n"
		end
	end

	return outstring
end

-- 	return left_hand_sides
-- end
function M.open()
	local popup = Popup({
		enter = true,
		focusable = true,
		border = {
			style = "double"
		},
		-- border = {
		-- 	style = "rounded",
		-- 	highlight = "FloatBorder",
		-- },
		position = settings.position,
		size = {
			width = settings.width,
			height = settings.height,
		},
		buf_options = {
			modifiable = true,
			readonly = false,
			filetype = "supercollider",
		},
		win_options = {
			winblend = 25,
			winhighlight = "Normal:Normal",
		},
	})

	-- mount/open the component
	popup:mount()

	-- print(vim.inspect(popup.border.style))

	-- Set keymaps
	set_popup_maps(popup)

	-- set content
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, { "// sc-scratchpad.nvim", "" })
	vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), {2,1})

	-- unmount component when cursor leaves buffer
	popup:on(event.BufLeave, function()

		-- Get text from buffer
		local numLines = vim.api.nvim_buf_line_count(popup.bufnr)
		local text = vim.api.nvim_buf_get_lines(popup.bufnr, 0, numLines, false)
		text = flatten_lines(text, true)

		-- Send text to sclang
		send2sc(text)

		-- Close buffer
		popup:unmount()
	end)

end
function M.setup(user_settings)
	-- settings = user_settings

	register_commands()
	register_global_keymaps()
end

return M
