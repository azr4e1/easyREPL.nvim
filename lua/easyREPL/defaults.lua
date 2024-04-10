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

M.default_repls = {
	{
		cmd = "python",
		name = "python interpreter",
		cwd = ".",
		nr_cr = 2,
		strip = false,
		nonewline = true,
		filetypes = { "python" },
	},
	{
		cmd = "ipython",
		name = "ipython REPL",
		cwd = ".",
		nr_cr = 2,
		strip = false,
		nonewline = true,
		filetypes = {},
	},
	{
		cmd = "lua",
		name = "lua interpreter",
		cwd = ".",
		nr_cr = 1,
		strip = false,
		nonewline = true,
		filetypes = { "lua" },
	},
	{
		cmd = "R",
		name = "R interpreter",
		cwd = ".",
		nr_cr = 1,
		strip = false,
		nonewline = true,
		filetypes = { "r", "rmarkdown" },
	},
	{
		cmd = "sh",
		name = "shell interpreter",
		cwd = ".",
		nr_cr = 1,
		strip = false,
		nonewline = true,
		filetypes = { "sh" },
	},
	{
		cmd = "ghci",
		name = "haskell interpreter",
		cwd = ".",
		nr_cr = 1,
		strip = false,
		nonewline = true,
		filetypes = { "haskell" },
	},
	{
		cmd = "julia",
		name = "julia interpreter",
		cwd = ".",
		nr_cr = 1,
		strip = false,
		nonewline = true,
		filetypes = { "julia" },
	},
}

return M