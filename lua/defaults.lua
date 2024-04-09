local u = require("utils")

local M = {}

M.repl_defaults = {
	name = "REPL",
	cwd = ".",
	nr_cr = 1,
	strip = false,
	nonewline = true,
}

local height, width = u.get_term_size_pct(0.5)
M.term_defaults = {
	height = height,
	width = width,
	horizontal = false,
	floating = false,
}

return M
