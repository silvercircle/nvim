-- setup command center commands. Outsourced from setup_telescope.lua
Command_center = require("command_center")
local noremap = {noremap = true}
local silent_noremap = {noremap = true, silent = true}

Command_center.add({
  {
    desc = "Bookmark Toggle",
    cmd = "<Plug>BookmarkToggle",
    keys = { "n", "<leader>bt",  noremap },
    category = "Bookmarks"
  },
  {
    desc = "Bookmark Annotate",
    cmd = "<Plug>BookmarkAnnotate",
    keys = { "n", "<leader>by", noremap },
    category = "Bookmarks"
  },
  {
    desc = "Bookmarks show all",
    cmd = "<Plug>BookmarkShowAll",
    keys = { "n", "<leader>ba", noremap },
    category = "Bookmarks"
  },
  {
    desc = "Bookmark next",
    cmd = "<Plug>BookmarkNext",
    keys = { "n", "<leader>bn", noremap },
    category = "Bookmarks"
  },
  {
    desc = "Bookmark previous",
    cmd = "<Plug>BookmarkPrev",
    keys = { "n", "<leader>bp", noremap },
    category = "Bookmarks"
  },
  {
    desc = "Bookmark delete",
    cmd = "<Plug>BookmarkClear",
    keys = { "n", "<leader>bd", noremap },
    category = "Bookmarks"
  },
  {
    desc = "Bookmark delete All",
    cmd = "<Plug>BookmarkClearAll",
    keys = { "n", "<leader>bx", noremap },
    category = "Bookmarks"
  },
  {
    desc = "Bookmark move down",
    cmd = "<Plug>BookmarkMoveDown",
    keys = { "n", "<leader>bb",  noremap },
    category = "Bookmarks"
  },
  {
    desc = "Bookmark move up",
    cmd = "<Plug>BookmarkMoveUp",
    keys = { "n", "<leader>bu", noremap },
    category = "Bookmarks"
  },
  {
    desc = "Bookmark move to line",
    cmd = "<Plug>BookmarkMoveToLine",
    keys = { "n", "<leader>bm", noremap },
    category = "Bookmarks"
  },
  -- LSP
  {
    desc = "LSP Server Info",
    cmd = "<CMD>LspInfo<CR>",
    keys = { "n", "lsi", noremap },
    category = "LSP"
  },
  {
    desc = "Peek definitions (Glance Plugin)",
    cmd = "<CMD>Glance definitions<CR>",
    keys = { "n", "GD", noremap },
    category = "LSP"
  },
  {
    desc = "Peek references (Glance Plugin)",
    cmd = "<CMD>Glance references<CR>",
    keys = { "n", "GR", noremap },
    category = "LSP"
  },
  -- LSP Diagnostics
  {
    desc = "Show diagnostic popup",
    cmd = function() vim.diagnostic.open_float() end,
    keys = { "n", "DO",  noremap},
    category = "LSP Diagnostics"
  },
  {
    desc = "Go to next diagnostic",
    cmd = function() vim.diagnostic.goto_next() end,
    keys = { "n", "DN", noremap },
    category = "LSP Diagnostics"
  },
  {
    desc = "Go to previous diagnostic",
    cmd = function() vim.diagnostic.goto_prev() end,
    keys = { "n", "DP", noremap },
    category = "LSP Diagnostics"
  },
  {
    desc = "Show hover info for current symbol",
    cmd = function() vim.lsp.buf.hover() end,
    keys = { "n", "DD", noremap },
    category = "LSP Diagnostics"
  },
  {
    desc = "Code Action",
    cmd = function() vim.lsp.buf.code_action() end,
    keys = { "n", "DA",  },
    category = "LSP Diagnostics"
  },
  -- GIT
  {
    desc = "GIT status (Telescope)",
    cmd = function() require'telescope.builtin'.git_status({layout_config={height=0.8, width=0.8}}) end,
    keys = { "n", "tgs", noremap },
    category = "GIT"
  },
  {
    desc = "GIT commits (Telescope)",
    cmd = function() require'telescope.builtin'.git_commits({layout_config={height=0.8, width=0.8}}) end,
    keys = { "n", "tgc", noremap },
    category = "GIT"
  },
  -- text formatting
  {
    desc = "Format paragraph",
    cmd = "}kV{jgq",
    keys = { "n", "<A-C-w>", noremap },
    category = "Formatting"
  },
  {
    desc = "Select paragraph",
    cmd = "}kV{j",
    keys = { "n", "<leader>v", noremap },
    category = "Formatting"
  },
  {
    desc = "Search inside current buffer",
    cmd = "<CMD>Telescope current_buffer_fuzzy_find<CR>",
    keys = { "n", "<leader>fl", noremap },
  },
  {
    -- If no descirption is specified, cmd is used to replace descirption by default
    -- You can change this behavior in setup()
    cmd = "<CMD>Telescope find_files<CR>",
    keys = { "n", "<leader>ff", noremap },
  }, {
    -- If no keys are specified, no keymaps will be displayed nor set
    desc = "Find hidden files",
    cmd = "<CMD>Telescope find_files hidden=true<CR>",
  }, {
    -- You can specify multiple keys for the same cmd ...
    desc = "Show document symbols",
    cmd = "<CMD>Telescope lsp_document_symbols<CR>",
    keys = {
      {"n", "<leader>ss", noremap},
      {"n", "<leader>ssd", noremap},
    },
  }, {
    -- ... and for different modes
    desc = "Show function signaure (hover)",
    cmd = "<CMD>lua vim.lsp.buf.hover()<CR>",
    keys = {
      {"n", "K", silent_noremap },
      {"i", "<C-k>", silent_noremap },
    }
  }, {
    -- You can pass in a key sequences as if you would type them in nvim
    desc = "My favorite key sequence",
    cmd = "A  -- Add a comment at the end of a line",
    keys = {"n", "<leader>Ac", noremap}
  }, {
    -- You can also pass in a lua functions as cmd
    -- NOTE: binding lua funciton to a keymap requires nvim 0.7 and above
    desc = "Run lua function",
    cmd = function() print("ANONYMOUS LUA FUNCTION") end,
    keys = {"n", "<leader>alf", noremap},
  }
})

