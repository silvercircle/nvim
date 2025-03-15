local util = require 'lspconfig.util'

return {
  cmd = { Tweaks.lsp.server_bin['phpactor'], 'language-server' },
  on_attach = On_attach,
  filetypes = { 'php' },
  root_dir = function(pattern)
    local cwd = vim.loop.cwd()
    local root = util.root_pattern('composer.json', '.git')(pattern)

    -- prefer cwd if root is a descendant
    return util.path.is_descendant(cwd, root) and cwd or root
  end,
  capabilities = CGLOBALS.get_lsp_capabilities()
}

