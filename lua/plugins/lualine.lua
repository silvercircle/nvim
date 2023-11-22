local my_extension = { sections = { lualine_a = {'filetype'} }, filetypes = {'NvimTree'} }
local globals = require("globals")
local navic
if vim.g.config.breadcrumb == 'navic' then
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

local function getWordsV2()
  if globals.cur_bufsize > vim.g.config.wordcount_limit * 1024 * 1024 then
    return "NaN"
  end
  local wc = vim.fn.wordcount()
  if wc["visual_words"] then -- text is selected in visual mode
    return wc["visual_words"] .. " Words/" .. wc['visual_chars'] .. " Chars (Vis)"
  else -- all of the document
    return wc["words"] .. " Words"
  end
end

--- hack-ish. just return a very long string for the central section. Set the
--- highlight group to bg=none and fg=bg and it will appear "transparent"
local function padding()
  return string.rep(" ", 250)
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
  if vim.g.theme.lualine == 'internal' then
    return Lualine_internal_theme()
  else
    return vim.g.theme.lualine
  end
end

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
  winbar = vim.g.config.breadcrumb == 'navic' and {
    --- winbar top/left shows either the lsp context, or the lsp progress message
    lualine_a = {
      {
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
    },
    lualine_c = {
      {
        padding,
        color = "WinBarInvis",
        separator = { left = "", right = "" }
      }
    },
    lualine_z = {
      {
        full_filename,
        separator = { left = "", right = "" },
        -- separator = { left ="", right = "" },
        --separator = "",
        color = 'WinBarFilename'
      },
      'tabs'
    }
  } or {},
  inactive_winbar = vim.g.config.breadcrumb == 'navic' and {
    -- lualine_x = { { win_pad, color = 'Normal' } },
    lualine_z = { { full_filename, color = 'WinBarNC' }, 'tabs' }
  } or {},
  extensions = {my_extension},
})

