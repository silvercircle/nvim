# My Neovim Config aka „Dotfiles”

This is my growing and constantly changing configuration directory for Neovim. The repository contains 
two branches with different setups.

- The `main` branch. This is a bleeding edge setup using native LSP, CMP (for completion), NeoTree 
  (as NERDTree replacement), luasnip and Glance. This is about 90% LUA and some tiny remains of 
  Vimscript. The majority of plugins in use are written in LUA. The color theme is still an old Vimscript 
  theme, but almost everything else is LUA.

- The `coc` branch. This is somewhat more traditional, using NERDTree and CoC for code assistance and 
  snippet handling. It is  relatively stable but a bit outdated and depends heavily on NodeJS and NPM 
  (due to Coc). It is currently unmaintained, but should work ok.

All branches use lots of Telescope stuff and Tree-Sitter for syntax highlighting. **The minimum required 
Neovim version is 0.8**.

# Some words of warning

These dotfiles are likely **not to work out of the box**. They are heavily customized for *Linux only* 
and some things won't work on Windows and probably not on macOS. These problems should, however, be easy 
to fix, particularly in `lua/config.lua`.

The main branch (LSP) is modular and uses the Lazy plugin manger to load almost all plugins lazily when 
they are needed. This leads to fast startup times.

The coc branch is still based on Packer so the two can actually exist in parallel without overwriting 
their plugin configuration.

## LSP Config (main branch)

This is my (experimental) LSP configuration for Neovim. It should be considered a fast moving target and 
plugin configuration might change. This configuration is built around:

* Native Neovim LSP together with [mason](https://github.com/williamboman/mason.nvim), 
  [lspconfig](https://github.com/neovim/nvim-lspconfig) and 
  [null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim). Mason is optional for comfortably
  installing and updating language servers, but essentially, nvim-lspconfig is enough.
  The configuration has presets for the following languages:

  By default, Mason is optional and language servers configured manually via lspconfig.

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
    and project management tool sbt. An easier way to set up Neovim for Scala programming might be the 
    separate plugin [nvim-metals](https://github.com/scalameta/nvim-metals).
  * VimScript via vimls.


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

* [Nvim-Tree](https://github.com/nvim-tree/nvim-tree.luam) - a file system browser like NERDTree, but 
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
file for more information. Basically, it's possible to enable/disable some plugins and to customize some 
color settings. This is still in an early stage, more will follow.

## Custom mappings:

Lots of, actually. Please see lua/vim_mappings.lua for details. These are only custom mappings on top of 
already existing plugin keymaps.

## Color Theme

It is a customized variant of the [Sonokai theme](https://github.com/sainnhe/sonokai).

## How it looks?

![Screenshot](https://i.imgur.com/oz21okb.png)

![Screenshot 2](https://i.imgur.com/lXvfJQk.png)

