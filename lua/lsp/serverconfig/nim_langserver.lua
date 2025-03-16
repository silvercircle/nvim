local Util = require('lspconfig.util')

return {
  cmd = { LSPDEF.server_bin['nimls'] },
  filetypes = { 'nim' },
  root_dir = function(fname)
    return Util.root_pattern '*.nimble' (fname) or Util.find_git_ancestor(fname)
  end,
  single_file_support = true
}

