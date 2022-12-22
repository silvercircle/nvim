-- configuration variables

-- table of features. You can set a feature to false and then restart vim. Ideally you should run
-- a PackerSync to clean up the plugin folder. This is mandatory when changing features from false to
-- true in order to install potentially missing plugins.

-- I currently do not use optional or conditional packer features. That might change at some point.
-- To add or remove a plugin, just change its enable status

vim.g.features = {
  lsp = { enable = true, module = 'setup_lsp' },                         -- mason, lspconfig, fidget Glance
  cmp = { enable = true, module = 'setup_cmp' },                          -- cmp
  scrollbar = { enable = true, module = 'setup_scrollbar' },              -- scrollbar
  gitsigns = { enable = true, module = 'setup_gitsigns' },                -- gitsigns plugin
  indent_blankline = { enable = true, module = 'setup_indent_blankline' },-- indent guides
  cokeline = { enable = true, module = 'setup_cokeline' },                -- cokeline
                                                                          -- diables lualine bufferbar
  neodev = "", -- setup_neodev
  treesitter = { enable = true, module = 'setup_treesitter' },           -- use treesitter
  -- playground is a special case, it is configured in the treesitter module and has no setup module of its own
  treesitter_playground = { enable = true, module = '' },
  telescope = { enable = true, module = 'setup_telescope'},               -- use telescope (+ various extensions)
  lualine = { enable = true, module = 'setup_lualine'},                   -- use lualine
  outline = { enable = true, module = 'setup_outline' },                  -- use symbols-outline plugin
  lspsaga = { enable = false, module = 'setup_lspsaga' },                 -- use lspsaga
  noice = { enable = false, module = 'setup_noice' },                     -- use noice for notifications
  dressing = { enable = true, module = 'setup_dressing' },                -- use dressing for various UI improvements
  telekasten = { enable = true, module = 'setup_telekasten' },            -- telekasten/calendar personal note taking
  -- please use ONLY ONE of te following two. Using both wont hurt but will
  -- be a waste.
  neotree = { enable = false, module = 'setup_neotree' },                 -- neotree file explorer
  nvimtree = { enable = true, module = 'setup_nvim-tree' },               -- nvim-tree file explorer
  null_ls = { enable = false, module = 'setup_null_ls' },                  -- null-ls for linting, formatting and more lsp features
  todo = { enable = true, module = 'setup_todo' }
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

-- some tweaks
vim.g.cokeline_filename_width = 20             -- max filename length on cokeline tabs
vim.g.lualine_theme = 'internal'               -- lualine theme, use 'internal' for the integrated theme 
                                               -- or any valid lualine theme name (e.g. 'dracula')
-- lualine internal theme
-- this is used when g.lualine_theme is set to 'internal'. otherwise, the variable can specify 
-- a builtin lualine theme (e.g. 'dracula')

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

-- internal global function to create the lualine color theme
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

-- this global funciton is used in cokeline, cmp and maybe other modules to truncate strings.
Truncate = function(text, max_width)
  if #text > max_width then
    return string.sub(text, 1, max_width) .. "…"
  else
    return text
  end
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
g.tex_conceal = ''

-- load the color theme
vim.cmd [[silent! colorscheme my_sonokai]]