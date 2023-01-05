-- setup command center commands. Outsourced from setup_telescope.lua
Command_center = require("command_center")
local noremap = {noremap = true}
local silent_noremap = {noremap = true, silent = true}


-- bookmark plugin, set and navigate bookmarks
-- map('n', "<Leader>bt", '<Plug>BookmarkToggle', { silent = true, noremap = false })
-- map('n', "<Leader>by", '<Plug>BookmarkAnnotate', { silent = true, noremap = false })
-- map('n', "<Leader>ba", '<Plug>BookmarkShowAll', { silent = true, noremap = false })
-- map('n', "<Leader>bn", '<Plug>BookmarkNext', { silent = true, noremap = false })
-- map('n', "<Leader>bp", '<Plug>BookmarkPrev', { silent = true, noremap = false })
-- map('n', "<Leader>bd", '<Plug>BookmarkClear', { silent = true, noremap = false })
-- map('n', "<Leader>bx", '<Plug>BookmarkClearAll', { silent = true, noremap = false })
-- map('n', "<Leader>bu", '<Plug>BookmarkMoveUp', { silent = true, noremap = false })
-- map('n', "<Leader>bb", '<Plug>BookmarkMoveDown', { silent = true, noremap = false })
-- map('n', "<Leader>bm", '<Plug>BookmarkMoveToLine', { silent = true, noremap = false })
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

