vim.cmd([[packadd packer.nvim]])
return require("packer").startup(function(use)
  use { 'wbthomason/packer.nvim', opt = true }
  if vim.g.features["lualine"]['enable'] == true then
    use 'nvim-lualine/lualine.nvim'
  end
  -- multiple cursors.
  use { 'mg979/vim-visual-multi', branch = "master" }
  if vim.g.features["lsp"]['enable'] == true then
    if vim.g.features['mason']['enable'] == true then
      use 'williamboman/mason.nvim'
      use 'williamboman/mason-lspconfig.nvim'
    end
    if vim.g.use_private_forks == true then
      use '~/.config/nvim/local_plugin/my_nvim-lspconfig'
    else
      use 'neovim/nvim-lspconfig'
    end
    use 'onsails/lspkind-nvim'
    -- the following two belong to the lsp group. They are useless without the LSP client
    use 'j-hui/fidget.nvim'
    use 'dnlhc/glance.nvim'
    -- outline view depends on lsp. It is completely useless without.
    if vim.g.features['outline']['enable'] == true then
      use 'silvercircle/symbols-outline.nvim'
    end
    -- same for lspsaga
    if vim.g.features['lspsaga']['enable'] == true then
      use 'glepnir/lspsaga.nvim'
    end
  end
  -- while cmp does not make much sense without lsp, some things like snippets, emojis, command-line
  -- and path completion will still work.
  -- that's why it's separated from lsp and grouped with luasnip.
  if vim.g.features['cmp']['enable'] == true then
    use 'L3MON4D3/LuaSnip'
    -- use the local version of nvim-cmp. Makes tweaking easier.
    if vim.g.use_private_forks == true then
      use '~/.config/nvim/local_plugin/nvim-cmp'
    else
      use 'hrsh7th/nvim-cmp'
    end
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-emoji'
    use 'saadparwaiz1/cmp_luasnip'
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
  end
  -- some generic plugins
  use 'tpope/vim-liquid'             -- markdown / liquid mode, mainly for jekyll pages
  use 'MunifTanjim/nui.nvim'
  use 'nvim-tree/nvim-web-devicons'
  use 'alaviss/nim.nvim'
  use 'gpanders/editorconfig.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'MattesGroeger/vim-bookmarks'
  use 'sharkdp/fd'
  use 'BurntSushi/ripgrep'
  use 'mhinz/vim-startify'
  use 'kevinhwang91/nvim-hlslens'
  if vim.g.features["telescope"]['enable'] == true then
    use { 'nvim-telescope/telescope.nvim', branch = '0.1.x' }
    use 'nvim-telescope/telescope-file-browser.nvim'
    use 'tom-anders/telescope-vim-bookmarks.nvim'
    use 'FeiyouG/command_center.nvim'
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build" }
  end
  -- filesystem tree. Only enable ONE of the following, either neo-tree or nvim-tree. I prefer the latter
  if vim.g.features['nvimtree']['enable'] == true then
    use 'nvim-tree/nvim-tree.lua'
  end
  if vim.g.features['neotree']['enable'] == true then
    use { 'nvim-neo-tree/neo-tree.nvim', branch = "main" }
  end
  -- treesitter
  if vim.g.features["treesitter"]['enable'] == true then
    use 'nvim-treesitter/nvim-treesitter'
    -- playground depends on tree-sitter and does nothing standalone.
    if vim.g.features['treesitter_playground']['enable'] == true then
      use 'nvim-treesitter/playground'
    end
  end
  if vim.g.features["gitsigns"]['enable'] == true then
    use 'lewis6991/gitsigns.nvim'
  end
  if vim.g.features["scrollbar"]['enable'] == true then
    use 'petertriho/nvim-scrollbar'
  end
  if vim.g.features["indent_blankline"]['enable'] == true then
    use 'lukas-reineke/indent-blankline.nvim'
  end
  if vim.g.features["cokeline"]['enable'] == true then
    use { 'noib3/nvim-cokeline' }
  end
  if vim.g.features['dressing']['enable'] == true then
    use 'stevearc/dressing.nvim'
  end
  if vim.g.features['todo']['enable'] == true then
    use 'folke/todo-comments.nvim'
  end
  if vim.g.features['orgmode']['enable'] == true then
    use 'nvim-orgmode/orgmode'
  end
  if vim.g.features['telekasten']['enable'] == true then
    use 'renerocksai/telekasten.nvim'
    use 'renerocksai/calendar-vim'
  end
  if vim.g.features['sidebar']['enable'] then
    if vim.g.use_private_forks == true then
      use 'silvercircle/sidebar.nvim'
    else
      use 'sidebar-nvim/sidebar.nvim'
    end
  end
  use '~/.config/nvim/local_plugin/quickfavs'
  use '~/.config/nvim/local_plugin/local_utils'
  use 'voldikss/vim-floaterm'
  use 'preservim/vim-markdown'
end)

