local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- bootstrap lazy
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  {'nvim-lualine/lualine.nvim',
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
    'nvim-telescope/telescope.nvim',--  branch = '0.1.x',
    lazy = true,
    dependencies = {
      -- 'nvim-telescope/telescope-file-browser.nvim',
      'tom-anders/telescope-vim-bookmarks.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build" },
      { 'FeiyouG/commander.nvim',
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
           telescope_theme = Telescope_dropdown_theme,
          })
        end
      }
    },
    config = function()
      require("plugins.telescope_setup")
    end
  },
  {'nvim-treesitter/nvim-treesitter',
    branch = "master",
    event = { "BufReadPre" },
    config = function()
      --require("plugins.treesitter")
    end,
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-context',
        config = function()
          require('treesitter-context').setup {
            enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
            max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
            min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
            line_numbers = true,
            multiline_threshold = 20, -- Maximum number of lines to show for a single context
            trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
            mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
            -- Separator between context and content. Should be a single character string, like '-'.
            -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
            separator = nil,
            zindex = 20, -- The Z-index of the context window
            on_attach = function(buf)
              if buf then
                local ft = vim.bo[buf].filetype
                if vim.tbl_contains(Config.treesitter_types, ft) or vim.tbl_contains(Config.treesitter_context_types, ft) then
                  return true
                end
              end
              return false
            end
          }
          require("globals").setup_treesitter_context(true)
        end
      }
    }
  },
  {'dcampos/nvim-snippy',
    lazy=true,
    config=function()
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
  { 'hrsh7th/nvim-cmp',
    lazy = true,
    event = { "InsertEnter", "CmdLineEnter" },
    dependencies = {
      'hrsh7th/cmp-cmdline',
      {'hrsh7th/cmp-nvim-lsp'},
      'hrsh7th/cmp-path',
      {'hrsh7th/cmp-emoji'},
      {'dcampos/cmp-snippy'},
      {'hrsh7th/cmp-nvim-lua'},
      {'hrsh7th/cmp-nvim-lsp-signature-help'},
      {'https://gitlab.com/silvercircle74/cmp-wordlist.nvim',
        config = function()
          require("cmp_wordlist").setup({
            wordfiles={'wordlist.txt', "personal.txt" },
            debug = false,
            read_on_setup = false,
            watch_files = true,
            telescope_theme = Telescope_dropdown_theme
          })
        end
      },
      {'hrsh7th/cmp-buffer'}
    },
    config = function()
      require("plugins.cmp")
    end
  },
  -- lsp
  { 'neovim/nvim-lspconfig',
    lazy = true,
    event = { "LspAttach" },
    dependencies = {
      'onsails/lspkind-nvim',
      {'Bekaboo/dropbar.nvim', cond = Config.breadcrumb == 'dropbar' and vim.fn.has("nvim-0.10") == 1,
        event = "LspAttach",
        config = function()
          require("plugins.dropbar")
        end
      },
      {'SmiteshP/nvim-navic',lazy=true, cond = Config.breadcrumb == 'navic', event = "LspAttach" },
      {'dnlhc/glance.nvim',
        config = function()
          require("plugins.glance")
        end
      },
      {'vigoux/notifier.nvim',
        event = "LspAttach",
        lazy = true,
        config = function()
          require("notifier").setup({
            components = {
              "nvim",
              "lsp"
            },
            notify = {
              min_level = 0
            }
          })
          vim.g.notifier = require("notifier")
        end
      },
    },
    config = function()
      require("plugins.lsp")
    end
  },
  {
    'williamboman/mason.nvim', cmd = "Mason",
    config =function()
      require("mason").setup()
    end
  },
--  { 'williamboman/mason-lspconfig.nvim' },
  {'tpope/vim-liquid', ft = "liquid" },
  'nvim-tree/nvim-web-devicons',
  'nvim-lua/plenary.nvim',
  'MattesGroeger/vim-bookmarks',
  'sharkdp/fd',
  'BurntSushi/ripgrep',
  'kevinhwang91/nvim-hlslens',
  'lewis6991/gitsigns.nvim',
  {'lukas-reineke/indent-blankline.nvim', config = function() require("plugins.ibl") end },
  {'petertriho/nvim-scrollbar',
    config = function()
      require("plugins.nvim-scrollbar")
    end
  },
--  {'lewis6991/satellite.nvim',
--    config = function()
--      require("plugins.satellite")
--    end
--  },
  { 'stevearc/dressing.nvim',
    event = { "UIEnter" },
    config = function()
      require("plugins.dressing")
    end
  },
  { 'voldikss/vim-floaterm', cmd = {"FloatermNew", "FloatermToggle"} },
  --{ 'numToStr/FTerm.nvim', lazy=true },
  { 'preservim/vim-markdown', ft = "markdown" },
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
    config = function()
      require("plugins.nvim-tree")
    end
  },
  {
    'renerocksai/telekasten.nvim', lazy = true, ft={"telekasten", "markdown"},
    dependencies = {
      { 'renerocksai/calendar-vim' },
    },
    config = function()
      require("plugins.telekasten_setup")
    end
  },
  {
    'folke/todo-comments.nvim',
    config = function()
      require("plugins.todo")
    end
  },
  { 'silvercircle/alpha-nvim',
    branch = "mine",
    cond = Config.plain == false,
    config = function ()
      require("plugins.alpha")
    end
  },
  { 'mfussenegger/nvim-dap',
    lazy = true,
    dependencies = {
      { 'rcarriga/nvim-dap-ui',
        config = function()
          require("dap.nvim_dap_ui")
        end
      }
    },
    config = function()
      require("dap.nvim_dap")
    end
  },
  { 'kevinhwang91/rnvimr', lazy=true, cmd={"RnvimrToggle"} },
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
    --'silvercircle/outline.nvim', branch = "mine", cmd = { "Outline", "OutlineOpen", "OutlineClose" },
    'https://gitlab.com/silvercircle74/symbols-outline.nvim', branch = 'mine', cmd = { "Outline", "OutlineOpen", "OutlineClose" },
    lazy = true,
    config = function()
      require("plugins.symbols_outline")
    end
  },
  { 'silvercircle/aerial.nvim',
    event = "LspAttach",
    branch = 'mine',
    verylazy = true,
    config = function()
      require("plugins.aerialsetup")
    end
  }
}

require("lazy").setup(plugins)
