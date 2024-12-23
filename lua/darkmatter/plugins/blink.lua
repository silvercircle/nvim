-- support blink.cmp highlight groups

local function _set()
  local c = require("darkmatter")
  local conf = c.get_conf()

  c.link("BlinkCmpItemMenu", "Fg")
  c.link("BlinkCmpItemMenuDetail", "@include")
  c.link("BlinkCmpItemMenuBuffer", "FgDim")
  c.link("BlinkCmpItemMenuSnippet", "Number")
  c.link("BlinkCmpItemMenuLSP", "StorageClass")
  c.link("BlinkCmpItemAbbr", "Fg")
  c.set_hl(0, "BlinkCmpItemAbbrDeprecated", { bg = "NONE", strikethrough = true, fg = "#808080" })
  c.link("BlinkCmpItemAbbrMatch", "RedBold")
  c.link("BlinkCmpItemAbbrMatchFuzzy", "DarkPurpleBold")
  c.hl_with_defaults("BlinkCmpPmenu", c.P.fg, c.P.bg_dim)
  c.hl_with_defaults("BlinkCmpPmenuBorder", c.P.grey_dim, c.P.bg_dim)
  c.hl_with_defaults("BlinkCmpGhostText", c.P.grey, c.NONE)
  c.link("BlinkCmpKindDefault", "FgDim")
  c.link("BlinkCmpKind", "CmpItemKindDefault")
  c.link("BlinkCmpMenuPath", "CmpItemMenu")
  c.link("BlinkCmpKindStruct", "Structure")
  c.link("BlinkCmpKindConstructor", "@constructor")
  c.link("BlinkCmpKindMethod", "Method")
  c.link("BlinkCmpKindModule", "@include")
  c.link("BlinkCmpKindClass", "Class")
  c.link("BlinkCmpKindVariable", "Fg")
  c.link("BlinkCmpKindProperty", "Member")
  c.link("BlinkCmpKindField", "Member")
  c.link("BlinkCmpKindFunction", "Function")
  c.link("BlinkCmpKindKeyword", "Keyword")
  c.link("BlinkCmpKindText", "String")
  c.link("BlinkCmpKindUnit", "@include")
  c.link("BlinkCmpKindConstant", "Constant")
  c.link("BlinkCmpKindEnum", "CmpItemKindConstant")
  c.link("BlinkCmpKindSnippet", "CmpItemMenuSnippet")
  c.link("BlinkCmpKindOperator", "Operator")
  c.link("BlinkCmpKindInterface", "Interface")
  c.link("BlinkCmpKindValue", "StorageClass")
  c.link("BlinkCmpKindTypeParameter", "Type")

  c.hl_with_defaults("BlinkCmpFloat", c.P.fg_dim, c.P.treebg)
  c.hl_with_defaults("BlinkCmpBorder", c.P.accent, c.P.treebg)

end

local M = {}
function M.set()
  _set()
end

return M

