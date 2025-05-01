local function clangd_switch_source_header(bufnr)
  local method_name = 'textDocument/switchSourceHeader'
  local client = require("lsp.utils").get_active_client_by_name(bufnr, 'clangd')
  if not client then
    return vim.notify(('method %s is not supported by any servers active on the current buffer'):format(method_name))
  end
  local params = vim.lsp.util.make_text_document_params(bufnr)
  client.request(method_name, params, function(err, result)
    if err then
      error(tostring(err))
    end
    if not result then
      vim.notify('corresponding file cannot be determined')
      return
    end
    vim.cmd.edit(vim.uri_to_fname(result))
  end, bufnr)
end

local function clangd_symbol_info()
  local bufnr = vim.api.nvim_get_current_buf()
  local clangd_client = require("lsp.defaults").get_active_client_by_name(bufnr, 'clangd')
  if not clangd_client or not clangd_client.supports_method 'textDocument/symbolInfo' then
    return vim.notify('Clangd client not found', vim.log.levels.ERROR)
  end
  local win = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(win, clangd_client.offset_encoding)
  clangd_client.request('textDocument/symbolInfo', params, function(err, res)
    if err or #res == 0 then
      -- Clangd always returns an error, there is not reason to parse it
      return
    end
    local container = string.format('container: %s', res[1].containerName) ---@type string
    local name = string.format('name: %s', res[1].name) ---@type string
    vim.lsp.util.open_floating_preview({ name, container }, '', {
      height = 2,
      width = math.max(string.len(name), string.len(container)),
      focusable = false,
      focus = false,
      border = 'single',
      title = 'Symbol Info',
    })
  end, bufnr)
end

local clangd_root_files = {
  '.clangd',
  '.clang-tidy',
  '.clang-format',
  'compile_commands.json',
  'compile_flags.txt',
  'configure.ac', -- AutoTools
}

--local function rdir(dir)
--  vim.notify(dir)
--end

return {
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_markers = clangd_root_files,
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true
      },
    },
    -- offsetEncoding = { "utf-8", "utf-16" },
  },
  ---@param client vim.lsp.Client
  ---@param config vim.lsp.ClientConfig
  reuse_client = function(client, config)
    if client.name == "clangd" and (config.root_dir == "." or config.root_dir == client.root_dir) then
        return true
    else
      return false
    end
  end,
  root_dir = function(_, rdir)
    local dir = require("subspace.lib").getroot_current()
    rdir(dir)
  end,
  commands = {
    ClangdSwitchSourceHeader = {
      function()
        clangd_switch_source_header(0)
      end,
      description = "Switch between source/header",
    },
    ClangdShowSymbolInfo = {
      function()
        clangd_symbol_info()
      end,
      description = "Show symbol info",
    },
  }
}

