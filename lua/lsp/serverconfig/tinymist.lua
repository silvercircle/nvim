return {
  cmd = { "tinymist" },
  filetypes = { 'typst' },
  root_dir = function(fname)
    return vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
  end,
  single_file_support = true,
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities
}

