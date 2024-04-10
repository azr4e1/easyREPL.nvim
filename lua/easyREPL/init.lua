local c = require("easyREPL.config")
local core = require("easyREPL.core")
local commands = require("easyREPL.commands")
local defaults = require("easyREPL.defaults")

local function setup(opts)
	local repls = {}
	for _, repl in ipairs(defaults.default_repls) do
		if vim.fn.executable(repl.cmd) == 1 then
			table.insert(repls, repl)
		end
	end
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
	defaults.set_term_background(opts.background)
end

local M = {
	actions = require("easyREPL.actions"),
	setup = setup,
}

return M
