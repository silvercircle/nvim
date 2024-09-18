local lazy = require("lazy")
lazy.setup({
  'sharkdp/fd',
  {
    "lervag/vimtex",
    ft = "tex",
    init = function()
      -- Use init for configuration, don't use the more common "config".
    end
  },
  'BurntSushi/ripgrep',
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
    "brenton-leighton/multiple-cursors.nvim",
    version = "*", -- Use the latest tagged version
    opts = {
      pre_hook = function()
        vim.cmd("set nocul")
        vim.cmd("NoMatchParen")
      end,
      post_hook = function()
        vim.cmd("set cul")
        vim.cmd("DoMatchParen")
      end,
    },
    keys = {
      { "<C-Down>",      "<Cmd>MultipleCursorsAddDown<CR>",           mode = { "n", "i" } },
      { "<C-Up>",        "<Cmd>MultipleCursorsAddUp<CR>",             mode = { "n", "i" } },
      { "<C-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>",    mode = { "n", "i" } },
      { "<C-n>",         "<Cmd>MultipleCursorsAddMatches<CR>",        mode = { "n", "x" } },
      { "<C-n><C-n>",    "<Cmd>MultipleCursorsAddJumpNextMatch<CR>",  mode = { "n", "x" } },
      { "<C-n><C-l>",    "<Cmd>MultipleCursorsLock<CR>",              mode = { "n", "x" } },
      { "<leader>n",     "<Cmd>MultipleCursorsJumpNextMatch<CR>",     mode = { "n", "x" } },
    },
  },
  {
    "j-hui/fidget.nvim",
    cond = vim.g.tweaks.notifier == "fidget",
    priorty = 9999,
    config = function()
      require("plugins.others").setup.fidget()
    end
  },
  {
    'echasnovski/mini.notify',
    cond = vim.g.tweaks.notifier == "mini",
    config = function()
      require("mini.notify").setup({
        window = {
          config = {
            anchor = "SE",
            row = vim.o.lines
          },
          winblend = 0
        }
      })
      vim.notify = require("mini.notify").make_notify()
      vim.g.notifier = require("mini.notify").make_notify()
    end
  },
  'nvim-lua/plenary.nvim',
  {
    'nvim-lualine/lualine.nvim',
    event = "UIEnter",
    config = function()
      require("plugins.lualine")
    end
  },
  -- telescope + extensions, mandatory
  {
    'nvim-telescope/telescope.nvim', --  branch = '0.1.x',
    lazy = true,
    dependencies = {
      { 'nvim-telescope/telescope-fzf-native.nvim', build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build" },
      {
        'FeiyouG/commander.nvim',
        tag = "v0.1.0",
        event = { "BufReadPost" },
        config = function()
          require("plugins.command_center_setup")
        end
      },
      {
        'https://gitlab.com/silvercircle74/quickfavs.nvim',
        lazy = true,
        config = function()
          require("quickfavs").setup({
            telescope_theme = require("local_utils").Telescope_dropdown_theme
          })
        end
      }
    },
    config = function()
      require("plugins.telescope")
    end
  },
  -- treesitter + friends
  {
    'nvim-treesitter/nvim-treesitter',
    branch = "main",
    event = { "BufReadPre" },
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
      },
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        cond = false,
        lazy = true,
        config = function()
        end
      }
    }
  },
  -- cmp and all its helpers
  {
    'hrsh7th/nvim-cmp',
    lazy = true,
    event = { "InsertEnter", "CmdLineEnter" },
    dependencies = {
      'hrsh7th/cmp-cmdline',
      { 'hrsh7th/cmp-nvim-lsp' },
      'hrsh7th/cmp-path',
      { 'hrsh7th/cmp-emoji' },
      { 'dcampos/cmp-snippy' },
      { 'hrsh7th/cmp-nvim-lua' },
      { 'PhilRunninger/cmp-rpncalc'},
      { "kdheepak/cmp-latex-symbols"},
      { 'hrsh7th/cmp-nvim-lsp-signature-help' },
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
      { 'hrsh7th/cmp-buffer' },
      { 'windwp/nvim-autopairs',
        config = function()
          require("nvim-autopairs").setup({})
          if __Globals.perm_config.autopair then
            require("nvim-autopairs").enable()
          else
            require("nvim-autopairs").disable()
          end
        end
      },
      {
        'dcampos/nvim-snippy',
        lazy = true,
        config = function()
          require('snippy').setup({
            mappings = {
              is = {
                ['<Tab>'] = 'expand_or_advance',
                ['<S-Tab>'] = 'previous',
              },
              nx = {
                ['<leader>x'] = 'cut_text',
              },
            },
          })
        end
      }
    },
    config = function()
      require("plugins.cmp")
    end
  },
  -- lsp
  {
    "SmiteshP/nvim-navbuddy",
    lazy = true,
    cond = vim.g.tweaks.breadcrumb == "navic",
    event = "BufReadPre",
    dependencies = {
      {
        "silvercircle/nvim-navic",
        branch = "mine",
        config = function()
          require("plugins.others").setup.navic()
        end
      }
    },
    config = function()
      require("plugins.others").setup.navbuddy()
    end
  },
  {
    'neovim/nvim-lspconfig',
    lazy = true,
    event = { "LspAttach" },
    dependencies = {
      { 'Hoffs/omnisharp-extended-lsp.nvim', cond = (vim.g.tweaks.lsp.csharp == "omnisharp") },         -- omnisharp decompilation support
      { 'Decodetalkers/csharpls-extended-lsp.nvim', cond = (vim.g.tweaks.lsp.csharp == "csharp_ls") },  -- this is for csharp_ls decompilation support
      'onsails/lspkind-nvim',
      {
        'https://gitlab.com/silvercircle74/lsp_lines.nvim',
        cond = vim.g.tweaks.lsp.virtual_lines == true,
        config = function()
          require("lsp_lines").setup()
        end
      },
      {
        'dnlhc/glance.nvim',
        config = function()
          require("plugins.glance")
        end
      },
      { "danymat/neogen",
        config = function()
          require("plugins.others").setup.neogen()
        end
      },
      {
        "lewis6991/hover.nvim",
        config = function()
          require("hover").setup({
           init = function()
           -- Require providers
             require("hover.providers.lsp")
           -- require('hover.providers.gh')
           -- require('hover.providers.gh_user')
           -- require('hover.providers.jira')
           -- require('hover.providers.man')
           -- require('hover.providers.dictionary')
           end,
           preview_opts = {
             border = __Globals.perm_config.float_borders
           },
           preview_window = false,
           title = false
        })
        end
      }
    },
    config = function()
      require("plugins.lsp")
    end
  },
  {
  },
  {
    'williamboman/mason.nvim',
    cmd = "Mason",
    config = function()
      require("mason").setup({
        ui = {
          border = __Globals.perm_config.float_borders
        }
      })
    end
  },
  -- { 'tpope/vim-liquid', ft = "liquid" },
  {
    'MattesGroeger/vim-bookmarks',
    event = "BufReadPre",
    dependencies = {
      {
        'https://gitlab.com/silvercircle74/telescope-vim-bookmarks.nvim'
      }
    }
  },
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require("plugins.others").setup.gitsigns()
    end
  },
  { 'lukas-reineke/indent-blankline.nvim', event = "UIEnter", config = function() require("plugins.iblsetup") end },
  {
    'petertriho/nvim-scrollbar',
    event = "BufReadPre",
    config = function()
      require("plugins.nvim-scrollbar")
      __Globals.set_scrollbar()
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
  --  {'lewis6991/satellite.nvim',
  --    config = function()
  --      require("plugins.satellite")
  --    end
  --  },
  {
    'stevearc/dressing.nvim',
    event = { "UIEnter" },
    config = function()
      require("plugins.dressing")
    end
  },
  {
    'akinsho/toggleterm.nvim',
    lazy = true,
    config = function()
      require("plugins.others").setup.toggleterm()
    end
  },
  --{ 'preservim/vim-markdown',     ft = "markdown" },
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
    'echasnovski/mini.pick',
    version = false,
    lazy = true,
    config = function()
      require("plugins.others").setup.mini_pick()
    end
  },
  {
    'echasnovski/mini.extra',
    version = false,
    lazy = true,
    config = function()
      require("plugins.others").setup.mini_extra()
    end
  },
  {
    'echasnovski/mini.files',
    version = false,
    lazy = true,
    config = function()
      require("plugins.others").setup.mini_files()
    end
  },
  {
    'nvim-tree/nvim-tree.lua',
    cond = vim.g.tweaks.tree.version == "Nvim",
    config = function()
      require("plugins.nvim-tree")
    end
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    cond = vim.g.tweaks.tree.version == "Neo",
    config = function()
      require("plugins.neotree")
    end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      {
        's1n7ax/nvim-window-picker',
        event = "VeryLazy",
        config = function()
          require("window-picker").setup({
            hint = 'floating-big-letter'
          })
        end
      }
    }
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
    'silvercircle/alpha-nvim',
    branch = "mine",
    cond = Config.plain == false,
    config = function()
      require("plugins.alpha")
    end
  },
  {
    'mfussenegger/nvim-dap',
    lazy = true,
    dependencies = {
      'nvim-neotest/nvim-nio',
      {
        'rcarriga/nvim-dap-ui',
        config = function()
          require("dap.nvim_dap_ui")
        end
      }
    },
    config = function()
      require("dap.nvim_dap")
    end
  },
  { 'kevinhwang91/rnvimr', cond = false, lazy = true, cmd = { "RnvimrToggle" } },
  {
    "smjonas/inc-rename.nvim",
    event = { "BufRead" },
    config = function()
      require("inc_rename").setup()
    end
  },
  {
    'gabrielpoca/replacer.nvim',
    ft = { "qf" }
  },
  {
    'willothy/nvim-cokeline', lazy = true, event="UIEnter", branch = "main",
    config = function()
      require("plugins.cokeline")
    end
  },
  {
    'silvercircle/outline.nvim',
    branch = 'mine',
    cmd = { "Outline", "OutlineOpen", "OutlineClose" },
    lazy = true,
    config = function()
      require("plugins.symbols_outline-forked")
    end
  },
  {
    'silvercircle/aerial.nvim',
    branch = 'mine',
    cond = false,
    lazy = true,
    config = function()
      require("plugins.aerialsetup")
    end
  },
  --{
  --  "folke/which-key.nvim",
  --  keys = { "<c-h>" },
  --  config = function()
  --    require("which-key").setup({
  --      plugins = {
  --        registers = false,
  --        marks = false,
  --        spelling = {
  --          enabled = false
  --        }
  --      },
  --      window = {
  --        border = 'single',
  --      },
  --      layout = {
  --        height = { max = 10 }
  --      }
  --    })
  --  end
  --},
  --{
  --  '3rd/image.nvim',
  --  lazy = true,
  --  config = function()
  --    require("plugins.image-nvim")
  --  end
  --},
  {
    'edluffy/hologram.nvim',
    lazy = true,
    config = function()
      require("hologram").setup({})
    end
  },
  {
    'kevinhwang91/nvim-ufo',
    cond = false,
    --event = "UIEnter",
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
  {
    "MaximilianLloyd/ascii.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim"
    }
  },
  {
    'jmederosalvarado/roslyn.nvim',
    cond = (vim.g.tweaks.lsp.csharp == "roslyn"),
    lazy = true,
    ft = { "cs" },
    config = function()
      require("roslyn").setup({
        roslyn_version = "4.9.0-3.23604.10",
        capabilities = __Globals.get_lsp_capabilities()
      })
    end
  },
  {
    "jlcrochet/vim-razor",
    ft = { "cshtml", "razor" }
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
    'folke/edgy.nvim',
    cond = false,
    event = "VeryLazy",
    config = function()
      require("plugins.edgy")
    end
  },
  {
    "ibhagwan/fzf-lua",
    -- cond = false,
    lazy = true,
    event = "BufReadPost",
    config = function()
      require("plugins.fzf-lua")
    end
  },
  --{
  --  "folke/noice.nvim",
  --  event = "VeryLazy",
  --  config = function()
  --    require("plugins.noice")
  --  end
  --}
},
{
  ui = {
    border = __Globals.perm_config.float_borders
  }
})
