-- configuration variables

-- table of features. You can set a feature to false and then restart vim. Ideally you should run
-- a PackerSync to clean up the plugin folder. This is mandatory when changing features from false to
-- true in order to install potentially missing plugins.

-- I currently do not use optional or conditional packer features. That might change at some point.
-- To add or remove a plugin, just change its enable status

-- NOTE: the environment variable NVIM_USE_PRIVATE_FORKS must be set (to anything) in order to use the private
-- forks of some plugins.

-- when NVIM_PLAIN is set (to whatever value), the editor will start plain without a neotree and 
-- terminal split.
local env_plain = os.getenv("NVIM_PLAIN")

-- this is the global config table. Since the migration to lazy, the features table is gone and
-- no longer needed. load_lazy.lua handles all the plugin loading and deals with optional plugins.

vim.g.config = {
  telescope_fname_width = 140,
  nightly = vim.fn.has("nvim-0.9"),             -- TODO: fix this when 0.9 goes release
  use_cokeline = true,                          -- when false, lualine handles the bufferline
  telescope_dropdown='bottom',                  -- position for the input box in the dropdown theme. 'bottom' or 'top'
  cpalette_dropdown = 'top',                    -- same for the command palette
  -- accent color is used for important highlights like the currently selected tab (buffer) 
  -- and more.
  accent_color = '#cbaf00',
  alt_accent_color = '#bd2f4f',
  -- the minipicker is the small telescope picker used for references, symbols and
  -- treesitter-symbols. It also works in insert mode.
  minipicker_height = 0.8,
  minipicker_width = 50,
  minipicker_preview_height = 10,
  minipicker_iprefix = "#>",
  minipicker_anchor = "N",
  -- some optional plugins
  mason = true,                                 -- on demand, setup in setup_lsp.lua
  null_ls = false,                              -- setup by lazy loader
  neodev = false,                               -- setup by lazy loader
  treesitter = true,
  treesitter_playground = false,                -- no setup required, optional, handled by setup_treesitter
  plain = env_plain ~= nil and true or false,
  use_rainbow_indentguides = false,             -- for indent-blankline: rainbow-colorize indent guides
  --statuscol_normal = '%s%#LineNr#%=%{printf("%4d", v:lnum)} %C%#IndentBlankLineChar#│ ',
  --the same as above with highlighting the current line number
  statuscol_normal = '%s%=%#LineNr#%{v:relnum != 0 ? printf("%4d",v:lnum) : ""}%#Yellow#%{v:relnum == 0 ? printf("%4d", v:lnum) : ""} %C%#IndentBlankLineChar#│ ',
  --statuscol_rel = '%s%#LineNr#%=%{printf("%4d", v:relnum)} %C%#IndentBlankLineChar#│ ',
  --again, with highlighting relative number
  statuscol_rel = '%s%=%#LineNr#%{v:relnum != 0 ? printf("%4d",v:relnum) : ""}%#Yellow#%{v:relnum == 0 ? printf("%4d", v:relnum) : ""} %C%#IndentBlankLineChar#│ ',
  statuscol_default = 'normal',
  nvim_tree = true,
  cokeline_filename_width = 25             -- max filename length on cokeline tabs
}

Statuscol_current = vim.g.config.statuscol_default

vim.g.theme = {
  variant = "warm",     -- "warm" gives a slight red-ish tint for some backgrounds. "cold" a more blue-ish
  desaturate = true     -- true: desaturate some colors to get a more "pastel" look with less intense colors
}

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
  als = masonbinpath .. 'ada_language_server',
  jdtls = masonbinpath .. 'jdtls',
  csharp_ls = homepath .. '/.dotnet/tools/csharp-ls'
}


-- ugly but working hack. If $NVIM_USE_PRIVATE_FORKS is set (to anything), we will use private
-- forks of some plugins.
-- Reason: I'm just experimenting with some plugins.
-- This hack may go away without notice.

-- You REALLY should not use this and stick to the official plugins.
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
vim.g.lualine_theme = 'internal'               -- lualine theme, use 'internal' for the integrated theme 
                                               -- or any valid lualine theme name (e.g. 'dracula')

-- this color table is used when g.lualine_theme is set to 'internal'. otherwise, the variable can specify 
-- a builtin lualine theme (e.g. 'dracula')
-- the internal theme is designed to blend into the global color scheme.

local LuaLineColors

if vim.g.theme.variant == 'cold' then
  LuaLineColors = {
    white          = '#ffffff',
    darkestgreen   = '#003f00',
    brightgreen    =  vim.g.config.accent_color,
    darkestcyan    = '#005f5f',
    mediumcyan     = '#87dfff',
    darkestblue    = '#005f87',
    darkred        = '#870000',
    brightred      = vim.g.config.alt_accent_color,
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
    brightgreen    = vim.g.config.accent_color,
    darkestcyan    = '#005f5f',
    mediumcyan     = '#87dfff',
    darkestblue    = '#005f87',
    darkred        = '#870000',
    brightred      = vim.g.config.alt_accent_color,
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

function Set_statuscol(mode)
  if mode == 'normal' then
    Statuscol_current = 'normal'
    vim.o.statuscolumn = vim.g.config.statuscol_normal
    vim.o.relativenumber = false
    vim.o.numberwidth=5
    vim.o.number = true
    return
  elseif mode == 'rel' then
    Statuscol_current = 'rel'
    vim.o.statuscolumn = vim.g.config.statuscol_rel
    vim.o.relativenumber = true
    vim.o.numberwidth=5
    vim.o.number = false
    return
  end
end

function Toggle_statuscol()
  if Statuscol_current == 'normal' then
    Set_statuscol('rel')
    return
  end
  if Statuscol_current == 'rel' then
    Set_statuscol('normal')
    return
  end
end


function FindbufbyType(type)
  local ls = vim.api.nvim_list_bufs()
  for _, buf in pairs(ls) do
    if vim.api.nvim_buf_is_valid(buf) then
      local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
      if filetype == type then
        local winid = vim.fn.win_findbuf(buf)
        if winid[1] ~= nil then
          vim.fn.win_gotoid(winid[1])
          return true
        end
      end
    end
  end
  return false
end

