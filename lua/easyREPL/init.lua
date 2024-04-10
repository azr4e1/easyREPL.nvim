local c = require("config")
local core = require("core")
local commands = require("commands")

local function setup(opts)
	EasyreplConfiguration = c.Config:new(opts)
	EasyreplTerminalList = core.Manager:new()
	commands.setup_commands()
end

local M = {
	actions = require("actions"),
	setup = setup,
}

return M
