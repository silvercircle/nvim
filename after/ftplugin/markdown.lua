local win = vim.api.nvim_get_current_win()
vim.wo[win].foldmethod = "expr"
vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo[win].foldlevel = 99
vim.wo[win].foldcolumn = "1"
