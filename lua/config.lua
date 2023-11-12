-- configuration variables

-- NOTE: the environment variable NVIM_USE_PRIVATE_FORKS must be set (to anything) in order to use the private
-- forks of some plugins.

-- when NVIM_PLAIN is set (to whatever value), the editor will start plain without a neotree and
-- terminal split.
local env_plain = os.getenv("NVIM_PLAIN")
vim.g.tweaks = require("tweaks")
local tweaks = vim.g.tweaks

if vim.fn.has("nvim-0.9") == 0 then
  vim.notify("Warning, this configuration requires Neovim version 0.9 or later.", 3)
end

local nvim_10 = vim.fn.has("nvim-0.10")

-- this is the global config table. Since the migration to lazy, the features table is gone and
-- no longer needed. load_lazy.lua handles all the plugin loading and deals with optional plugins.

vim.g.config = {
  telescope_fname_width = tweaks.telescope_fname_width,
  telescope_vertical_preview_layout = tweaks.telescope_vertical_preview_layout,
  nightly = nvim_10,
  cokeline = {
    enabled = true,                             -- when false, lualine handles the bufferline
    show_close = false                          -- showa close button on the tabs
  },
  telescope_dropdown='bottom',                  -- position for the input box in the dropdown theme. 'bottom' or 'top'
  cpalette_dropdown = 'top',                    -- same for the command palette
  -- the minipicker is the small telescope picker used for references, symbols and
  -- treesitter-symbols. It also works in insert mode.
  minipicker_symbolwidth = tweaks.telescope_symbol_width,
  minipicker_layout = {
    height = 0.85,
    width = tweaks.telescope_mini_picker_width,
    preview_height =10,
    anchor = "N",
  },
  cmp = {
    autocomplete = tweaks.cmp.autocomplete,
    autocomplete_kwlen = tweaks.cmp.keywordlen,
    max_abbr_item_width = 40,                   -- item name width (maximum for truncate())
    max_detail_item_width = 40,                 -- item detail field maxium width
    -- the following lists file types that are allowed to use the cmp_buffer source
    buffer_ft_allowed = {tex = true, md = true, markdown = true, telekasten = true, text =true, mail = true },
    buffer_maxsize = tweaks.cmp.buffer_maxsize, -- PERF: maximum buffer size allowed to use cmp_buffer source. 300kB
    ghost_text = tweaks.cmp_ghost
  },
  minipicker_iprefix = "#>",
  filetree_width = 44,                          -- width nvim-tree plugin (file tree)
  outline_width = 36,                           -- split width for symbols-outline window (right sidebar)
  -- some optional plugins
  mason = true,                                 -- on demand, setup in setup_lsp.lua
  null_ls = false,                              -- setup by lazy loader
  neodev = false,                               -- setup by lazy loader
  treesitter = true,
  plain = (env_plain ~= nil or vim.g.want_plain == true) and true or false,
  -- statuscol_normal = '%s%=%{printf("%4d", v:lnum)} %C ',
  statuscol_normal = '%s%=%l %C ',
  --the same as above with highlighting the current line number
  --statuscol_normal = '%s%=%#LineNr#%{v:relnum != 0 ? printf("%4d",v:lnum) : ""}%#Yellow#%{v:relnum == 0 ? printf("%4d", v:lnum) : ""} %C%#IndentBlankLineChar#│ ',
  --statuscol_rel = '%s%=%{printf("%4d", v:relnum)} %C ',
  statuscol_rel = '%s%=%r %C ',
  --again, with highlighting relative number
  --statuscol_rel = '%s%=%#LineNr#%{v:relnum != 0 ? printf("%4d",v:relnum) : ""}%#Yellow#%{v:relnum == 0 ? printf("%4d", v:relnum) : ""} %C%#IndentBlankLineChar#│ ',
  nvim_tree = true,
  cokeline_filename_width = tweaks.cokeline_filename_width,               -- max filename length on cokeline tabs
  fortunecookie = false,                      --"fortune science politics -s -n500 | cowsay -W 120",  -- display a fortune cookie on start screen.
                                              -- needs fortune and cowsay installed.
                                              -- set to false or an empty string to disable
                                              -- set this to "" or false if your start screen throws errors.
  mkview_on_leave = true,                     -- set to true if you want to save views on BufWinLeave
                                              -- when false, views are only written on write/update or manually (f4)
  mkview_on_fold = false,                     -- always create a view when using the folding keys (f2/f3)
  breadcrumb = ((nvim_10 == 1) and (tweaks.breadcrumb == 'navic' or tweaks.breadcrumb == 'dropbar')) and tweaks.breadcrumb or 'navic',
  termheight = 11,
  iconpad = ' ',                              -- additional padding for devicons.
  texoutput = "~/Documents/TEXOUTPUT/",
  texviewer = 'zathura',                      -- must be able to display PDFs, must be in $PATH
  wordcount_limit = 5,                         -- file size limit in megabytes. Above it, the word count will be disabled for performance reasons
  sysmon = {
    width = 51,
    modules = "cpu,mem,memswap,network,load,system,uptime"
    -- modules = "cpu,mem,network,load,system,uptime,quicklook", -- this requiers a width of 58 or more
  },
  weather = {
    width = 42,
    file = "~/.weather/weather",
    splitright = false,
    required_height = 14
  },
  -- this is a table of filetype <> colorcolumns associations. it's used by globals.toggle_colorcolumn()
  -- to figure out where the color column for the given filetype should be.
  colorcolumns = {
    all = {
      filetype ="all",
      value = "100"
    },
    text = {
      filetype = "tex,markdown,liquid,telekasten",
      value = "107"
    },
    mail = {
      filetype = "mail",
      value = "76"
    }
  },
}

