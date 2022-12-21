-- packer.nvim example
-- local install_path = vim.fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'

require("editorconfig").properties.foo = function(bufnr, val)
  vim.b[bufnr].foo = val
end

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
  default = true,
})

require("luasnip.loaders.from_snipmate").load()

local glance = require("glance")
local actions = glance.actions
glance.setup({
  height = 30, -- Height of the window
  border = {
    enable = true, -- Show window borders. Only horizontal borders allowed
    top_char = "—",
    bottom_char = "—",
  },
  preview_win_opts = { -- Configure preview window options
    cursorline = true,
    number = true,
    wrap = false,
    foldcolumn = "0",
  },
  list = {
    position = "right", -- Position of the list window 'left'|'right'
    width = 0.25, -- 33% width relative to the active window, min 0.1, max 0.5
  },
  theme = { -- This feature might not work properly in nvim-0.7.2
    enable = true, -- Will generate colors for the plugin based on your current colorscheme
    mode = "darken", -- 'brighten'|'darken'|'auto', 'auto' will set mode based on the brightness of your colorscheme
  },
  mappings = {
    list = {
      ["j"] = actions.next, -- Bring the cursor to the next item in the list
      ["k"] = actions.previous, -- Bring the cursor to the previous item in the list
      ["<Down>"] = actions.next,
      ["<Up>"] = actions.previous,
      ["<Tab>"] = actions.next_location, -- Bring the cursor to the next location skipping groups in the list
      ["<S-Tab>"] = actions.previous_location, -- Bring the cursor to the previous location skipping groups in the list
      ["<C-u>"] = actions.preview_scroll_win(5),
      ["<C-d>"] = actions.preview_scroll_win(-5),
      ["v"] = actions.jump_vsplit,
      ["s"] = actions.jump_split,
      ["t"] = actions.jump_tab,
      ["<CR>"] = actions.jump,
      ["o"] = actions.jump,
      ["<A-Left>"] = actions.enter_win("preview"), -- Focus preview window
      ["q"] = actions.close,
      ["Q"] = actions.close,
      ["<Esc>"] = actions.close,
    },
    preview = {
      ["Q"] = actions.close,
      ["<Tab>"] = actions.next_location,
      ["<S-Tab>"] = actions.previous_location,
      ["<A-Right>"] = actions.enter_win("list"), -- Focus list window
    },
  },
  folds = {
    fold_closed = "",
    fold_open = "",
    folded = true, -- Automatically fold list on startup
  },
  indent_lines = {
    enable = true,
    icon = "│",
  },
  winbar = {
    enable = true, -- Available strating from nvim-0.8+
  },
})

require("hlslens").setup({
--  calm_down = true,
--  nearest_float_when = "always",
--  nearest_only = false,
})

-- setup all optional features according to vim.g.features (see config.lua)
for _, v in pairs(vim.g.features) do
  -- the plugin has a setup module associated
  if v['enable'] == true and #v['module'] > 0 then
    require(v['module'])
  end
end
