-- configuration variables

-- table of features. You can set a feature to false and then restart vim. Ideally you should run
-- a PackerSync to clean up the plugin folder. This is mandatory when changing features from false to
-- true in order to install potentially missing plugins.

-- I currently do not use optional or conditional packer features. That might change at some point.
-- To add or remove a plugin, just change its enable status

-- NOTE: the environment variable NVIM_USE_PRIVATE_FORKS must be set (to anything) in order to use the private
-- forks of some plugins. 

-- the following features are optional modules
-- by default lsp, cmp, telescope, gitsigns, scrollbar and indent-blankline are always enabled

vim.g.features = {
  noice = { enable = false, module = 'setup_noice' },                     -- use noice for notifications
  -- please use ONLY ONE of te following two. Using both wont hurt but will be a waste.
  -- personally i prefer Neotree, but both plugins are fine. Matter of personal preference.
  neotree = { enable = true, module = '' },                               -- setup is done in lazyload
  null_ls = { enable = false, module = 'setup_null_ls' },                 -- null-ls for linting, formatting and more lsp features
  todo = { enable = true, module = 'setup_todo' }
}

local env_plain = os.getenv("NVIM_PLAIN")

vim.g.config = {
  telescope_fname_width = 140,
  theme_variant = 'warm',
  nightly = vim.fn.has("nvim-0.9"),
  use_cokeline = true,
  telescope_dropdown='bottom',
  accent_color = '#7faf00',
  alt_accent_color = '#00af7f',
  minipicker_height = 0.8,
  minipicker_width = 50,
  minipicker_preview_height = 10,
  minipicker_iprefix = "#>",
  minipicker_anchor = "N",
  -- submodules
  mason = true,                   -- setup in setup_lsp.lua
  neodev = false,                 -- setup in setup_lsp.lua
  treesitter_playground = false,  -- no setup required, optional
  treesitter = true,               -- default plugin
  plain = env_plain ~= nil and true or false
}

vim.g.accent_color = vim.g.config.accent_color
vim.g.alt_accent_color = vim.g.config.alt_accent_color

-- theme variant can be either cold or warm.
-- cold has slight blue-ish tint in the background colors, while warm is more reddish
-- the default is warm
vim.g.theme_variant = 'warm'

-- vim.g.theme_variant = 'cold'

local masonbinpath = vim.fn.stdpath('data') .. '/mason/bin/'
local localbin = vim.fn.getenv('HOME') .. '/.local/bin/'
local homepath = vim.fn.getenv('HOME')

-- this table holds full path information for lsp server binaries. They can be installed with mason or
-- manually. setup_lsp.lua does all the work. Mason and mason-lspconfig are optional. They allow easy installation
-- and upgrading of your lsp servers, but if you do this manually, nvim-lspconfig alone is enough.

vim.g.lsp_server_bin = {
  phpactor = '/usr/local/bin/phpactor',
  rust_analyzer = masonbinpath .. 'rust-analyzer',
  gopls = localbin .. 'gopls',
  nimls = homepath .. '/.nimble/bin/nimlsp',
  texlab = localbin .. 'texlab',
  clangd = '/usr/bin/clangd',
  dartls = '/opt/flutter/bin/dart',
  vimlsp = masonbinpath .. 'vim-language-server',
  omnisharp = masonbinpath .. 'omnisharp',
  metals = '/home/alex/.local/share/coursier/bin/metals',
  pyright = masonbinpath .. 'pyright-langserver',
  sumneko_lua = masonbinpath .. 'lua-language-server',
  serve_d = localbin .. 'serve-d',
  cssls = masonbinpath .. 'vscode-css-language-server',
  tsserver = masonbinpath .. 'typescript-language-server',
  html = masonbinpath .. 'vscode-html-language-server',
  yamlls = masonbinpath .. 'yaml-language-server',
  als = masonbinpath .. 'ada_language_server'
}

-- ugly but working hack. If $NVIM_USE_PRIVATE_FORKS is set (to anything), we will use private
-- forks of some plugins.
-- Reason: I'm just experimenting with some plugins.
-- This hack may go away without notice.
-- You REALLY should not use this and stick to the official plugins. It may
-- break the config
vim.g.use_private_forks = false
if os.getenv('NVIM_USE_PRIVATE_FORKS') ~= nil then
  vim.g.use_private_forks = true
end

vim.g.confirm_actions = {
  exit = true,            -- ALWAYS confirm force-close (Alt-q), even when no buffers are modified
  close_buffer = true,    -- <C-x><C-c>: only confirm when buffer modified
}

local g = vim.g
-- disable some standard plugins
g.loaded_netrw       = 1
g.loaded_netrwPlugin = 1

g.loaded_zipPlugin= 1
g.loaded_zip = 1

g.loaded_tarPlugin= 1
g.loaded_tar = 1

g.loaded_gzipPlugin= 1
g.loaded_gzip = 1

