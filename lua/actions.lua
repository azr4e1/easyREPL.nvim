local manager = vim.g.easyrepl_terminal_list
local config = vim.g.easyrepl_configuration

local M = {}

function M.add_new_repl(name) end

function M.restart_repl(...) end

function M.restart_all() end

function M.kill_repl(...) end

function M.kill_all() end

function M.rename_repl(id, new_name) end

function M.select_repl() end

function M.send_to_repl(...) end

function M.send_to_all() end

function M.show_repl(...) end

function M.show_all() end

function M.hide_repl(...) end

function M.hide_all() end

function M.toggle_repl(...) end

function M.toggle_all() end

function M.to_float(...) end

function M.to_horizontal(...) end

function M.to_vertical(...) end

function M.clear_repl(...) end

function M.clear_all() end

function M.interrupt_repl(...) end

function M.interrupt_all() end

return M
