vim.treesitter.language.register('objc', 'objcpp')
vim.treesitter.language.register('markdown', 'telekasten')

require("nvim-treesitter.configs").setup({
  auto_install = false,
  ensure_installed = { "c", "cpp", "lua", "vim", "python", "dart", "go", "c_sharp",
                       "scala", "markdown", "java", "kdl", "ada", "json", "nim", "d",
                       "yaml", "rust" },
  textobjects = {
    enable = false
  },
  incremental_selection = {
    enable = false,
    keymaps = {
      init_selection = '<Space>',
      scope_incremental = '<Space>',
      node_incremental = '<C-Space>',
      node_decremental = '<A-Space>',
    },
  },
  highlight = {
    enable = true,
    disable = { "help", "markdown", "vimdoc" },      -- FIXME: JavaScript parser is painfully slow. Help can be
                              -- slow with large pages. This is caused by injections, so disabling them
                              -- does help.
    additional_vim_regex_highlighting = false
  },
  indent = {
    -- FIXME: Setting this to true will cause a huge memory leak when inserting lines
    -- probably related to: https://github.com/nvim-treesitter/nvim-treesitter/issues/2918
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
