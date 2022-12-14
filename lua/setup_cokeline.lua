
local truncate = function(text, max_width)
  if #text > max_width then
    return string.sub(text, 1, max_width) .. "…"
  else
    return text
  end
end

vim.cmd([[ PackerLoad nvim-cokeline ]])
require('cokeline').setup({
  -- Cokeline_theme() is defined in config.lua
  default_hl = Cokeline_theme().hl,
  -- header for the neo-tree sidebar
  sidebar = {
    filetype = 'neo-tree',
    components = {
      {
        text = '  Neotree',
        bg = vim.g.cokeline_bg,
        style = 'bold',
      },
    }
  },
  components = {
    { text = function(buffer) return (buffer.index ~= 1) and '▏' or '' end, },
    {
      text = function(buffer)
        return buffer.devicon.icon
      end,
      fg = function(buffer)
        return buffer.devicon.color
      end,
    },
    {
      text = function(buffer) return truncate(buffer.filename, vim.g.cokeline_filename_width) end,
      style = function(buffer)
        return buffer.is_focused and 'bold' or nil
      end,
    },
    { text = ' ' },
    {
       text = function(buffer) return buffer.is_modified and '●' or '' end,
       fg = function(buffer) return buffer.is_modified and Cokeline_theme().unread or nil end,
    },
    { text = '  ' }
  }
})