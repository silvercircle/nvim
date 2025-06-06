local my_extension = { sections = { lualine_a = {'filetype'} }, filetypes = {'NvimTree'} }
local navic = nil

local LuaLineColors = {
  white = "#ffffff",
  accent_fg = "#106010",   -- M.T.accent_fg,
  accent_bg = "#106060",    -- M.T.accent_color,
  darkestcyan = "#005f5f",
  darkestblue = "#002f47",
  insertbg = "#802020",   -- M.T.alt_accent_color,
  visualbg = "#2f47df",
  statuslinebg = "#263031",   -- M.T[conf.variant].statuslinebg,
}

---@diagnostic disable-next-line
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
         (vim.b[0].snacks_indent == false and "i" or (PCFG.indent_guides and "I" or "i")) ..
         (disabled and "a" or "A")
end

local function status_indicators()
  return (PCFG.treesitter_context == true and "C" or "c") ..
         (PCFG.is_dev == true and "D" or "d") ..
         (PCFG.autopair == true and "A" or "a") ..
         (PCFG.cmp_automenu and 'O' or 'o') ..
         (PCFG.cmp_ghost and 'G' or 'g') ..
         (PCFG.lsp.inlay_hints and 'H' or 'h')
end

local function get_mem()
  return string.format("%.1fM", collectgarbage("count") / 1024)
end

--- internal global function to create the lualine color theme
--- @return table
local function lualine_internal_theme()
  return {
    normal = {
      a = {
        fg = LuaLineColors.accent_fg,
        bg = LuaLineColors.accent_bg, --[[, gui = 'bold']]
      },
      b = { fg = LuaLineColors.white, bg = LuaLineColors.darkestblue },
      c = "LuaLine",
      x = "LuaLine",
    },
    insert = {
      a = { fg = LuaLineColors.white, bg = LuaLineColors.insertbg },
      b = { fg = LuaLineColors.white, bg = LuaLineColors.darkestblue },
      c = "LuaLine",
      x = "LuaLine",
    },
    visual = {
      a = {
        fg = LuaLineColors.white,
        bg = LuaLineColors.visualbg, --[[, gui = 'bold']]
      },
    },
    replace = { a = { fg = LuaLineColors.white, bg = LuaLineColors.insertbg } },
    inactive = {
      a = "CursorLine",
      b = "LuaLine",
      c = "LuaLine"
    }
  }
end


local function setup_theme()
  if Tweaks.theme.disable == false then
    local T = require("darkmatter").T

    LuaLineColors.accent_fg = T.accent_fg
    LuaLineColors.accent_bg = T.accent_color
    LuaLineColors.insertbg = T.alt_accent_color
    LuaLineColors.statuslinebg = vim.api.nvim_get_hl(0, { name = "LuaLine" }).bg
    local _bg = vim.api.nvim_get_hl(0, { name="Visual" }).bg
    local _fg = vim.api.nvim_get_hl(0, { name="Fg" }).fg
    local _normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
    vim.api.nvim_set_hl(0, "WinBarULSep", { fg = _bg, bg = _normal_bg })
    vim.api.nvim_set_hl(0, "WinBarUL", { fg = _fg, bg = _bg, sp = _bg, underline = true })
  end
end
setup_theme()

