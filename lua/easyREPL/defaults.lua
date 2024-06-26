local M = {}

M.window_settings = {
	number = false,
	relativenumber = false,
	cursorline = false,
	cursorcolumn = false,
	spell = false,
	list = false,
	signcolumn = "no",
}

M.repl_defaults = {
	name = "REPL",
	cwd = ".",
	nr_cr = 1,
	strip = false,
	nonewline = true,
	notab = true,
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
	height = -1,
	width = -1,
}

M.term_types = {
	height = "number",
	width = "number",
	horizontal = "boolean",
	floating = "boolean",
}

M.default_repls = {
	{
		cmd = "ipython --no-autoindent",
		name = "ipython REPL",
		cwd = ".",
		nr_cr = 2,
		strip = false,
		nonewline = true,
		filetypes = { "python" },
	},
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
	{
		cmd = "bash",
		name = "bash shell",
		cwd = ".",
		nr_cr = 1,
		strip = false,
		nonewline = true,
		filetypes = { "bash", "sh" },
	},
	{
		cmd = "zsh",
		name = "zsh shell",
		cwd = ".",
		nr_cr = 1,
		strip = false,
		nonewline = true,
		filetypes = { "zsh", "sh" },
	},
	{
		cmd = "fish",
		name = "fish shell",
		cwd = ".",
		nr_cr = 1,
		strip = false,
		nonewline = true,
		filetypes = { "fish", "sh" },
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
}

function M.set_term_background(bg)
	if bg == nil then
		bg = "#000000"
	end
	vim.api.nvim_set_hl(0, "EasyReplBackground", { bg = bg })
end

return M
