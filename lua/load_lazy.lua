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
      { 'nvim-telescope/telescope-fzf-native.nvim', build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build" },
      { 'FeiyouG/command_center.nvim',
        cond = not vim.g.config.plain,
        event = { "UIEnter" },
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
    end
  },
  { 'L3MON4D3/LuaSnip',
    lazy = true,
    config = function()
      require("luasnip.loaders.from_snipmate").lazy_load()
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
      'saadparwaiz1/cmp_luasnip',
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
      'j-hui/fidget.nvim',
      'dnlhc/glance.nvim',
      { 'jose-elias-alvarez/null-ls.nvim', cond = vim.g.config.null_ls == true,
        config = function()
          require("plugins.null_ls")
        end
      }
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
  'petertriho/nvim-scrollbar',
  { 'stevearc/dressing.nvim',
    lazy = true,
    event = { "UIEnter" },
    config = function()
      require("plugins.dressing")
    end
  },
  { dir = '~/.config/nvim/local_plugin/local_utils' },
  { 'voldikss/vim-floaterm', cmd = {"FloatermNew", "FloatermToggle"} },
  { 'preservim/vim-markdown', ft = "markdown" },
  { 'norcalli/nvim-colorizer.lua' },
  'echasnovski/mini.move',
  {
    'nvim-tree/nvim-tree.lua', cmd="",
    config = function()
      require("plugins.nvim-tree")
    end
  },
  {
    'glepnir/lspsaga.nvim', lazy = true, cmd = "Lspsaga",
    config = function()
      require("plugins.lspsaga")
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
  { 'nvim-treesitter/playground', cond = vim.g.config.treesitter_playground == true },
  -- { 'folke/neodev.nvim', cond = vim.g.config.neodev == true },
  {
    'folke/noice.nvim', cond = vim.g.config.noice == true,
    config = function()
      require("plugins.noice")
    end
  },
  { 'goolord/alpha-nvim',
    cond = vim.g.config.plain == false,
    config = function ()
      if vim.g.config.plain == false then
        local theme = require("alpha.themes.startify")
        if vim.fn.has("linux") > 0 and (vim.g.config.fortunecookie ~= false and #vim.g.config.fortunecookie > 0) then
          local handle = io.popen("fortune science politics -s -n500 | cowsay -W 120")
          local result = {"",""}
          if handle ~= nil then
            local lines = handle:lines()
            for line in lines do
              table.insert(result, line)
            end
            handle:close()
            theme.section.header.val = result
          end
        end
        require'alpha'.setup(theme.config)
      end
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
  }
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
    dir = '/mnt/shared/data/code/neovim_plugins/symbols-outline.nvim', cmd = { "SymbolsOutline", "SymbolsOutlineOpen" },
    config = function()
      require("plugins.symbols_outline")
    end
  },
--  -- CMP and all its extensions
--  {
--    dir = '/mnt/shared/data/code/neovim_plugins/nvim-cmp',
--    lazy = true,
--    event = { "InsertEnter", "CmdLineEnter" },
--    dependencies = {
--      'hrsh7th/cmp-cmdline',
--      'hrsh7th/cmp-nvim-lsp',
--      'hrsh7th/cmp-path',
--      'hrsh7th/cmp-emoji',
--      'saadparwaiz1/cmp_luasnip',
--      'hrsh7th/cmp-nvim-lsp-signature-help',
--      { dir = '/mnt/shared/data/code/neovim_plugins/cmp-wordlist.nvim' },
--      'hrsh7th/cmp-buffer'
--    },
--    config = function()
--      require("plugins.cmp")
--    end
--  }
}

local plugins_official = {
  {
    'simrat39/symbols-outline.nvim', cmd = { "SymbolsOutline", "SymbolsOutlineOpen" },
    config = function()
      require("plugins.symbols_outline")
    end
  },
--  -- cmp and all its helpers
--  { 'hrsh7th/nvim-cmp',
--    lazy = true,
--    event = { "InsertEnter", "CmdLineEnter" },
--    dependencies = {
--      'hrsh7th/cmp-cmdline',
--      'hrsh7th/cmp-nvim-lsp',
--      'hrsh7th/cmp-path',
--      'hrsh7th/cmp-emoji',
--      'saadparwaiz1/cmp_luasnip',
--      'hrsh7th/cmp-nvim-lsp-signature-help',
--      {'https://gitlab.com/silvercircle74/cmp-wordlist.nvim' },
--      'hrsh7th/cmp-buffer'
--    },
--    config = function()
--      require("plugins.cmp")
--    end
--  },
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

Telescope_dropdown_theme = require("local_utils").Telescope_dropdown_theme
Telescope_vertical_dropdown_theme = require("local_utils").Telescope_vertical_dropdown_theme
