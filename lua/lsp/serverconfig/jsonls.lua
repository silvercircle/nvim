local Util = require('lspconfig.util')
return {
  cmd = { Tweaks.lsp.server_bin[ "jsonls" ], "--stdio" },
  filetypes = { "json", "jsonc" },
  init_options = {
    provideFormatter = true,
  },
  root_dir = Util.find_git_ancestor,
  single_file_support = true,
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities
}

