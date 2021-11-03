local M = {}

local old_buf_index = 0

-- Turn lines into one long text
function M.flatten_lines(lines_table, keep_linebreaks)
	local outstring = ""
	for _, line in pairs(lines_table) do
		outstring = outstring .. line
		if keep_linebreaks then
			outstring = outstring .. "\n"
		end
	end

	return outstring
end

-- Copy the current buffer to a global array of buffers to be recalled later (like arrow up in a terminal to recall earlier commands)
-- @TODO this is unused as of now
function M.push(buffer)
	local listed = false
	local new_buf = vim.api.nvim_create_buf(listed, false)

	if new_buf ~= 0 then
		local start = 0
		local ending = vim.api.nvim_buf_line_count(buffer)
		local buffer_lines = vim.api.nvim_buf_get_lines(buffer, 0, ending, false)
		vim.api.nvim_buf_set_lines(new_buf, start, ending-1, true, buffer_lines)

		vim.api.nvim_buf_set_name(new_buf, "sc-scratchpad-" .. #M.buffers)
		table.insert(M.buffers, new_buf)
	else
		print("Could not create new buffer")

	end
end

-- @TODO: This loads the buffers in the wrong places
function M.load_old(buffer)
	local numbufs = #M.buffers
	old_buf_index = (old_buf_index + 1) % numbufs

	local old = M.buffers[old_buf_index]
	local num_lines_old = vim.api.nvim_buf_line_count(old)
	local old_lines = vim.api.nvim_buf_get_lines(buffer, 0, num_lines_old - 1, false)

	print("loading old" .. old_buf_index .. ": ")
	print(M.flatten_lines(old_lines))
	vim.api.nvim_buf_set_lines(buffer, 0, num_lines_old, false, old_lines)

	-- Update window
	local window = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(window, old)

end

return M
