local lazy = require("lazy")
lazy.setup({
  {
    'nvim-tree/nvim-web-devicons',
    config = function()
      require("nvim-web-devicons").setup({
      override = {
        zsh = {
          icon = " ",
          color = "#428850",
          cterm_color = "65",
          name = "Zsh",
        },
        cs = {
          color = "#59a006",
          icon = "󰌛",
          name = "CSharp"
        }
      },
      color_icons = true,
      default = true
      })
    end
  },
  {
    'neovim/nvim-lspconfig',
    lazy = true,
  },
  {
    "brenton-leighton/multiple-cursors.nvim",
    cond = Tweaks.multicursor == "brenton-leighton",
    version = "*", -- Use the latest tagged version
    keys = {
      { "<C-Down>",      "<Cmd>MultipleCursorsAddDown<CR>",          mode = { "n", "i" } },
      { "<C-Up>",        "<Cmd>MultipleCursorsAddUp<CR>",            mode = { "n", "i" } },
      { "<C-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>",   mode = { "n", "i" } },
      { "<C-n>",         "<Cmd>MultipleCursorsAddMatches<CR>",       mode = { "n", "x" } },
      { "<C-n><C-n>",    "<Cmd>MultipleCursorsAddJumpNextMatch<CR>", mode = { "n", "x" } },
      { "<C-n><C-l>",    "<Cmd>MultipleCursorsLock<CR>",             mode = { "n", "x" } },
      { "<leader>n",     "<Cmd>MultipleCursorsJumpNextMatch<CR>",    mode = { "n", "x" } }
    },
    config = function()
      require("plugins.others").setup.multicursor_brenton()
    end
  },
  {
    "jake-stewart/multicursor.nvim",
    cond = Tweaks.multicursor == "jake-stewart",
    branch = "1.0",
    config = function()
      require("plugins.others").setup.multicursor_stewart()
    end
  },
  'nvim-lua/plenary.nvim',
  {
    'nvim-lualine/lualine.nvim',
    event = "UIEnter",
    config = function()
      require("plugins.lualine_lite_setup")
    end
  },
  {
    "ibhagwan/fzf-lua",
    lazy = true,
    config = function()
      require("plugins.fzf-lua_setup")
    end
  },
  {
    dir = "/mnt/shared/data/code/neovim_plugins/commandpicker.nvim/",
    branch = "v1",
    lazy = true,
    event = "BufReadPost",
    config = function()
      require("commandpicker").setup({
        order = { 'desc', 'cmd', 'mappings', 'category' },
        custom_layout = SPL( { width=120, height=20, row=5, input="bottom", preview = false } ),
        width = 120,
        height = 20
      })
    end
  },
  {
    dir = "/mnt/shared/data/code/neovim_plugins/quickfavs.nvim/",
    -- 'https://gitlab.com/silvercircle74/quickfavs.nvim',
    lazy = true,
    config = function()
      require("quickfavs").setup({
        telescope_theme = require("subspace.lib").Telescope_dropdown_theme,
        picker = "snacks",
        snacks_layout = SPL( { width = 120, height = 20, row = 5, input = "top" }),
        fzf_winopts = Tweaks.fzf.winopts.narrow_small_preview,
        explorer_layout = SPL( { width = 70 })
      })
    end
  },
  -- treesitter + friends
  {
    'nvim-treesitter/nvim-treesitter',
    branch = "master",
    -- lazy = true,
    -- event = { "UIEnter" },
    config = function()
      require("plugins.treesitter")
    end,
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-context',
        lazy = true,
        config = function()
          require("plugins.others").setup.treesitter_context()
        end
      }
    }
  },
  -- cmp and all its helpers
  -- using the magazine nvim-cmp fork.
  -- blink.cmp (alternative to nvim-cmp)
  {
    'Saghen/blink.cmp',
    branch = "main",
    build = "cargo build --release",
    lazy = true,
    event = "ModeChanged",
    cond = Tweaks.completion.version == "blink",
    config = function()
      require("plugins.blink")
    end,
    dependencies = {
      { "rafamadriz/friendly-snippets" },
      {
        'Kaiser-Yang/blink-cmp-dictionary',
      },
      { "moyiz/blink-emoji.nvim" },
      { 'windwp/nvim-autopairs',
        config = function()
          require("nvim-autopairs").setup({})
          if CGLOBALS.perm_config.autopair then
            require("nvim-autopairs").enable()
          else
            require("nvim-autopairs").disable()
          end
        end
      },
      {
        'https://gitlab.com/silvercircle74/blink-cmp-wordlist'
      },
      {
        'https://gitlab.com/silvercircle74/blink-cmp-lua'
      }
    }
  },
  {
    'tomasky/bookmarks.nvim',
    event = "UIEnter",
    config = function()
      local bm = require "bookmarks"
      require("bookmarks").setup({
        -- sign_priority = 8,  --set bookmark sign priority to cover other sign
        save_file = vim.fn.stdpath("state") .. "/.bookmarks", -- bookmarks save file path
        keywords = {
          ["@t"] = " ", -- mark annotation startswith @t ,signs this icon as `Todo`
          ["@w"] = " ", -- mark annotation startswith @w ,signs this icon as `Warn`
          ["@f"] = " ", -- mark annotation startswith @f ,signs this icon as `Fix`
          ["@n"] = "󰈔 ", -- mark annotation startswith @n ,signs this icon as `Note`
        }
      })
      local map = vim.keymap.set
      map("n", "<leader>bm", bm.bookmark_toggle) -- add or remove bookmark at current line
      map("n", "<leader>bi", bm.bookmark_ann) -- add or edit mark annotation at current line
      map("n", "<leader>bc", bm.bookmark_clean) -- clean all marks in local buffer
      map("n", "<leader>bn", bm.bookmark_next) -- jump to next mark in local buffer
      map("n", "<leader>bp", bm.bookmark_prev) -- jump to previous mark in local buffer
      map("n", "<leader>bl", bm.bookmark_list) -- show marked file list in quickfix window
      map("n", "<leader>bx", bm.bookmark_clear_all) -- removes all bookmarks
    end
  },
  {
    'lewis6991/gitsigns.nvim',
    lazy = true,
    event = "BufReadPre",
    config = function()
      require("plugins.others").setup.gitsigns()
    end
  },
  {
    "folke/snacks.nvim",
    lazy = false,
    config = function()
      require("plugins.snacks_setup")
    end
  },
  --{
  --  'lukas-reineke/indent-blankline.nvim',
  --  event = "BufReadPost",
  --  config = function()
  --    require("plugins.iblsetup")
  --  end
  --},
  {
    'petertriho/nvim-scrollbar',
    event = "BufReadPre",
    config = function()
      require("plugins.nvim-scrollbar")
      CGLOBALS.set_scrollbar()
    end,
    dependencies = {
      {
        'kevinhwang91/nvim-hlslens', event = "BufReadPre",
        config = function()
          require("hlslens").setup({
            build_position_cb = function(plist, _, _, _)
              require("scrollbar.handlers.search").handler.show(plist.start_pos)
            end,
            calm_down = true,    -- set to true to clear all lenses when cursor moves
            nearest_float_when = "never",
            nearest_only = true
          })
        end
      }
    }
  },
  --{
  --  'stevearc/dressing.nvim',
  --  event = { "UIEnter" },
  --  config = function()
  --    require("plugins.dressing")
  --  end
  --},
  {
    'akinsho/toggleterm.nvim',
    lazy = true,
    config = function()
      require("plugins.others").setup.toggleterm()
    end
  },
  {
    "norcalli/nvim-colorizer.lua",
    lazy = true,
    event = { 'BufReadPre'},
    config = function()
      require "colorizer".setup {
        "css",
        "scss",
        html = {
          mode = "foreground",
        }
      }
    end
  },
  {
    'echasnovski/mini.move',
    lazy = true,
    event = { 'BufReadPre'},
    config = function()
      require("mini.move").setup()
    end
  },
  {
    'nvim-tree/nvim-tree.lua',
    cond = Tweaks.tree.version == "Nvim",
    lazy = true,
    config = function()
      require("plugins.nvim-tree")
    end
  },
  {
    "zk-org/zk-nvim",
    lazy = true,
    ft = { "markdown" },
    config = function()
      require("plugins.others").setup.zk()
    end
  },
  {
    'folke/todo-comments.nvim',
    event = "BufReadPre",
    config = function()
      require("plugins.todo")
    end
  },
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = function()
      require("inc_rename").setup()
    end
  },
  {
    'silvercircle/outline.nvim',
    branch = 'mine',
    cmd = { "Outline", "OutlineOpen", "OutlineClose" },
    lazy = true,
    dependencies = {
      {
        'epheien/outline-treesitter-provider.nvim'
      }
    },
    config = function()
      require("plugins.outline_setup")
    end
  },
  {
    'kevinhwang91/nvim-ufo',
    cond = false,
    config = function()
      require("plugins.others").setup.ufo()
    end,
    dependencies = {
      'kevinhwang91/promise-async'
    }
  },
  {
    'mfussenegger/nvim-jdtls',
    lazy = true
  },
  {
    "scalameta/nvim-metals",
    ft = { "scala", "sbt" },
  },
  {
    "folke/trouble.nvim",
    event = "LspAttach",
    config = function()
      require("plugins.others").setup.trouble()
    end
  },
  --{
  --  "MaximilianLloyd/ascii.nvim",
  --  dependencies = {
  --    "MunifTanjim/nui.nvim"
  --  }
  --},
  {
    'seblyng/roslyn.nvim',
    cond = (Tweaks.lsp.csharp == "roslyn"),
    ft = { "cs", "razor" },
    config = function()
      require("plugins.roslyn")
    end,
    dependencies = {
      {
        'tris203/rzls.nvim',
        config = function()
          require('rzls').setup {}
          -- revert some wrong highlight redefinitions
        end,
        init = function()
      -- we add the razor filetypes before the plugin loads
          vim.filetype.add({
            extension = {
              razor = 'razor',
              cshtml = 'razor',
            }})
        end
      }
    }
  },
  {
    "carbon-steel/detour.nvim",
    lazy = true,
    cmd = { "Detour", "DetourCurrentWindow" },
    config = function()
      vim.keymap.set("n", "<c-w><enter>", ":DetourCurrentWindow<cr>")
    end
  },
  {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    config = function()
      require("quicker").setup({
        use_default_opts = true
      })
    end
  },
  {
    'sindrets/diffview.nvim',
    lazy = true,
  }
},
{
  ui = {
    border = Borderfactory("thicc")
  }
})
