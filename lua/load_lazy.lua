local lazy = require("lazy")
lazy.setup({
  {
    'stevearc/oil.nvim',
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = true,
    config = function()
      require("plugins.oil")
    end
  },
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
    "jake-stewart/multicursor.nvim",
    event = "BufReadPost",
    branch = "1.0",
    config = function()
      require("plugins.others").setup.multicursor_stewart()
    end
  },
  {
    --(Tweaks.use_foldlevel_patch == true) and "silvercircle/fidget.nvim" or "j-hui/fidget.nvim",
    "j-hui/fidget.nvim",
    cond = Tweaks.notifier == "fidget",
    config = function()
      require("plugins.others").setup.fidget()
    end
  },
  -- 'nvim-lua/plenary.nvim',
  {
    'nvim-lualine/lualine.nvim',
    event = "UIEnter",
    config = function()
      require("plugins.lualine_setup")
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
    dir = PCFG.is_dev and "/mnt/shared/data/code/neovim_plugins/commandpicker.nvim/" or nil,
    url = PCFG.is_dev and nil or 'https://gitlab.com/silvercircle74/commandpicker.nvim',
    branch = "v1",
    lazy = true,
    event = "BufReadPost",
    config = function()
      require("commandpicker").setup({
        columns = {
          desc = { hl = "String" }
        },
        order = { 'desc', 'cmd', 'mappings', 'category' },
        custom_layout = SPL( { width=120, height=20, row=5, input="bottom", preview = false } ),
        width = 120,
        height = 20,
        preserve_mode = true,
      })
    end
  },
  {
    -- dir = "/mnt/shared/data/code/neovim_plugins/quickfavs.nvim/",
    'https://gitlab.com/silvercircle74/quickfavs.nvim',
    lazy = true,
    config = function()
      require("quickfavs").setup({
        filename = vim.fs.joinpath(vim.fn.stdpath("config"), "favs"),
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
    event = "BufReadPre",
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
  {
    --'hrsh7th/nvim-cmp',
    "iguanacucumber/magazine.nvim",
    name = 'nvim-cmp',
    lazy = true,
    cond = Tweaks.completion.version == "nvim-cmp",
    event = { "InsertEnter", "CmdLineEnter" },
    dependencies = {
      { "iguanacucumber/mag-cmdline", name = "cmp-cmdline" },
      { "iguanacucumber/mag-nvim-lsp", name = "cmp-nvim-lsp", opts = {} },
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-emoji',
      { "iguanacucumber/mag-nvim-lua", name = "cmp-nvim-lua" },
      'PhilRunninger/cmp-rpncalc',
      "kdheepak/cmp-latex-symbols",
      'hrsh7th/cmp-nvim-lsp-signature-help',
      {
        'https://gitlab.com/silvercircle74/cmp-wordlist.nvim',
        config = function()
          require("cmp_wordlist").setup({
            wordfiles = { 'wordlist.txt', "personal.txt" },
            debug = false,
            read_on_setup = false,
            watch_files = true,
            telescope_theme = __Telescope_dropdown_theme
          })
        end
      },
      --{ 'hrsh7th/cmp-buffer' },
      { "iguanacucumber/mag-buffer", name = "cmp-buffer" },
      { "rafamadriz/friendly-snippets" },
      {
        "garymjr/nvim-snippets",
        config = function()
          require("snippets").setup({
            friendly_snippets = true
          })
        end,
        keys = {
          {
            "<Tab>",
            function()
              if vim.snippet.active({ direction = 1 }) then
                vim.schedule(function()
                  vim.snippet.jump(1)
                end)
                return
              end
              return "<Tab>"
            end,
            expr = true,
            silent = true,
            mode = "i",
          },
          {
            "<Tab>",
            function()
              vim.schedule(function()
                vim.snippet.jump(1)
              end)
            end,
            expr = true,
            silent = true,
            mode = "s",
          },
          {
            "<S-Tab>",
            function()
              if vim.snippet.active({ direction = -1 }) then
                vim.schedule(function()
                  vim.snippet.jump(-1)
                end)
                return
              end
              return "<S-Tab>"
            end,
            expr = true,
            silent = true,
            mode = { "i", "s" },
          },
        },
      },
      { 'windwp/nvim-autopairs',
        config = function()
          require("nvim-autopairs").setup({})
          if PCFG.autopair then
            require("nvim-autopairs").enable()
          else
            require("nvim-autopairs").disable()
          end
        end
      },
    },
    config = function()
      require("plugins.cmp_setup")
    end
  },
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
        -- 'Kaiser-Yang/blink-cmp-dictionary',
      },
      { "moyiz/blink-emoji.nvim" },
      { 'windwp/nvim-autopairs',
        config = function()
          require("nvim-autopairs").setup({})
          if PCFG.autopair then
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
    'neovim/nvim-lspconfig',
    lazy = true,
    event = { "BufReadPost" },
    dependencies = {
      {
        "silvercircle/nvim-navic",
        branch = "mine",
        config = function()
          require("plugins.others").setup.navic()
        end
      },
      -- no longer needed, because roslyn has that integrated
      -- { 'Hoffs/omnisharp-extended-lsp.nvim', cond = (Tweaks.lsp.csharp == "omnisharp") },         -- omnisharp decompilation support
      -- { 'Decodetalkers/csharpls-extended-lsp.nvim', cond = (Tweaks.lsp.csharp == "csharp_ls") },  -- this is for csharp_ls decompilation support
      'onsails/lspkind-nvim',
      {
        'https://gitlab.com/silvercircle74/lsp_lines.nvim',
        cond = Tweaks.lsp.virtual_lines == true,
        config = function()
          require("lsp_lines").setup()
        end
      },
      {
        'dnlhc/glance.nvim',
        config = function()
          require("plugins.others").setup.glance()
        end
      },
      { "danymat/neogen",
        cmd = { "Neogen" },
        config = function()
          require("plugins.others").setup.neogen()
        end
      },
      {
        "lewis6991/hover.nvim",
        event = "BufReadPost",
        config = function()
          require("hover").setup({
            init = function()
              -- Require providers
              require("hover.providers.lsp")
              -- require('hover.providers.gh')
              -- require('hover.providers.gh_user')
              -- require('hover.providers.jira')
              -- require('hover.providers.dictionary')
              require('hover.providers.fold_preview')
              require('hover.providers.diagnostic')
              require('hover.providers.man')
            end,
            preview_opts = {
              border = Borderfactory("thicc")
            },
            preview_window = true,
            title = true
          })
        end
      }
    },
    config = function()
      require("plugins.lsp")
    end
  },
  {
    'williamboman/mason.nvim',
    cmd = "Mason",
    config = function()
      require("mason").setup({
        ui = {
          border = PCFG.float_borders
        }
      })
    end
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
            calm_down = false,    -- set to true to clear all lenses when cursor moves
            nearest_float_when = "never",
            nearest_only = true
          })
        end
      }
    }
  },
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufReadPost",
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
    -- cond = Tweaks.tree.version == "Nvim",
    -- LAZY = true,
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
    'goolord/alpha-nvim',
    cond = true,
    branch = "main",
    config = function()
      require("plugins.alpha")
    end
  },
  {
    "rcarriga/nvim-dap-ui",
    cond = Tweaks.dap.enabled == true,
    lazy = true,
    dependencies = {
      {
        "mfussenegger/nvim-dap",
        config = function() require("dap.nvim_dap") end
      },
      "nvim-neotest/nvim-nio"
    },
    config = function() require("dap.nvim_dap_ui") end
  },
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = function()
      require("inc_rename").setup()
    end
  },
  {
    'silvercircle/nvim-cokeline', lazy = true, event="UIEnter",
    branch = "mine",
    config = function()
      require("plugins.cokeline")
    end
  },
  {
    'silvercircle/outline.nvim',
    -- dir = "/data/mnt/shared/data/code/neovim_plugins/outline.nvim/",
    branch = 'mine',
    cond = Tweaks.outline_plugin == "outline",
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
    cond = false,
    event = "LspAttach",
    config = function()
      require("plugins.others").setup.trouble()
    end
  },
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
    "stevearc/quicker.nvim",
    event = "FileType qf",
    config = function()
      require("quicker").setup({
        opts = {
          number = true,
          signcolumn = "yes:3"
        }
      })
    end
  },
  {
    url = PCFG.is_dev and nil or "https://github.com/oskarrrrrrr/symbols.nvim",
    dir = PCFG.is_dev and "/mnt/shared/data/code/neovim_plugins/symbols.nvim/" or nil,
    cmd = { "Symbols", "SymbolsOpen" },
    lazy = true,
    cond = Tweaks.outline_plugin == "symbols",
    branch = PCFG.is_dev and "experiments" or "main",
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
      -- The following options are recommended when layout == "float"
      vim.opt.wrap = false
      vim.opt.sidescrolloff = 36 -- Set a large value

      vim.g.neominimap = {
        x_multiplier = 3,
        auto_enable = false,
        layout = "split",
        delay = 800,
        split = {
          minimap_width = 15,
          fix_width = true,
          direction = "right",
          close_if_last_window = true
        },
        exclude_buftypes = {
          "nofile",
          "nowrite",
          "quickfix",
          "terminal",
          "prompt",
        },
        treesitter = { enabled = Tweaks.minimap.features.treesitter },
        git = { enabled = Tweaks.minimap.features.git, mode = "icon" },
        search = { enabled = Tweaks.minimap.features.search },
        diagnostic = { enabled = Tweaks.minimap.features.diagnostic,
          mode = "line",
          severity = vim.diagnostic.severity.HINT
        },
        winopt = function(opt, _)
          opt.statuscolumn = ""
          opt.winbar = ""
          opt.signcolumn = "no"
          opt.statusline = "Minimap"
        end
      }
    end
  },
  {
    "sindrets/diffview.nvim",
    lazy = true,
    cmd = { "DiffviewOpen" }
  }
},
{
  ui = {
    border = Borderfactory("thicc")
  },
})
