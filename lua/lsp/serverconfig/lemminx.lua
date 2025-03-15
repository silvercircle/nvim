local Util = require('lspconfig.util')
return {
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities,
  cmd = { Tweaks.lsp.server_bin['lemminx'] },
  filetypes = { 'xml', 'xsd', 'xsl', 'xslt', 'svg' },
  root_dir = Util.find_git_ancestor,
  single_file_support = true
}

