-- darkmatter theme plugin
-- contains highlights for various syntax definitions

local c = require("colors.darkmatter")
local conf = c.get_conf()

  -- builtin: https://notabug.org/jorgesumle/vim-html-syntax{{{
c.hl("htmlH1", c.localtheme.blue, c.palette.none, conf.attrib.bold)
c.hl("htmlH2", c.localtheme.orange, c.palette.none, conf.attrib.bold)
c.hl("htmlH3", c.localtheme.yellow, c.palette.none, conf.attrib.bold)
c.hl("htmlH4", c.localtheme.green, c.palette.none, conf.attrib.bold)
c.hl("htmlH5", c.localtheme.blue, c.palette.none, conf.attrib.bold)
c.hl("htmlH6", c.palette.purple, c.palette.none, conf.attrib.bold)
c.hl("htmlLink", c.palette.none, c.palette.none, { underline = true })
c.hl("htmlBold", c.palette.none, c.palette.none, conf.attrib.bold)
c.hl("htmlBoldUnderline", c.palette.none, c.palette.none, { bold = true, underline = true })
c.hl("htmlBoldItalic", c.palette.none, c.palette.none, { bold = true, italic = true })
c.hl("htmlBoldUnderlineItalic", c.palette.none, c.palette.none, { bold = true, underline = true, italic = true })
c.hl("htmlUnderline", c.palette.none, c.palette.none, { underline = true })
c.hl("htmlUnderlineItalic", c.palette.none, c.palette.none, { underline = true, italic = true })
c.hl("htmlItalic", c.palette.none, c.palette.none, conf.attrib.italic)
c.link("htmlTag", "Green")
c.link("htmlEndTag", "Blue")
c.link("htmlTagN", "RedItalic")
c.link("htmlTagName", "RedItalic")
c.link("htmlArg", "Blue")
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
c.hl("helpNote", c.palette.purple, c.palette.none, conf.attrib.bold)
c.hl("helpHeadline", c.localtheme.red, c.palette.none, conf.attrib.bold)
c.hl("helpHeader", c.localtheme.orange, c.palette.none, conf.attrib.bold)
c.hl("helpURL", c.localtheme.green, c.palette.none, { underline = true })
c.hl("helpHyperTextEntry", c.localtheme.blue, c.palette.none, conf.attrib.bold)
c.link("helpHyperTextJump", "Blue")
c.link("helpCommand", "Yellow")
c.link("helpExample", "Green")
c.link("helpSpecial", "Purple")
c.link("helpSectionDelim", "Grey")

