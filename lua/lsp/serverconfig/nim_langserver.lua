local Util = require('lspconfig.util')

return {
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities,
  cmd = { Tweaks.lsp.server_bin['nimls'] },
  filetypes = { 'nim' },
  root_dir = function(fname)
    return Util.root_pattern '*.nimble' (fname) or Util.find_git_ancestor(fname)
  end,
  single_file_support = true
}

