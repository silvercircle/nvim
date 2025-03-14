local util = require('lspconfig.util')

local function clangd_switch_source_header(bufnr)
  local method_name = 'textDocument/switchSourceHeader'
  bufnr = util.validate_bufnr(bufnr)
  local client = util.get_active_client_by_name(bufnr, 'clangd')
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
  local clangd_client = util.get_active_client_by_name(bufnr, 'clangd')
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

return {
  cmd = { "clangd", "--background-index", "--malloc-trim",
    "--pch-storage=memory", "--log=error", "--header-insertion=never",
    "--completion-style=detailed", "--function-arg-placeholders=1", "--inlay-hints=true" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_dir = function(fname)
    return util.root_pattern(unpack(clangd_root_files))(fname) or util.find_git_ancestor(fname)
  end,
  single_file_support = true,
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities,
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

