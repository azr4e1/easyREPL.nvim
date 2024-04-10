local u = require("utils")

local M = {}

M.repl_defaults = {
	name = "REPL",
	cwd = ".",
	nr_cr = 1,
	strip = false,
	nonewline = true,
	filetypes = {},
}

M.repl_types = {
	name = "string",
	cwd = "string",
	nr_cr = "number",
	strip = "boolean",
	nonewline = "boolean",
	filetypes = "table",
}

M.term_defaults = {
	screen_pct = "50%",
	horizontal = false,
	floating = false,
}

M.term_types = {
	height = "number",
	width = "number",
	horizontal = "boolean",
	floating = "boolean",
}

return M
