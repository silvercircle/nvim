vim.cmd([[packadd packer.nvim]])
-- all plugins handled by packer. Plug has been retired
return require("packer").startup(function(use)
  use { 'wbthomason/packer.nvim', opt = true }
  if vim.g.features["lualine"] ~= nil then
    use 'nvim-lualine/lualine.nvim'
  end
  use { 'mg979/vim-visual-multi', branch = "master" }
  if vim.g.features["lsp"] ~= nil then
    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'
    use 'neovim/nvim-lspconfig'
    use 'onsails/lspkind-nvim'
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-emoji'
    use 'saadparwaiz1/cmp_luasnip'
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
  end
  use 'L3MON4D3/LuaSnip'
  use 'MunifTanjim/nui.nvim'
  use 'nvim-tree/nvim-web-devicons'
  use 'silvercircle/symbols-outline.nvim'
  use 'dnlhc/glance.nvim'
  use 'j-hui/fidget.nvim'
  use 'alaviss/nim.nvim'
  use 'gpanders/editorconfig.nvim'
  use 'nvim-lua/plenary.nvim'
  if vim.g.features["telescope"] ~= nil then
    use { 'nvim-telescope/telescope.nvim', branch = '0.1.x' }
    use 'nvim-telescope/telescope-file-browser.nvim'
    use 'tom-anders/telescope-vim-bookmarks.nvim'
    use 'nvim-telescope/telescope-project.nvim'
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build" }
  end
  if vim.g.config_nvimtree then
    use 'nvim-tree/nvim-tree.lua'
  end
  if vim.g.config_neotree then
    use { "nvim-neo-tree/neo-tree.nvim", branch = "v2.x" }
  end
--  use { "nvim-neo-tree/neo-tree.nvim", branch = "v2.x" }
  use 'MattesGroeger/vim-bookmarks'
  if vim.g.features["treesitter"] ~= nil then
    use 'nvim-treesitter/nvim-treesitter'
  end
  use 'sharkdp/fd'
  use 'BurntSushi/ripgrep'
  if vim.g.features["gitsigns"] ~= nil then
    use 'lewis6991/gitsigns.nvim'
  end
  if vim.g.features["scrollbar"] ~= nil then
    use 'petertriho/nvim-scrollbar'
  end
  if vim.g.features["indent-blankline"] ~= nil then
    use 'lukas-reineke/indent-blankline.nvim'
  end
  use 'renerocksai/calendar-vim'
  use 'renerocksai/telekasten.nvim'
  use 'mhinz/vim-startify'
  use 'kevinhwang91/nvim-hlslens'
  if vim.g.features["cokeline"] ~= nil then
    use { 'noib3/nvim-cokeline' }
  end
  use 'stevearc/dressing.nvim'
end)