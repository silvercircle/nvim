local _s = vim.g.lspkind_symbols
CFG.outline_plugin = require("outline")
CFG.outline_plugin.setup(
{
outline_window = {
    -- Where to open the split window: right/left
    position = 'right',
    split_command = 'rightbelow vs',
    -- Percentage or integer of columns
    width = PCFG.outline.width,
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
    auto_jump = true,

    -- Vim options for the outline window
    show_numbers = false,
    show_relative_numbers = false,
    jump_highlight_duration = false,
    center_on_jump = false,
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
    hide_cursor = false,

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
      follow = { "CursorHold", "CursorHoldI" },
      items = {--[['InsertLeave',]] --[['WinEnter',]] 'BufEnter', --[['BufWinEnter',]] --[['TabEnter',]] 'BufWritePost' }
    }
    -- lock = "window"
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
    priority = { 'lsp', 'treesitter', 'markdown', 'norg' },
    lsp = {
      -- Lsp client names to ignore
      blacklist_clients = { "texlab", "marksman" },
    },
  },

  symbols = {
    -- filter symbols for certain filtypes. Lua is particularly "spammy" and can create
    -- long symbol trees.
    filter = {
      lua = { "Array", "Variable", "Boolean", "Constant", "String", exclude = true}
    },
    icon_fetcher = nil,
    -- 3rd party source for fetching icons. Fallback if icon_fetcher returned
    -- empty string. Currently supported values: 'lspkind'
    icon_source = nil,
    -- The next fall back if both icon_fetcher and icon_source has failed, is
    -- the custom mapping of icons specified below. The icons table is also
    -- needed for specifying hl group.
    -- Changed in this fork to fix deprecated icons not showing.
    icons = {
      File          = { icon = _s.File, hl = "@text.uri" },
      Module        = { icon = _s.Module, hl = "Include" },
      Namespace     = { icon = _s.Namespace, hl = "@namespace" },
      Package       = { icon = _s.Package, hl = "Include" },
      Class         = { icon = _s.Class, hl = "Class" },
      Method        = { icon = _s.Method, hl = "@method" },
      Property      = { icon = _s.Property, hl = "@property" },
      Field         = { icon = _s.Field, hl = "@field" },
      Constructor   = { icon = _s.Constructor, hl = "@constructor" },
      Enum          = { icon = _s.Enum, hl = "@type" },
      Interface     = { icon = _s.Interface, hl = "Interface" },
      Function      = { icon = _s.Function, hl = "@function" },
      Variable      = { icon = _s.Variable, hl = "@constant" },
      Constant      = { icon = _s.Constant, hl = "@constant" },
      String        = { icon = _s.String, hl = "@string" },
      Number        = { icon = _s.Number, hl = "@number" },
      Boolean       = { icon = _s.Boolean, hl = "@boolean" },
      Array         = { icon = _s.Array, hl = "@constant" },
      Object        = { icon = _s.Object, hl = "@type" },
      Key           = { icon = _s.Key, hl = "@type" },
      Null          = { icon = _s.Null, hl = "@type" },
      EnumMember    = { icon = _s.EnumMember, hl = "@field" },
      Struct        = { icon = _s.Struct, hl = "@type" },
      Event         = { icon = _s.Event, hl = "@type" },
      Operator      = { icon = _s.Operator, hl = "@operator" },
      TypeParameter = { icon = _s.TypeParameter, hl = "@parameter" },
      Component     = { icon = _s.Module, hl = "@function" },
      Fragment      = { icon = _s.Array, hl = "@constant" },
      -- Added ccls symbols in this fork
      TypeAlias     = { icon = _s.Type, hl = '@type' },
      Parameter     = { icon = _s.TypeParameter, hl = '@parameter' },
      StaticMethod  = { icon = _s.Method, hl = '@function' },
      Macro         = { icon = ' ', hl = '@macro' },
    },
  },
})
