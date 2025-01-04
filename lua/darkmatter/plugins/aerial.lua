-- aerial plugin support

local function _set()
  local c = require("darkmatter")
  local conf = c.get_conf()

  c.link("AerialModule", "@module")
  c.link("AerialNamespace", "@module")
  c.link("AerialPackage", "@module")
  c.link("AerialClass", "Class")
  c.link("AerialMethod", "Method")
  c.link("AerialProperty", "Member")
  c.link("AeriaField", "Member")
  c.link("AerialConstructor", "@constructor")
  c.link("AerialEnum", "@type")
  c.link("AerialInterface", "Interface")
  c.link("AerialFunction", "Function")
  c.link("AerialConstant", "@constant" )
  c.link("AerialString", "String")
  c.link("AerialNumber", "Number")
  c.link("AerialBoolean", "Boolean")
  c.link("AerialObject", "Type")
  c.link("AerialEnumMember", "@constant")
  c.link("AerialStruct", "Struct")
  c.link("AerialOperator", "@operator")
end

local M = {}
function M.set()
  _set()
end

return M

