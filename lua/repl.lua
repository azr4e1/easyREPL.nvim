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
---@param hidden boolean
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
---@param lines Fmt
function Terminal:send(lines)
	if self.termid <= 0 then
		error("repl is not active!")
	end

	if self.repl.strip then
		lines = lines:strip()
	end
	if self.repl.nonewline then
		lines = lines:nonewline()
	end

	local ok = pcall(vim.api.nvim_chan_send, self.termid, lines:string())
	if not ok then
		error("repl cannot accept input")
	end
end

function Terminal:clear() end

function Terminal:hide() end

function Terminal:show() end

function Terminal:toggle() end

function Terminal:float() end

function Terminal:anchor() end

function Terminal:resize(height, width) end

M.Terminal = Terminal
M.Repl = Repl

return M
