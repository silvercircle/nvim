local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  'nvim-lualine/lualine.nvim',
  'noib3/nvim-cokeline',
  -- multiple cursors.
  'mg979/vim-visual-multi',
  -- telescope + extensions, mandatory
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x' },
  'nvim-telescope/telescope-file-browser.nvim',
  'tom-anders/telescope-vim-bookmarks.nvim',
  'FeiyouG/command_center.nvim',
  { 'nvim-telescope/telescope-fzf-native.nvim', build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build" },
  'L3MON4D3/LuaSnip',
  -- cmp + various sources
  'hrsh7th/cmp-cmdline',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-emoji',
  'saadparwaiz1/cmp_luasnip',
  'hrsh7th/cmp-nvim-lsp-signature-help',
  -- lsp
  { 'neovim/nvim-lspconfig' },
  'onsails/lspkind-nvim',
  'j-hui/fidget.nvim',
  'dnlhc/glance.nvim',
  { 'williamboman/mason.nvim', cmd="Mason" },
--  { 'williamboman/mason-lspconfig.nvim' },
  'tpope/vim-liquid',
  'MunifTanjim/nui.nvim',
  'nvim-tree/nvim-web-devicons',
  'alaviss/nim.nvim',
  'nvim-lua/plenary.nvim',
  'MattesGroeger/vim-bookmarks',
  'sharkdp/fd',
  'BurntSushi/ripgrep',
  'mhinz/vim-startify',
  'kevinhwang91/nvim-hlslens',
  'lewis6991/gitsigns.nvim',
  'lukas-reineke/indent-blankline.nvim',
  'petertriho/nvim-scrollbar',
  'stevearc/dressing.nvim',
  'nvim-treesitter/nvim-treesitter',
  { dir = '~/.config/nvim/local_plugin/local_utils' },
  'voldikss/vim-floaterm',
  'preservim/vim-markdown',
  'norcalli/nvim-colorizer.lua',
  'echasnovski/mini.move',
}

local plugins_optional = {
  { 'nvim-neo-tree/neo-tree.nvim', branch = "main", cond = vim.g.features['neotree']['enable'] == true},
  { 'renerocksai/telekasten.nvim', cond = vim.g.features['telekasten']['enable'] == true },
  { 'renerocksai/calendar-vim', cond = vim.g.features['telekasten']['enable'] },
  { 'folke/todo-comments.nvim', cond = vim.g.features['todo']['enable'] == true },
  { 'nvim-tree/nvim-tree.lua', cond = vim.g.features['nvimtree']['enable'] == true },
  { 'jose-elias-alvarez/null-ls.nvim', cond = vim.g.features['null_ls']['enable'] == true }
}

-- for experimental purpose, I use some private forks.
local plugins_private = {
  { dir = '/mnt/shared/data/code/neovim_plugins/quickfavs.nvim' },
  { dir = '/mnt/shared/data/code/neovim_plugins/cmp-wordlist.nvim' },
  { 'silvercircle/symbols-outline.nvim' },
  { dir = '/mnt/shared/data/code/neovim_plugins/nvim-cmp' },
--  { dir='~/.config/nvim/local_plugin/nvim-cmp' }
}

local plugins_official = {
  'simrat39/symbols-outline.nvim',
  'hrsh7th/nvim-cmp',
  'https://gitlab.com/silvercircle74/cmp-wordlist.nvim',
  'https://gitlab.com/silvercircle74/quickfavs.nvim'
}

for _,v in ipairs(plugins_optional) do
  table.insert(plugins, v)
end

--- use private forks of some plugins, not recommended. this is normally disabled
if vim.g.use_private_forks == true then
  for _,v in ipairs(plugins_private) do
    table.insert(plugins, v)
  end
else
  for _,v in ipairs(plugins_official) do
    table.insert(plugins, v)
  end
end

require("lazy").setup(plugins)
