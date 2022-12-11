# My Neovim Config

This is my growing and constantly changing configuration directory for Neovim. The repository contains 
two branches with different setups.

* The `main` branch. This is a bleeding edge setup using native LSP, CMP (for autocompletion), NeoTree 
  (as NERDTree replacement), luasnip and Glance.

* The `coc` branch. This is somewhat more traditional, using NERDTree and CoC for code assistance and 
  snippet handling. It is  relatively stable but a bit outdated and depends heavily on NodeJS and NPM (due to Coc).

Both branches use lots of Telescope stuff and Tree-Sitter for syntax highlighting. **The minimum required 
Neovim version is 0.8**.

You can switch by checking out either `main` or `coc`, but since the plugin configuration is vastly 
different, a **PackerSync** is required after switching branches. I use only packer for plugin setup, so 
it will keep your `~/.local/share/nvim/site` directory tidied up and remove unused plugins. The first start 
after switching the config branch will throw a lot of errors, but after syncing all plugins, all should 
be fine again.

## LSP Config (main branch)

This is my (experimental) LSP configuration for Neovim. It should be considered a fast moving target and 
plugin configuration might change. This configuration is built around:

* Native Neovim LSP together with [mason](https://github.com/williamboman/mason.nvim), [lspconfig](https://github.com/neovim/nvim-lspconfig),
  [null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim) and 
  [lsp-signature](https://github.com/ray-x/lsp_signature.nvim). These plugins provide all the LSP support 
  and allow for easy setup of language servers. The configuration has presets for the following 
  languages:
  * Lua (sumneko_lua LSP)
  * Python (pyright)
  * C/C++  (clangd)
  * Rust   (rust_analyzer)
  * Dart   (dartls)
  * Nim    (nimlsp)
  * JS     (tsserver)
  * CSS    (cssls)
  * LaTeX  (texlab)
* [CMP](https://github.com/hrsh7th/nvim-cmp) for auto-completion with various sources (lsp, dictionaries, snippets)
* [Telescope](https://github.com/nvim-telescope/telescope.nvim) for all kind of cool stuff. Pick recent files, select open buffer, find files, LSP 
  references, diagnostics and more. Telescope is one of the absolute must-have plugins for Neovim, IMHO.
  Some functionality is provided by extensions.
* [Glance](https://github.com/DNLHC/glance.nvim) (for cool VSCode-like definition and references peeks)
* [Treesitter](https://github.com/nvim-treesitter). Should be standard nowadays, it just gives way better syntax highlighting and syntax-based 
  folding.
* [Luasnip](https://github.com/L3MON4D3/LuaSnip) for snippets.
* A custom colorscheme based on sonokai
* [Lualine](https://github.com/nvim-lualine/lualine.nvim), a blazingly fast and customizable status- and tab line.
* Various utilities, editorconfig, scrollbar, [gitsigns](https://github.com/lewis6991/gitsigns.nvim), hlslens, [indent 
  guides](https://github.com/lukas-reineke/indent-blankline.nvim), 
  [startify](https://github.com/mhinz/vim-startify) (a start 
  screen), [neodev](https://github.com/folke/neodev.nvim) to help with Lua development on Neovim and more.
* [Neotree](https://github.com/nvim-neo-tree/neo-tree.nvim) - a file system browser like NERDTree, but much faster and written in Lua.

Nim support is manually installed via nimlsp.

## Custom mappings:

Lots of, actually. Please see lua/vim_mappings.lua for details. These are only custom mappings on top of 
already existing plugin keymaps.

## Color Theme

It is a customized variant of the [Sonokai theme](https://github.com/sainnhe/sonokai).

## List of plugins in use by this config.

```lua
return require("packer").startup({
  {
    {
      "wbthomason/packer.nvim", opt = true
    },
    "nvim-lualine/lualine.nvim",
    {
      "mg979/vim-visual-multi", branch = "master"
    },
    "qpkorr/vim-bufkill",
    "hrsh7th/nvim-cmp",
    --      'hrsh7th/cmp-buffer',
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "nvim-tree/nvim-web-devicons",
    "sainnhe/sonokai",
    "saadparwaiz1/cmp_luasnip",
    "uga-rosa/cmp-dictionary",
    'jose-elias-alvarez/null-ls.nvim',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    "neovim/nvim-lspconfig",
    "silvercircle/symbols-outline.nvim",
    "dnlhc/glance.nvim",
    "ray-x/lsp_signature.nvim",
    "j-hui/fidget.nvim",
    "onsails/lspkind-nvim",
    "alaviss/nim.nvim",
    "gpanders/editorconfig.nvim",
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope.nvim", branch = "0.1.x"
    },
    "nvim-telescope/telescope-file-browser.nvim",
    "tom-anders/telescope-vim-bookmarks.nvim",
    "MunifTanjim/nui.nvim",
    --      'rcarriga/nvim-notify',
    --      'folke/noice.nvim',
    {
      "nvim-neo-tree/neo-tree.nvim", branch = "v2.x"
    },
    "MattesGroeger/vim-bookmarks",
    "nvim-treesitter/nvim-treesitter",
    "nvim-treesitter/playground",
    "sharkdp/fd",
    "BurntSushi/ripgrep",
    "lewis6991/gitsigns.nvim",
    "petertriho/nvim-scrollbar",
    "nvim-telescope/telescope-project.nvim",
    "renerocksai/calendar-vim",
--  "goolord/alpha-nvim",
    "renerocksai/telekasten.nvim",
    "lukas-reineke/indent-blankline.nvim",
    "kevinhwang91/nvim-hlslens",
    'folke/neodev.nvim',
    'mhinz/vim-startify',
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      run = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    },
    --      'windwp/nvim-autopairs',
  }
})
```