local c = require("config")
local core = require("core")
local commands = require("commands")
local defaults = require("defaults")
local u = require("utils")

local function setup(opts)
	local repls = u.copy(defaults.default_repls)
	if opts.repls ~= nil and type(opts.repls) == "table" then
		for _, repl in ipairs(opts.repls) do
			table.insert(repls, repl)
		end
	end
	opts.repls = repls
	---@diagnostic disable-next-line: undefined-field
	EasyreplConfiguration = c.Config:new(opts)
	EasyreplTerminalList = core.Manager:new()
	commands.setup_commands()
end

local M = {
	actions = require("actions"),
	setup = setup,
}

return M
