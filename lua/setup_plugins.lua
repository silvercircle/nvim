-- packer.nvim example
-- local install_path = vim.fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'

require("editorconfig").properties.foo = function(bufnr, val)
  vim.b[bufnr].foo = val
end

-- devicons for lua plugins (e.g. Telescope needs them)
require("nvim-web-devicons").setup({
  -- your personnal icons can go here (to override)
  -- you can specify color or cterm_color instead of specifying both of them
  -- DevIcon will be appended to `name`
  override = {
    zsh = {
      icon = "",
      color = "#428850",
      cterm_color = "65",
      name = "Zsh",
    },
  },
  -- globally enable different highlight colors per icon (default to true)
  -- if set to false all icons will have the default icon's color
  color_icons = true,
  -- globally enable default icons (default to false)
  -- will get overriden by `get_icons` option
  default = true,
})


require("luasnip.loaders.from_snipmate").load()