vim.g.theme = {
  string = 'yellow',    -- yellow strings, default is green. Respects desaturate
  -- accent color is used for important highlights like the currently selected tab (buffer)
  -- and more.
  accent_color = '#cbaf00',
  alt_accent_color = '#bd2f4f',
  lualine = 'internal',  -- use 'internal' for the integrated theme or any valid lualine theme name
  cold = {
    bg = '#141414',
    treebg = '#18181c',
    gutterbg = '#101013'
  },
  warm = {
    bg = '#161414',
    treebg = '#1b1818',
    gutterbg = '#131010'
  }
}
vim.g.theme_variant = 'warm'
vim.g.theme_desaturate = true

vim.g.formatters = {
  lua = {
    cmd = "stylua",
    range = false
  },
  rust = {
    cmd = "rustfmt",
    range = false
  },
  python = {
    cmd = "autopep8",
    range = false
  }
}

-- quick actions for the alpha start screen
vim.g.startify_top = {
  {
    key = 'e',
    text = "  New file",
    command = ":ene <BAR> startinsert <CR>"
  },
  {
    key = 'q',
    text = "  Quit NVIM",
    command = ":qa!<CR>"
  },
  {
    key = 'c',
    text = "  Edit config",
    command = ":e ~/.config/nvim/init.vim<CR>:NvimTreeFindFile<CR>"
  }
}
local masonbinpath = vim.fn.stdpath('data') .. '/mason/bin/'
local localbin = vim.fn.getenv('HOME') .. '/.local/bin/'
local homepath = vim.fn.getenv('HOME')

-- this table holds full path information for lsp server binaries. They can be installed with mason or
-- manually. plugins/lsp.lua does all the real work. Mason and mason-lspconfig are optional.
-- They allow easy installation and upgrading of your lsp servers, but if you do this manually,
-- nvim-lspconfig alone is enough for a working LSP setup.

