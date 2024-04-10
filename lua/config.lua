local defaults = require("defaults")
local repl = require("repl")
local u = require("utils")

local M = {}

---@class Config
---@field repls table<Repl>
---@field default_repl table
---@field default_term table
local Config = {}

---Class constructor
---@param opts table
---@return Config
function Config:new(opts)
	local obj = {}

	obj.default_repl = u.get_defaults(opts, defaults.repl_defaults)
	obj.default_term = u.get_defaults(opts, defaults.term_defaults)

	local repls = {}
	if type(opts["repls"]) == "table" then
		for _, repl_conf in ipairs(opts["repls"]) do
			local current_repl = repl.Repl:new(repl_conf)
			repls[current_repl.name] = current_repl
		end
	end

	obj.repls = repls

	self.__index = self
	return setmetatable(obj, self)
end

---Create a new REPL from the configuration
---@param name string
---@return Repl
function Config:new_repl(name)
	local params = u.copy(self.repls[name])

	if params == nil then
		params = u.copy(self.default_repl)
		params.cmd = name
	end

	return repl.Repl:new(params)
end

function Config:new_term(name)
	local params = u.copy(self.default_term)
	params.repl = self:new_repl(name)

	return repl.Terminal:new(params)
end

M.Config = Config

return M
