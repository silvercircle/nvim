local lazy = require("lazy")
lazy.setup({
  -- treesitter + friends
  {
    'nvim-treesitter/nvim-treesitter',
    event = "VeryLazy",
    branch = "master",
    config = function()
      require("plugins.treesitter")
    end
  },
},
{
})
