return {
  cmd = { "ctags-lsp" },
  filetypes = { "*" },
  root_dir = function()
    return vim.fn.getcwd()
  end
}
