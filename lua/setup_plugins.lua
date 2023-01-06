-- packer.nvim example
-- local install_path = vim.fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'

--require("editorconfig").properties.foo = function(bufnr, val)
--  vim.b[bufnr].foo = val
-- end

-- devicons for lua plugins (e.g. Telescope, neotree, nvim-tree among others  need them)
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
  default = true
})

require("hlslens").setup({
--  calm_down = true,
--  nearest_float_when = "always",
--  nearest_only = false,
  build_position_cb = function(plist, _, _, _)
    require("scrollbar.handlers.search").handler.show(plist.start_pos)
  end
})

-- setup all optional features according to vim.g.features (see config.lua)
for _, v in pairs(vim.g.features) do
  -- the plugin has a setup module associated
  if v['enable'] == true and #v['module'] > 0 then
    require(v['module'])
  end
end

if vim.g.use_private_forks == true then
  vim.notify("Warning: Using private forks of some plugins", 3)
end

