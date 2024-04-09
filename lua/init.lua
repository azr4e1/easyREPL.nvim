local c = require("config")
local core = require("core")
local commands = require("commands")

local function setup(opts)
	vim.g.easyrepl_configuration = c.Config:new(opts)
	vim.g.easyrepl_terminal_list = core.Manager:new()
	commands.setup_commands()
end

local M = {
	actions = require("actions"),
	setup = setup,
}

return M