vim.g.lsp_server_bin = {
  phpactor      =   '/usr/local/bin/phpactor',
  rust_analyzer =   masonbinpath .. 'rust-analyzer',
  gopls         =   localbin .. 'gopls',
  nimls         =   homepath .. '/.nimble/bin/nimlsp',
  texlab        =   localbin .. 'texlab',
  clangd        =   '/usr/bin/clangd',
  dartls        =   '/opt/flutter/bin/dart',
  vimlsp        =   masonbinpath .. 'vim-language-server',
  omnisharp     =   masonbinpath .. 'omnisharp',
  metals        =   '/home/alex/.local/share/coursier/bin/metals',
  pyright       =   masonbinpath .. 'pyright-langserver',
  lua_ls        =   masonbinpath .. 'lua-language-server',
  serve_d       =   localbin .. 'serve-d',
  cssls         =   masonbinpath .. 'vscode-css-language-server',
  tsserver      =   masonbinpath .. 'typescript-language-server',
  html          =   masonbinpath .. 'vscode-html-language-server',
  yamlls        =   masonbinpath .. 'yaml-language-server',
  als           =   masonbinpath .. 'ada_language_server',
  jdtls         =   masonbinpath .. 'jdtls',
  csharp_ls     =   homepath .. '/.dotnet/tools/csharp-ls',
  marksman      =   masonbinpath .. 'marksman',
  lemminx       =   masonbinpath .. 'lemminx',
  haskell       =   homepath .. '/.ghcup/hls/1.9.0.0/bin/haskell-language-server-9.4.4',
  bashls        =   masonbinpath .. 'bash-language-server',
  pylyzer       =   localbin .. "pylyzer",
  taplo         =   masonbinpath .. 'taplo'
}

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

-- this color table is used when g.lualine_theme is set to 'internal'. otherwise, the variable can specify
-- a builtin lualine theme (e.g. 'dracula')
-- the internal theme is designed to blend into the global color scheme.

local LuaLineColors

if vim.g.theme.variant == 'cold' then
  LuaLineColors = {
    white          = '#ffffff',
    darkestgreen   = '#003f00',
    brightgreen    =  vim.g.theme.accent_color,
    darkestcyan    = '#005f5f',
    mediumcyan     = '#87dfff',
    darkestblue    = '#005f87',
    darkred        = '#870000',
    brightred      = vim.g.theme.alt_accent_color,
    brightorange   = '#2f47df',
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
    brightgreen    = vim.g.theme.accent_color,
    darkestcyan    = '#005f5f',
    mediumcyan     = '#87dfff',
    darkestblue    = '#005f87',
    darkred        = '#870000',
    brightred      = vim.g.theme.alt_accent_color,
    brightorange   = '#2f47df',
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
vim.g.cokeline_colors = {
  --bg = LuaLineColors.statuslinebg,
  bg = LuaLineColors.statuslinebg,
  focus_bg = vim.g.theme.accent_color,
  fg = LuaLineColors.gray7,
  focus_fg = '#202020'
}

--- internal global function to create the lualine color theme
--- @return table
function Lualine_internal_theme()
  return {
    normal = {
      a = { fg = LuaLineColors.darkestgreen, bg = LuaLineColors.brightgreen, gui = 'bold' },
      b = { fg = LuaLineColors.gray10, bg = LuaLineColors.gray5 },
      c = { fg = LuaLineColors.gray7, bg = LuaLineColors.statuslinebg },
      x = { fg = LuaLineColors.gray7, bg = LuaLineColors.statuslinebg },
    },
    insert = {
      a = { fg = LuaLineColors.white, bg = LuaLineColors.brightred, gui = 'bold' },
      b = { fg = LuaLineColors.gray10, bg = LuaLineColors.gray5 },
      c = { fg = LuaLineColors.gray7, bg = LuaLineColors.statuslinebg },
    },
    visual = { a = { fg = LuaLineColors.white, bg = LuaLineColors.brightorange, gui = 'bold' } },
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
      fg = function(buffer) return buffer.is_focused and vim.g.cokeline_colors.focus_fg or vim.g.cokeline_colors.fg end,
      bg = function(buffer) return buffer.is_focused and vim.g.cokeline_colors.focus_bg or vim.g.cokeline_colors.bg end
    },
    unsaved = '#ff6060' -- the unsaved indicator on the tab
  }
end

-- global variables for plugins
g.mapleader = ','

-- multicursor highlight colors
g.VM_Mono_hl   = 'DiffText'
g.VM_Extend_hl = 'DiffAdd'
g.VM_Cursor_hl = 'Visual'
g.VM_Insert_hl = 'DiffChange'

Telescope_dropdown_theme = require("local_utils").Telescope_dropdown_theme
Telescope_vertical_dropdown_theme = require("local_utils").Telescope_vertical_dropdown_theme

