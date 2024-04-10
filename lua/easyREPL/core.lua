local M = {}

---@class Manager
---@field terminals table<Terminal>
local Manager = {}

function Manager:new()
	self.__index = self

	return setmetatable({ terminals = {} }, self)
end

---Add terminal object
---@param term Terminal
function Manager:add(term)
	term:spawn()
	table.insert(self.terminals, term)
end

---Remove provided terminal
---@param id number
function Manager:remove(id)
	local term = self.terminals[id]
	if term == nil then
		error("terminal doesn't exist")
	end
	term:kill()
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
	for id, _ in ipairs(self.terminals) do
		self:apply(id, func)
	end
end

M.Manager = Manager

return M
