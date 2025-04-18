local dressing_select_default = {
  -- Set to false to disable the vim.ui.select implementation
  enabled = true,

  -- Priority list of preferred vim.select implementations
--    backend = { "builtin", "nui", "telescope" },
  backend = { "builtin" },

  -- Trim trailing `:` from prompt
  trim_prompt = true,

  -- Options for telescope selector
  -- These are passed into the telescope picker directly. Can be used like:
  -- telescope = require('telescope.themes').get_ivy({...})

  telescope = nil,

  -- Options for nui Menu
  nui = {
    position = "50%",
    size = nil,
    relative = "editor",
    border = {
      style = "single",
    },
    buf_options = {
      swapfile = false,
      filetype = "DressingSelect",
    },
    win_options = {
      winblend = 0,
      winhighlight = "CursorLine:Visual"
    },
    max_width = 80,
    max_height = 40,
    min_width = 40,
    min_height = 2,
  },

  -- Options for built-in selector
  builtin = {
    -- do not show the line numbers for each option
    show_numbers = false,
    -- These are passed to nvim_open_win
    -- anchor = "NW",
    border = Borderfactory(CGLOBALS.perm_config.float_borders),
    -- 'editor' and 'win' will default to being centered
    relative = "editor",

    buf_options = { filetype = "DressingSelect" },
    win_options = {
      -- Window transparency (0-100)
      winblend = 0,
      cursorlineopt = "both"
    },

    -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- the min_ and max_ options can be a list of mixed types.
    -- max_width = {140, 0.8} means "the lesser of 140 columns or 80% of total"
    width = nil,
    max_width = { 140, 0.8 },
    min_width = { 20, 0.1 },
    height = nil,
    max_height = 0.9,
    min_height = { 2, 0.0 },

    -- Set to `false` to disable
    mappings = {
      ["<Esc>"] = "Close",
      ["<C-c>"] = "Close",
      ["<CR>"] = "Confirm",
    },

    override = function(conf)
      -- This is the config that will be passed to nvim_open_win.
      -- Change values here to customize the layout
      return conf
    end,
  },

  -- Used to override format_item. See :help dressing-format
  format_item_override = {},
}
require('dressing').setup({
  input = {
    -- Set to false to disable the vim.ui.input implementation
    enabled = true,

    -- Default prompt string
    default_prompt = "Input:",

    -- Can be 'left', 'right', or 'center'
    prompt_align = "left",

    -- When true, <Esc> will close the modal
    insert_only = true,

    -- When true, input will start in insert mode.
    start_in_insert = true,

    -- These are passed to nvim_open_win
    -- anchor = "SW",
    border = CGLOBALS.perm_config.float_borders,
    -- 'editor' and 'win' will default to being centered
    relative = "editor",

    -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    prefer_width = 40,
    width = nil,
    -- min_width and max_width can be a list of mixed types.
    -- min_width = {20, 0.2} means "the greater of 20 columns or 20% of total"
    max_width = { 140, 0.9 },
    min_width = { 40, 0.2 },

    buf_options = { filetype = "DressingInput" },
    win_options = {
      -- Window transparency (0-100)
      winblend = 0,
      -- Disable line wrapping
      wrap = false,
    },

    -- Set to `false` to disable
    mappings = {
      n = {
        ["<Esc>"] = "Close",
        ["<CR>"] = "Confirm",
      },
      i = {
        ["<C-c>"] = "Close",
        ["<CR>"] = "Confirm",
        ["<Up>"] = "HistoryPrev",
        ["<Down>"] = "HistoryNext",
      },
    },

    override = function(conf)
      -- This is the config that will be passed to nvim_open_win.
      -- Change values here to customize the layout
      return conf
    end,

    -- see :help dressing_get_config
    get_config = nil,
  },
  select = {
    get_config = function(opts)
      if opts.kind == 'legendary.nvim' then
        return {
          telescope =
            require("local_utils").command_center_theme({
              sorter = require('telescope.sorters').fuzzy_with_index_bias({})
            })
          }
      else
        return dressing_select_default
      end
    end
    -- see :help dressing_get_config
  }
})
