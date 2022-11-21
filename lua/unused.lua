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

