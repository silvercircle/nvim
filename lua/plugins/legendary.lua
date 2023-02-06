local lutils = require("local_utils")
local _t = require("telescope")
local _tb = require("telescope.builtin")
local lsputil = require('lspconfig.util')

require('legendary').setup({
  include_builtin = true,
  select_prompt = ' legendary ',
  item_type_bias = 'group',
  keymaps = {
    {
      -- groups with same itemgroup will be merged
      itemgroup = 'GIT',
      description = 'Git commands',
      icon = '',
      keymaps = {
        {
          'tgs',
          function() _tb.git_status({cwd = lsputil.root_pattern(".git")(vim.fn.expand("%:p")), layout_config={height=0.8, width=0.8}}) end,
          description = "GIT status (Telescope)",
        },
        {
          'tgc',
          function() _tb.git_commits({cwd = lsputil.root_pattern(".git")(vim.fn.expand("%:p")), layout_config={height=0.8, width=0.8}}) end,
          description = "GIT commits (Telescope)",
        },
        {
          '<f6>',
          -- open a float term with lazygit.
          -- use the path of the current buffer to find the .git root. The LSP utils are useful here
          function() local path = lsputil.root_pattern(".git")(vim.fn.expand("%:p"))
            path = path or "."
            local cmd = "FloatermNew --name=GIT --width=0.9 --height=0.9 lazygit --path=" .. path
            vim.cmd(cmd)
          end,
          description = "FloatTerm lazygit",
        },
        {
          '<leader>h',
          function()
            print('hello world in submenu!')
          end,
          description = 'Say hello in submenu',
        }
      },
    },
    {
      itemgroup = 'Bookmarks',
      description = 'Bookmark plugin commands',
      icon = '',
      keymaps = {
        {
          '<leader>bt',
          "<Plug>BookmarkToggle",
          description = "Bookmark Toggle",
        },
        {
          '<leader>by',
          "<Plug>BookmarkAnnotate",
          description = "Bookmark Annotate",
        },
        {
          '<leader>ba',
          "<Plug>BookmarkShowAll",
          description = "Bookmarks show all",
        },
        {
          '<leader>bn',
          "<Plug>BookmarkNext",
          description = "Bookmark next",
        },
        {
          '<leader>bp',
          "<Plug>BookmarkPrev",
          description = "Bookmark previous",
        },
        {
          '<leader>bd',
          "<Plug>BookmarkClear",
          description = "Bookmark delete",
        },
        {
          '<leader>bx',
          "<Plug>BookmarkClearAll",
          description = "Bookmark delete All",
        },
        {
          '<leader>bb',
          "<Plug>BookmarkMoveDown",
          description = "Bookmark move down",
        },
        {
          '<leader>bu',
          "<Plug>BookmarkMoveUp",
          description = "Bookmark move up",
        },
        {
          '<leader>bm',
          "<Plug>BookmarkMoveToLine",
          description = "Bookmark move to line",
        },
        {
          '<A-b>',
          function() _t.extensions.vim_bookmarks.all(Telescope_vertical_dropdown_theme({prompt_title="All Bookmarks", hide_filename=false, width_text=120})) end,
          description = "Show all bookmarks (Telescope)",
        },
        {
          '<A-B',
          function() _t.extensions.vim_bookmarks.current_file(Telescope_vertical_dropdown_theme({prompt_title="File Bookmarks"})) end,
          description = "Show bookmarks in current file (Telescope)",
        },
        {
          '<f12>',
          function() require "quickfavs".Quickfavs(false) end,
          description = "Show favorite folders",
        },
        {
          '<f24>',
          function() require "quickfavs".Quickfavs(true) end,
          description = "Show favorite folders (rescan fav file)",
        },
      }
    }
  },
  commands = {
    -- easily create user commands
    {
      ':SayHello',
      function()
        print('hello world!')
      end,
      description = 'Say hello as a command',
    }
  },
  funcs = {
    -- Make arbitrary Lua functions that can be executed via the item finder
    {
      function()
        doSomeStuff()
      end,
      description = 'Do some stuff with a Lua function!',
    },
    {
      -- groups with same itemgroup will be merged
      itemgroup = 'short ID',
      -- don't need to copy the other group data because
      -- it will be merged with the one from the keymaps table
      funcs = {
        -- more funcs here
      },
    },
  }
})
