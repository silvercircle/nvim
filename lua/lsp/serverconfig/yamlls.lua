local Util = require("lspconfig.util")
return {
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities,
  cmd = { Tweaks.lsp.server_bin["yamlls"], "--stdio" },
  filetypes = { "yaml", "yaml.docker-compose" },
  root_dir = Util.find_git_ancestor,
  single_file_support = true,
  settings = {
    -- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
    redhat = { telemetry = { enabled = false } },
  }
}
