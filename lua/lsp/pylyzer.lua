local lspconfig = require("lspconfig")
local util = require 'lspconfig.util'

print("load pylyzer")

lspconfig.pylyzer.setup({
  cmd = { Tweaks.lsp.server_bin['pylyzer'], '--server' },
  filetypes = { 'python' },
  root_dir = function(fname)
    local root_files = {
      'setup.py',
      'tox.ini',
      'requirements.txt',
      'Pipfile',
      'pyproject.toml',
    }
    return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
  end,
  settings = {
    python = {
      diagnostics = true,
      inlayHints = true,
      smartCompletion = true,
      checkOnType = false,
    },
  }
})

