local Util = require('lspconfig.util')
return {
  capabilities = CGLOBALS.lsp_capabilities,
  on_attach = On_attach,
  cmd = { Tweaks.lsp.server_bin['groovy'] },
  filetypes = { 'groovy' },
  root_dir = function(fname)
    return Util.root_pattern 'settings.gradle'(fname) or Util.find_git_ancestor(fname)
  end
}

