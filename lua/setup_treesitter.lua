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
 
--parser_config.scala = {
--  install_info = {
--  -- url can be Git repo or a local directory:
--    url = "https://github.com/eed3si9n/tree-sitter-scala",
--    branch = "fork-integration",
--    -- url = "/mnt/shared/data/code/treesitter-parsers/tree-sitter-scala", -- local path or git repo
--    files = {"src/parser.c", "src/scanner.c"},
--    requires_generate_from_grammar = false,
--  },
-- }

local ft_to_parser = require"nvim-treesitter.parsers".filetype_to_parsername
ft_to_parser.objcpp = 'objc'

require("nvim-treesitter.configs").setup({
  auto_install = false,
  -- NOTE: Problem parsers: JavaScript is slow, scala lacks Scala3 syntax.
  ensure_installed = { "c", "cpp", "lua", "vim", "python", "rust", "dart", "go", "c_sharp" },
  playground = {
    enable = vim.g.features['treesitter_playground']['enable'],
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
  highlight = {
    enable = true,
    disable = { "javascript" },     -- FIXME: JavaScript parser is painfully slow.
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true },
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