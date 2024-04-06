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

---comment
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

return M
