local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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
  'nvim-lualine/lualine.nvim',
  'noib3/nvim-cokeline',
  -- multiple cursors.
  'mg979/vim-visual-multi',
  -- telescope + extensions, mandatory
  {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    lazy = true,
    dependencies = {
      'nvim-telescope/telescope-file-browser.nvim',
      'tom-anders/telescope-vim-bookmarks.nvim',
      'FeiyouG/command_center.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build" }
    }
  },
  'L3MON4D3/LuaSnip',
  -- lsp
  { 'neovim/nvim-lspconfig',
    dependencies = {
      'onsails/lspkind-nvim',
      'j-hui/fidget.nvim',
      'dnlhc/glance.nvim',
      { 'jose-elias-alvarez/null-ls.nvim', cond = vim.g.config.null_ls == true,
        config = function()
          require("setup_null_ls")
        end
      }
    }
  },
  {
    'williamboman/mason.nvim', cmd = "Mason",
    config = function()
      require("mason").setup()
    end
  },
--  { 'williamboman/mason-lspconfig.nvim' },
  {'tpope/vim-liquid', ft = "liquid" },
  {'MunifTanjim/nui.nvim', lazy = true },
  'nvim-tree/nvim-web-devicons',
  { 'alaviss/nim.nvim', ft = "nim" },
  'nvim-lua/plenary.nvim',
  'MattesGroeger/vim-bookmarks',
  'sharkdp/fd',
  'BurntSushi/ripgrep',
  'mhinz/vim-startify',
  'kevinhwang91/nvim-hlslens',
  'lewis6991/gitsigns.nvim',
  'lukas-reineke/indent-blankline.nvim',
  'petertriho/nvim-scrollbar',
  'stevearc/dressing.nvim',
  'nvim-treesitter/nvim-treesitter',
  { dir = '~/.config/nvim/local_plugin/local_utils' },
  { 'voldikss/vim-floaterm', cmd = {"FloatermNew", "FloatermToggle"} },
  { 'preservim/vim-markdown', ft = "markdown" },
  { 'norcalli/nvim-colorizer.lua' },
  'echasnovski/mini.move',
  {
    'nvim-neo-tree/neo-tree.nvim', branch = "main", cmd="NeoTreeShow",
    config = function()
      require("setup_neotree")
    end
  },
  {
    'renerocksai/telekasten.nvim', lazy = true,
    dependencies = {
      { 'renerocksai/calendar-vim' },
    },
    --config = function()
    --  require("setup_telekasten")
    --end
  },
  {
    'folke/todo-comments.nvim',
    config = function()
      require("setup_todo")
    end
  },
  { 'nvim-treesitter/playground', cond = vim.g.config.treesitter_playground == true },
  {
    'glepnir/lspsaga.nvim', lazy = true, cmd = "Lspsaga",
    config = function()
      require("setup_lspsaga")
    end
  },
  { 'folke/neodev.nvim', cond = vim.g.config.neodev == true },
  {
    'folke/noice.nvim', cond = vim.g.config.noice == true,
    config = function()
      require("setup_noice")
    end
  }
}

-- for experimental purpose, I use some private forks and local repos.
-- plugins_official (see below) contains the same stuff..
local plugins_private = {
  { dir = '/mnt/shared/data/code/neovim_plugins/quickfavs.nvim' },
  {
    'silvercircle/symbols-outline.nvim', cmd = "SymbolsOutline",
    config = function()
      require("setup_outline")
    end
  },
  -- CMP and all its extensions
  {
    dir = '/mnt/shared/data/code/neovim_plugins/nvim-cmp',
    lazy = true,
    dependencies = {
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-emoji',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      {
        dir = '/mnt/shared/data/code/neovim_plugins/cmp-wordlist.nvim',
        config = function()
          require("cmp_wordlist").setup({
            wordfiles={'wordlist.txt', "personal.txt" },
            debug = true,
            read_on_setup = false,
            watch_files = true,
            telescope_theme = Telescope_dropdown_theme
          })
        end
      }
    }
  },
}

local plugins_official = {
  {
    'simrat39/symbols-outline.nvim', cmd = "SymbolsOutline",
    config = function()
      require("setup_outline")
    end
  },
  -- cmp and 
  { 'hrsh7th/nvim-cmp',
    lazy = true,
    dependencies = {
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-emoji',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      {'https://gitlab.com/silvercircle74/cmp-wordlist.nvim',
        config = function()
          require("cmp_wordlist").setup({
            wordfiles={'wordlist.txt', "personal.txt" },
            debug = true,
            read_on_setup = false,
            watch_files = true,
            telescope_theme = Telescope_vertical_dropdown_theme
          })
        end
      }
    }
  },
  'https://gitlab.com/silvercircle74/quickfavs.nvim'
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
