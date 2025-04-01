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
    PCFG.is_dev and "silvercircle/nvim-navic" or "SmiteshP/nvim-navic",
    branch = PCFG.is_dev and "mine" or "master",
    lazy = true,
    config = function()
      require("plugins.others").setup.navic()
    end
  },
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
      require("plugins.others").setup.multicursor_stewart()
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    event = "UIEnter",
    config = function()
      require("plugins.lualine_setup")
      require("plugins.lualine_setup").fixhl()
    end
  },
  {
    "silvercircle/nvim-cokeline",
    lazy = true,
    event = "UIEnter",
    branch = "mine",
    config = function()
      require("plugins.cokeline")
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
    "stevearc/quicker.nvim",
    event = "FileType qf",
    config = function()
      require("quicker").setup({
        use_default_opts = true
      })
    end
  },
  {
    "kdheepak/tabline.nvim"
  },
  {
    "oskarrrrrrr/symbols.nvim",
    branch = "main",
    cmd = { "Symbols", "SymbolsOpen" },
    lazy = true,
    cond = Tweaks.outline_plugin == "symbols",
    config = function()
      require("plugins.others").setup.symbols()
    end
  },
  {
    "Isrothy/neominimap.nvim",
    version = "v3.*.*",
    event = "BufReadPost",
    cond = true,
    init = function()
      require("plugins.others").setup.neominimap()
    end
  }
},
{
  ui = {
    border = Borderfactory("thicc")
  }
})
