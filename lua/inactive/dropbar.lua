require("dropbar").setup({
  bar = {
    padding = {
      left = 2,
      right = 2
    }
  },
  sources = {
    path = {
      relative_to = function()
        return vim.fn.expand("%:p:h")
      end
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
