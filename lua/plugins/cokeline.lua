local colors = Config.theme
local show_close = vim.g.tweaks.cokeline.closebutton
local left_pad = vim.g.tweaks.cokeline.styles[vim.g.tweaks.cokeline.active_tab_style].left
local right_pad = vim.g.tweaks.cokeline.styles[vim.g.tweaks.cokeline.active_tab_style].right
local inactive_pad = vim.g.tweaks.cokeline.styles[vim.g.tweaks.cokeline.active_tab_style].inactive

local version = vim.version()
local buildinfo = '    Neovim ' .. version.major .. "." .. version.minor .. "." .. version.patch
if type(version.build) == "string" then
  buildinfo = buildinfo .. "-" .. version.build
end
if type(version.prerelease) == "string" then
  buildinfo = buildinfo .. "-" .. version.prerelease
end

-- crete the cokeline theme. Global function
local function Cokeline_theme()
  return {
    hl = {
      fg = function(buffer) return buffer.is_focused and colors.cokeline_colors.focus_fg or colors.cokeline_colors.fg end,
      bg = function(buffer) return buffer.is_focused and colors.cokeline_colors.focus_bg or colors.cokeline_colors.inact_bg end,
      -- underline = function(buffer) return buffer.is_focused and true or false end,
      underline = vim.g.tweaks.cokeline.underline,
      sp = function(buffer) return buffer.is_focused and colors.cokeline_colors.focus_sp or colors.cokeline_colors.inact_sp end
    },
    group = {
      highlight = function(buffer) return buffer.is_focused and "CokelineActive" or "CokelineInactive" end
    },
    unsaved = colors.P.special.red[1] -- the unsaved indicator on the tab
  }
end

local treename = vim.g.tweaks.tree.version == "Neo" and "neo-tree" or 'NvimTree'
require('cokeline').setup({
  -- Cokeline_theme() is defined in config.lua
  buffers = {
    filter_visible = function(buffer) return not(buffer['type'] == 'quickfix' or buffer['type'] == 'terminal' or buffer['type'] == 'nofile' or buffer['type'] == 'acwrite') and true or false end,
    new_buffers_position = 'directory'
  },
  default_hl = Cokeline_theme().group,
  -- header for the neo-tree sidebar
  sidebar = {
    filetype = treename,
    components = {
      {
        text = buildinfo,
        bg = colors.cokeline_colors.bg,
        style = 'bold',
        fg = "Yellow",
        sp = colors.cokeline_colors.inact_sp
      },
    }
  },
  tabs = {
    placement = "right",
    components = {
      {
        text = function(tab) return tab.is_first and "" or "" end,
        fg = function(tab) return (tab.is_first and tab.is_active) and colors.cokeline_colors.focus_bg or colors.P.accent[1] end,
        bg = colors.cokeline_colors.bg
      },
      {
        text = function(tab) return " " .. tab.number .. " " end,
        highlight = function(tab) return tab.is_active and "CokelineActive" or "Accent" end
      }
    }
  },
  components = {
    {
      text = function(buffer) return buffer.is_first and " " or "" end,
      highlight = "StatusLine"
    },
    {
      text = function(buffer) return buffer.is_focused and left_pad or inactive_pad end,
      highlight = function(buffer) return buffer.is_focused and "CokelineActive" or "CokelineInactive" end
    },
    {
      text = function(buffer) return buffer.devicon.icon end,
      bg = function(buffer) return buffer.is_focused and colors.cokeline_colors.focus_bg or colors.cokeline_colors.bg end,
      fg = function(buffer) return buffer.devicon.color end
    },
    {
      text = function(buffer) return buffer.filename end,
      highlight = function(buffer) return buffer.is_focused and "CokelineActive" or "CokelineInactive" end,
      truncation = {
        priority = 4,
        direction = "left"
      }
    },
    {
      text = function(buffer) return buffer.is_modified and ' ●' or (show_close == true and  '' or '') end,
      highlight = function(buffer) return buffer.is_focused and "CokelineActiveModified" or "CokelineInactiveModified" end
    },
    {
      text = function(buffer) return buffer.is_focused and right_pad or inactive_pad end,
      highlight = function(buffer) return buffer.is_focused and "CokelineActive" or "CokelineInactive" end
    },
    {
      text = function(buffer) return not buffer.is_last and "|" or "" end,
      highlight = "CokelineInactive"
    }
  }
})

