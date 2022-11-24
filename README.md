# My Neovim Config


## Coc
I still use coc for LSP support and all the fancy features like auto-complete, code navigation and other 
things. The following extensions are installed using the **CocInstall** command

*  @yaegassy/coc-pylsp Current version 0.7.1 is up to date.
*  coc-json Current version 1.7.0 is up to date.
*  coc-clangd Current version 0.27.0 is up to date.
*  coc-texlab Current version 3.2.0 is up to date.
*  coc-dictionary Current version 1.2.2 is up to date.
*  coc-snippets Current version 3.1.5 is up to date.
*  coc-css Current version 2.0.0 is up to date.
*  coc-dlang Current version 1.1.2 is up to date.
*  coc-yaml Current version 1.9.0 is up to date.
*  coc-html Current version is up to date

Nim support is manually installed via nimlsp.

## Custom mappings:

|  KEY      |      Mode(s)       | Function                               |
| --------- | ------------------ | -------------------------------------- |
|C-x C-q   | Normal, Insert     | Save (if modified), close buffer       |
|C-x C-s   | Normal, Insert     | Save (if modified)                     |
|C-x C-c   | Normal, Insert     | Close buffer (will warn when modified) |
|C-x C-h   | Normal, Insert     | execute nohl (cancel highlights)       |
|SH        | Normal             | Show Treesitter highlight class        |
|C-f C-a   | Insert             | Toggle autowrap (a formatoption)       |
|C-f C-w   | Insert             | Toggle w format option                 |
|C-f C-t   | Insert             | Toggle t format option                 |
|C-f 1      | Insert             | autowrap on (+a+w)                     |
|C-f 2      | Insert             | Autowrap off (-a-w)                    |
|C-f a      | Insert             | Full autorwrap                         |
|C-f f      | Insert             | Disable all Autowrap modes             |

## List of non-CoC plugins:

```lua
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
      'p00f/nvim-ts-rainbow',
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
      'Darazaki/indent-o-matic',
      'kevinhwang91/nvim-hlslens',
    { 'nvim-telescope/telescope-fzf-native.nvim', run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' },
    { 'windwp/nvim-autopairs', config = function() require("nvim-autopairs").setup({
          map_cr = false,
          map_bs = false
       }) end }
  }
}
```
