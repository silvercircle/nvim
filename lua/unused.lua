-- nvim-cmp autocomplete border
cmp.setup {
  window = {
    completion = { -- rounded border; thin-style scrollbar
      border = 'rounded',
      scrollbar = '║',
    },
    documentation = { -- no border; native-style scrollbar
      border = nil,
      scrollbar = '',
      -- other options
    },
  },
  -- other options
}

-- satellite - a scroll bar plugin

require('satellite').setup {
  current_only = false,
  winblend = 20,
  zindex = 40,
  excluded_filetypes = {},
  width = 2,
  handlers = {
    search = {
      enable = true,
    },
    diagnostic = {
      enable = true,
    },
    gitsigns = {
      enable = true,
    },
    marks = {
      enable = true,
      key = 'm',
      show_builtins = false, -- shows the builtin marks like [ ] < >
    },
  },
}

