local Util = require("lspconfig.util")
return {
  on_attach = On_attach,
  cmd = { Tweaks.lsp.server_bin["marksman"] },
  filetypes = { "markdown", "telekasten", "liquid" },
  root_dir = function(fname)
    local root_files = { ".marksman.toml" }
    return Util.root_pattern(unpack(root_files))(fname) or Util.find_git_ancestor(fname)
  end,
  single_file_support = true,
  capabilities = CGLOBALS.lsp_capabilities
}
