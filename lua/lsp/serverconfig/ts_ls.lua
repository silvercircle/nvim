local Util = require('lspconfig.util')
return {
  init_options = { hostInfo = "neovim" },
  cmd = { Tweaks.lsp.server_bin["tsserver"], "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx"
  },
  root_dir = function(fname)
    return Util.root_pattern "tsconfig.json" (fname) or Util.root_pattern("package.json", "jsconfig.json", ".git")(fname)
  end,
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities
}
