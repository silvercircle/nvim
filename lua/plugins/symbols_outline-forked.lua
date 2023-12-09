Config.outline_plugin = require("outline")
Config.outline_plugin.setup(
{
outline_window = {
    -- Where to open the split window: right/left
    position = 'right',
    split_command = 'rightbelow vs',
    -- Percentage or integer of columns
    width = __Globals.perm_config.outline.width,
    -- Whether width is relative to the total width of nvim
    -- When relative_width = true, this means take 25% of the total
    -- screen width for outline window.
    relative_width = false,

    -- Behaviour changed in this fork:
    -- Auto close the outline window if goto_location is triggered and not for
    -- peek_location
    auto_close = false,
    -- Automatically go to location in code when navigating outline window.
    -- Only in this fork
    auto_goto = true,

    -- Vim options for the outline window
    show_numbers = false,
    show_relative_numbers = false,

    -- Only in this fork (this and the one below)
    show_cursorline = false,
    -- Enable this when you enabled cursorline so your cursor color can
    -- blend with the cursorline, in effect, as if your cursor is hidden
    -- in the outline window.
    -- This is useful because with cursorline, there isn't really a need
    -- to know the vertical column position of the cursor and it may even
    -- be distracting, rendering lineno/guides/icons unreadable.
    -- This makes your line of cursor look the same as if the cursor wasn't
    -- focused on the outline window.
    hide_cursor = true,

    -- Whether to wrap long lines, or let them flow off the window
    wrap = false,
    -- Only in this fork:
    -- Whether to focus on the outline window when it is opened.
    -- Set to false to remain focus on your previous buffer when opening
    -- symbols-outline.
    focus_on_open = false,
    -- Only in this fork:
    -- Winhighlight option for outline window.
    -- See :help 'winhl'
    -- To change background color to "CustomHl" for example, append "Normal:CustomHl".
    -- Note that if you're adding highlight changes, you should append to this
    -- default value, otherwise details/lineno will not have highlights.
    winhl = "SymbolsOutlineDetails:Comment,SymbolsOutlineLineno:LineNr",
    unfold_on_goto = "zv"
  },

  outline_items = {
    -- Whether to highlight the currently hovered symbol (high cpu usage)
    highlight_hovered_item = false,
    -- Show extra details with the symbols (lsp dependent)
    show_symbol_details = true,
    -- Only in this fork.
    -- Show line numbers of each symbol next to them.
    -- Why? See this comment:
    -- https://github.com/simrat39/symbols-outline.nvim/issues/212#issuecomment-1793503563
    show_symbol_lineno = false,
    auto_set_cursor = true,
    auto_update_events = {
      follow = { "CursorHold" },
      items = { 'InsertLeave', --[['WinEnter',]] 'BufEnter', --[['BufWinEnter',]] --[['TabEnter',]] 'BufWritePost' }
    },
    lock = "window"
  },

  -- Options for outline guides.
  -- Only in this fork
  guides = {
    enabled = true,
    markers = {
      bottom = '└',
      middle = '├',
      vertical = '│',
      horizontal = '─',
    },
  },

  symbol_folding = {
    -- Depth past which nodes will be folded by default
    autofold_depth = false,
    -- Automatically unfold hovered symbol
    auto_unfold_hover = true,
    markers = { '', '' },
  },

  preview_window = {
    -- Automatically open preview of code location when navigating outline window
    auto_preview = false,
    -- Automatically open hover_symbol when opening preview (see keymaps for
    -- hover_symbol).
    -- If you disable this you can still open hover_symbol using your keymap
    -- below.
    -- Only in this fork
    open_hover_on_preview = false,
    -- Only in this fork:
    width = 50,     -- Percentage or integer of columns
    min_width = 50, -- This is the number of columns
    -- Whether width is relative to the total width of nvim.
    -- When relative_width = true, this means take 50% of the total
    -- screen width for preview window, ensure the result width is at least 50
    -- characters wide.
    relative_width = true,
    -- Border option for floating preview window.
    -- Options include: single/double/rounded/solid/shadow or an array of border
    -- characters.
    -- See :help nvim_open_win() and search for "border" option.
    border = 'single',
    -- winhl options for the preview window, see ':h winhl'
    winhl = '',
    -- Pseudo-transparency of the preview window, see ':h winblend'
    winblend = 0
  },

  -- These keymaps can be a string or a table for multiple keys
  keymaps = {
    show_help = '?',
    close = {"<Esc>", "q"},
    -- Jump to symbol under cursor.
    -- It can auto close the outline window when triggered, see
    -- 'auto_close' option above.
    goto_location = "<Cr>",
    -- Jump to symbol under cursor but keep focus on outline window.
    -- Renamed in this fork!
    peek_location = "o",
    -- Only in this fork (next 2):
    -- Visit location in code and close outline immediately
    goto_and_close = "<S-Cr>",
    -- Change cursor position of outline window to the current location in code.
    -- "Opposite" of goto/peek_location.
    restore_location = "<C-g>",
    -- Open LSP/provider-dependent symbol hover information
    hover_symbol = "<C-space>",
    -- Preview location code of the symbol under cursor
    toggle_preview = "K",
    -- Symbol actions
    rename_symbol = "r",
    code_actions = "a",
    -- These fold actions are collapsing tree nodes, not code folding
    fold = "h",
    unfold = "l",
    fold_toggle = "<Tab>",       -- Only in this fork
    -- Toggle folds for all nodes.
    -- If at least one node is folded, this action will fold all nodes.
    -- If all nodes are folded, this action will unfold all nodes.
    fold_toggle_all = "<S-Tab>", -- Only in this fork
    fold_all = "W",
    unfold_all = "E",
    fold_reset = "R",
    -- Only in this fork:
    -- Move down/up by one line and peek_location immediately.
    down_and_goto = "<C-j>",
    up_and_goto = "<C-k>",
  },

  providers = {
    lsp = {
      -- Lsp client names to ignore
      blacklist_clients = {},
    },
  },

  symbols = {
    -- Symbols to ignore.
    -- Possible values are the Keys in the icons table below.
    blacklist = {"Array"},
    -- Added in this fork:
    -- You can use a custom function that returns the icon for each symbol kind.
    -- This function takes a kind (string) as parameter and should return an
    -- icon.
    icon_fetcher = nil,
    -- 3rd party source for fetching icons. Fallback if icon_fetcher returned
    -- empty string. Currently supported values: 'lspkind'
    icon_source = nil,
    -- The next fall back if both icon_fetcher and icon_source has failed, is
    -- the custom mapping of icons specified below. The icons table is also
    -- needed for specifying hl group.
    -- Changed in this fork to fix deprecated icons not showing.
    icons = {
      File = { icon = "󰈔", hl = "@text.uri" },
      Module = { icon = "󰆧", hl = "@namespace" },
      Namespace = { icon = "󰅪", hl = "@namespace" },
      Package = { icon = "󰏗", hl = "@namespace" },
      Class = { icon = "𝓒", hl = "@type" },
      Method = { icon = "ƒ", hl = "@method" },
      Property = { icon = "", hl = "@method" },
      Field = { icon = "󰆨", hl = "@field" },
      Constructor = { icon = "", hl = "@constructor" },
      Enum = { icon = "ℰ", hl = "@type" },
      Interface = { icon = "󰜰", hl = "@type" },
      Function = { icon = "", hl = "@function" },
      Variable = { icon = "", hl = "@constant" },
      Constant = { icon = "", hl = "@constant" },
      String = { icon = "𝓐", hl = "@string" },
      Number = { icon = "#", hl = "@number" },
      Boolean = { icon = "⊨", hl = "@boolean" },
      Array = { icon = "󰅪", hl = "@constant" },
      Object = { icon = "⦿", hl = "@type" },
      Key = { icon = "🔐", hl = "@type" },
      Null = { icon = "NULL", hl = "@type" },
      EnumMember = { icon = "", hl = "@field" },
      Struct = { icon = "𝓢", hl = "@type" },
      Event = { icon = "🗲", hl = "@type" },
      Operator = { icon = "+", hl = "@operator" },
      TypeParameter = { icon = "𝙏", hl = "@parameter" },
      Component = { icon = "󰅴", hl = "@function" },
      Fragment = { icon = "󰅴", hl = "@constant" },
      -- Added ccls symbols in this fork
      TypeAlias =  { icon = ' ', hl = '@type' },
      Parameter = { icon = ' ', hl = '@parameter' },
      StaticMethod = { icon = ' ', hl = '@function' },
      Macro = { icon = ' ', hl = '@macro' },
    },
  },
})
