local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.objc = {
  install_info = {
    --url = "/mnt/shared/data/code/treesitter-parsers/tree-sitter-objc", -- local path or git repo
    url = "https://github.com/merico-dev/tree-sitter-objc",
    files = {"src/parser.c" },
    -- optional entries:
    branch = "master", -- default branch in case of git repo if different from master
    generate_requires_npm = false, -- if stand-alone parser without npm dependencies
    requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
  },
}
local ft_to_parser = require"nvim-treesitter.parsers".filetype_to_parsername
ft_to_parser.objcpp = 'objc'

require("nvim-treesitter.configs").setup({
  auto_install = false,
  -- NOTE: Problem parsers: JavaScript is slow, scala lacks Scala3 syntax.
  ensure_installed = { "c", "cpp", "lua", "vim", "python", "rust", "dart", "go", "c_sharp" },
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
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<CR>',
      scope_incremental = '<CR>',
      node_incremental = '<TAB>',
      node_decremental = '<S-TAB>',
    },
  },
  highlight = {
    enable = true,
    disable = { "javascript", "help" },     -- FIXME: JavaScript parser is painfully slow. Help can be
                                            -- slow with large pages, and scala is a pain, because the parser is
                                            -- so complex because it has to support 2 very different syntaxes (scala3
                                            -- and older)..
    additional_vim_regex_highlighting = { 'org' },
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
    },
  },
})
