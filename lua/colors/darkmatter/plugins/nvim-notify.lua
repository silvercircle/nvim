local function _set()
  local c = require("colors.darkmatter")
  c.link("NotifyERRORBorder", "Red")
  c.link("NotifyWARNBorder", "Yellow")
  c.link("NotifyINFOBorder", "Green")
  c.link("NotifyDEBUGBorder", "Grey")
  c.link("NotifyTRACEBorder", "Purple")
  c.link("NotifyERRORIcon", "Red")
  c.link("NotifyWARNIcon", "Yellow")
  c.link("NotifyINFOIcon", "Green")
  c.link("NotifyDEBUGIcon", "Grey")
  c.link("NotifyTRACEIcon", "Purple")
  c.link("NotifyERRORTitle", "Red")
  c.link("NotifyWARNTitle", "Yellow")
  c.link("NotifyINFOTitle", "Green")
  c.link("NotifyDEBUGTitle", "Grey")
  c.link("NotifyTRACETitle", "Purple")
end

local M = {}
function M.set()
  _set()
end

return M

