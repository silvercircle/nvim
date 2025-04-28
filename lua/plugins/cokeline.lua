local show_close = Tweaks.cokeline.closebutton
local left_pad = Tweaks.cokeline.styles[Tweaks.cokeline.active_tab_style].left
local right_pad = Tweaks.cokeline.styles[Tweaks.cokeline.active_tab_style].right
local inactive_pad = Tweaks.cokeline.styles[Tweaks.cokeline.active_tab_style].inactive

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
    group = {
      highlight = function(buffer) return buffer.is_focused and "CokelineActive" or "CokelineInactive" end
    }
  }
end

local treename = { Tweaks.tree.filetype, "DiffviewFiles" }
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
        highlight = "Debug"
      },
    }
  },
  tabs = {
    placement = "right",
    components = {
      {
        text = function(tab) return tab.is_first and "" or "" end,
        highlight = function(tab) return (tab.is_first and tab.is_active) and "CokelineTabSepActive" or "CokelineTabSepInactive" end,
      },
      {
        text = function(tab) return " " .. tab.number .. " " end,
        highlight = function(tab) return tab.is_active and "CokelineTabActive" or "CokelineTabInactive" end
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
      highlight = function(buffer) return buffer.is_focused and "CokelineActivePad" or "CokelineInactivePad" end
    },
    {
      text = function(buffer) return buffer.devicon.icon end,
      -- bg = function(buffer) return buffer.is_focused and colors.cokeline_colors.focus_bg or colors.cokeline_colors.bg end,
      -- fg = function(buffer) return buffer.devicon.color end
      fg = function(buffer) return buffer.devicon.color end,
      bg = function(buffer) return vim.api.nvim_get_hl(0,
        { name = buffer.is_focused and "CokelineActive" or "CokelineInactive"}).bg end
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
      highlight = function(buffer) return buffer.is_focused and "CokelineActivePad" or "CokelineInactivePad" end
    },
    {
      text = function(buffer) return not buffer.is_last and "┃" or "" end,
      highlight = "CokelineInactive"
    }
  }
})

