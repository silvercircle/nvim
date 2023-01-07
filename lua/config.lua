-- configuration variables

-- table of features. You can set a feature to false and then restart vim. Ideally you should run
-- a PackerSync to clean up the plugin folder. This is mandatory when changing features from false to
-- true in order to install potentially missing plugins.

-- I currently do not use optional or conditional packer features. That might change at some point.
-- To add or remove a plugin, just change its enable status

-- NOTE: the environment variable NVIM_USE_PRIVATE_FORKS must be set (to anything) in order to use the private
-- forks of some plugins. 
vim.g.features = {
  lsp = { enable = true, module = 'setup_lsp' },                          -- mason, lspconfig, fidget Glance
  -- mason is part of the lsp plugin group, but optional. it has no setup module of its own - setup_lsp.lua
  -- deals with mason
  mason = { enable = false, module = '' },
  cmp = { enable = true, module = 'setup_cmp' },                          -- cmp, including all its sources
                                                                          -- and luasnip
  orgmode = { enable = false, module = 'setup_orgmode' },                  -- orgmode is a must-have
  telekasten = { enable = true, module = 'setup_telekasten' },
  scrollbar = { enable = true, module = 'setup_scrollbar' },              -- scrollbar
  gitsigns = { enable = true, module = 'setup_gitsigns' },                -- gitsigns plugin
  indent_blankline = { enable = true, module = 'setup_indent_blankline' },-- indent guides
  cokeline = { enable = true, module = 'setup_cokeline' },                -- cokeline
                                                                          -- diables lualine bufferbar
  neodev = { enable = false, module = '' },                               -- neodev has no own module as it requires a working lsp
                                                                          -- config. So it's activated in setup_lsp.lua
  treesitter = { enable = true, module = 'setup_treesitter' },            -- use treesitter
  -- playground is a special case, it is configured in the treesitter module and has no setup module of its own
  treesitter_playground = { enable = true, module = '' },
  telescope = { enable = true, module = 'setup_telescope'},               -- use telescope (+ various extensions)
  lualine = { enable = true, module = 'setup_lualine'},                   -- use lualine
  outline = { enable = true, module = 'setup_outline' },                  -- use symbols-outline plugin
  lspsaga = { enable = false, module = 'setup_lspsaga' },                 -- use lspsaga
  noice = { enable = false, module = 'setup_noice' },                     -- use noice for notifications
  dressing = { enable = true, module = 'setup_dressing' },                -- use dressing for various UI improvements
  -- please use ONLY ONE of te following two. Using both wont hurt but will be a waste.
  -- personally i prefer nvim-tree, but both plugins are fine. Matter of personal preference.
  neotree = { enable = true, module = 'setup_neotree' },                  -- neotree file explorer
  nvimtree = { enable = false, module = 'setup_nvim-tree' },              -- nvim-tree file explorer
  null_ls = { enable = false, module = 'setup_null_ls' },                 -- null-ls for linting, formatting and more lsp features
  todo = { enable = true, module = 'setup_todo' },
  sidebar = { enable = false, module = 'setup_sidebar' }
}
vim.g.root_patterns = { "*.gpr", "Makefile", "CMakeLists.txt", ".git" }

-- theme variant can be either cold or warm.
-- cold has slight blue-ish tint in the background colors, while warm is more reddish
-- the default is warm
vim.g.theme_variant = 'warm'
vim.g.use_command_center=true

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
-- You REALLY should not use this and stick to the official plugins
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
    darkestgreen   = '#005f00',
    brightgreen    = '#afdf00',
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
    darkestgreen   = '#005f00',
    brightgreen    = '#afdf00',
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
  focus_bg = '#afdf00',
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
