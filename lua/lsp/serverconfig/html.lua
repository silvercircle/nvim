local Util = require('lspconfig.util')
return {
  cmd = { Tweaks.lsp.server_bin["html"], "--stdio" },
  filetypes = { "html", "xhtml", "jsp", "razor" },
  root_dir = Util.root_pattern("package.json", ".git"),
  single_file_support = true,
  settings = {},
  init_options = {
    provideFormatter = false,
    embeddedLanguages = { css = true, javascript = true },
    configurationSection = { "html", "css", "javascript" },
  },
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities
}
