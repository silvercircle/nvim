require("dropbar").setup({
  bar = {
    padding = {
      left = 2,
      right = 2
    }
  },
  menu = {
    win_configs = {
      border = "none"
    },
    keymaps = {
      ['<esc>'] = function()
        vim.cmd("wincmd c")
      end
    }
  },
  fzf = {
    win_configs = {
      border = "none"
    }
  }
})
