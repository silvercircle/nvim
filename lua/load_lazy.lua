local lazy = require("lazy")
lazy.setup({
  'sharkdp/fd',
  'BurntSushi/ripgrep',
  'nvim-tree/nvim-web-devicons',
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
  {
    'nvim-treesitter/nvim-treesitter',
    branch = "master",
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
      { 'hrsh7th/cmp-buffer' }
    },
    config = function()
      require("plugins.cmp")
    end
  },
  -- lsp
  {
    'neovim/nvim-lspconfig',
    lazy = true,
    event = { "LspAttach" },
    dependencies = {
      'Decodetalkers/csharpls-extended-lsp.nvim',
      'onsails/lspkind-nvim',
      {
        'Bekaboo/dropbar.nvim',
        cond = Config.breadcrumb == 'dropbar' and vim.fn.has("nvim-0.10") == 1,
        event = "LspAttach",
        config = function()
          require("plugins.dropbar")
        end
      },
      { 'SmiteshP/nvim-navic', lazy = true, cond = Config.breadcrumb == 'navic', event = "LspAttach" },
      {
        'dnlhc/glance.nvim',
        config = function()
          require("plugins.glance")
        end
      },
      --{
      --  "vigoux/notifier.nvim",
      --  event = "UIEnter",
      --  cond = false,
      --  lazy = true,
      --  config = function()
      --    require("notifier").setup({
      --      components = {
      --        --"nvim",
      --        -- "lsp"
      --      },
      --      notify = {
      --        min_level = 0
      --      }
      --    })
      --    -- vim.g.notifier = require("notifier")
      --  end
      --},
    },
    config = function()
      require("plugins.lsp")
    end
  },
  {
    'j-hui/fidget.nvim',
    priorty = 9999,
    config = function()
      vim.g.notifier = require("fidget")
      require("fidget").setup({
        progress = {
          poll_rate = 1,
          ignore_done_already = true,
          display = {
            render_limit = 2
          }
        },
        notification = {
          override_vim_notify = true,
          history_size = 20,
          filter = vim.log.levels.TRACE,
          configs = {
            --default = require("fidget.notification").default_config
          }
        }
      })
    end
  },
  {
    'williamboman/mason.nvim',
    cmd = "Mason",
    config = function()
      require("mason").setup()
    end
  },
  --  { 'williamboman/mason-lspconfig.nvim' },
  { 'tpope/vim-liquid', ft = "liquid" },
  {
    'tomasky/bookmarks.nvim',
    event = "UIEnter",
    config = function()
      require('bookmarks').setup({
        -- sign_priority = 8,  --set bookmark sign priority to cover other sign
        save_file = vim.fn.stdpath("state") .. "/.bookmarks", -- bookmarks save file path
        keywords = {
          ["@t"] = " ", -- mark annotation startswith @t ,signs this icon as `Todo`
          ["@w"] = " ",  -- mark annotation startswith @w ,signs this icon as `Warn`
          ["@f"] = " ", -- mark annotation startswith @f ,signs this icon as `Fix`
          ["@n"] = " ", -- mark annotation startswith @n ,signs this icon as `Note`
        }
      })
    end
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
  --{ 'numToStr/FTerm.nvim', lazy=true },
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
    'nvim-tree/nvim-tree.lua',
    lazy = true,
    cond = vim.g.tweaks.tree == "Nvim",
    config = function()
      require("plugins.nvim-tree")
    end
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
    'willothy/nvim-cokeline', branch = "main"
  },
  {
    'silvercircle/outline.nvim',
    --'https://gitlab.com/silvercircle74/symbols-outline.nvim',
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
    --cond = false,
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
  }
  --{ "catppuccin/nvim", name = "catppuccin", priority = 1000 }
})
