-- local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
-- parser_config.objc = {
--   install_info = {
--     url = "https://github.com/merico-dev/tree-sitter-objc",
--     files = {"src/parser.c" },
--     -- optional entries:
--     branch = "master", -- default branch in case of git repo if different from master
--     generate_requires_npm = false, -- if stand-alone parser without npm dependencies
--     requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
--   },
-- }
vim.treesitter.language.register('objc', 'objcpp')
require("nvim-treesitter.configs").setup({
  auto_install = false,
  ensure_installed = { "c", "cpp", "lua", "vim", "python", "dart", "go", "c_sharp", "scala" },
  playground = {
    enable = vim.g.config.treesitter_playground,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = "o",
      toggle_hl_groups = "i",
      toggle_injected_languages = "t",
      toggle_anonymous_nodes = "a",
      toggle_language_display = "I",
      focus_language = "f",
      unfocus_language = "F",
      update = "R",
      goto_node = "<cr>",
      show_help = "?",
    },
  },
--  incremental_selection = {
--    enable = true,
--    keymaps = {
--      init_selection = '<Space>',
--      scope_incremental = '<Space>',
--      node_incremental = '<C-Space>',
--      node_decremental = '<A-Space>',
--    },
--  },
  highlight = {
    enable = true,
    disable = { "help", "markdown" },      -- FIXME: JavaScript parser is painfully slow. Help can be
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
