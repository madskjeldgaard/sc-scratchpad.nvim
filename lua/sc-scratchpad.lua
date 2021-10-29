local M = {}

local scnvim = require"scnvim"
local send2sc = scnvim.send
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

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

-- function M.find_scnvim_keymap(rhs_contains)
-- 	local mappings = vim.api.nvim_buf_get_keymap(0, "n")
-- 	local left_hand_sides = {}

-- 	for _, mapping in ipairs(mappings) do
-- 		local does_contain = string.find(mapping.rhs, rhs_contains)
-- 		print(mappings.rhs)
-- 		if  does_contain then
-- 			table.insert(left_hand_sides, mapping.lhs)
-- 		end
-- 	end

-- 	return left_hand_sides
-- end
function M.open()
	local popup = Popup({
		enter = true,
		focusable = true,
		border = {
			style = "solid",
			highlight = "FloatBorder",
			text = {
				top = "yo",
				top_align = "center",
			},
		},
		position = "50%",
		size = {
			width = "80%",
			height = "80%",
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

	-- popup.border:set_text("top", "sc", "center")

	local map_callback = function(bufnr)
		local window = vim.api.nvim_get_current_win()
		vim.api.nvim_win_close(window, true)
	end

	popup:map("n", "<C-E>", map_callback, { noremap = true })
	popup:map("i", "<C-E>", map_callback, { noremap = true })
	popup:map("n", "<CR>", map_callback, { noremap = true })

	-- Set keymaps
	-- vim.api.nvim_buf_del_keymap(popup.bufnr, "n", "<C-E>")
	-- vim.api.nvim_buf_set_keymap(popup.bufnr, "n", "<C-E>", ":close<CR>", {})
	-- vim.api.nvim_buf_set_keymap(popup.bufnr, "i", "<C-E>", ":close<CR>", {})

	-- vim.api.nvim_buf_del_keymap(popup.bufnr, "n", "<CR>")
	-- vim.api.nvim_buf_set_keymap(popup.bufnr, "n", "<CR>", ":close<CR>", {})

	-- set content
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, { "// sc-scratchpad.nvim", "" })
	vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), {2,1})

	-- unmount component when cursor leaves buffer
	popup:on(event.BufLeave, function()
		local numLines = vim.api.nvim_buf_line_count(popup.bufnr)
		local text = vim.api.nvim_buf_get_lines(popup.bufnr, 0, numLines, false)
		text = flatten_lines(text, true)
		send2sc(text)
		popup:unmount()
	end)

end

function M.setup()
	vim.cmd[[
	command! SCScratchPad lua require('sc-scratchpad').open()
	]]
end

return M
