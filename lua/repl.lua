---@class Repl
local Repl = {}

---Class contructor
---@param opts table
---@return Repl
function Repl:new(opts)
	local obj = opts
	self.__index = self

	return setmetatable(obj, self)
end
