require("nvim-treesitter").setup({
  install_dir = vim.fn.stdpath('data') .. '/site',
  -- ensure_installed = CFG.treesitter_types,
  require'nvim-treesitter'.install(CFG.treesitter_types),
  textobjects = {
    enable = true
  },
  --incremental_selection = {
  --  enable = true,
  --  keymaps = {
  --    init_selection = '<Space>',
  --    scope_incremental = '<Space>',
  --    node_incremental = '<C-Space>',
  --    node_decremental = '<A-Space>',
  --  },
  --},
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
CGLOBALS.configure_treesitter()
