-- darkmatter theme plugin
-- contains highlights for various syntax definitions
local function _set()
  local c = require("darkmatter")
  local conf = c.get_conf()

    -- builtin: https://notabug.org/jorgesumle/vim-html-syntax{{{
  c.hl("htmlH1", c.P.blue, c.NONE, conf.attrib.bold)
  c.hl("htmlH2", c.P.orange, c.NONE, conf.attrib.bold)
  c.hl("htmlH3", c.P.yellow, c.NONE, conf.attrib.bold)
  c.hl("htmlH4", c.P.green, c.NONE, conf.attrib.bold)
  c.hl("htmlH5", c.P.blue, c.NONE, conf.attrib.bold)
  c.hl("htmlH6", c.P.lpurple, c.NONE, conf.attrib.bold)
  c.hl("htmlLink", c.NONE, c.NONE, { underline = true })
  c.hl("htmlBold", c.NONE, c.NONE, conf.attrib.bold)
  c.hl("htmlBoldUnderline", c.NONE, c.NONE, { bold = true, underline = true })
  c.hl("htmlBoldItalic", c.NONE, c.NONE, { bold = true, italic = true })
  c.hl("htmlBoldUnderlineItalic", c.NONE, c.NONE, { bold = true, underline = true, italic = true })
  c.hl("htmlUnderline", c.NONE, c.NONE, { underline = true })
  c.hl("htmlUnderlineItalic", c.NONE, c.NONE, { underline = true, italic = true })
  c.hl("htmlItalic", c.NONE, c.NONE, conf.attrib.italic)
  c.link("htmlTag", "Braces")
  c.link("htmlEndTag", "Braces")
  c.link("htmlTagN", "Function")
  c.link("htmlTagName", "Function")
  c.link("htmlArg", "Type")
  c.link("htmlScriptTag", "Purple")
  c.link("htmlSpecialTagName", "RedItalic")
  c.link("htmlString", "String")

    -- syn_begin: python
    -- builtin
  c.link("pythonBuiltin", "BlueItalic")
  c.link("pythonExceptions", "Exception")
  c.link("pythonDecoratorName", "OrangeItalic")
    -- syn_begin: lua
    -- builtin:
  c.link("luaFunc", "Green")
  c.link("luaFunction", "Red")
  c.link("luaTable", "Fg")
  c.link("luaIn", "Red")
    -- syn_begin: help
  c.hl("helpNote", c.P.lpurple, c.NONE, conf.attrib.bold)
  c.hl("helpHeadline", c.P.red, c.NONE, conf.attrib.bold)
  c.hl("helpHeader", c.P.orange, c.NONE, conf.attrib.bold)
  c.hl("helpURL", c.P.green, c.NONE, { underline = true })
  c.hl("helpHyperTextEntry", c.P.blue, c.NONE, conf.attrib.bold)
  c.link("helpHyperTextJump", "Blue")
  c.link("helpCommand", "Yellow")
  c.link("helpExample", "Green")
  c.link("helpSpecial", "Purple")
  c.link("helpSectionDelim", "Grey")
end

local M = {}
function M.set()
  _set()
end

return M

