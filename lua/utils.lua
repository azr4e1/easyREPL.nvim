local M = {}

---Get height and width of window relative to ui
---@param pct string|number
---@return number, number
function M.get_term_size_pct(pct)
	local _type = type(pct)
	local ui = vim.api.nvim_list_uis()[1]
	local numPct
	local height = ui.height
	local width = ui.width

	if _type == string then
		---@diagnostic disable-next-line: param-type-mismatch
		if #pct < 1 or not vim.endswith(pct, "%") then
			error("incorrectly formatted string. Must be in format '%d%%'")
		end
		numPct = tonumber(string.sub(pct, 1, -2)) / 100
	elseif _type == "number" then
		if pct < 0 or pct > 1 then
			error("incorrect percentage value. Must be between 0 and 1")
		end
		numPct = pct
	else
		error("Value must be a string or a number")
	end

	local termHeight = math.floor(height * numPct)
	local termWidth = math.floor(width * numPct)

	return termHeight, termWidth
end

---Get anchor for floating window
---@param termHeight number
---@param termWidth number
---@return number, number
function M.get_centre_pos_float(termHeight, termWidth)
	local ui = vim.api.nvim_list_uis()[1]
	local height = ui.height
	local width = ui.width

	local row = math.floor((height - termHeight) / 2)
	local col = math.floor((width - termWidth) / 2)

	if row < 0 then
		row = 0
	end

	if col < 0 then
		col = 0
	end

	return row, col
end

---Get current line as text
---@return string
function M.get_current_line()
	return vim.api.nvim_get_current_line()
end

---Get current visual selection as text. From https://neovim.discourse.group/t/function-that-return-visually-selected-text/1601
---@return string
function M.get_current_selection()
	local s_start = vim.fn.getpos("'<")
	local s_end = vim.fn.getpos("'>")
	local n_lines = math.abs(s_end[2] - s_start[2]) + 1
	local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
	lines[1] = string.sub(lines[1], s_start[3], -1)
	if n_lines == 1 then
		lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
	else
		lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
	end
	return table.concat(lines, "\n")
end

function M.get_current_buffer()
	local content = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
	return table.concat(content, "\n")
end

-- TODO: Add data validation

---Get defaults if key not available in input
---@param input_vales table
---@param default_values table
---@return table
function M.get_defaults(input_vales, default_values)
	local obj = {}
	for key, default_val in pairs(default_values) do
		local val = input_vales[key]
		if val == nil then
			val = default_val
		end
		obj[key] = val
	end

	return obj
end

---Return a shallow copy of original table
---@param input table
---@return table|nil
function M.copy(input)
	if input == nil then
		return nil
	end

	local copy = {}
	for key, val in pairs(input) do
		copy[key] = val
	end

	return copy
end

function M.select_repl() end

return M
