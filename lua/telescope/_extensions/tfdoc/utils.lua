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
		local win_id = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(win_id, bufnr)
	elseif open_type == "vsplit" then
		-- Vスプリットウィンドウを作成して、バッファを設定（デフォルト）
		vim.api.nvim_command("vsplit")
		local win_id = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(win_id, bufnr)
	elseif open_type == "tab" then
		-- 新規タブを作成して、バッファを設定
		vim.api.nvim_command("tabnew")
		local win_id = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(win_id, bufnr)
	end

	local doc_width = vim.api.nvim_win_get_width(0)
	local cmd = string.format("%s -c 'glow -w %s %s; sleep 0.2'", vim.env.SHELL, doc_width - 7, tempfile)

	vim.fn.termopen(cmd, {
		detach = 0,
		on_exit = function(_, _)
			os.remove(tempfile)
		end,
	})

	-- バッファローカルなマップを設定
	local map_buf_opts = { noremap = true, silent = true, nowait = true }
	vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<Cmd>bdelete<CR>", map_buf_opts)

	return nil
end

return M
