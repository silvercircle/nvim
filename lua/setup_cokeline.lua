local get_hex = require('cokeline/utils').get_hex

local red = vim.g.terminal_color_1

local truncate = function(text, max_width)
  if #text > max_width then
    return string.sub(text, 1, max_width) .. "…"
  else
    return text
  end
end

require('cokeline').setup({
--  buffers = {
--    -- filter_valid = function(buffer) return buffer.type ~= 'terminal' end,
--    -- filter_visible = function(buffer) return buffer.type ~= 'terminal' end,
--    new_buffers_position = 'next',
--  },

  default_hl = {
    fg = function(buffer) return buffer.is_focused and '#000000' or get_hex('Normal', 'fg') end,
    bg = function(buffer) return buffer.is_focused and vim.g.cokeline_focustab_bg or vim.g.cokeline_bg end
  },
  sidebar = {
    filetype = 'neo-tree',
    components = {
      {
        text = '  Neotree',
        bg = def_bg,
        style = 'bold',
      },
    }
  },
  components = {
   {
     text = function(buffer) return (buffer.index ~= 1) and '▏' or '' end,
   },
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
   {
      text = ' '
   },
   { 
      text = function(buffer) return buffer.is_modified and '●' or '' end,
      fg = function(buffer) return buffer.is_modified and red or nil end,
   },
   {
     text = '  ',
   }
 }
})