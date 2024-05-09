local function _set()
  -- phaazon/hop.nvim {{{
  local c = require("darkmatter")
  local conf = c.get_conf()
  c.hl("HopNextKey", c.P.red, c.NONE, conf.attrib.bold)
  c.hl("HopNextKey1", c.P.blue, c.NONE, conf.attrib.bold)
  c.link("HopNextKey2", "Blue")
  c.link("HopUnmatched", "Grey")
end

local M = {}
function M.set()
  _set()
end

return M

