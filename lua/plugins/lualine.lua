local my_extension = { sections = { lualine_a = {'filetype'} }, filetypes = {'NvimTree'} }
local globals = require("globals")
local navic
local colors = require("colors.mine")
if Config.breadcrumb == 'navic' then
  navic = require('nvim-navic')
end

-- use either cokeline or lualine's internal buffer line, depending on 
-- configuration choice.
local function actual_tabline()
  if vim.g.tweaks.cokeline.enabled == true then
    return {}
  else return {
    lualine_a = { { "buffers", mode = 2 } },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { "tabs" } }
  end
end

local function status_indicators()
  return (globals.perm_config.treesitter_context == true and "C" or "c") ..
         (globals.perm_config.debug == true and "D" or "d") ..
         (globals.perm_config.transbg == true and "T" or "t")
end

local function getWordsV2()
  if globals.cur_bufsize > Config.wordcount_limit * 1024 * 1024 then
    return "NaN"
  end
  local wc = vim.fn.wordcount()
  if wc["visual_words"] then -- text is selected in visual mode
    return wc["visual_words"] .. " Words/" .. wc['visual_chars'] .. " Chars (Vis)"
  else -- all of the document
    return wc["words"] .. " Words"
  end
end

local pad_string = string.rep(" ", 250)
--- hack-ish. just return a very long string for the central section. Set the
--- highlight group to bg=none and fg=bg and it will appear "transparent"
--- uses the WinBarInvis hl group
local function padding()
  return pad_string
end

local function full_filename()
  return vim.fn.expand("%")
end

local function navic_context()
  return navic.get_location()
end

local function indentstats()
  if globals.perm_config.statusline_declutter > 0 then
    return string.format("%d:%d:%s", vim.bo.tabstop, vim.bo.shiftwidth, vim.bo.expandtab == true and 'y' or 'n')
  else
    return string.format("%d:%d:%s|%s%s", vim.bo.tabstop, vim.bo.shiftwidth, vim.bo.expandtab == true and 'y' or 'n', vim.g.theme_variant, vim.g.theme_desaturate == true and ",D" or "")
  end
end

-- the internal theme is defined in config.lua
local function theme()
  return colors.Lualine_internal_theme()
end
local _bg = vim.api.nvim_get_hl(0, { name="Visual" }).bg
--local _bg = theme().normal.b.bg

vim.api.nvim_set_hl(0, "WinBarULSep", { fg = _bg, bg = colors.theme[globals.perm_config.theme_variant].bg })
vim.api.nvim_set_hl(0, "WinBarUL", { fg = theme().normal.b.fg, bg = _bg })

local navic_component = {
  navic_context,
  fmt = function(string)
    if #string < 2 then
      return ""
    else
     return string.format("Context: %s", string)
   end
  end,
  -- separator = { right ="", left = "" },
  separator = "",
  color = 'WinBarContext',
}

local aerial_component = {
  "aerial",
  -- The separator to be used to separate symbols in status line.
  sep = "  ",
  sep_highlight = "Debug",

  -- The number of symbols to render top-down. In order to render only 'N' last
  -- symbols, negative numbers may be supplied. For instance, 'depth = -1' can
  -- be used in order to render only current symbol.
  depth = nil,

  -- When 'dense' mode is on, icons are not rendered near their symbols. Only
  -- a single icon that represents the kind of current symbol is rendered at
  -- the beginning of status line.
  dense = false,

  -- The separator to be used to separate symbols in dense mode.
  dense_sep = ".",

  -- Color the symbol icons.
  colored = true,
--  color = 'WinBarContext'
}

require("lualine").setup({
  options = {
    icons_enabled = true,
    theme = theme(),
    component_separators = "│", -- {left = "", right = "" },
    section_separators = { left = '', right = '' },
    -- section_separators = { left = "", right = "" },
    disabled_filetypes = {
      statusline = { "Outline", 'terminal', 'query', 'qf', 'BufList', 'sysmon', 'weather', "NvimTree", "aerial" },
      winbar = { 'Outline', 'terminal', 'query', 'qf', 'NvimTree', 'alpha', 'BufList', 'sysmon', 'weather', 'aerial' },
      tabline = {},
    },
    -- ignore_focus = {'NvimTree'},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 2000,
      tabline = 3000,
      winbar = 5000,
    },
  },
  sections = {
    lualine_a = { "mode", "o:formatoptions", " : ",
    {
      "o:textwidth",
      fmt = function(str)
        return string.format("%s:%s:%s", str, vim.api.nvim_win_get_option(0, "wrap") == true and "wr" or "no", vim.o.foldmethod)
      end
    },
    }, -- display textwidth after formattingoptions
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = {"filename", "searchcount" },
    lualine_x = {
      { indentstats },
      {
        -- show unicode for character under cursor in hex and decimal
        -- "%05B - %06b",
        "%05B",
        fmt = function(str)
          return string.format("U:0x%s", str)
        end
      },
      "filetype",
      "fileformat",
      { "encoding", draw_empty=false, cond = function() return globals.perm_config.statusline_declutter < 3 and true or false end }
    },
    lualine_y = { { "progress", cond = function() return globals.perm_config.statusline_declutter < 2 and true or false end, draw_empty=false} },
    -- word counter via custom function
    lualine_z = { { getWordsV2 }, "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = actual_tabline(),
  winbar = Config.breadcrumb ~= 'dropbar' and {
    --- winbar top/left shows either the lsp context, or the lsp progress message
    lualine_a = {
      Config.breadcrumb == 'navic' and navic_component or aerial_component
    },
    lualine_c = {
      {
        padding,
        color = "WinBarInvis",
        separator = { left = "", right = "" }
      }
    },
    lualine_y = {
      {
        "",
        padding = 0,
        separator = { left = "", right = "" },
        color = "WinBarULSep",
        fmt = function()
          return ""
        end,
        cond = function() return globals.perm_config.show_indicators end
      },
      {
        status_indicators,
        color = "WinBarUL",
        padding = 0,
        cond = function() return globals.perm_config.show_indicators end
      }
    },
    lualine_z = {
      {
        "",
        padding = 0,
        separator = { left = "", right = "" },
        draw_empty = true,
        color = { fg = colors.theme.accent_color, bg = colors.theme[globals.perm_config.theme_variant].bg },
        fmt = function()
          return ""
        end,
        cond = function() return not globals.perm_config.show_indicators end
      },
      {
        'filename',
        padding = 0,
        path = 4,
        shorting_target = 60,
        --separator = "",
        --separator = { left = "", right = "" },
        color = 'WinBarFilename'
      },
      'tabs',
    }
  } or {},
  inactive_winbar = Config.breadcrumb ~= 'dropbar' and {
    -- lualine_x = { { win_pad, color = 'Normal' } },
    lualine_z = { { full_filename, color = 'WinBarNC' }, 'tabs' }
  } or {},
  extensions = {my_extension},
})

