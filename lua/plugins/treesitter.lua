require("nvim-treesitter").setup({
  install_dir = vim.fn.stdpath('data') .. '/site',
  require'nvim-treesitter'.install(CFG.treesitter_types),
  textobjects = {
    enable = true
  },
  highlight = {
    additional_vim_regex_highlighting = false,
    enable = true,
    disable = { "tex", "latex" }
  },
  indent = {
    enable = false
  },
  autotag = {
    enable = false,
    filetypes = {
      "html",
      "javascript",
      "javascriptreact",
      "svelte",
      "typescript",
      "typescriptreact",
      "vue",
      "xml",
    }
  }
})
