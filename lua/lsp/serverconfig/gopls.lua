local Util = require('lspconfig.util')
return {
  on_attach = On_attach,
  cmd = { Tweaks.lsp.server_bin["gopls"] },
  capabilities = CGLOBALS.lsp_capabilities,
  single_file_support = true,
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  settings = {
    gopls = {
      semanticTokens = false,
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    }
  },
  root_dir = function(fname)
    return Util.root_pattern "go.work" (fname) or Util.root_pattern("go.mod", ".git")(fname)
  end
}

