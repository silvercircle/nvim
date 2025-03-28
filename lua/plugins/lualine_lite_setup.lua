local my_extension = { sections = { lualine_a = {'filetype'} }, filetypes = {'NvimTree'} }
local _, navic = pcall(require, "nvim-navic")

local  LuaLineColors = {
    white = "#ffffff",
    darkestgreen = "#106010", -- M.T.accent_fg,
    brightgreen = "#106060", -- M.T.accent_color,
    darkestcyan = "#005f5f",
    mediumcyan = "#87dfff",
    darkestblue = "#002f47",
    darkred = "#870000",
    brightred = "#802020", -- M.T.alt_accent_color,
    brightorange = "#2f47df",
    gray1 = "#262626",
    gray2 = "#303030",
    gray4 = "#585858",
    gray5 = "#404050",
    gray7 = "#9e9e9e",
    gray10 = "#f0f0f0",
    statuslinebg = "#263031", -- M.T[conf.variant].statuslinebg,
  }

local function get_permissions_color()
  local file = vim.fn.expand("%:p")
  if file == "" or file == nil then
    return "No File", "#0099ff" -- Default blue for no or non-existing file
  else
    local permissions = vim.fn.getfperm(file)
    -- Check only the first three characters for 'rwx' to determine owner permissions
    local owner_permissions = permissions:sub(1, 3)
    -- Green for owner 'rwx', blue otherwise
    return permissions, owner_permissions == "rwx" and "#00ff00" or "#0099ff"
  end
end

local function status()
  local s, val = pcall(vim.api.nvim_buf_get_var, 0, "completion")
  local disabled = (s == true and val == false )
  return (CGLOBALS.get_buffer_var(0, "tsc") == true and "C" or "c") ..
         (CGLOBALS.get_buffer_var(0, "inlayhints") == true and "H" or "h") ..
         (vim.b[0].snacks_indent == false and "i" or (PCFG.ibl_enabled and "I" or "i")) ..
         (disabled and "a" or "A")
end

local function status_indicators()
  return (PCFG.treesitter_context == true and "C" or "c") ..
         (PCFG.debug == true and "D" or "d") ..
         (PCFG.transbg == true and "T" or "t") ..
         (PCFG.autopair == true and "A" or "a") ..
         (PCFG.cmp_automenu and 'O' or 'o') ..
         (PCFG.cmp_ghost and 'G' or 'g') ..
         (PCFG.lsp.inlay_hints and 'H' or 'h')
end

--- internal global function to create the lualine color theme
--- @return table
local function lualine_internal_theme()
  return {
    normal = {
      a = {
        fg = LuaLineColors.darkestgreen,
        bg = LuaLineColors.brightgreen, --[[, gui = 'bold']]
      },
      b = { fg = LuaLineColors.white, bg = LuaLineColors.darkestblue },
      c = "LuaLine",
      x = "LuaLine",
    },
    insert = {
      a = { fg = LuaLineColors.white, bg = LuaLineColors.brightred },
      b = { fg = LuaLineColors.white, bg = LuaLineColors.darkestblue },
      c = "LuaLine",
      x = "LuaLine",
    },
    visual = {
      a = {
        fg = LuaLineColors.white,
        bg = LuaLineColors.brightorange, --[[, gui = 'bold']]
      },
    },
    replace = { a = { fg = LuaLineColors.white, bg = LuaLineColors.brightred } },
    inactive = {
      a = "LuaLine",
      b = "LuaLine",
      c = "LuaLine"
    }
  }
end


