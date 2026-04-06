local M = {}

function M.setup()
  -- vim.pack BEGIN (experimental)
  -- this shall be outsourced to its own file
  vim.pack.add({
    { src = "https://github.com/jake-stewart/multicursor.nvim" },
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
    { src = "https://github.com/nvim-lualine/lualine.nvim" },
    { src = "https://github.com/nmac427/guess-indent.nvim" },
    { src = "https://github.com/silvercircle/nvim-cokeline" }
  })
  require("plugins.others").setup.multicursor_stewart()
  require("nvim-web-devicons").setup({
    override = {
      zsh = {
        icon = " ",
        color = "#428850",
        cterm_color = "65",
        name = "Zsh",
      },
      cs = {
        color = "#59a006",
        icon = "󰌛",
        name = "CSharp"
      },
      css = {
        icon = "",
        color = "#20c0c0",
        name = "CSS"
      }
    },
    color_icons = true,
    default = true
  })
  require("plugins.treesitter")
  require("plugins.others").setup.treesitter_context()
  require("guess-indent").setup()

  -- condidtional plugins
  if Tweaks.notifier == "fidget" then
    vim.pack.add({ "https://github.com/j-hui/fidget.nvim" })
    require("plugins.others").setup.fidget()
  end

end

local rtp_to_add = {
  "nvim-treesitter-context",
  "lualine.nvim",
  "nvim-cokeline"
}

function M.fixRtp()
  local base = vim.fn.stdpath("data") .. "/site/pack/core/opt/"
  vim.iter(rtp_to_add):filter(function(v)
    vim.opt.rtp:prepend(base .. v)
    return v
  end)
  -- vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/site/pack/core/opt/nvim-treesitter-context")
  -- vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/site/pack/core/opt/lualine.nvim")
  -- vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/site/pack/core/opt/nvim-cokeline")
end

return M
