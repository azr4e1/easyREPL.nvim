local c = require("easyREPL.config")
local core = require("easyREPL.core")
local commands = require("easyREPL.commands")
local defaults = require("easyREPL.defaults")
local u = require("easyREPL.utils")

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
