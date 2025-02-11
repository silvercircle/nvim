local lspconfig = require("lspconfig")
local util = require 'lspconfig.util'

lspconfig.csharp_ls.setup({
  on_attach = function(client, bufnr) On_attach(client, bufnr) end,
  capabilities = __Globals.get_lsp_capabilities(),
  handlers = {
    ["textDocument/definition"] = require('csharpls_extended').handler
  },
  cmd = { vim.g.lsp_server_bin['csharp_ls'] },
  root_dir = util.root_pattern('*.sln', '*.csproj', '*.fsproj', '.git'),
  filetypes = { 'cs' },
  init_options = {
    AutomaticWorkspaceInit = true,
  },
  flags = {
    debounce_text_changes = 1000
  }
})

