require("scrollbar").setup({
  show = true,
  show_in_active_only = false,
  throttle_ms = 100,
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
    "nofile"
  },
  excluded_filetypes = {
    "prompt",
    "mason",
    "lazy",
    "alpha",
    "NvimTree",
    "cmp_menu",
    "cmp_docs",
    "blink-cmp-menu",
    "blink-cmp-documentation",
    "weather",
    "sysmon",
    "Glance",
    "fzf",
    "snacks_picker_list",
    "snacks_picker_input",
    "snacks_input",
    "neominimap",
    "oil_preview"
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
    search = true -- Requires hlslens
  },
})

