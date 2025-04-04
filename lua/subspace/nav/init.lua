local lib = require("subspace.nav.lib")

---@class LspOptions
---@field auto_attach boolean
---@field preference table | nil

---@class Options
---@field icons table | nil
---@field highlight boolean | nil
---@field format_text function | nil
---@field depth_limit number | nil
---@field depth_limit_indicator string | nil
---@field lazy_update_context boolean | nil
---@field safe_output boolean | nil
---@field click boolean | nil
---@field lsp LspOptions | nil

-- @Public Methods

local M = {}

---@type Options
local config = {
  icons = CFG.lspkind_symbols,
	highlight = true,
	separator = " > ",
	depth_limit = 0,
	depth_limit_indicator = "..",
	safe_output = true,
	click = false,
	lsp = {
		auto_attach = false,
		preference = nil
	},
	format_text = function(a) return a end,
}

setmetatable(config.icons, {
	__index = function()
		return "? "
	end,
})

-- returns table of context or nil
function M.get_data(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local context_data = lib.get_context_data(bufnr)

	if context_data == nil then
		return nil
	end

	local ret = {}

	for i, v in ipairs(context_data) do
		if i ~= 1 then
		  local t = lib.adapt_lsp_num_to_str(v.kind)
			table.insert(ret, {
				kind = v.kind,
				type = t,
				name = v.name,
				icon = config.icons[t],
				scope = v.scope,
			})
		end
	end
	return ret
end

function M.is_available(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	return vim.b[bufnr].navic_client_id ~= nil
end

function M.format_data(data, opts)
	if data == nil then
		return ""
	end

	local local_config = {}

	if opts ~= nil then
		local_config = vim.deepcopy(config)

		if opts.icons ~= nil then
			for k, v in pairs(opts.icons) do
				if lib.adapt_lsp_str_to_num(k) then
					local_config.icons[lib.adapt_lsp_str_to_num(k)] = v
				end
			end
		end

		if opts.separator ~= nil then
			local_config.separator = opts.separator
		end
		if opts.depth_limit ~= nil then
			local_config.depth_limit = opts.depth_limit
		end
		if opts.depth_limit_indicator ~= nil then
			local_config.depth_limit_indicator = opts.depth_limit_indicator
		end
		if opts.highlight ~= nil then
			local_config.highlight = opts.highlight
		end
		if opts.safe_output ~= nil then
			local_config.safe_output = opts.safe_output
		end
		if opts.click ~= nil then
			local_config.click = opts.click
		end
	else
		local_config = config
	end


	local location = {}

	local function add_hl(kind, type, name)
		return "%#NavicIcons"
			.. lib.adapt_lsp_num_to_str(kind)
			.. "#"
			.. local_config.icons[type]
			.. "%*%#NavicText#"
			.. config.format_text(name)
			.. "%*"
	end


	for _, v in ipairs(data) do
		local name = ""

		if local_config.safe_output then
			name = string.gsub(v.name, "%%", "%%%%")
			name = string.gsub(name, "\n", " ")
		else
			name = v.name
		end
		table.insert(location, add_hl(v.kind, v.type, name))
	end

	if local_config.depth_limit ~= 0 and #location > local_config.depth_limit then
		location = vim.list_slice(location, #location - local_config.depth_limit + 1, #location)
		if local_config.highlight then
			table.insert(location, 1, "%#NavicSeparator#" .. local_config.depth_limit_indicator .. "%*")
		else
			table.insert(location, 1, local_config.depth_limit_indicator)
		end
	end

	return table.concat(location, "%#NavicSeparator#" .. local_config.separator .. "%*")
end

function M.get_location(opts, bufnr)
	local data = M.get_data(bufnr)
	return M.format_data(data, opts)
end

local awaiting_lsp_response = {}
local function lsp_callback(for_buf, symbols)
	awaiting_lsp_response[for_buf] = false
	lib.update_data(for_buf, symbols)
end

local autocmds_done = false
local navic_augroup_buf = nil
local buf_autocmd = {}

-- auto commands
-- CursorHold[I]: update the context
-- BufDelete: clear the buffer data
-- these do not need buf-local data, so they can be global
local function create_autocmds()
  if autocmds_done == true then return end
  autocmds_done = true
	local navic_augroup_global = vim.api.nvim_create_augroup("navic_global", { clear = false })
	navic_augroup_buf = vim.api.nvim_create_augroup("navic", { clear = false })

	vim.api.nvim_create_autocmd( { "CursorHold", "CursorHoldI" }, {
		callback = function(args)
			lib.update_context(args.buf)
		end,
		group = navic_augroup_global,
	})
	vim.api.nvim_create_autocmd("BufDelete", {
		callback = function(args)
			lib.clear_buffer_data(args.buf)
			if buf_autocmd[args.buf] then
  			for _,v in ipairs(buf_autocmd[args.buf]) do
	  		  vim.api.nvim_del_autocmd(v)
        end
        buf_autocmd[args.buf] = nil
      end
		end,
		group = navic_augroup_global,
	})

	--vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter" }, {
	--	callback = function(args)
	--	  local bufnr = args.buf
	--	  local s, id = pcall(vim.api.nvim_buf_get_var, bufnr, "client_for_navic")
	--	  if s == false then return end
	--	  local client = vim.lsp.get_client_by_id(id)
	--		if not awaiting_lsp_response[bufnr] and changedtick[bufnr] < vim.b[bufnr].changedtick then
	--			awaiting_lsp_response[bufnr] = true
	--			changedtick[bufnr] = vim.b[bufnr].changedtick
	--			lib.request_symbol(bufnr, lsp_callback, client)
	--		end
	--	end,
	--	group = navic_augroup_buf,
	--	buffer = bufnr
	--})

end

function M.attach(client, bufnr)
  local changedtick = 0
  if vim.tbl_contains(LSPDEF.exclude_navic, client.name) then return end

	if not client.server_capabilities.documentSymbolProvider then
		if LSPDEF.verbose then
			vim.notify(string.format('Navic: LSP server %s does not support **documentSymbols**. Not attaching to buffer %d',
			  client.name, bufnr), vim.log.levels.INFO)
		end
		return
	end

  if LSPDEF.debug then
    vim.notify(string.format("Navic: Attaching client %s to buffer %d (%s)", client.name,
      bufnr, vim.api.nvim_buf_get_name(bufnr)), vim.log.levels.DEBUG)
  end

  -- vim.api.nvim_buf_set_var(bufnr, "client_for_navic", client.id)
  create_autocmds()

  buf_autocmd[bufnr] = buf_autocmd[bufnr] or {}
	table.insert(buf_autocmd[bufnr], vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter" }, {
		callback = function()
			if not awaiting_lsp_response[bufnr] and changedtick < vim.b[bufnr].changedtick then
				awaiting_lsp_response[bufnr] = true
				changedtick = vim.b[bufnr].changedtick
				lib.request_symbol(bufnr, lsp_callback, client)
			end
		end,
		group = navic_augroup_buf,
		buffer = bufnr
	}))

	vim.b[bufnr].navic_client_id = client.id
	vim.b[bufnr].navic_client_name = client.name

	-- First call
	vim.b[bufnr].navic_awaiting_lsp_response = true
	lib.request_symbol(bufnr, lsp_callback, client)
end

return M
