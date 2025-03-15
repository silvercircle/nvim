local Util = require('lspconfig.util')
return {
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities,
  cmd = { Tweaks.lsp.server_bin['bashls'], 'start' },
  filetypes = { 'sh' },
  root_dir = Util.find_git_ancestor,
  single_file_support = true,
  settings = {
    bashIde = {
      -- Glob pattern for finding and parsing shell script files in the workspace.
      -- Used by the background analysis features across files.

      -- Prevent recursive scanning which will cause issues when opening a file
      -- directly in the home directory (e.g. ~/foo.sh).
      --
      -- Default upstream pattern is "**/*@(.sh|.inc|.bash|.command)".
      globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)',
    }
  }
}

