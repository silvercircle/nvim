vim.cmd([[packadd packer.nvim]])
-- all plugins handled by packer. Plug has been retired
return require("packer").startup(function(use)
  use { 'wbthomason/packer.nvim', opt = true }
  if vim.g.features["lualine"]['enable'] == true then
    use 'nvim-lualine/lualine.nvim'
  end
  use { 'mg979/vim-visual-multi', branch = "master" }
  use 'L3MON4D3/LuaSnip'
  if vim.g.features["lsp"]['enable'] == true then
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
  use 'MunifTanjim/nui.nvim'
  use 'nvim-tree/nvim-web-devicons'
  if vim.g.features['outline']['enable'] == true then
    use 'silvercircle/symbols-outline.nvim'
  end
  use 'dnlhc/glance.nvim'
  use 'j-hui/fidget.nvim'
  use 'alaviss/nim.nvim'
  use 'gpanders/editorconfig.nvim'
  use 'nvim-lua/plenary.nvim'
  if vim.g.features["telescope"]['enable'] == true then
    use { 'nvim-telescope/telescope.nvim', branch = '0.1.x' }
    use 'nvim-telescope/telescope-file-browser.nvim'
    use 'tom-anders/telescope-vim-bookmarks.nvim'
    use 'nvim-telescope/telescope-project.nvim'
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build" }
  end
  if vim.g.features['nvimtree']['enable'] == true then
    use 'nvim-tree/nvim-tree.lua'
  end
  if vim.g.features['neotree']['enable'] == true then
    use { "nvim-neo-tree/neo-tree.nvim", branch = "v2.x" }
  end
  use 'MattesGroeger/vim-bookmarks'
  if vim.g.features["treesitter"]['enable'] == true then
    use 'nvim-treesitter/nvim-treesitter'
  end
  if vim.g.features['treesitter_playground']['enable'] == true then
    use 'nvim-treesitter/playground'
  end
  use 'sharkdp/fd'
  use 'BurntSushi/ripgrep'
  if vim.g.features["gitsigns"]['enable'] == true then
    use 'lewis6991/gitsigns.nvim'
  end
  if vim.g.features["scrollbar"]['enable'] == true then
    use 'petertriho/nvim-scrollbar'
  end
  if vim.g.features["indent_blankline"]['enable'] == true then
    use 'lukas-reineke/indent-blankline.nvim'
  end
  use 'renerocksai/calendar-vim'
  use 'renerocksai/telekasten.nvim'
  use 'mhinz/vim-startify'
  use 'kevinhwang91/nvim-hlslens'
  if vim.g.features["cokeline"]['enable'] == true then
    use { 'noib3/nvim-cokeline' }
  end
  if vim.g.features['dressing']['enable'] == true then
    use 'stevearc/dressing.nvim'
  end
  if vim.g.features['todo']['enable'] == true then
    use 'folke/todo-comments.nvim'
  end
end)

-- TODO: test and make this useful