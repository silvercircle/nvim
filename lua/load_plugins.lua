vim.cmd([[packadd packer.nvim]])
-- all plugins handled by packer. Plug has been retired
return require("packer").startup(function(use)
  use { 'wbthomason/packer.nvim', opt = true }
  use 'nvim-lualine/lualine.nvim'
  use { 'mg979/vim-visual-multi', branch = "master" }
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-emoji'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  use 'nvim-tree/nvim-web-devicons'
  use { 'jose-elias-alvarez/null-ls.nvim', cond = function() return vim.g.config_null_ls end }
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'neovim/nvim-lspconfig'
  use 'silvercircle/symbols-outline.nvim'
  use 'dnlhc/glance.nvim'
  use 'j-hui/fidget.nvim'
  use 'onsails/lspkind-nvim'
  use 'alaviss/nim.nvim'
  use 'gpanders/editorconfig.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'hrsh7th/cmp-nvim-lsp-signature-help'
  use { 'nvim-telescope/telescope.nvim', branch = '0.1.x' }
  use 'nvim-telescope/telescope-file-browser.nvim'
  use 'tom-anders/telescope-vim-bookmarks.nvim'
  use 'MunifTanjim/nui.nvim'
  --      'rcarriga/nvim-notify',
  use { 'folke/noice.nvim', cond = function() return vim.g.config_noice end }
  use { "nvim-neo-tree/neo-tree.nvim", branch = "v2.x" }
  use 'MattesGroeger/vim-bookmarks'
  use 'nvim-treesitter/nvim-treesitter'
  use 'sharkdp/fd'
  use 'BurntSushi/ripgrep'
  use 'lewis6991/gitsigns.nvim'
  use 'petertriho/nvim-scrollbar'
  use 'nvim-telescope/telescope-project.nvim'
  use 'renerocksai/calendar-vim'
  use 'renerocksai/telekasten.nvim'
  use 'lukas-reineke/indent-blankline.nvim'
  use 'kevinhwang91/nvim-hlslens'
  use 'folke/neodev.nvim'
  use 'mhinz/vim-startify'
  use { 'noib3/nvim-cokeline', cond = function() return vim.g.config_cokeline end }
  use { 'nvim-telescope/telescope-fzf-native.nvim',
    run = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build" }
end)