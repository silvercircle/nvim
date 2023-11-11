utils = require("dropbar.utils")
require("dropbar").setup({
  bar = {
    padding = {
      left = 2,
      right = 2
    }
  },
  menu = {
    win_configs = {
      border = "single"
    },
    keymaps = {
      ['<esc>'] = function()
        vim.cmd("wincmd c")
      end
    }
  },
  fzf = {
    win_configs = {
      border = "single"
    }
  }
})
