-- setup cokeline plugin. It provides a buffer line (aka tab-bar)
local sidebar_or_tree = vim.g.features['sidebar']['enable'] == true and true or false

require('cokeline').setup({
  -- Cokeline_theme() is defined in config.lua
  buffers = {
    filter_visible = function(buffer) return not(buffer['type'] == 'terminal' and true or false) end
  },
  default_hl = Cokeline_theme().hl,
  -- header for the neo-tree sidebar
  sidebar = {
    -- filetype = 'neo-tree',
    -- filetype = 'SidebarNvim',
    filetype = sidebar_or_tree == true and 'SidebarNvim' or 'neo-tree',
    components = {
      {
        text = sidebar_or_tree == true and '  Side Bar' or '  File Explorer',
        bg = vim.g.cokeline_bg,
        style = 'bold',
      },
    }
  },
  components = {
    { text = function(buffer) return (buffer.index ~= 1) and '▏' or ' ' end, },
    {
      text = function(buffer) return buffer.devicon.icon end,
      fg = function(buffer) return buffer.devicon.color end
    },
    {
      text = function(buffer) return Truncate(buffer.filename, vim.g.cokeline_filename_width) end,
      style = function(buffer) return buffer.is_focused and 'bold' or nil end
    },
    { text = ' ' },
    {
       text = function(buffer) return buffer.is_modified and '●' or '' end,
       fg = function(buffer) return buffer.is_modified and Cokeline_theme().unsaved or nil end,
    },
    { text = '  ' }
  }
})

