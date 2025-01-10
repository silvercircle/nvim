-- support blink.cmp highlight groups

local function _set()
  local c = require("darkmatter")

  c.link("BlinkCmpMenu", "NeoTreeNormalNC")
  c.link("BlinkCmpMenuBorder", "CmpBorder")
  c.link("BlinkCmpDoc", "NeoTreeNormalNC")
  c.link("BlinkCmpDocBorder", "CmpBorder")
  c.link("BlinkCmpSignature", "NeoTreeNormalNC")
  c.link("BlinkCmpSignatureBorder", "CmpBorder")
  c.link("BlinkCmpDocSeparator", "Debug")
  c.link("BlinkCmpDocCursorLine", "CursorLine")

  c.link("BlinkCmpLabelDetail", "Include")
  c.link("BlinkCmpMenuSnippet", "Number")
  c.link("BlinkCmpMenuLSP", "StorageClass")
  c.set_hl(0, "BlinkCmpLabelDeprecated", { bg = "NONE", strikethrough = true, fg = "#808080" })
  c.link("BlinkCmpLabelMatch", "RedBold")
  c.link("BlinkCmpLabelMatchFuzzy", "DarkPurpleBold")
  c.link("BlinkCmpSource", "Brown")
  c.link("BlinkCmpKindDefault", "FgDim")
  c.link("BlinkCmpKind", "CmpItemKindDefault")
  c.link("BlinkCmpKindFile", "Include")
  c.link("BlinkCmpKindFolder", "Yellow")
  c.link("BlinkCmpMenuPath", "CmpItemMenu")
  c.link("BlinkCmpKindStruct", "Structure")
  c.link("BlinkCmpKindConstructor", "@constructor")
  c.link("BlinkCmpKindMethod", "Method")
  c.link("BlinkCmpKindModule", "Include")
  c.link("BlinkCmpKindClass", "Class")
  c.link("BlinkCmpKindVariable", "Fg")
  c.link("BlinkCmpKindProperty", "Member")
  c.link("BlinkCmpKindField", "Member")
  c.link("BlinkCmpKindFunction", "Function")
  c.link("BlinkCmpKindKeyword", "Keyword")
  c.link("BlinkCmpKindText", "String")
  c.link("BlinkCmpKindUnit", "Include")
  c.link("BlinkCmpKindConstant", "Constant")
  c.link("BlinkCmpKindEnum", "Constant")
  c.link("BlinkCmpKindEnumMember", "Constant")
  c.link("BlinkCmpKindSnippet", "Number")
  c.link("BlinkCmpKindOperator", "Operator")
  c.link("BlinkCmpKindEvent", "Keyword")
  c.link("BlinkCmpKindInterface", "Interface")
  c.link("BlinkCmpKindValue", "StorageClass")
  c.link("BlinkCmpKindTypeParameter", "Type")
end

local M = {}
function M.set()
  _set()
end

return M

