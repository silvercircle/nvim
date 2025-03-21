return {
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
  root_markers = { "go.work", "go.mod "}
}

