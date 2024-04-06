local fmt = require("fmt")
local u = require("utils")

local M = {}

local C_L = ""
local C_C = ""

---@class Repl
---@field cmd string
---@field name string
---@field cwd string
---@field strip boolean
---@field nonewline boolean
local Repl = {}

---Class constructor
---@param cmd string
---@param name string
---@param cwd string
---@param strip boolean
---@param nonewline boolean
---@return Repl
function Repl:new(cmd, name, cwd, strip, nonewline)
	local obj = {
		cmd = cmd,
		name = name,
		cwd = cwd,
		strip = strip,
		nonewline = nonewline,
	}
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
local Terminal = {}

---Class constructor
---@param repl Repl
---@param height number
---@param width number
---@param horizontal boolean
---@param floating boolean
---@return Terminal
function Terminal:new(repl, height, width, horizontal, floating)
	local obj = {
		repl = repl,
		height = height,
		width = width,
		horizontal = horizontal,
		floating = floating,
	}
	self.__index = self

	return setmetatable(obj, self)
end

---Initialize and open terminal buffer
function Terminal:spawn()
	-- create empty buffer
	self.bufid = vim.api.nvim_create_buf(false, false)
	if self.bufid <= 0 then
		error("couldn't create new buffer")
	end
	-- set terminal into buffer
	self.termid = vim.api.nvim_buf_call(self.bufid, function()
		local chanid = vim.fn.termopen(self.repl.cmd, {
			cwd = self.repl.cwd,
			height = self.height,
			width = self.width,
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

	local ok = pcall(vim.api.nvim_chan_send, self.termid, formatted:string())
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
	if self.bufid <= 0 then
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

	if self.floating then
		local row, col = u.get_centre_pos_float(self.height, self.width)
		local winid = vim.api.nvim_open_win(self.bufid, true, {
			relative = "editor",
			width = self.width,
			height = self.height,
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
		local cmd = self.horizontal and self.height .. "split" or self.width .. "vsplit"
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
---@param height number
---@param width number
function Terminal:resize(height, width)
	if height <= 0 or width <= 0 then
		error("cannot provide negative height/width")
	end
	self.height = math.floor(height)
	self.width = math.floor(width)
	self:hide()
	self:show()
end

M.Terminal = Terminal
M.Repl = Repl

return M
