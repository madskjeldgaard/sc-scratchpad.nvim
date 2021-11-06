local M = {}
M.buffers = {}

local scnvim = require"scnvim"
local send2sc = scnvim.send
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local utils = require"sc-scratchpad/utils"
local settings = {}

-- Defualt settings
settings.keymaps = {
	toggle = "<space>",
	send = "<C-E>",
	-- previous = "<BS>"
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
	vim.api.nvim_buf_set_keymap(0, "n", settings.keymaps.toggle, ":SCratch<CR>", {})
end

local function set_popup_maps(popup)

	local keymap_callback_func = function(bufnr)
		local window = vim.api.nvim_get_current_win()
		vim.api.nvim_win_close(window, true)
	end

	-- local previous_buf = function(bufnr)
	-- 	load_old(bufnr)
	-- end

	popup:map("n", settings.keymaps.send, keymap_callback_func, { noremap = true })
	popup:map("i", settings.keymaps.send, keymap_callback_func, { noremap = true })
	popup:map("n", settings.keymaps.toggle, keymap_callback_func, { noremap = true })

	-- popup:map("n", settings.keymaps.previous, previous_buf, { noremap = true })

	-- Make sure that scnvim's post window toggle doesn't interfere
	-- @FIXME: This is hacky and should be done in a more reliable fashion compatible with
	vim.api.nvim_buf_del_keymap(popup.bufnr, "n", "<CR>")

end
-- 	return left_hand_sides
-- end
function M.open()
	local popup = Popup({
		enter = true,
		focusable = true,
		border = {
			style = "single"
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
			winblend = 5,
			winhighlight = "Normal:Normal",
		},
	})

	-- mount/open the component
	popup:mount()

	-- Set keymaps
	set_popup_maps(popup)

	-- set content
	local template_content ={ "// sc-scratchpad" .. #M.buffers+1, "" }
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, template_content)
	vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), {2,1})

	-- unmount component when cursor leaves buffer
	popup:on(event.WinClosed, function()

		-- Get text from buffer
		local numLines = vim.api.nvim_buf_line_count(popup.bufnr)
		local buffer_contents = vim.api.nvim_buf_get_lines(popup.bufnr, 0, numLines, false)
		local text = utils.flatten_lines(buffer_contents, true)

		-- Only send if something has been typed in
		if utils.flatten_lines(buffer_contents) ~= utils.flatten_lines(template_content) then
			-- Send text to sclang
			send2sc(text)
		end

		-- push(popup.bufnr)

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
