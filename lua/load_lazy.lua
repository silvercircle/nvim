local lazy = require("lazy")
lazy.setup({
  'sharkdp/fd',
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
        }
      },
      color_icons = true,
      default = true
      })
    end
  },
  --{
  --  "j-hui/fidget.nvim",
  --  priorty = 9999,
  --  config = function()
  --    vim.g.notifier = require("fidget")
  --    require("fidget").setup({
  --      progress = {
  --        poll_rate = 1,
  --        ignore_done_already = true,
  --        display = {
  --          render_limit = 2
  --        }
  --      },
  --      notification = {
  --        override_vim_notify = true,
  --        history_size = 20,
  --        filter = vim.log.levels.TRACE,
  --        configs = {
  --          --default = require("fidget.notification").default_config
  --        }
  --      }
  --    })
  --  end
  --},
  'nvim-lua/plenary.nvim',
  {
    'nvim-lualine/lualine.nvim',
    event = "UIEnter",
    config = function()
      require("plugins.lualine")
    end
  },
  -- multiple cursors.
  {
    'mg979/vim-visual-multi',
    event = "BufReadPre"
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
            telescope_theme = require("local_utils").Telescope_dropdown_theme,
          })
        end
      }
    },
    config = function()
      require("plugins.telescope_setup")
    end
  },
  -- treesitter + friends
  {
    'nvim-treesitter/nvim-treesitter',
    --branch = "main",
    event = { "BufReadPre" },
    config = function()
      require("plugins.treesitter")
    end,
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-context',
        lazy = true,
        config = function()
          require('treesitter-context').setup {
            enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
            max_lines = 12,           -- How many lines the window should span. Values <= 0 mean no limit.
            min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
            line_numbers = true,
            multiline_threshold = 20, -- Maximum number of lines to show for a single context
            trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
            mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
            -- Separator between context and content. Should be a single character string, like '-'.
            -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
            separator = "─",
            zindex = 100, -- The Z-index of the context window
            on_attach = function()
              return true
            end
          }
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
    cond = Config.breadcrumb == "navic",
    event = "BufReadPre",
    dependencies = {
      {
        "SmiteshP/nvim-navic",
        config = function()
          require("nvim-navic").setup({
            lsp = {
              auto_attach = true
            },
            highlight = true,
            icons = vim.g.lspkind_symbols,
          })
        end
      }
    },
    config = function()
      local actions = require("nvim-navbuddy.actions")
      require("nvim-navbuddy").setup({
        lsp = {
          auto_attach = true
        },
        icons = vim.g.lspkind_symbols,
        mappings = {
          ["<Left>"] = actions.parent(),     -- Move to left panel
          ["<Right>"] = actions.children()
        },
        window = {
          sections = {
            left = {
              size = "40%",
            },
            mid = {
              size = "30%",
            },
            right = {
              size = "30%",
              preview = "never"
            }
          }
        }
      })
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
          local i = require("neogen.types.template").item
          require("neogen").setup({
            enabled = true,
            snippet_engine = "snippy",
            languages = {
              cs = {
                template = {
                  annotation_convention = "xmldoccustom",
                  xmldoccustom = {
                    { nil, "/**"},
                    { nil, " * <summary>", { no_results = true } },
                    { nil, " * $1", { no_results = true } },
                    { nil, " * </summary>", { no_results = true } },

                    { nil, " * <summary>", {} },
                    { nil, " * $1", {} },
                    { nil, " * </summary>", {} },
                    { i.Parameter, ' * <param name="%s">$1</param>', { type = { "func", "type" } } },
                    { i.Tparam, ' * <typeparam name="%s">$1</typeparam>', { type = { "func", "class" } } },
                    { i.Return, " * <returns>$1</returns>", { type = { "func", "type" } } },
                    { nil, " */"}
                  }
                }
              },
              lua = {
                template = {
                  annotation_convention = "emmylua"
                }
              }
            }
          })
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
           preview_window = true,
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
      require("mason").setup()
    end
  },
  { 'tpope/vim-liquid', ft = "liquid" },
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
    'kevinhwang91/nvim-hlslens', event = "BufReadPre",
    config = function()
      require("hlslens").setup({
        calm_down = false,    -- set to true to clear all lenses when cursor moves
        nearest_float_when = "never",
        nearest_only = true
      })
    end
  },
  'lewis6991/gitsigns.nvim',
  { 'lukas-reineke/indent-blankline.nvim', event = "UIEnter", config = function() require("plugins.iblsetup") end },
  {
    'petertriho/nvim-scrollbar',
    event = "BufReadPre",
    config = function()
      require("plugins.nvim-scrollbar")
      __Globals.set_scrollbar()
    end
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
  { 'voldikss/vim-floaterm',      cmd = { "FloatermNew", "FloatermToggle" } },
  { 'preservim/vim-markdown',     ft = "markdown" },
  { 'norcalli/nvim-colorizer.lua' },
  'echasnovski/mini.move',
  {
    'echasnovski/mini.pick',
    version = false,
    lazy = true,
    config = function()
      require("plugins.mini_pick")
    end
  },
  {
    'echasnovski/mini.extra',
    version = false,
    lazy = true,
    config = function()
      require("plugins.mini_extra")
    end
  },
  {
    'echasnovski/mini.notify',
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
    'renerocksai/telekasten.nvim',
    lazy = true,
    ft = { "telekasten", "markdown" },
    dependencies = {
      { 'renerocksai/calendar-vim' },
    },
    config = function()
      require("plugins.telekasten_setup")
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
  { 'kevinhwang91/rnvimr', lazy = true, cmd = { "RnvimrToggle" } },
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
      require("plugins.default")
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
    event = "LspAttach",
    branch = 'mine',
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
  {
    '3rd/image.nvim',
    lazy = true,
    config = function()
      require("plugins.image-nvim")
    end
  },
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
      require('ufo').setup({
        open_fold_hl_timeout = 0,
        --provider_selector = function(bufnr, filetype, buftype)
        provider_selector = function()
          return {'treesitter', 'indent'}
        end,
        -- fold_virt_text_handler = __Globals.ufo_virtual_text_handler,
        preview = {
          mappings = {
            scrollU = "<Up>",
            scrollD = "<Down>",
            jumpTop = "<Home>",
            jumpBot = "<End>"
          },
          win_config = {
            max_height = 30,
            border = __Globals.perm_config.telescope_borders
          }
        }
      })
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
        local trouble = require("trouble")
        _Config_SetKey({ 'n', 'i' }, "<C-t>t", function() trouble.open() end, "Toggle Trouble window")
        _Config_SetKey({ 'n', 'i' }, "<C-t>q", function() trouble.close() end, "Toggle Trouble window")
        _Config_SetKey({ 'n', 'i' }, "<C-t><Down>", function() trouble.next({skip_groups = true, jump = true}) end, "Trouble next item")
        _Config_SetKey({ 'n', 'i' }, "<C-t><Up>", function() trouble.previous({skip_groups = true, jump = true}) end, "Trouble previous item")
        require("trouble").setup({
          position = "bottom",
          height = 15,
          width = 50,
          action_keys = {
            open_tab = { }
          }
        })
        vim.cmd("hi TroubleText guibg=NONE")
        vim.cmd("hi TroubleLocation guibg=NONE")
      end
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    event = "BufReadPre",
    cond = false,
    config = function()
      require("plugins.harpoon")
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
  }
})
