local function _set()
  -- phaazon/hop.nvim {{{
  local c = require("colors.darkmatter")
  local conf = c.get_conf()
  c.hl("CmpItemKindStruct", c.localtheme.darkpurple, c.palette.none, conf.attrib.cmpkind)
  c.hl("CmpItemKindConstructor", c.localtheme.yellow, c.palette.none, conf.attrib.cmpkind)
  c.hl("CmpItemKindMethod", c.localtheme.brightteal, c.palette.none, conf.attrib.cmpkind)
  c.hl("CmpItemKindModule", c.palette.olive, c.palette.none, conf.attrib.cmpkind)
  c.hl("CmpItemKindClass", c.localtheme.special.class, c.palette.none, conf.attrib.cmpkind)
  c.hl("CmpItemKindVariable", c.localtheme.fg, c.palette.none, conf.attrib.cmpkind)
  c.hl("CmpItemKindProperty", c.localtheme.orange, c.palette.none, conf.attrib.cmpkind)
  c.hl("CmpItemKindFunction", c.localtheme.teal, c.palette.none, conf.attrib.cmpkind)
  c.hl("CmpItemKindKeyword", c.localtheme.blue, c.palette.none, conf.attrib.cmpkind)
  c.hl("CmpItemKindText", c.localtheme.string, c.palette.none, conf.attrib.cmpkind)
  c.hl("CmpItemKindUnit", c.palette.olive, c.palette.none, conf.attrib.cmpkind)
  c.hl("CmpItemKindConstant", c.palette.purple, c.palette.none, conf.attrib.cmpkind)
  c.hl("CmpItemKindSnippet", c.localtheme.special.green, c.palette.none, conf.attrib.cmpkind)
  c.hl("CmpItemKindOperator", c.localtheme.special[conf.special.operator], c.palette.none, conf.attrib.cmpkind)
  c.hl("CmpItemKindInterface", c.localtheme.purple, c.palette.none, conf.attrib.cmpkind)
  c.hl("CmpItemKindValue", c.localtheme.special.storage, c.palette.none, conf.attrib.cmpkind)
  c.hl("CmpItemKindTypeParameter", c.localtheme.darkpurple, c.palette.none, conf.attrib.cmpkind)
end

local M = {}
function M.set()
  _set()
end

return M

