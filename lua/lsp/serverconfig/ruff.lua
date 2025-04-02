local root_files = {
  'pyproject.toml',
  'setup.py',
  'setup.cfg',
  'requirements.txt',
  'Pipfile',
  'pyrightconfig.json',
  '.git',
}
return {
  cmd = { "ruff", "server" },
  root_markers = root_files,
  filetypes = { "python" },
  single_file_support = true,
  settings = {},
  attach_config = function(client, _)
    client.server_capabilities.hoverProvider = false
    client.server_capabilities.documentSymbolProvider = false
  end
}
