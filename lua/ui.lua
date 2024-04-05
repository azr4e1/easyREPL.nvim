---@class Terminal
local Terminal = {}

---Class contructor
---@param opts table
---@return Terminal
function Terminal:new(opts)
	local obj = opts
	self.__index = self

	return setmetatable(obj, self)
end