g.filetree_width = 44    -- width for the neotree and nvim-tree plugins
g.outline_width = 36     -- split width for symbols-outline
g.float_winblend = 0

-- some tweaks
vim.g.cokeline_filename_width = 20             -- max filename length on cokeline tabs
vim.g.lualine_theme = 'internal'               -- lualine theme, use 'internal' for the integrated theme 
                                               -- or any valid lualine theme name (e.g. 'dracula')

-- this color table is used when g.lualine_theme is set to 'internal'. otherwise, the variable can specify 
-- a builtin lualine theme (e.g. 'dracula')
-- the internal theme is designed to blend into the global color scheme.

local LuaLineColors

if vim.g.theme_variant == 'cold' then
  LuaLineColors = {
    white          = '#ffffff',
    darkestgreen   = '#003f00',
    brightgreen    =  vim.g.config.accent_color,
    darkestcyan    = '#005f5f',
    mediumcyan     = '#87dfff',
    darkestblue    = '#005f87',
    darkred        = '#870000',
    brightred      = '#df0000',
    brightorange   = '#ff8700',
    gray1          = '#262626',
    gray2          = '#303030',
    gray4          = '#585858',
    gray5          = '#404050',
    gray7          = '#9e9e9e',
    gray10         = '#f0f0f0',
    statuslinebg   = '#262636'
  }
else
  LuaLineColors = {
    white          = '#ffffff',
    darkestgreen   = '#003f00',
    brightgreen    = vim.g.config.accent_color,
    darkestcyan    = '#005f5f',
    mediumcyan     = '#87dfff',
    darkestblue    = '#005f87',
    darkred        = '#870000',
    brightred      = '#df0000',
    brightorange   = '#ff8700',
    gray1          = '#262626',
    gray2          = '#303030',
    gray4          = '#585858',
    gray5          = '#474040',
    gray7          = '#9e9e9e',
    gray10         = '#f0f0f0',
    statuslinebg   = '#2c2626'
  }
end

vim.g.statuslinebg = LuaLineColors.statuslinebg

-- cokeline colors for the buffer line
local cokeline_colors = {
  bg = LuaLineColors.statuslinebg,
--  bg = '#202050',
  focus_bg = vim.g.config.accent_color,
  fg = LuaLineColors.gray7,
  focus_fg = '#202020'
}

-- internal global function to create the lualine color theme
function Lualine_internal_theme()
  return {
    normal = {
      a = { fg = LuaLineColors.darkestgreen, bg = LuaLineColors.brightgreen, gui = 'bold' },
      b = { fg = LuaLineColors.gray10, bg = LuaLineColors.gray5 },
      c = { fg = LuaLineColors.gray7, bg = LuaLineColors.statuslinebg },
    },
    insert = {
      a = { fg = LuaLineColors.white, bg = LuaLineColors.brightred, gui = 'bold' },
      b = { fg = LuaLineColors.gray10, bg = LuaLineColors.gray5 },
      -- c = { fg = LuaLineColors.mediumcyan, bg = LuaLineColors.darkestblue },
      c = { fg = LuaLineColors.gray7, bg = LuaLineColors.statuslinebg },
    },
    visual = { a = { fg = LuaLineColors.darkred, bg = LuaLineColors.brightorange, gui = 'bold' } },
    replace = { a = { fg = LuaLineColors.white, bg = LuaLineColors.brightred, gui = 'bold' } },
    inactive = {
      a = { fg = LuaLineColors.gray4, bg = LuaLineColors.statuslinebg, gui = 'bold' },
      b = { fg = LuaLineColors.gray4, bg = LuaLineColors.statuslinebg },
      c = { fg = LuaLineColors.gray4, bg = LuaLineColors.statuslinebg }
    },
  }
end

-- crete the cokeline theme. Global function
function Cokeline_theme()
  return {
    hl = {
      fg = function(buffer) return buffer.is_focused and cokeline_colors.focus_fg or cokeline_colors.fg end,
      bg = function(buffer) return buffer.is_focused and cokeline_colors.focus_bg or cokeline_colors.bg end
    },
    unsaved = '#ff6060' -- the unsaved indicator on the tab
  }
end

-- global variables for plugins
g.mapleader = ','

-- sonokai theme
g.sonokai_menu_selection_background='red'
g.sonokai_style='default'
g.sonokai_transparent_background=1
g.sonokai_disable_italic_comment=1
g.sonokai_cursor = "auto"
g.sonokai_diagnostic_text_highlight=0
g.sonokai_diagnostic_line_highlight=0

-- multicursor highlight colors
g.VM_Mono_hl   = 'DiffText'
g.VM_Extend_hl = 'DiffAdd'
g.VM_Cursor_hl = 'Visual'
g.VM_Insert_hl = 'DiffChange'

Truncate = function(text, max_width)
  if #text > max_width then
    return string.sub(text, 1, max_width) .. "…"
  else
    return text
  end
end

-- load the color theme
vim.cmd [[silent! colorscheme my_sonokai]]