local tab_sep_color;
local function setup_theme()
  if Tweaks.theme.disable == false then
    local T = require("darkmatter").T

    LuaLineColors.darkestgreen = T.accent_fg
    LuaLineColors.brightgreen = T.accent_color
    LuaLineColors.brightred = T.alt_accent_color
    LuaLineColors.statuslinebg = vim.api.nvim_get_hl(0, { name = "LuaLine" }).bg
    local _bg = vim.api.nvim_get_hl(0, { name="Visual" }).bg
    local _fg = vim.api.nvim_get_hl(0, { name="Fg" }).fg
    local _normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
    vim.api.nvim_set_hl(0, "WinBarULSep", { fg = _bg, bg = _normal_bg })
    vim.api.nvim_set_hl(0, "WinBarUL", { fg = _fg, bg = _bg, sp = _bg, underline = true })
    tab_sep_color = { fg = T.accent_color, bg = string.format("#%x", _normal_bg ) }
  end
end
setup_theme()

local function getWordsV2()
  if CGLOBALS.cur_bufsize > CFG.wordcount_limit * 1024 * 1024 then
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
  return string.format("%d:%d:%s", vim.bo.tabstop, vim.bo.shiftwidth, vim.bo.expandtab == true and 'y' or 'n')
end

local navic_component = {
  navic_context,
  fmt = function(string)
    if #string < 2 then
      return ""
    else
     --return string.format("%s: %s", vim.lsp.get_active_clients( {bufnr=0} )[1].name, string)
     return string.format("> %s", string)
   end
  end,
  separator = "",
  color = 'WinBarFilename',
}

require("lualine").setup({
  options = {
    icons_enabled = true,
    theme = Tweaks.statusline.lualine.theme == "internal" and lualine_internal_theme() or Tweaks.statusline.lualine.theme,
    --component_separators = "│",
    component_separators = {left = "", right = "" },
    section_separators = { left = '', right = '' },
    -- section_separators = { left = "", right = "" },
    disabled_filetypes = {
      statusline = { "Outline", 'SymbolsSidebar', 'SymbolsHelp', 'SymbolsSearch', 'terminal', 'query_rt', 'sysmon', 'weather', "NvimTree" },
      winbar = {},
    },
    ignore_focus = {'NvimTree', 'neo-tree', 'fzf'},
    always_divide_middle = true,
    globalstatus = false,
    always_show_tabline = true,
    refresh = {
      statusline = Tweaks.statusline.lualine.refresh,
      tabline = 1000,
      winbar = Tweaks.statusline.lualine.refresh,
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
    lualine_b = { "branch", "diff", "diagnostics"  },
    lualine_c = {"filename", "searchcount"--[[, { get_permissions_color }]] },
    lualine_x = {
      { indentstats, cond = function() return PCFG.statusline_declutter < 3 and true or false end },
      {
        -- show unicode for character under cursor in hex and decimal
        -- "%05B - %06b",
        "%05B",
        fmt = function(str)
          return string.format("U:0x%s", str)
        end
      },
      "filetype",
      { "fileformat", cond = function() return PCFG.statusline_declutter < 2 and true or false end },
      { status },
      { "encoding", draw_empty=false, cond = function() return PCFG.statusline_declutter < 2 and true or false end }
    },
    lualine_y = { { "progress", cond = function() return PCFG.statusline_declutter < 1 and true or false end, draw_empty=false} },
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
  tabline = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { require'tabline'.tabline_buffers },
    lualine_x = { require'tabline'.tabline_tabs },
    lualine_y = {'filename'},
    lualine_z = {}
  },
  winbar = {},
  inactive_winbar = {},
  extensions = {my_extension},
})

local M = {}

function M.fixhl()
  if Tweaks.theme.disable == true then return end
  local fix_hlg = { "StatusLine", "StatusLineNC", "Tabline", "TabLineFill", "TabLineSel", "Winbar", "WinbarNC" }
  local hl = vim.api.nvim_get_hl(0, { name = "LuaLine" })
  for _,v in ipairs(fix_hlg) do
    vim.api.nvim_set_hl(0, v, { fg = hl.fg, bg = hl.bg })
  end
end

function M.update_internal_theme()
  setup_theme()
  require("lualine").setup({
    options = {
      theme = Tweaks.statusline.lualine.theme == "internal" and lualine_internal_theme() or Tweaks.statusline.lualine.theme
    }
  })
  M.fixhl()
end

return M

