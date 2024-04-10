local M = {}

---@class Fmt
---@field lines table
local Fmt = {}

---Class contructor
---@param content string
---@return Fmt
function Fmt:new(content)
	local lines = vim.split(content, "\n")
	local obj = { lines = lines }
	self.__index = self

	return setmetatable(obj, self)
end

---Strip lines from whitespace
---@return Fmt
function Fmt:strip()
	local lines = {}
	for _, line in ipairs(self.lines) do
		table.insert(lines, vim.trim(line))
	end

	return Fmt:new(table.concat(lines, "\n"))
end

---Strip lines from newlines
---@return Fmt
function Fmt:nonewline()
	local lines = {}
	for _, line in ipairs(self.lines) do
		if vim.trim(line) ~= "" then
			table.insert(lines, line)
		end
	end

	return Fmt:new(table.concat(lines, "\n"))
end

---Replace tabs with spaces
---@param nr_sp number
---@return Fmt
function Fmt:notab(nr_sp)
	local lines = {}
	local tab_replacement = string.rep(" ", nr_sp)
	for _, line in ipairs(self.lines) do
		table.insert(lines, string.gsub(line, "\t", tab_replacement)[1])
	end

	return Fmt:new(table.concat(lines, "\n"))
end

---Return stringified content
---@param nr_cr number|nil
---@return string
function Fmt:string(nr_cr)
	local lines = table.concat(self.lines, "\n")
	if nr_cr == nil then
		nr_cr = 0
	end
	for _ = 1, nr_cr do
		lines = lines .. "\n"
	end
	return lines
end

M.Fmt = Fmt

return M
