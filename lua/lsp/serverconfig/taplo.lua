local Util = require('lspconfig.util')
return {
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities,
  cmd = { Tweaks.lsp.server_bin['taplo'], 'lsp', 'stdio' },
  filetypes = { 'toml' },
  root_dir = function(fname)
    return Util.root_pattern '*.toml' (fname) or Util.find_git_ancestor(fname)
  end,
  single_file_support = true
}

