local c = require("easyREPL.config")
local core = require("easyREPL.core")
local commands = require("easyREPL.commands")
local defaults = require("easyREPL.defaults")
local u = require("easyREPL.utils")

local function setup(opts)
	local repls = u.copy(defaults.default_repls)
	if opts.repls ~= nil and type(opts.repls) == "table" then
		for _, repl in ipairs(opts.repls) do
			if vim.fn.executable(repl.cmd) == 1 then
				table.insert(repls, repl)
			end
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
