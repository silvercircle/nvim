local util = require "lspconfig.util"

return {
  capabilities = CGLOBALS.get_lsp_capabilities(),
  cmd = { Tweaks.lsp.server_bin["dartls"], "language-server", "--protocol=lsp" },
  filetypes = { "dart" },
  root_dir = util.root_pattern "pubspec.yaml",
  init_options = {
    onlyAnalyzeProjectsWithOpenFiles = true,
    suggestFromUnimportedLibraries = true,
    closingLabels = true,
    outline = true,
    flutterOutline = true,
  },
  settings = {
    dart = {
      completeFunctionCalls = true,
      showTodos = true,
    }
  }
}
