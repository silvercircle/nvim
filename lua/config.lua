-- configuration variables

-- lualine internal theme
-- this is used then g.lualine_theme is set to 'internal'
-- otherwise, the variable can specify a builtin lualine theme (e.g.
-- 'dracula'

local Colors = {
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
  gray5          = '#606060',
  gray7          = '#9e9e9e',
  gray10         = '#f0f0f0',
}

-- cokeline colors for the buffer line
local cokeline_colors = {
  bg = '#005f87',
  focus_bg = '#afdf00',
  fg = '#e0e0e0',
  focus_fg = '#202020'
}

function Lualine_internal_theme()
  return {
    normal = {
      a = { fg = Colors.darkestgreen, bg = Colors.brightgreen, gui = 'bold' },
      b = { fg = Colors.gray10, bg = Colors.gray5 },
      c = { fg = Colors.gray7, bg = Colors.gray2 },
    },
    insert = {
      a = { fg = Colors.white, bg = Colors.brightred, gui = 'bold' },
      b = { fg = Colors.gray10, bg = Colors.gray5 },
      c = { fg = Colors.mediumcyan, bg = Colors.darkestblue },
    },
    visual = { a = { fg = Colors.darkred, bg = Colors.brightorange, gui = 'bold' } },
    replace = { a = { fg = Colors.white, bg = Colors.brightred, gui = 'bold' } },
    inactive = {
      a = { fg = Colors.gray1, bg = Colors.gray5, gui = 'bold' },
      b = { fg = Colors.gray1, bg = Colors.gray5 },
      c = { bg = Colors.gray1, fg = Colors.gray5 },
    },
  }
end

vim.g.features = {
  lsp = { enable = true, module = 'setup_lsp' },
  scrollbar = { enable = true, module = 'setup_scrollbar' },
  gitsigns = { enable = true, module = 'setup_gitsigns' },
  indent_blankline = { enable = true, module = 'setup_indent_blankline' },
  cokeline = { enable = true, module = 'setup_cokeline' },
  neodev = "", -- setup_neodev
  treesitter = { enable = true, module = 'setup_treesitter' },
  telescope = { enable = true, module = 'setup_telescope'},
  lualine = { enable = true, module = 'setup_lualine'},
  outline = { enable = true, module = 'setup_outline' },
  lspsaga = { enable = false, module = 'setup_lspsaga' },
  noice = { enable = false, module = 'setup_noice' },
  dressing = { enable = true, module = 'setup_dressing' },
  telekasten = { enable = true, module = 'setup_telekasten' },
  -- please use ONLY ONE of te following two. Using both won't hurt but will
  -- be a waste.
  neotree = { enable = false, module = 'setup_neotree' },
  nvimtree = { enable = true, module = 'setup_nvim-tree' }
}

vim.g.config_null_ls = false                   -- use null_ls plugin
vim.g.cokeline_filename_width = 20             -- max filename length on cokeline tabs
vim.g.lualine_theme = 'internal'               -- lualine theme, use 'internal' for the integrated theme 
                                               -- or any valid lualine theme name (e.g. 'dracula')
function Cokeline_theme()
  return {
    hl = {
      fg = function(buffer) return buffer.is_focused and cokeline_colors.focus_fg or cokeline_colors.fg end,
      bg = function(buffer) return buffer.is_focused and cokeline_colors.focus_bg or cokeline_colors.bg end
    },
    unsaved = '#ff6060' -- the unsaved indicator on the tab
  }
end

Truncate = function(text, max_width)
  if #text > max_width then
    return string.sub(text, 1, max_width) .. "…"
  else
    return text
  end
end

-- global variables for plugins
local g = vim.g

g.mapleader = ','

-- sonokai theme
g.sonokai_menu_selection_background='red'
g.sonokai_style='default'
g.sonokai_transparent_background=1
g.sonokai_disable_italic_comment=1
g.sonokai_cursor = "auto"
g.sonokai_diagnostic_text_highlight=0
g.sonokai_diagnostic_line_highlight=0

-- multicursor
g.VM_Mono_hl   = 'DiffText'
g.VM_Extend_hl = 'DiffAdd'
g.VM_Cursor_hl = 'Visual'
g.VM_Insert_hl = 'DiffChange'
g.tex_conceal = ''

-- disable some standard plugins
g.loaded_netrw       = 1
g.loaded_netrwPlugin = 1

g.loaded_zipPlugin= 1
g.loaded_zip = 1

g.loaded_tarPlugin= 1
g.loaded_tar = 1

g.loaded_gzipPlugin= 1
g.loaded_gzip = 1

g.neotree_width = 44
g.outline_width = 36

-- load the color theme
vim.cmd [[silent! colorscheme my_sonokai]]