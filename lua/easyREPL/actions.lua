local u = require("easyREPL.utils")

local M = {}

local function select_active_repl(func)
	local repls = {}
	for i, term in ipairs(EasyreplTerminalList.terminals) do
		local selection = tostring(i) .. ". " .. term.repl.name .. " - " .. term.repl.cmd
		table.insert(repls, selection)
	end
	u.select(repls, "Select the REPL:", func)
end

local function select_config_repl(func)
	local repls = {}
	local i = 1
	for name, repl in pairs(EasyreplConfiguration.repls) do
		local selection = tostring(i) .. ". " .. name .. " - " .. repl.repl_config.cmd
		table.insert(repls, selection)
		i = i + 1
	end
	u.select(repls, "Select the REPL:", func)
end

function M.add_new_repl(name)
	local ok, new_term = pcall(function()
		return EasyreplConfiguration:new_term(name)
	end)
	if not ok then
		vim.notify(
			"There was an error creating the REPL "
				.. name
				.. ":\n"
				.. new_term
				.. "\nMake sure to provide the correct REPL and that there is no error in your configuration",
			vim.log.levels.ERROR
		)
		return
	end
	local err
	ok, err = pcall(function()
		EasyreplTerminalList:add(new_term)
	end)
	if not ok then
		vim.notify(
			"There was an error starting the REPL "
				.. name
				.. ":\n"
				.. err
				.. ".\nMake sure to provide the correct REPL and that there is no error in your configuration",
			vim.log.levels.ERROR
		)
		return
	end
end

function M.add_new_repl_and_show(name)
	local prev_len = #EasyreplTerminalList.terminals
	M.add_new_repl(name)
	local new_len = #EasyreplTerminalList.terminals
	if new_len - prev_len == 1 then
		(EasyreplTerminalList.terminals[new_len]):show()
	end
end

function M.add_new_select_repl()
	local default_repls = {}
	for name, _ in pairs(EasyreplConfiguration.repls) do
		table.insert(default_repls, name)
	end

	select_config_repl(function(id)
		local name = default_repls[id]
		M.add_new_repl(name)
	end)
end

function M.add_new_select_and_show()
	local default_repls = {}
	for name, _ in pairs(EasyreplConfiguration.repls) do
		table.insert(default_repls, name)
	end

	select_config_repl(function(id)
		local name = default_repls[id]
		M.add_new_repl_and_show(name)
	end)
end

function M.add_new_repl_auto()
	local auto_repl_name = nil
	local filetype = vim.o.filetype
	for name, repl in pairs(EasyreplConfiguration.repls) do
		for _, ft in ipairs(repl.repl_config.filetypes) do
			if filetype == ft then
				auto_repl_name = name
				goto continue
			end
		end
	end
	::continue::

	if auto_repl_name == nil then
		M.add_new_select_repl()
		return
	end
	M.add_new_repl(auto_repl_name)
end

function M.add_new_repl_auto_and_show()
	local auto_repl_name = nil
	local filetype = vim.o.filetype
	for name, repl in pairs(EasyreplConfiguration.repls) do
		for _, ft in ipairs(repl.repl_config.filetypes) do
			if filetype == ft then
				auto_repl_name = name
				goto continue
			end
		end
	end
	::continue::

	if auto_repl_name == nil then
		M.add_new_select_and_show()
		return
	end
	M.add_new_repl_and_show(auto_repl_name)
end

function M.restart_repl(id)
	if EasyreplTerminalList.terminals[id] == nil then
		vim.notify("REPL doesn't exist", vim.log.levels.WARN)
		return
	end
	EasyreplTerminalList:apply(id, function(term)
		term:restart()
	end)
end

function M.restart_select_repl()
	select_active_repl(M.restart_repl)
end

function M.restart_all()
	EasyreplTerminalList:broadcast(function(term)
		term:restart()
	end)
end

function M.kill_repl(id)
	if EasyreplTerminalList.terminals[id] == nil then
		vim.notify("REPL doesn't exist", vim.log.levels.WARN)
		return
	end
	EasyreplTerminalList:remove(id)
end

function M.kill_select_repl()
	select_active_repl(M.kill_repl)
end

function M.kill_all()
	EasyreplTerminalList:broadcast(function(term)
		term:kill()
	end)
	EasyreplTerminalList.terminals = {}
end

function M.rename_repl(id, new_name)
	if EasyreplTerminalList.terminals[id] == nil then
		vim.notify("REPL doesn't exist", vim.log.levels.WARN)
		return
	end
	---@diagnostic disable-next-line: undefined-field
	EasyreplTerminalList.terminals[id].repl.name = new_name
end

function M.rename_select_repl(new_name)
	select_active_repl(function(id)
		M.rename_repl(id, new_name)
	end)
end

function M.send_line_to_repl(id)
	if EasyreplTerminalList.terminals[id] == nil then
		vim.notify("REPL doesn't exist", vim.log.levels.WARN)
		return
	end
	EasyreplTerminalList:apply(id, function(term)
		local line = u.get_current_line()
		local ok, err = pcall(function()
			term:send(line)
		end)
		if not ok then
			vim.notify(
				"There was an error sending text to REPL:\n" .. err .. "\nMake sure the process is running.",
				vim.log.levels.ERROR
			)
			return
		end
	end)
end

function M.send_line_to_select_repl()
	select_active_repl(M.send_line_to_repl)
end

