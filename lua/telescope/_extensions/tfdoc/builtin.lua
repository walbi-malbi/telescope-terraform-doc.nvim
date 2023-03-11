local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local utils = require("telescope._extensions.tfdoc.utils")
local api = require("telescope._extensions.tfdoc.api")

local M = {}

M.exec = function(opts)
	opts = opts or {}

	if not opts.provider then
		vim.api.nvim_err_write("an error occurred: " .. "provider name not found" .. "\n")
	end

	local provider_full_name, err = api.get_provider_full_name(opts.provider)

	if err ~= nil then
		vim.api.nvim_err_write("an error occurred: " .. err .. "\n")
		return
	end

	local provider_latest_version, err = api.get_provider_latest_version(provider_full_name)

	if err ~= nil then
		vim.api.nvim_err_write("an error occurred: " .. err .. "\n")
		return
	end

	local provider_version

	if opts.version ~= nil and opts.version ~= provider_latest_version then
		local exist, err = api.is_exist_provider_version(provider_full_name, opts.version)
		if not exist then
			vim.api.nvim_err_write("an error occurred: " .. err .. "\n")
			return
		end
		provider_version = opts.version
	else
		provider_version = provider_latest_version
	end

	local resource_list, err = api.get_resource_list(provider_full_name, provider_version)

	if err ~= nil then
		vim.api.nvim_err_write("an error occurred: " .. err .. "\n")
		return
	end

	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 70 },
			{ width = 20 },
			{ width = 40 },
			{ remaining = true },
		},
	})

	local make_display = function(entry)
		return displayer({
			entry.title,
			entry.category,
			entry.subcategory,
		})
	end

	pickers
		.new(opts, {
			prompt_title = "Search",
			finder = finders.new_table({
				results = resource_list,
				entry_maker = function(entry)
					return {
						ordinal = entry.title .. entry.category .. entry.subcategory,
						display = make_display,

						title = entry.title,
						category = entry.category,
						subcategory = entry.subcategory,
						slug = entry.slug,
						path = entry.path,
						id = entry.id,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local entry = action_state.get_selected_entry()
					actions.close(prompt_bufnr)

					local md, err = api.get_document(provider_full_name, provider_version, entry.path)
					if err ~= nil then
						vim.api.nvim_err_write("an error occurred: " .. err .. "\n")
						return
					end

					utils.view_markdown(md, "floating")
				end)
				actions.select_horizontal:replace(function()
					local entry = action_state.get_selected_entry()
					actions.close(prompt_bufnr)

					local md, err = api.get_document(provider_full_name, provider_version, entry.path)
					if err ~= nil then
						vim.api.nvim_err_write("an error occurred: " .. err .. "\n")
						return
					end

					utils.view_markdown(md, "split")
				end)
				actions.select_vertical:replace(function()
					local entry = action_state.get_selected_entry()
					actions.close(prompt_bufnr)

					local md, err = api.get_document(provider_full_name, provider_version, entry.path)
					if err ~= nil then
						vim.api.nvim_err_write("an error occurred: " .. err .. "\n")
						return
					end

					utils.view_markdown(md, "vsplit")
				end)
				actions.select_tab:replace(function()
					local entry = action_state.get_selected_entry()
					actions.close(prompt_bufnr)

					local md, err = api.get_document(provider_full_name, provider_version, entry.path)
					if err ~= nil then
						vim.api.nvim_err_write("an error occurred: " .. err .. "\n")
						return
					end

					utils.view_markdown(md, "tab")
				end)

				return true
			end,
		})
		:find()
end

return M
