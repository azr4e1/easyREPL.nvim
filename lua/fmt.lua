---@class Text
local Text = {}

---Class contructor
---@param content string
---@return Text
function Text:new(content)
	local obj = { content = content }
	self.__index = self

	return setmetatable(obj, self)
end
