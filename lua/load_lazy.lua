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
  'MunifTanjim/nui.nvim',
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
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
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
      }
    },
    config = function()
      require("plugins.telescope_setup")
    end
  },
  {'nvim-treesitter/nvim-treesitter',
    config = function()
      require("plugins.treesitter")
      vim.treesitter.query.set("javascript", "injections", "")
      vim.treesitter.query.set("typescript", "injections", "")
    end,
    event = { "BufReadPre" },
    dependencies = {
      { 'nvim-treesitter/playground', cond = vim.g.config.treesitter_playground == true },
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
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-emoji',
      'dcampos/cmp-snippy',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      {'https://gitlab.com/silvercircle74/cmp-wordlist.nvim' },
      'hrsh7th/cmp-buffer'
    },
    config = function()
      require("plugins.cmp")
    end
  },
  -- lsp
  { 'neovim/nvim-lspconfig',
    lazy = true,
    event = { "UIEnter" },
    dependencies = {
      'onsails/lspkind-nvim',
      --'j-hui/fidget.nvim',
      {'SmiteshP/nvim-navic',lazy=true },
      'dnlhc/glance.nvim',
      { 'jose-elias-alvarez/null-ls.nvim', cond = vim.g.config.null_ls == true,
        config = function()
          require("plugins.null_ls")
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
  { 'alaviss/nim.nvim', ft = "nim" },
  'nvim-lua/plenary.nvim',
  'MattesGroeger/vim-bookmarks',
  'sharkdp/fd',
  'BurntSushi/ripgrep',
  'kevinhwang91/nvim-hlslens',
  'lewis6991/gitsigns.nvim',
  'lukas-reineke/indent-blankline.nvim',
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
--  {
--    'glepnir/lspsaga.nvim', lazy = true, cmd = "Lspsaga",
--    config = function()
--      require("plugins.lspsaga")
--    end
--  },
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
  { 'goolord/alpha-nvim',
    cond = vim.g.config.plain == false,
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
--  {
--    'mrjones2014/legendary.nvim',
--    lazy = true,
--    cmd = { "Legendary" },
--    config = function()
--      require("plugins.legendary")
--    end
--  },
  {
    'ibhagwan/fzf-lua',
    lazy = true,
    cmd = { "FzfLua" },
    config = function()
      require("plugins.fzf")
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
--  {
--    'pwntester/octo.nvim',
--    cmd = { "Octo" },
--    config = function()
--      require("plugins.octo")
--    end
--  },
--  {
--    'https://gitlab.com/silvercircle74/marks.nvim',
--    branch = "CursorHold",
--    event = "BufReadPre",
--    config = function()
--      require("marks").setup({ --TODO: foobar
--        signcolumn = 4,
--        refresh_interval = 1000
--      })
--    end
--  },
  {
    'gabrielpoca/replacer.nvim',
    ft = { "qf" }
  },
  {
    'arkav/lualine-lsp-progress',
    config = function()

    end
  },
  {
    'willothy/nvim-cokeline', branch = "main"
  },
}
-- for experimental purpose, I use some private forks and local repos.
-- plugins_official (see below) contains the same stuff..
local plugins_private = {
  {
    dir = '/mnt/shared/data/code/neovim_plugins/quickfavs.nvim',
    lazy = true,
    config = function()
      require("quickfavs").setup({
       telescope_theme = Telescope_dropdown_theme,
       file_browser_theme = {
         theme = Telescope_vertical_dropdown_theme,
         layout_config = {
           preview_height = 0.4
         }
       }
      })
    end
  },
  {
    'silvercircle/symbols-outline.nvim', branch = "mine", cmd = { "SymbolsOutline", "SymbolsOutlineOpen" },
    config = function()
      require("plugins.symbols_outline")
    end
  }
}

local plugins_official = {
  {
    'simrat39/symbols-outline.nvim', cmd = { "SymbolsOutline", "SymbolsOutlineOpen" },
    config = function()
      require("plugins.symbols_outline")
    end
  },
  {
    dir = '/mnt/shared/data/code/neovim_plugins/quickfavs.nvim',
    lazy = true,
    config = function()
      require("quickfavs").setup({
       telescope_theme = Telescope_dropdown_theme,
       file_browser_theme = {
         theme = Telescope_vertical_dropdown_theme,
         layout_config = {
           preview_height = 0.4
         }
       }
      })
    end
  },
}

--- use private forks of some plugins, not recommended. this is normally disabled
if vim.g.use_private_forks == true then
  for _,v in ipairs(plugins_private) do
    table.insert(plugins, v)
  end
else
  for _,v in ipairs(plugins_official) do
    table.insert(plugins, v)
  end
end

require("lazy").setup(plugins)
