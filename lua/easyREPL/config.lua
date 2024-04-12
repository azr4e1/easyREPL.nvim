-- TODO: implement priority filetypes
local defaults = require("easyREPL.defaults")
local repl = require("easyREPL.repl")
local u = require("easyREPL.utils")

local M = {}

---Update filetype table
---@param repl_name string
---@param old_ft table<string>
local function update_filetypes(repl_name, old_ft, new_ft)
	if new_ft == nil or type(new_ft) ~= "table" then
		return
	end

	for _, ft in ipairs(new_ft) do
		local repls = u.copy(old_ft[ft])
		if repls == nil then
			repls = {}
		end
		table.insert(repls, repl_name)
		old_ft[ft] = repls
	end
end

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
	local filetypes = {}
	if type(opts["repls"]) == "table" then
		for _, repl_conf in ipairs(opts["repls"]) do
			local ok, current_repl = pcall(function()
				return repl.Repl:new(repl_conf)
			end)
			if not ok then
				vim.notify("command " .. repl_conf.cmd .. " does not exist.", vim.log.levels.ERROR)
				goto continue
			end
			local current_term_conf = u.get_defaults(repl_conf, obj.default_term)
			repls[current_repl.name] = { repl_config = current_repl, term_config = current_term_conf }

			update_filetypes(current_repl.name, filetypes, current_repl.filetypes)
			::continue::
		end
	end

	obj.repls = repls
	obj.filetypes = filetypes

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
