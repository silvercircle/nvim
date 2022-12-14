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

vim.g.config_null_ls = false                   -- use null_ls plugin
vim.g.config_noice = false
vim.g.config_cokeline = true                   -- use cokeline (and disable lualine tabbar)
vim.g.cokeline_filename_width = 20             -- max filename length on cokeline tabs
vim.g.lualine_theme = 'internal'               -- lualine theme, use 'internal' for the integrated theme 
                                               -- or any valid lualine theme name

function Cokeline_theme()
  return {
    hl = {
      fg = function(buffer) return buffer.is_focused and cokeline_colors.focus_fg or cokeline_colors.fg end,
      bg = function(buffer) return buffer.is_focused and cokeline_colors.focus_bg or cokeline_colors.bg end
    },
    unread = '#ff6060'
  }
end