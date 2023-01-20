-- devicons for lua plugins (e.g. Telescope, neotree, nvim-tree among others  need them)
require("nvim-web-devicons").setup({
  override = {
    zsh = {
      icon = "",
      color = "#428850",
      cterm_color = "65",
      name = "Zsh",
    },
  },
  -- globally enable different highlight colors per icon (default to true)
  -- if set to false all icons will have the default icon's color
  color_icons = true,
  -- globally enable default icons (default to false)
  -- will get overriden by `get_icons` option
  default = true
})

--- count words in either the entire document or the current visual mode selection.
--- required for the lualine plugin
local function getWordsV2()
  local wc = vim.fn.wordcount()
  if wc["visual_words"] then -- text is selected in visual mode
    return wc["visual_words"] .. " Words (Selection)"
  else -- all of the document
    return wc["words"] .. " Words"
  end
end

-- -- lspsaga plugin: display the current symbol context in the winbar or
-- local sagastatus, saga = pcall(require, "lspsaga.symbolwinbar")
-- local function getsagasymbol()
--   if sagastatus == true then
--     return saga.get_symbol_node()
--   end
--   return ''
-- end

local function actual_tabline()
  if vim.g.config.use_cokeline == true then
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

-- the internal theme is defined in config.lua
local function theme()
  if vim.g.lualine_theme == 'internal' then
    return Lualine_internal_theme()
  else
    return vim.g.lualine_theme
  end
end

require("lualine").setup({
  options = {
    icons_enabled = true,
    theme = theme(),
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = {
      statusline = { "Outline", "neo-tree", 'terminal', 'Treesitter', 'qf', 'lspsagaoutline'},
      winbar = {},
      tabline = {},
    },
    ignore_focus = {'NvimTree'},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 2000,
      tabline = 3000,
      winbar = 5000,
    },
  },
  sections = {
    lualine_a = { "mode", "o:formatoptions", " : ", "o:textwidth" }, -- display textwidth after formattingoptions
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename", "searchcount" },
    lualine_x = {
      "encoding",
      {
        -- show unicode for character under cursor in hex and decimal
        "%05B - %06b",
        fmt = function(str)
          return string.format("U:0x%s", str)
        end,
      },
      "fileformat",
      "filetype",
    },
    lualine_y = { "progress" },
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
  winbar = {},
  --  lualine_a = { { saga_symbols} }
  inactive_winbar = {},
  extensions = {},
})
-- setup cokeline plugin. It provides a buffer line (aka tab-bar)
--local sidebar_or_tree = vim.g.features['sidebar']['enable'] == true and true or false
local sidebar_or_tree = false
local treename = 'neo-tree' -- vim.g.features['neotree']['enable'] and 'neo-tree' or 'NvimTree'

require('cokeline').setup({
  -- Cokeline_theme() is defined in config.lua
  buffers = {
    filter_visible = function(buffer) return not(buffer['type'] == 'terminal' and true or false) end
  },
  default_hl = Cokeline_theme().hl,
  -- header for the neo-tree sidebar
  sidebar = {
    -- filetype = 'neo-tree',
    -- filetype = 'SidebarNvim',
    filetype = sidebar_or_tree == true and 'SidebarNvim' or treename,
    components = {
      {
        text = sidebar_or_tree == true and '  Side Bar' or '  File Explorer',
        bg = vim.g.cokeline_bg,
        style = 'bold',
      },
    }
  },
  components = {
    { text = function(buffer) return (buffer.index ~= 1) and '▏' or ' ' end, },
    {
      text = function(buffer) return buffer.devicon.icon end,
      fg = function(buffer) return buffer.devicon.color end
    },
    {
      text = function(buffer) return Truncate(buffer.filename, vim.g.cokeline_filename_width) end,
      style = function(buffer) return buffer.is_focused and 'bold' or nil end
    },
    { text = ' ' },
    {
       text = function(buffer) return buffer.is_modified and '●' or '' end,
       fg = function(buffer) return buffer.is_modified and Cokeline_theme().unsaved or nil end,
    },
    { text = '  ' }
  }
})

