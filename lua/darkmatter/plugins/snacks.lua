-- aerial plugin support

local function _set()
  local c = require("darkmatter")
  c.link("SnacksPickerIconModule", "@module")
  c.link("SnacksPickerIconNamespace", "@module")
  c.link("SnacksPickerIconPackage", "@module")
  c.link("SnacksPickerIconClass", "Class")
  c.link("SnacksPickerIconMethod", "Method")
  c.link("SnacksPickerIconProperty", "Member")
  c.link("SnacksPickerIconield", "Member")
  c.link("SnacksPickerIconConstructor", "@constructor")
  c.link("SnacksPickerIconEnum", "@type")
  c.link("SnacksPickerIconInterface", "Interface")
  c.link("SnacksPickerIconFunction", "Function")
  c.link("SnacksPickerIconConstant", "@constant" )
  c.link("SnacksPickerIconString", "String")
  c.link("SnacksPickerIconNumber", "Number")
  c.link("SnacksPickerIconBoolean", "Boolean")
  c.link("SnacksPickerIconObject", "Type")
  c.link("SnacksPickerIconEnumMember", "@constant")
  c.link("SnacksPickerIconStruct", "Struct")
  c.link("SnacksPickerIconOperator", "@operator")
  c.link("SnacksPickerMatch", "Error")
  c.hl_with_defaults("SnacksInputBorder", c.P.brown, c.NONE)
end

local M = {}
function M.set()
  _set()
end

return M

