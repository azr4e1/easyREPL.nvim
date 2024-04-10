--  TODO: every action must check that the terminal job is still active
local fmt = require("easyREPL.fmt")
local u = require("easyREPL.utils")
local defaults = require("easyREPL.defaults")

local M = {}

local C_L = ""
local C_C = ""

---@class Repl
---@field cmd string
---@field name string
---@field cwd string
---@field nr_cr number
---@field strip boolean
---@field nonewline boolean
---@field filetypes table<string>
local Repl = {}

---Class constructor
---@param opts table
---@return Repl
function Repl:new(opts)
	if opts.cmd == nil then
		error("'cmd' value cannot be nil or empty. It must be a valid REPL command.")
	end
	if vim.fn.executable(opts.cmd) ~= 1 then
		error(opts.cmd .. " does not exist.")
	end

	local obj = u.get_defaults(opts, defaults.repl_defaults)
	obj.cmd = opts.cmd

	self.__index = self

	return setmetatable(obj, self)
end

---@class Terminal
---@field repl Repl
---@field bufid number
---@field termid number
---@field height number
---@field width number
---@field horizontal boolean
---@field floating boolean
---@field screen_pct string|number
local Terminal = {}

---Class constructor
---@param opts table
---@return Terminal
function Terminal:new(opts)
	if opts.repl == nil then
		error("'repl' value cannot be nil or empty. It must be a valid REPL.")
	end

	local obj = u.get_defaults(opts, defaults.term_defaults)
	obj.repl = opts.repl

	self.__index = self

	return setmetatable(obj, self)
end

---Initialize and open terminal buffer
function Terminal:spawn()
	-- if it already exists, do nothing
	if self.bufid ~= nil and self.bufid > 0 then
		return
	end

	-- create empty buffer
	self.bufid = vim.api.nvim_create_buf(false, false)
	if self.bufid <= 0 then
		error("couldn't create new buffer")
	end

	local height, width = u.fill_in_terminal_size(self)
	-- set terminal into buffer
	self.termid = vim.api.nvim_buf_call(self.bufid, function()
		local chanid = vim.fn.termopen(self.repl.cmd, {
			cwd = self.repl.cwd,
			height = height,
			width = width,
			on_exit = function()
				local id = u.get_term_id(self, EasyreplTerminalList)
				if id ~= -1 then
					EasyreplTerminalList:remove(u.get_term_id(self, EasyreplTerminalList))
				end
			end,
		})
		return chanid
	end)
	if self.termid <= 0 then
		error("couldn't create new REPL")
	end
end

function Terminal:kill()
	_ = pcall(vim.fn.jobstop, self.termid)
	_ = pcall(vim.api.nvim_buf_delete, self.bufid, { force = true })
	self.bufid = -1
	self.termid = -1
end

function Terminal:restart()
	local winid = vim.fn.bufwinid(self.bufid)
	self:kill()
	self:spawn()
	if winid > 0 then
		self:show()
	end
end

---Send text object
---@param text string
function Terminal:send(text)
	local formatted = fmt.Fmt:new(text)
	if self.termid <= 0 then
		error("repl is not active!")
	end

	if self.repl.strip then
		formatted = formatted:strip()
	end
	if self.repl.nonewline then
		formatted = formatted:nonewline()
	end

	local ok = pcall(vim.api.nvim_chan_send, self.termid, formatted:string(self.repl.nr_cr))
	if not ok then
		error("repl cannot accept input")
	end
end

function Terminal:clear()
	self:send(C_L)
end

function Terminal:interrupt()
	self:send(C_C)
end

function Terminal:show()
	if self.bufid == nil or self.bufid <= 0 then
		error("terminal not instantiated")
	end
	-- if terminal is already displayed, ignore
	if vim.fn.bufwinid(self.bufid) >= 0 then
		return
	end
	-- horizontal has precedence over float
	if self.horizontal and self.floating then
		self.floating = false
	end

	local height, width = u.fill_in_terminal_size(self)
	if self.floating then
		local row, col = u.get_centre_pos_float(height, width)
		local winid = vim.api.nvim_open_win(self.bufid, true, {
			relative = "editor",
			width = width,
			height = height,
			row = row,
			col = col,
			title = self.repl.name,
			border = "solid",
			style = "minimal",
		})
		if winid <= 0 then
			error("there was a problem creating a floating window")
		end
	else
		local cmd = self.horizontal and height .. "split" or width .. "vsplit"
		local prev_winid = vim.api.nvim_get_current_win()
		vim.cmd(cmd)
		local winid = vim.api.nvim_get_current_win()
		local ok = pcall(vim.api.nvim_win_set_buf, winid, self.bufid)
		if not ok then
			error("there was an error loading terminal buffer in new split")
		end
		vim.api.nvim_set_current_win(prev_winid)
	end
end

function Terminal:hide()
	local winid = vim.fn.bufwinid(self.bufid)
	if winid < 0 then
		return
	end
	vim.api.nvim_win_close(winid, true)
end

function Terminal:toggle()
	local winid = vim.fn.bufwinid(self.bufid)
	if winid < 0 then
		self:show()
		return
	end
	self:hide()
end

function Terminal:to_float()
	self.floating = true
	self.horizontal = false
	self:hide()
	self:show()
end

function Terminal:to_horizontal()
	self.floating = false
	self.horizontal = true
	self:hide()
	self:show()
end

function Terminal:to_vertical()
	self.floating = false
	self.horizontal = false
	self:hide()
	self:show()
end

---Resize terminal window
---@param opts string|table<number>
function Terminal:resize(opts)
	if type(opts) == "string" then
		self.height = -1
		self.width = -1
		self.screen_pct = opts
		return
	end
	local height = opts.height
	local width = opts.width

	if height ~= nil and type(height) == "number" and height > 0 then
		self.height = math.floor(height)
	end
	if width ~= nil and type(width) == "number" and width > 0 then
		self.width = math.floor(width)
	end
end

M.Terminal = Terminal
M.Repl = Repl

return M
