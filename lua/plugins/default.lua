local show_close = vim.g.tweaks.cokeline.closebutton
local version = vim.version()
local buildinfo = ' Neovim ' .. version.major .. "." .. version.minor .. "." .. version.patch
if type(version.build) == "string" then
  buildinfo = buildinfo .. "-" .. version.build
end
if type(version.prerelease) == "string" then
  buildinfo = buildinfo .. "-" .. version.prerelease
end
-- devicons for lua plugins (e.g. Telescope, neotree, nvim-tree among others  need them)
require("nvim-web-devicons").setup({
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

local colors = Config.theme

-- crete the cokeline theme. Global function
local function Cokeline_theme()
  return {
    hl = {
      fg = function(buffer) return buffer.is_focused and colors.cokeline_colors.focus_fg or colors.cokeline_colors.fg end,
      bg = function(buffer) return buffer.is_focused and colors.cokeline_colors.focus_bg or colors.cokeline_colors.bg end
    },
    unsaved = '#ff6060' -- the unsaved indicator on the tab
  }
end

-- setup cokeline plugin. It provides a buffer line (aka tab-bar)
-- local sidebar_or_tree = vim.g.features['sidebar']['enable'] == true and true or false
-- local treename = Config.nvim_tree == true and 'NvimTree' or 'neo-tree'
local treename = 'NvimTree'
require('cokeline').setup({
  -- Cokeline_theme() is defined in config.lua
  buffers = {
    filter_visible = function(buffer) return not(buffer['type'] == 'quickfix' or buffer['type'] == 'terminal' or buffer['type'] == 'nofile' or buffer['type'] == 'acwrite') and true or false end,
    new_buffers_position = 'directory'
  },
  default_hl = Cokeline_theme().hl,
  -- header for the neo-tree sidebar
  sidebar = {
    filetype = treename,
    components = {
      {
        text = buildinfo,
        bg = vim.g.cokeline_bg,
        style = 'bold',
      },
    }
  },
  components = {
    { text = ' ' },
    -- { text = function(buffer) return buffer.is_focused and '' or ' ' end },
    -- { text = function(buffer) return (buffer.index ~= 1 and buffer.is_focused == false) and '│ ' or ' ' end },
    -- { text = function(buffer) return buffer.is_focused and (buffer.index == 1 and '' or '') or ' ' end },
    {
      text = function(buffer) return buffer.devicon.icon end,
      fg = function(buffer) return buffer.devicon.color end
    },
    { text = Config.iconpad },
    {
      text = function(buffer) return __Globals.truncate(buffer.filename, Config.cokeline_filename_width) end,
      style = function(buffer) return buffer.is_focused and 'bold' or nil end
    },
    {
       text = function(buffer) return buffer.is_modified and ' ●' or (show_close == true and  '' or '') end,
       fg = function(buffer) return buffer.is_modified and Cokeline_theme().unsaved or nil end,
    },
    { text = ' ' }
    -- { text = function(buffer) return buffer.is_focused and '' or ' ' end }
  }
})

require("gitsigns").setup({
  _refresh_staged_on_update = false,
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    interval = 2000,
    follow_files = true,
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
  sign_priority = 0,
  update_debounce = 1000,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    border = __Globals.perm_config.telescope_borders,
    style = "minimal",
    relative = "cursor",
    row = 0,
    col = 1,
  },
  yadm = {
    enable = false,
  },
})

require 'colorizer'.setup {
  'css';
  'scss';
  html = {
    mode = 'foreground';
  }
}

require('mini.move').setup()

-- support a textwidth property in editorconfig files
require('editorconfig').properties.textwidth = function(bufnr, val, _)
  -- print("editorconfig textwidth to " .. val .. " for " .. bufnr)
  vim.api.nvim_buf_set_option(bufnr, "textwidth", tonumber(val))
end

