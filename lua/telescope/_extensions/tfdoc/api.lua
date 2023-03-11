local M = {}

function M.get_provider_full_name(provider_name)
	local url = ""
	if string.find(provider_name, "/") then
		url = "https://registry.terraform.io/v1/providers/" .. provider_name .. "/versions"
	else
		url = "https://registry.terraform.io/v1/providers/-/" .. provider_name .. "/versions"
	end

	local provider = nil

	local handle = io.popen("curl -s " .. url)
	if handle ~= nil then
		local response = handle:read("*a")
		handle:close()
		local response_json = vim.json.decode(response)

		provider = response_json.moved_to or response_json.id or nil
	else
		return nil, "failed to get provider info request"
	end

	if not provider then
		return nil, "failed to get provider info"
	end

	return provider, nil
end

function M.get_provider_latest_version(provider_full_name)
	local url = "https://registry.terraform.io/v1/providers/" .. provider_full_name
	local latest_version = nil

	local handle = io.popen("curl -s " .. url)
	if handle ~= nil then
		local response = handle:read("*a")
		handle:close()
		latest_version = vim.json.decode(response).version or nil
	else
		return nil, "request failed"
	end

	if not latest_version then
		return nil, "failed to get latest version"
	end

	return latest_version, nil
end

function M.is_exist_provider_version(provider_full_name, provider_version)
	local url = "https://registry.terraform.io/v1/providers/" .. provider_full_name .. "/" .. provider_version
	local is_exist = nil

	local handle = io.popen("curl -s " .. url)
	if handle ~= nil then
		local response = handle:read("*a")
		handle:close()
		local response_json = vim.json.decode(response)
		is_exist = response_json.id or nil
	else
		return false, "request failed"
	end

	if not is_exist then
		return false, "version " .. provider_version .. " does not exist"
	end

	return true, nil
end

function M.get_resource_list(provider_full_name, provider_version)
	local url = "https://registry.terraform.io/v1/providers/" .. provider_full_name .. "/" .. provider_version
	local resource_list = nil

	local handle = io.popen("curl -s " .. url)
	if handle ~= nil then
		local response = handle:read("*a")
		handle:close()
		local response_json = vim.json.decode(response)
		resource_list = response_json.docs or nil
	else
		return nil, "request failed"
	end

	if not resource_list then
		return nil, "failed to get resource list"
	end

	return resource_list, nil
end

function M.get_document(provider_full_name, provider_version, path)
	local url = "https://registry.terraform.io/v1/providers/"
		.. provider_full_name
		.. "/"
		.. provider_version
		.. "/docs?path="
		.. path

	local doc_md

	local handle = io.popen("curl -s " .. url)
	if handle ~= nil then
		local response = handle:read("*a")
		handle:close()
		doc_md = vim.json.decode(response).content or nil
	else
		return nil, "request failed"
	end

	if not doc_md then
		return nil, "failed to get markdown document"
	end

	local tempfile = vim.fn.tempname() .. ".md"
	local file = io.open(tempfile, "w")
	file:write(doc_md)
	file:close()

	return tempfile, nil
end

return M
