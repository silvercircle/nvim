
local api = require("image")

local M = {}
-- from a file (absolute path)
function M.test()
  local image = api.from_file("/home/alex/Downloads/shots/dns.png", {
    id = "my_image_id", -- optional, defaults to a random string
    --window = 1000, -- optional, binds image to a window and its bounds
    buffer = vim.api.nvim_get_current_buf(), -- optional, binds image to a buffer (paired with window binding)
    with_virtual_padding = true, -- optional, pads vertically with extmarks
  })
  image:render() -- render image
end

function M.test_hologram()
  local source = '/home/alex/Downloads/shots/dns.png'
  local buf = vim.api.nvim_get_current_buf()
  local image = require('hologram.image'):new(source, {})

-- Image should appear below this line, then disappear after 5 seconds

  image:display(10, 0, buf, {})

  vim.defer_fn(function()
      image:delete(0, {free = true})
  end, 5000)
end
return M
