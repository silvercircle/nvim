return {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  root_markers = { ".git" },
  single_file_support = true,
  -- FIXME: as of 0.13, semantic tokens cause errors in Neovim.
  -- temporarily disabled.
  attach_config = function(client, _)
    client.server_capabilities.semanticTokensProvider = false
  end
}