local function getWordsV2()
  if CGLOBALS.cur_bufsize > CFG.wordcount_limit * 1024 * 1024 then
    return "NaN"
  end
  local wc = vim.fn.wordcount()
  if wc["visual_words"] then -- text is selected in visual mode
    return wc["visual_words"] .. "W/" .. wc['visual_chars'] .. "C (Vis)"
  else -- all of the document
    return wc["words"]
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
  if navic == nil then
    navic = require("subspace.nav")
  end
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
     return string.format("> %s", string)
   end
  end,
  separator = { left = "", right = "" },
  -- separator = "",
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
      statusline = { "SymbolsSidebar", "SymbolsHelp", "SymbolsSearch",
        "terminal", "sysmon", "weather", Tweaks.tree.filetype, "query_rt", "DiffviewFiles", "neominimap" },
      winbar = { "terminal", "qf", Tweaks.tree.filetype, "alpha", "sysmon", "weather", "query_rt", "help",
        "dap-repl", "dapui_console", "dapui_watches", "dapui_stacks", "dapui_scopes", "dapui_breakpoints",
        "snacks_picker_preview", "snacks_dashboard", "SymbolsSidebar", "SymbolsHelp", "SymbolsSearch", "DiffviewFiles", "neominimap" },
      tabline = {},
    },
    -- ignore_focus = {"dap-repl", "dapui_console", "dapui_watches", "dapui_stacks", "dapui_scopes", "dapui_breakpoints"},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = Tweaks.statusline.lualine.refresh,
      tabline = 10000, -- note that we do not use it in favor of cokeline
      winbar = Tweaks.statusline.lualine.refresh,
    },
  },
  sections = {
    lualine_a = { "mode", "o:formatoptions", " : ",
    {
      "o:textwidth",
      fmt = function(str)
        return string.format("%s:%s:%s", str, vim.api.nvim_get_option_value("wrap", { win = 0 }) == true and "wr" or "no", vim.o.foldmethod)
      end
    },
    }, -- display textwidth after formattingoptions
    lualine_b = { "branch", "diff", "diagnostics"  },
    lualine_c = {"filename", "searchcount"--[[, { get_permissions_color }]] },
    lualine_x = {
      { indentstats, cond = function() return PCFG.statusline_verbosity >= 3 and true or false end },
      {
        -- show unicode for character under cursor in hex and decimal
        -- "%05B - %06b",
        "%05B",
        fmt = function(str)
          return string.format("U:0x%s", str)
        end
      },
      "filetype",
      { "fileformat", cond = function() return PCFG.statusline_verbosity >= 4 and true or false end },
      { status },
      { "encoding", draw_empty=false, cond = function() return PCFG.statusline_verbosity >= 4 and true or false end }
    },
    lualine_y = {
      { "progress", cond = function() return PCFG.statusline_verbosity >= 3 and true or false end, draw_empty=false},
      { get_mem, cond = function() return PCFG.statusline_verbosity >= 2 and true or false end, draw_empty=false},
    },
    -- word counter via custom function
    lualine_z = { { getWordsV2 }, "location" },
  },
  inactive_sections = {
    lualine_a = { "mode", "o:formatoptions", " : ",
    {
      "o:textwidth",
      fmt = function(str)
        return string.format("%s:%s:%s", str, vim.api.nvim_get_option_value("wrap", { win = 0 }) == true and "wr" or "no", vim.o.foldmethod)
      end
    }},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  winbar = {
    --- winbar top/left shows either the lsp context, or the lsp progress message
    lualine_a = {
      {
        'filename',
        padding = { left = 1, right = 0 },
        path = 4,
        shorting_target = 60,
        --separator = "",
        separator = { left = "", right = "" },
        color = 'WinBarFilename'
      },
      navic_component
    },
    lualine_c = {
      {
        padding,
        color = "WinBarInvis",
        separator = { left = "", right = "" },
      },
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
        cond = function() return PCFG.show_indicators end
      },
      {
        status_indicators,
        color = "WinBarUL",
        padding = 0,
        cond = function() return PCFG.show_indicators end
      },
    },
    lualine_z = {
      {
        "",
        padding = 0,
        separator = { left = "", right = "" },
        draw_empty = true,
        -- color = tab_sep_color, -- { fg = colors.T.accent_color, bg = colors.T[PCFG.theme_variant].bg },
        fmt = function()
          return ""
        end,
        cond = function() return not PCFG.show_indicators end
      }
    }
  },
  inactive_winbar = {
    lualine_a = { { full_filename, color = 'WinBarNC' } }
  },
  extensions = {my_extension, 'nvim-dap-ui', 'quickfix'},
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