function M.send_line_to_all()
	EasyreplTerminalList:broadcast(function(term)
		local line = u.get_current_line()
		local ok, err = pcall(function()
			term:send(line)
		end)
		if not ok then
			vim.notify(
				"There was an error sending text to REPL:\n" .. err .. "\nMake sure the process is running.",
				vim.log.levels.ERROR
			)
			return
		end
	end)
end

function M.send_selection_to_repl(id)
	if EasyreplTerminalList.terminals[id] == nil then
		vim.notify("REPL doesn't exist", vim.log.levels.WARN)
		return
	end
	EasyreplTerminalList:apply(id, function(term)
		local line = u.get_current_selection()
		local ok, err = pcall(function()
			term:send(line)
		end)
		if not ok then
			vim.notify(
				"There was an error sending text to REPL:\n" .. err .. "\nMake sure the process is running.",
				vim.log.levels.ERROR
			)
			return
		end
	end)
end

function M.send_selection_to_select_repl()
	select_active_repl(M.send_selection_to_repl)
end

function M.send_selection_to_all()
	EasyreplTerminalList:broadcast(function(term)
		local line = u.get_current_selection()
		local ok, err = pcall(function()
			term:send(line)
		end)
		if not ok then
			vim.notify(
				"There was an error sending text to REPL:\n" .. err .. "\nMake sure the process is running.",
				vim.log.levels.ERROR
			)
			return
		end
	end)
end

function M.show_repl(id)
	if EasyreplTerminalList.terminals[id] == nil then
		vim.notify("REPL doesn't exist", vim.log.levels.WARN)
		return
	end
	EasyreplTerminalList:apply(id, function(term)
		local ok, err = pcall(function()
			term:show()
		end)
		if not ok then
			vim.notify(err, vim.log.levels.ERROR)
			return
		end
	end)
end

function M.show_select_repl()
	select_active_repl(M.show_repl)
end

function M.show_all()
	EasyreplTerminalList:broadcast(function(term)
		local ok, err = pcall(function()
			term:show()
		end)
		if not ok then
			vim.notify(err, vim.log.levels.ERROR)
			return
		end
	end)
end

function M.hide_repl(id)
	if EasyreplTerminalList.terminals[id] == nil then
		vim.notify("REPL doesn't exist", vim.log.levels.WARN)
		return
	end
	EasyreplTerminalList:apply(id, function(term)
		term:hide()
	end)
end

function M.hide_select_repl()
	select_active_repl(M.hide_repl)
end

function M.hide_all()
	EasyreplTerminalList:broadcast(function(term)
		term:hide()
	end)
end

function M.toggle_repl(id)
	if EasyreplTerminalList.terminals[id] == nil then
		vim.notify("REPL doesn't exist", vim.log.levels.WARN)
		return
	end
	EasyreplTerminalList:apply(id, function(term)
		local ok, err = pcall(function()
			term:toggle()
		end)
		if not ok then
			vim.notify(err, vim.log.levels.ERROR)
			return
		end
	end)
end

function M.toggle_selected_repl()
	select_active_repl(M.toggle_repl)
end

function M.toggle_all()
	EasyreplTerminalList:broadcast(function(term)
		local ok, err = pcall(function()
			term:toggle()
		end)
		if not ok then
			vim.notify(err, vim.log.levels.ERROR)
			return
		end
	end)
end

function M.to_float(id)
	if EasyreplTerminalList.terminals[id] == nil then
		vim.notify("REPL doesn't exist", vim.log.levels.WARN)
		return
	end
	EasyreplTerminalList:apply(id, function(term)
		term:to_float()
	end)
end

function M.to_float_select()
	select_active_repl(M.to_float)
end

function M.to_horizontal(id)
	if EasyreplTerminalList.terminals[id] == nil then
		vim.notify("REPL doesn't exist", vim.log.levels.WARN)
		return
	end
	EasyreplTerminalList:apply(id, function(term)
		term:to_horizontal()
	end)
end

function M.to_horizontal_select()
	select_active_repl(M.to_horizontal)
end

function M.to_vertical(id)
	if EasyreplTerminalList.terminals[id] == nil then
		vim.notify("REPL doesn't exist", vim.log.levels.WARN)
		return
	end
	EasyreplTerminalList:apply(id, function(term)
		term:to_vertical()
	end)
end

function M.to_vertical_select()
	select_active_repl(M.to_vertical)
end

function M.clear_repl(id)
	if EasyreplTerminalList.terminals[id] == nil then
		vim.notify("REPL doesn't exist", vim.log.levels.WARN)
		return
	end
	EasyreplTerminalList:apply(id, function(term)
		term:clear()
	end)
end

function M.clear_select_repl()
	select_active_repl(M.clear_repl)
end

function M.clear_all()
	EasyreplTerminalList:broadcast(function(term)
		term:clear()
	end)
end

function M.interrupt_repl(id)
	if EasyreplTerminalList.terminals[id] == nil then
		vim.notify("REPL doesn't exist", vim.log.levels.WARN)
		return
	end
	EasyreplTerminalList:apply(id, function(term)
		term:interrupt()
	end)
end

function M.interrupt_select_repl()
	select_active_repl(M.interrupt_repl)
end

function M.interrupt_all()
	EasyreplTerminalList:broadcast(function(term)
		term:interrupt()
	end)
end

function M.list_repls()
	for i, term in ipairs(EasyreplTerminalList.terminals) do
		local selection = tostring(i) .. ". " .. term.repl.name .. " - " .. term.repl.cmd
		print(selection)
	end
end

return M
