local Util = require('lspconfig.util')
return {
  cmd = { 'neocmakelsp', '--stdio' },
  filetypes = { 'cmake' },
  root_dir = function(fname)
    return Util.root_pattern(unpack({ '.git', 'build', 'cmake' }))(fname)
  end,
  single_file_support = true,
  capabilities = CGLOBALS.lsp_capabilities
}

