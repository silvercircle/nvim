vim.cmd [[packadd packer.nvim]]

return require("packer").startup {
  {
    { "wbthomason/packer.nvim", opt = true },
      "nvim-lualine/lualine.nvim",
    { 'mg979/vim-visual-multi', branch="master" },
    { 'neoclide/coc.nvim', branch="release" },
      'qpkorr/vim-bufkill',
      'lervag/vimtex',
      'alaviss/nim.nvim',
      'gpanders/editorconfig.nvim',
      'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope.nvim', branch="0.1.x", tag="0.1.0" },
      'nvim-telescope/telescope-file-browser.nvim',
      'tom-anders/telescope-vim-bookmarks.nvim',
      'MattesGroeger/vim-bookmarks',
      'fannheyward/telescope-coc.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-treesitter/playground',
      'p00f/nvim-ts-rainbow',
      'sharkdp/fd',
      'BurntSushi/ripgrep',
      'ryanoasis/vim-devicons',
      'nvim-tree/nvim-web-devicons',
      'windwp/nvim-autopairs',
      'lewis6991/impatient.nvim',
      'sainnhe/sonokai',
      'preservim/nerdtree',
      'lewis6991/gitsigns.nvim',
      'petertriho/nvim-scrollbar',
      'mtth/scratch.vim',
      'norcalli/nvim-colorizer.lua',
      'goolord/alpha-nvim',
  }
}

