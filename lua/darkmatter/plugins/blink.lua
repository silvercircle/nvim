-- support blink.cmp highlight groups

local function _set()
  local c = require("darkmatter")
  local conf = c.get_conf()

  c.link("BlinkCmpMenu", "Fg")
  c.link("BlinkCmpMenuBorder", "CmpBorder")

  c.link("BlinkCmpDoc", "Fg")
  c.link("BlinkCmpDocBorder", "CmpBorder")
  c.link("BlinkCmpDocSeparator", "Debug")
  c.link("BlinkCmpDocCursorLine", "CursorLine")

  c.link("BlinkCmpLabelDetail", "Include")
  c.link("BlinkCmpMenuSnippet", "Number")
  c.link("BlinkCmpMenuLSP", "StorageClass")
  c.set_hl(0, "BlinkCmpLabelDeprecated", { bg = "NONE", strikethrough = true, fg = "#808080" })
  c.link("BlinkCmpLabelMatch", "Purple")
  c.link("BlinkCmpLabelMatchFuzzy", "DarkPurpleBold")
  c.link("BlinkCmpSource", "Brown")
  c.link("BlinkCmpKindDefault", "FgDim")
  c.link("BlinkCmpKind", "CmpItemKindDefault")
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
  c.link("BlinkCmpKindEnum", "CmpItemKindConstant")
  c.link("BlinkCmpKindSnippet", "CmpItemMenuSnippet")
  c.link("BlinkCmpKindOperator", "Operator")
  c.link("BlinkCmpKindInterface", "Interface")
  c.link("BlinkCmpKindValue", "StorageClass")
  c.link("BlinkCmpKindTypeParameter", "Type")
end

local M = {}
function M.set()
  _set()
end

return M

