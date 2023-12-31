--- sample darkmatter theme plugin
local function _set()
  -- obtain the module and configuration
  local c = require("colors.darkmatter")
  local conf = c.get_conf()

  c.hl_with_defaults("MyGroup", c.localtheme.fg, c.palette.neotreebg)
  c.link("Foo", "Bar")
end

local M = {}
function M.set()
  _set()
end
return M

