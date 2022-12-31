-- null-ls: Linting, diagnostics, formatting etc.
if vim.g.config_null_ls == true then
  local null_ls = require("null-ls")
  null_ls.setup({
   -- the external tools must be installed separately. see comments
    -- to verify they are working: checkhealth null-ls
    sources = {
      -- lua
      null_ls.builtins.formatting.stylua, -- cargo install stylua (rust dev environment needed)
      -- but binaries available
      -- python
      null_ls.builtins.formatting.autopep8, -- autopep8 via pip
      null_ls.builtins.diagnostics.flake8, -- flake8 via pip
      -- null_ls.builtins.diagnostics.pylint, -- pylint via pip, disabled
      -- because sometimes annoyingly slow
      -- js, css, HTML, json etc.
      null_ls.builtins.formatting.prettier.with({ disabled_filetypes = { 'markdown', 'markdown.mdx' }}), -- npm install -g prettier
      -- astyle (artistic style): C/CPP, ObjC, Java, C#
      -- null_ls.builtins.formatting.astyle, -- astyle package (fedora, Ubuntu etc)
      -- clang_format
      -- null_ls.builtins.formatting.clang_format.with({ extra_args={"--style", "file" } })
    },
  })
  -- set up some custom commands (formatting, diagnostics)
  -- needs null-ls
  do
    vim.cmd([[
     command! LspFormatDoc :lua vim.lsp.buf.format()
     command! -range LspFormatRange :lua vim.lsp.buf.format( {range={}} )
    ]])
  end
end