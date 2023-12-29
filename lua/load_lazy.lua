local lazy = require("lazy")
lazy.setup({
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
  {
    'nvim-treesitter/nvim-treesitter',
    branch = "master",
    event = { "BufReadPre" },
    config = function()
      require("plugins.treesitter")
    end,
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    config = function()
      require("plugins.neotree")
    end,
    dependencies = {
      'MunifTanjim/nui.nvim'
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
  {
    'nvim-telescope/telescope.nvim', --  branch = '0.1.x',
    lazy = true,
    dependencies = {
      { 'nvim-telescope/telescope-fzf-native.nvim', build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build" },
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
      'onsails/lspkind-nvim',
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
  'echasnovski/mini.move',
  { 'kevinhwang91/rnvimr', lazy = true, cmd = { "RnvimrToggle" } },
  {
    'willothy/nvim-cokeline', branch = "main"
  },
})
