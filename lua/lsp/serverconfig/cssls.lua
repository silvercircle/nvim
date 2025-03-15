local Util = require('lspconfig.util')
return {
  cmd = { Tweaks.lsp.server_bin['cssls'], '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_dir = Util.root_pattern('package.json', '.git'),
  single_file_support = true,
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities,
  settings = {
    css = { validate = true },
    scss = { validate = true },
    less = { validate = true },
  },
}

