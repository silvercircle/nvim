vim.cmd [[packadd packer.nvim]]
-- all plugins handled by packer. Plug has been retired

return require("packer").startup {
  {
    { "wbthomason/packer.nvim", opt = true },
      "nvim-lualine/lualine.nvim",
    { 'mg979/vim-visual-multi', branch="master" },
    { 'neoclide/coc.nvim', branch="release" },
      'qpkorr/vim-bufkill',
--      'lervag/vimtex',
      'alaviss/nim.nvim',
      'gpanders/editorconfig.nvim',
      'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope.nvim', branch="0.1.x" },
      'nvim-telescope/telescope-file-browser.nvim',
      'tom-anders/telescope-vim-bookmarks.nvim',
      'MattesGroeger/vim-bookmarks',
      'nvim-treesitter/nvim-treesitter',
      'nvim-treesitter/playground',
 --     'p00f/nvim-ts-rainbow',
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
      'folke/noice.nvim',
      'sharkdp/fd',
      'BurntSushi/ripgrep',
      'ryanoasis/vim-devicons',
      'nvim-tree/nvim-web-devicons',
      'sainnhe/sonokai',
      'preservim/nerdtree',
      'lewis6991/gitsigns.nvim',
--      'lewis6991/satellite.nvim',
      'petertriho/nvim-scrollbar',
      'mtth/scratch.vim',
      'norcalli/nvim-colorizer.lua',
      'nvim-telescope/telescope-project.nvim',
      'm-demare/hlargs.nvim',
      'renerocksai/calendar-vim',
      'goolord/alpha-nvim',
      'nvim-telescope/telescope-media-files.nvim',
      'renerocksai/telekasten.nvim',
      'lukas-reineke/indent-blankline.nvim',
      'fannheyward/telescope-coc.nvim',
--      'Darazaki/indent-o-matic',
      'kevinhwang91/nvim-hlslens',
    { 'nvim-telescope/telescope-fzf-native.nvim', run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' },
    { 'windwp/nvim-autopairs', config = function() require("nvim-autopairs").setup({
          map_cr = false,
          map_bs = false
       }) end }
  }
}