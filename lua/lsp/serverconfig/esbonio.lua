 ---@type vim.lsp.Config
return {
  -- cmd = { 'python3', '-m', 'esbonio' },
  cmd = { 'python3', "-m", "esbonio" },
  filetypes = { 'rst', 'markdown' },
  root_markers = { '.git', 'conf.py' },
  init_options = {
    server = {
      logLevel = "error"
    }
  }
}
