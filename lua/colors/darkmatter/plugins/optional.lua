local function _set()
  -- phaazon/hop.nvim {{{
  local c = require("colors.darkmatter")
  local conf = c.get_conf()
  c.hl("HopNextKey", c.localtheme.red, c.palette.none, conf.attrib.bold)
  c.hl("HopNextKey1", c.localtheme.blue, c.palette.none, conf.attrib.bold)
  c.link("HopNextKey2", "Blue")
  c.link("HopUnmatched", "Grey")
end

local M = {}
function M.set()
  _set()
end

return M