require("indent_blankline").setup({
  -- for example, context is off by default, use this to turn it on
  show_current_context = false,
  show_current_context_start = false,
  show_end_of_line = true,
  show_foldtext = false,
  -- „rainbow style“ indent guides - if you want it, uncomment it. the highlight groups are already
  -- defined in the my_sonokai scheme.
  char_highlight_list = vim.g.config.use_rainbow_indentguides == true and {
    "IndentBlanklineIndent1",
    "IndentBlanklineIndent2",
    "IndentBlanklineIndent3",
    "IndentBlanklineIndent4",
    "IndentBlanklineIndent5",
    "IndentBlanklineIndent6",
  } or {},
  filetype_exclude = {
    "startify"
  }
})

require("gitsigns").setup({
  _refresh_staged_on_update = false,
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    interval = 2000,
    follow_files = true,
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
  sign_priority = 0,
  update_debounce = 1000,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    border = "single",
    style = "minimal",
    relative = "cursor",
    row = 0,
    col = 1,
  },
  yadm = {
    enable = false,
  },
})

require("scrollbar").setup({
  show = true,
  show_in_active_only = false,
  throttle_ms = 200,
  set_highlights = true,
  folds = 5000, -- handle folds, set to number to disable folds if no. of lines in buffer exceeds this
  max_lines = false, -- disables if no. of lines in buffer exceeds this
  hide_if_all_visible = false, -- Hides everything if all lines are visible
  handle = {
    text = " ",
    color = nil,
    color_nr = nil,
    highlight = "ScrollView",
    hide_if_all_visible = true, -- Hides handle if all lines are visible
  },
  marks = {
    Cursor = {
      text = "■",
      priority = 0,
      color = nil,
      color_nr = nil,
      highlight = "WarningMsg",
    },
    Search = {
      text = { "●" },
      priority = 1,
      color = nil,
      color_nr = nil,
      highlight = "PurpleBold",
    },
    Error = {
      text = { "-", "=" },
      priority = 2,
      color = nil,
      color_nr = nil,
      highlight = "DiagnosticVirtualTextError",
    },
    Warn = {
      text = { "-", "=" },
      priority = 3,
      color = nil,
      color_nr = nil,
      highlight = "DiagnosticVirtualTextWarn",
    },
    Info = {
      text = { "-", "=" },
      priority = 4,
      color = nil,
      color_nr = nil,
      highlight = "DiagnosticVirtualTextInfo",
    },
    Hint = {
      text = { "-", "=" },
      priority = 5,
      color = nil,
      color_nr = nil,
      highlight = "DiagnosticVirtualTextHint",
    },
    Misc = {
      text = { "-", "=" },
      priority = 6,
      color = nil,
      color_nr = nil,
      highlight = "Normal",
    },
    GitAdd = {
      text = "+",
      priority = 7,
      color = nil,
      color_nr = nil,
      highlight = "GitSignsAdd",
    },
    GitChange = {
      text = "*",
      priority = 7,
      color = nil,
      color_nr = nil,
      highlight = "GitSignsChange",
    },
    GitDelete = {
      text = "—",
      priority = 7,
      color = nil,
      color_nr = nil,
      highlight = "GitSignsDelete",
    },
  },
  excluded_buftypes = {
    "terminal",
  },
  excluded_filetypes = {
    "prompt",
    "TelescopePrompt",
    "noice",
    "neo-tree",
--    "Outline",
    "DressingSelect",
    "DressingInput",
    "mason",
    "lazy",
    "startify",
    "lspinfo"
  },
  autocmd = {
    render = {
      "BufWinEnter",
      "TabEnter",
      "TermEnter",
      "WinEnter",
      "CmdwinLeave",
      "TextChanged",
      "VimResized",
      "WinScrolled",
    },
    clear = {
      "BufWinLeave",
      "TabLeave",
      "TermLeave",
      "WinLeave",
    },
  },
  handlers = {
    cursor = true,
    diagnostic = true,
    gitsigns = true, -- Requires gitsigns
    handle = true,
    search = true, -- Requires hlslens
  },
})

require("hlslens").setup({
--  calm_down = true,
--  nearest_float_when = "always",
--  nearest_only = false,
  build_position_cb = function(plist, _, _, _)
    require("scrollbar.handlers.search").handler.show(plist.start_pos)
  end
})

require 'colorizer'.setup {
  'css';
  'scss';
  html = {
    mode = 'foreground';
  }
}

require("quickfavs").setup({
 telescope_theme = Telescope_dropdown_theme,
 file_browser_theme = {
   theme = Telescope_vertical_dropdown_theme,
   layout_config = {
     preview_height = 0.4
   }
 }
})
require('mini.move').setup()

