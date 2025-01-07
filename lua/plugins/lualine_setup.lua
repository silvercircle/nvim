local my_extension = { sections = { lualine_a = {'filetype'} }, filetypes = {'NvimTree'} }
local _, navic = pcall(require, "nvim-navic")
local colors = Config.theme

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

local function status_indicators()
  return (__Globals.perm_config.treesitter_context == true and "C" or "c") ..
         (__Globals.perm_config.debug == true and "D" or "d") ..
         (__Globals.perm_config.transbg == true and "T" or "t") ..
         (__Globals.perm_config.autopair == true and "A" or "a") ..
         (vim.g.tweaks.completion.version == 'nvim-cmp' and (__Globals.perm_config.cmp_autocomplete and 'O' or 'o') or '')
end

local function getWordsV2()
  if __Globals.cur_bufsize > Config.wordcount_limit * 1024 * 1024 then
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

-- the internal theme is defined in config.lua
local function theme()
  return colors.Lualine_internal_theme()
end
local _bg = vim.api.nvim_get_hl(0, { name="Visual" }).bg
--local _bg = theme().normal.b.bg

vim.api.nvim_set_hl(0, "WinBarULSep", { fg = _bg, bg = colors.T[__Globals.perm_config.theme_variant].bg })
vim.api.nvim_set_hl(0, "WinBarUL", { fg = theme().normal.b.fg, bg = _bg })

local navic_component = {
  navic_context,
  fmt = function(string)
    if #string < 2 then
      return ""
    else
     --return string.format("%s: %s", vim.lsp.get_active_clients( {bufnr=0} )[1].name, string)
     return string.format("%s", string)
   end
  end,
  separator = "",
  color = 'WinBarFilename',
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
      statusline = { "Outline", 'terminal', 'query', 'qf', 'BufList', 'sysmon', 'weather', "NvimTree", "neo-tree", "aerial", "Trouble" },
      winbar = { 'Outline', 'terminal', 'query', 'qf', 'NvimTree', 'neo-tree', 'alpha', 'BufList', 'sysmon', 'weather', 'aerial', 'Trouble',
                 'dap-repl', 'dapui_console', 'dapui_watches', 'dapui_stacks', 'dapui_scopes', 'dapui_breakpoints' },
      tabline = {},
    },
    -- ignore_focus = {'NvimTree', 'neo-tree'},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 2000,
      tabline = 2000,
      winbar = 2000,
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
    lualine_c = {"filename", "searchcount", { get_permissions_color } },
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
      { "encoding", draw_empty=false, cond = function() return __Globals.perm_config.statusline_declutter < 3 and true or false end }
    },
    lualine_y = { { "progress", cond = function() return __Globals.perm_config.statusline_declutter < 2 and true or false end, draw_empty=false} },
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
  winbar = {
    --- winbar top/left shows either the lsp context, or the lsp progress message
    lualine_a = {
      vim.g.tweaks.breadcrumb == 'navic' and navic_component or aerial_component,
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
        cond = function() return __Globals.perm_config.show_indicators end
      },
      {
        status_indicators,
        color = "WinBarUL",
        padding = 0,
        cond = function() return __Globals.perm_config.show_indicators end
      },
    },
    lualine_z = {
      {
        "",
        padding = 0,
        separator = { left = "", right = "" },
        draw_empty = true,
        color = { fg = colors.T.accent_color, bg = colors.T[__Globals.perm_config.theme_variant].bg },
        fmt = function()
          return ""
        end,
        cond = function() return not __Globals.perm_config.show_indicators end
      },
      {
        'filename',
        padding = 0,
        path = 4,
        shorting_target = 60,
        --separator = "",
        --separator = { left = "", right = "" },
        color = 'WinBarFilename'
      }
    }
  },
  inactive_winbar = vim.g.tweaks.breadcrumb ~= 'dropbar' and {
    -- lualine_x = { { win_pad, color = 'Normal' } },
    lualine_z = { { full_filename, color = 'WinBarNC' }, 'tabs' }
  } or {},
  extensions = {my_extension},
})

