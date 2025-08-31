return {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  root_markers = { ".git" },
  single_file_support = true,
  attach_config = function(client, _)
    client.server_capabilities.semanticTokensProvider = false
  end
}
