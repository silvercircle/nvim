-- aerial plugin support

local function _set()
  local c = require("darkmatter")
  c.link("SnacksInputTitle", "FloatTitle")
  c.hl_with_defaults("SnacksInputBorder", c.P.brown, c.NONE)

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
  c.link("SnacksPickerDir", "Comment")
  c.link("SnacksPickerFile", "DefaultLib")

  c.link("SnacksNotifierBorderInfo", "FloatBorder")
  c.link("SnacksNotifierBorderWarn", "FloatBorder")
  c.link("SnacksNotifierBorderDebug", "FloatBorder")
  c.link("SnacksNotifierBorderError", "FloatBorder")
  c.link("SnacksNotifierBorderTrace", "FloatBorder")

  c.link("SnacksNotifierTitleInfo", "NormalFloat")
  c.link("SnacksNotifierTitleWarn", "NormalFloat")
  c.link("SnacksNotifierTitleDebug", "NormalFloat")
  c.link("SnacksNotifierTitleError", "NormalFloat")
  c.link("SnacksNotifierTitleTrace", "NormalFloat")

  c.link("SnacksNotifierInfo", "NormalFloat")
  c.link("SnacksNotifierWarn", "NormalFloat")
  c.link("SnacksNotifierDebug", "NormalFloat")
  c.link("SnacksNotifierError", "NormalFloat")
  c.link("SnacksNotifierTrace", "NormalFloat")
end

local M = {}
function M.set()
  _set()
end

return M

