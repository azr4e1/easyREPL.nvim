-- TODO: allow for terminal configuration per REPL
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
			local current_term_conf = u.get_defaults(repl_conf, obj.default_term)
			repls[current_repl.name] = { repl_config = current_repl, term_config = current_term_conf }
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
	local params
	if self.repls[name] == nil then
		params = u.copy(self.default_repl)
		params.cmd = name
	else
		params = u.copy(self.repls[name].repl_config)
	end

	return repl.Repl:new(params)
end

function Config:new_term(name)
	local params
	if self.repls[name] == nil then
		params = u.copy(self.default_term)
	else
		---@diagnostic disable-next-line: undefined-field
		params = u.copy(self.repls[name].term_config)
	end
	params.repl = self:new_repl(name)

	return repl.Terminal:new(params)
end

M.Config = Config

return M
