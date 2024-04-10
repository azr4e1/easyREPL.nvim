local M = {}

function M.add_new_repl(name)
	local ok, new_term = pcall(function()
		return EasyreplConfiguration:new_term(name)
	end)
	if not ok then
		vim.notify(
			"There was an error creating the REPL "
				.. name
				.. ". Make sure to provide the correct REPL and that there is no error in your configuration",
			vim.log.levels.ERROR
		)
		return
	end
	ok = pcall(function()
		EasyreplTerminalList:add(new_term)
	end)
	if not ok then
		vim.notify(
			"There was an error starting the REPL "
				.. name
				.. ". Make sure to provide the correct REPL and that there is no error in your configuration",
			vim.log.levels.ERROR
		)
		return
	end
end

function M.select_repl(func)
	local repls = {}
	for i, term in ipairs(EasyreplTerminalList.terminals) do
		local selection = tostring(i) .. ". " .. term.repl.name .. " - " .. term.repl.cmd
		table.insert(repls, selection)
	end

	local catcher_thread = coroutine.create(function(index)
		local co = coroutine.running()
		vim.ui.select(repls, { prompt = "Select the REPL:" }, function(_, idx)
			coroutine.resume(co, idx)
		end)
		local input = coroutine.yield()
		func(input)
	end)

	coroutine.resume(catcher_thread)
end

function M.restart_repl(id) end

function M.restart_select_repl() end

function M.restart_all() end

function M.kill_repl(...) end

function M.kill_all()
	EasyreplTerminalList:broadcast(function(term)
		term:kill()
	end)
end

function M.rename_repl(id, new_name) end

function M.send_to_repl(...) end

function M.send_to_all() end

function M.show_repl(id)
	if EasyreplTerminalList.terminals[id] == nil then
		vim.notify("REPL doesn't exist", vim.log.levels.WARN)
	end
	EasyreplTerminalList:apply(id, function(term)
		term:show()
	end)
end

function M.show_select_repl()
	M.select_repl(M.show_repl)
end

function M.show_all() end

function M.hide_repl(id)
	if EasyreplTerminalList.terminals[id] == nil then
		vim.notify("REPL doesn't exist", vim.log.levels.WARN)
	end
	EasyreplTerminalList:apply(id, function(term)
		term:hide()
	end)
end

function M.hide_select_repl()
	M.select_repl(M.hide_repl)
end

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
