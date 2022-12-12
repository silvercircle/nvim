vim.cmd([[packadd packer.nvim]])
-- all plugins handled by packer. Plug has been retired
return require("packer").startup({
  {
    {
      'wbthomason/packer.nvim', opt = true
    },
      'nvim-lualine/lualine.nvim',
    {
      'mg979/vim-visual-multi', branch = "master"
    },
    'hrsh7th/nvim-cmp',
    --      'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'L3MON4D3/LuaSnip',
    'nvim-tree/nvim-web-devicons',
    'sainnhe/sonokai',
    'saadparwaiz1/cmp_luasnip',
 --   'uga-rosa/cmp-dictionary',
    'jose-elias-alvarez/null-ls.nvim',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',
    'silvercircle/symbols-outline.nvim',
    'dnlhc/glance.nvim',
    'j-hui/fidget.nvim',
    'onsails/lspkind-nvim',
    'alaviss/nim.nvim',
    'gpanders/editorconfig.nvim',
    'nvim-lua/plenary.nvim',
    'hrsh7th/cmp-nvim-lsp-signature-help',
    {
      'nvim-telescope/telescope.nvim', branch = '0.1.x'
    },
    'nvim-telescope/telescope-file-browser.nvim',
    'tom-anders/telescope-vim-bookmarks.nvim',
    'MunifTanjim/nui.nvim',
    --      'rcarriga/nvim-notify',
    --      'folke/noice.nvim',
    {
      "nvim-neo-tree/neo-tree.nvim", branch = "v2.x"
    },
    'MattesGroeger/vim-bookmarks',
    'nvim-treesitter/nvim-treesitter',
    'sharkdp/fd',
    'BurntSushi/ripgrep',
    'lewis6991/gitsigns.nvim',
    'petertriho/nvim-scrollbar',
    'nvim-telescope/telescope-project.nvim',
    'renerocksai/calendar-vim',
    'renerocksai/telekasten.nvim',
    'lukas-reineke/indent-blankline.nvim',
    'kevinhwang91/nvim-hlslens',
    'folke/neodev.nvim',
    'mhinz/vim-startify',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      run = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    },
  },
})
