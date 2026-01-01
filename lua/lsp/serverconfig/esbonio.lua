 ---@type vim.lsp.Config
return {
  -- cmd = { 'python3', '-m', 'esbonio' },
  cmd = { 'python3', "-m", "esbonio" },
  filetypes = { 'rst' },
  root_markers = { '.git' },
  init_options = {
    server = {
      logLevel = "debug"
    }
  }
}
