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

---Return stringified content
---@return string
function Fmt:string()
	return table.concat(self.lines, "\n")
end

M.Fmt = Fmt

return M
