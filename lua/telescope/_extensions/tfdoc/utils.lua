local M = {}

function M.is_exist_index(tbl, index)
	if type(tbl) == "table" and tbl[index] then
		local val = tbl[index]
		return true
	else
		return false
	end
end

function M.view_markdown(tempfile, open_type)
	local cmd = string.format("glow %s", tempfile)
	local bufnr = vim.api.nvim_create_buf(false, true)

	if open_type == "floating" then
		-- Floating windowを作成してバッファを設定
		local win_width = math.ceil(vim.o.columns * 0.8)
		local win_height = math.ceil(vim.o.lines * 0.8)
		local row = math.ceil((vim.o.lines - win_height) / 2 - 1)
		local col = math.ceil((vim.o.columns - win_width) / 2)
		local win_id = vim.api.nvim_open_win(bufnr, true, {
			relative = "editor",
			row = row,
			col = col,
			width = win_width,
			height = win_height,
			style = "minimal",
			focusable = false,
			border = "single",
		})
	elseif open_type == "split" then
		-- スプリットウィンドウを作成して、バッファを設定
		vim.api.nvim_command("split")
		local winid = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(winid, bufnr)
	elseif open_type == "vsplit" then
		-- Vスプリットウィンドウを作成して、バッファを設定（デフォルト）
		vim.api.nvim_command("vsplit")
		local winid = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(winid, bufnr)
	elseif open_type == "tab" then
		-- 新規タブを作成して、バッファを設定
		vim.api.nvim_command("tabnew")
		local winid = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(winid, bufnr)
	end

	-- テンポラリファイルに書き込みが完了した後、glowコマンドを実行
	local on_write_done = function()
		vim.fn.termopen(cmd, {
			detach = 0,
			on_exit = function(_, _)
				os.remove(tempfile)
			end,
		})
	end
	vim.schedule_wrap(on_write_done)()

	-- バッファローカルなマップを設定
	local map_buf_opts = { noremap = true, silent = true, nowait = true }
	vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<Cmd>bdelete<CR>", map_buf_opts)

	return nil
end

return M
