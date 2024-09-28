local lspconfig = require("lspconfig")
local util = require 'lspconfig.util'

lspconfig.roslyn.setup({
  filetypes = { 'cs', 'vb' },
  root_dir = function(fname)
    return util.root_pattern '*.sln'(fname)
  end,
  cmd = {
    "/opt/dotnet/dotnet",
    vim.g.lsp_server_bin['roslyn'], "--logLevel=Information", "--extensionLogDirectory=" .. vim.fn.stdpath("data")
  },
  --handlers = {
    --["textDocument/definition"] = require('omnisharp_extended').handler
  --},
  capabilities = __Globals.get_lsp_capabilities(),
--  on_new_config = function(new_config, new_root_dir)
--    new_config.cmd = { "/opt/dotnet/dotnet", vim.g.lsp_server_bin['roslyn'], "--logLevel=Information", "--extensionLogDirectory=" .. vim.fn.stdpath("data") }
--    new_config.handlers = {
--      ["textDocument/definition"] = require('omnisharp_extended').handler,
--    }
--    new_config.capabilities = __Globals.get_lsp_capabilities()
--  end,
  init_options = {}
})

