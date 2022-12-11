# My Neovim Config

This is my growing and constantly changing configuration directory for Neovim. It basically contains two 
branches:

* The main branch. This is somewhat more traditional, using NERDTree and CoC for code assistance. It is 
  relatively stable.

* The **lsp** branch. This is a bleeding edge setup using native LSP, CMP (for autocompletion), NeoTree 
  (as NERDTree replacement), luasnip and Glance.

Both branches use lots of Telescope stuff.

You can switch by checking out either main or lsp, but since the plugin configuration is vastly 
different, a **PackerSync** is required after switching branches. I use only packer for plugin setup, so 
it will keep your ~/.local/share/nvim/site directory clean and remove unused plugins. The first start 
after switching the config branch will throw a lot of errors, but after syncing all plugins, all should 
be fine again.

## LSP Config

This is my (experimental) LSP configuration for Neovim. It is built around:

* native Neovim LSP
* CMP for auto-completion with various sources (lsp, buffer, dictionaries, snippets)
* Telescope for all kind of cool stuff. Pick recent files, select open buffer, find files, LSP 
  references, diagnostics and more. Telescope is one of the absolute must-have plugins for Neovim, IMHO.
* Glance (for cool VSCode-like definition and references peeks)
* Treesitter. Should be standard nowadays, it just gives way better syntax highlighting and syntax-based 
  folding.
* Luasnip for snippets.
* A custom colorscheme based on sonokai
* Lualine, a blazingly fast and customizable status- and tab line.
* Various utilities, editorconfig, scrollbar, gitsigns and more.


Nim support is manually installed via nimlsp.

## Custom mappings:

|  KEY      |      Mode(s)       | Function                               |
| --------- | ------------------ | -------------------------------------- |
|C-x C-q    | Normal, Insert     | Save (if modified), close buffer       |
|C-x C-s    | Normal, Insert     | Save (if modified)                     |
|C-x C-c    | Normal, Insert     | Close buffer (will warn when modified) |
|C-x C-h    | Normal, Insert     | execute nohl (cancel highlights)       |
|SH         | Normal             | Show Treesitter highlight class        |
|C-f C-a    | Insert             | Toggle autowrap (a formatoption)       |
|C-f C-w    | Insert             | Toggle w format option                 |
|C-f C-t    | Insert             | Toggle t format option                 |
|C-f 1      | Insert             | autowrap on (+a+w)                     |
|C-f 2      | Insert             | Autowrap off (-a-w)                    |
|C-f a      | Insert             | Full autorwrap                         |
|C-f f      | Insert             | Disable all Autowrap modes             |

## List of plugins required.

```lua
return require("packer").startup {
  {
    { "wbthomason/packer.nvim", opt = true },
      "nvim-lualine/lualine.nvim",
    { 'mg979/vim-visual-multi', branch="master" },
      'qpkorr/vim-bufkill',
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'nvim-tree/nvim-web-devicons',
      'sainnhe/sonokai',
      'saadparwaiz1/cmp_luasnip',
--      'jose-elias-alvarez/null-ls.nvim',
      'neovim/nvim-lspconfig',
      'williamboman/nvim-lsp-installer',
      'silvercircle/symbols-outline.nvim',
      'dnlhc/glance.nvim',
      'ray-x/lsp_signature.nvim',
      'j-hui/fidget.nvim',
      'onsails/lspkind-nvim',
      'alaviss/nim.nvim',
      'gpanders/editorconfig.nvim',
      'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope.nvim', branch="0.1.x" },
      'nvim-telescope/telescope-file-browser.nvim',
      'tom-anders/telescope-vim-bookmarks.nvim',
      'MunifTanjim/nui.nvim',
--      'rcarriga/nvim-notify',
      'folke/noice.nvim',
    { 'nvim-neo-tree/neo-tree.nvim', branch = "v2.x" },
      'MattesGroeger/vim-bookmarks',
      'nvim-treesitter/nvim-treesitter',
      'nvim-treesitter/playground',
      'sharkdp/fd',
      'BurntSushi/ripgrep',
      'lewis6991/gitsigns.nvim',
      'petertriho/nvim-scrollbar',
      'mtth/scratch.vim',
      'norcalli/nvim-colorizer.lua',
      'nvim-telescope/telescope-project.nvim',
      'renerocksai/calendar-vim',
      'goolord/alpha-nvim',
      'nvim-telescope/telescope-media-files.nvim',
      'renerocksai/telekasten.nvim',
      'lukas-reineke/indent-blankline.nvim',
      'kevinhwang91/nvim-hlslens',
      'rafamadriz/friendly-snippets',
    { 'nvim-telescope/telescope-fzf-native.nvim', run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' },
      'windwp/nvim-autopairs',
    
  }
}
```