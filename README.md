# My Neovim Config

This is my growing and constantly changing configuration directory for Neovim. The repository contains 
two branches with different setups.

- The `main` branch. This is a bleeding edge setup using native LSP, CMP (for autocompletion), NeoTree 
  (as NERDTree replacement), luasnip and Glance.

- The `coc` branch. This is somewhat more traditional, using NERDTree and CoC for code assistance and 
  snippet handling. It is  relatively stable but a bit outdated and depends heavily on NodeJS and NPM 
  (due to Coc).

- The `minimal` branch. This is a fast-moving unstable testing environment not meant to be used for a 
  production configuration. It's unstable at times and might disable important plugins for testing 
  purposes.

All branches use lots of Telescope stuff and Tree-Sitter for syntax highlighting. **The minimum required 
Neovim version is 0.8**.

The main branch (LSP) is modular and it is fairly easy to disable certain features. See `config.lua` for 
more information. It is advised to run a `PackerSync` after adding or removing features. When removing 
features, some things may break until you perform a `PackerSync`.

You can switch by checking out either `main` or `coc`, but since the plugin configuration is vastly 
different, a **PackerSync** is required after switching branches. I use only packer for plugin setup, so 
it will keep your `~/.local/share/nvim/site` directory tidied up and remove unused plugins. The first 
start after switching the config branch will throw a lot of errors, but after syncing all plugins, all 
should be fine again.

## LSP Config (main branch)

This is my (experimental) LSP configuration for Neovim. It should be considered a fast moving target and 
plugin configuration might change. This configuration is built around:

* Native Neovim LSP together with [mason](https://github.com/williamboman/mason.nvim), 
  [lspconfig](https://github.com/neovim/nvim-lspconfig) and 
  [null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim) These plugins provide all the LSP support 
  and allow for easy setup of language servers. The configuration has presets for the following 
  languages:

  * Lua (sumneko_lua LSP)
  * Python (pyright)
  * C/C++  (clangd)
  * Rust   (rust_analyzer)
  * Dart   (dartls)
  * Nim    (nimlsp)
  * JavaScript, TypeScript (tsserver)
  * CSS    (cssls)
  * LaTeX  (texlab)
  * C# (omnisharp-roslyn)
  * Scala (via metals, sbt and coursier). This requires to setup quite some stuff, a working scala 
    environment (easiest way is to use SDKMAN), the Coursier scala package manager and the scala build 
    and project management tool sbt.

* [CMP](https://github.com/hrsh7th/nvim-cmp) for auto-completion with various sources 
  [lsp](https://github.com/hrsh7th/cmp-nvim-lsp), [signature 
  help](https://github.com/hrsh7th/cmp-nvim-lsp-signature-help), snippets via Luasnip and, 
  [emojis](https://github.com/hrsh7th/cmp-emoji) 

* [Telescope](https://github.com/nvim-telescope/telescope.nvim) for all kind of cool stuff. Pick recent 
  files, select open buffer, find files, LSP references, diagnostics and more. Telescope is one of the 
  absolute must-have plugins for Neovim, IMHO. Some functionality is provided by extensions.

* [Glance](https://github.com/DNLHC/glance.nvim) (for cool VSCode-like definition and references peeks)

* [Treesitter](https://github.com/nvim-treesitter). Should be standard nowadays, it just gives way better 
  syntax highlighting and syntax-based folding.

* [Luasnip](https://github.com/L3MON4D3/LuaSnip) for snippets.

* A custom colorscheme based on sonokai

* [Lualine](https://github.com/nvim-lualine/lualine.nvim), a blazingly fast and customizable status- and 
  tab line.
  
* Various utilities, editorconfig, scrollbar, [gitsigns](https://github.com/lewis6991/gitsigns.nvim), 
  hlslens, [indent guides](https://github.com/lukas-reineke/indent-blankline.nvim), 
  [startify](https://github.com/mhinz/vim-startify) (a start screen), 
  [neodev](https://github.com/folke/neodev.nvim) to help with Lua development on Neovim and more.

* [Neotree](https://github.com/nvim-neo-tree/neo-tree.nvim) - a file system browser like NERDTree, but 
  much faster and written in Lua.

Nim support is manually installed via nimlsp.

## Requirements

* Neovim 0.8 or later.

* A NERD Font. Optional, but things like the file browser, the status- and tab line and some other things 
  will look much better with such a font. [NERDfonts](https://www.nerdfonts.com/) provide the necessary 
  symbols and icons for text-based console applications.

* Some dependencies like ripgrep and fd. These packages must be installed on OS level.

## Customization

`lua/config.lua` contains some global variables to customize the setup. Refer to the comments in that 
file for more information. Basically, it's possible to enable/disable some plugins and to customize some color 
settings. This is still in an early stage, more will follow.

## Custom mappings:

Lots of, actually. Please see lua/vim_mappings.lua for details. These are only custom mappings on top of 
already existing plugin keymaps.

## Color Theme

It is a customized variant of the [Sonokai theme](https://github.com/sainnhe/sonokai).

## How it looks?

![Screenshot](https://github.com/silvercircle/nvim/blob/main/screenshot.png?raw=True)

## List of plugins in use by this config.

```lua
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
```