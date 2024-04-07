local M = {}

---@class Manager
---@field terminals table
local Manager = {}

function Manager:new()
	self.__index = self

	return setmetatable({ terminals = {} }, self)
end

---Append a terminal object
---@param term Terminal
function Manager:append(term)
	table.insert(self.terminals, term)
end

---Remove provided terminal
---@param id number
function Manager:remove(id)
	local term = self.terminals[id]
	if term == nil then
		error("terminal doesn't exist")
	end
	_ = table.remove(self.terminals, id)
end

---Do action to a terminal
---@param id number
---@param func function
function Manager:apply(id, func)
	local term = self.terminals[id]
	if term == nil then
		error("terminal doesn't exist")
	end
	func(term)
end

---Broadcast action to all terminals
---@param func function
function Manager:broadcast(func)
	for id, _ in self.terminals do
		self:apply(id, func)
	end
end

---Setup function
---@param config table
function M.setup(config) end

M.Manager = Manager

return M
