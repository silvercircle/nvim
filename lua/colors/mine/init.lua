-------------------------------------------------------------------------------
--Name:         my_Sonokai
--
--BASED ON original work by:
--Name:         Sonokai
--Description:  High Contrast & Vivid Color Scheme based on Monokai Pro
--Author:       Sainnhepark <i@sainnhe.dev>
--Website:      https://github.com/sainnhe/sonokai/
--License:      MIT
-------------------------------------------------------------------------------
--things no longer used because of LSP.
--desaturate means that some colors are less intense and less vivid but retain their basic color
--tint, resulting in a more "pastel" look with less contrast. the basic color scheme is unaffected
--by this setting.
--
local set_hl = vim.api.nvim_set_hl
local palette = {}
local theme = {}

local diff = vim.api.nvim_win_get_option(0, "diff")

local function simple_hl(hl, fg, bg)
  set_hl(0, hl, { fg = fg[1], ctermfg = fg[2], bg = bg[1], ctermbg = bg[2] })
end

local function merged_hl(hl, fg, bg, attr)
  local _t = {
    fg      = fg[1],
    ctermfg = fg[2],
    bg      = bg[1],
    ctermbg = bg[2]
  }
  set_hl(0, hl, vim.tbl_extend("force", _t, attr))
end

local function link_hl(hl, target)
  set_hl(0, hl, { link = target })
end

if vim.g.theme_desaturate == true then
  theme = {
    orange     = { '#ab6a6c', 215 },
    string     = vim.g.theme.string == "yellow" and { '#9a9a60', 231 } or { '#40804f', 231 },
    blue       = { '#5a6acf', 239 },
    purple     = { '#b070b0', 241 },
    teal       = { '#508080', 238 },
    brightteal = { '#70a0c0', 238 },
    darkpurple = { '#705070', 240 },
    red        = { '#bb4d5c', 203 }
  }
else
  theme = {
    string     = vim .. theme.string == "yellow" and { '#cccc60', 231 } or { '#10801f', 231 },
    orange     = { '#c36630', 215 },
    blue       = { '#4a4adf', 239 },
    purple     = { '#c030c0', 241 },
    teal       = { '#108080', 238 },
    brightteal = { '#30a0c0', 238 },
    darkpurple = { '#803090', 240 },
    red        = { '#cc2d4c', 203 }
  }
end

if vim.g.theme_variant == 'cold' then
  theme.darkbg       = { '#101013', 237 }
  theme.darkred      = { '#601010', 249 }
  theme.darkestred   = { '#161616', 249 }
  theme.darkestblue  = { '#10101a', 247 }
  theme.bg           = { vim.g.theme['cold'].bg, 0 }
  theme.statuslinebg = { vim.g.statuslinebg, 208 }
  palette.fg         = { '#a2a0ac', 1 }
  palette.grey       = { '#707070', 2 }
  theme.pmenubg      = { '#241a20', 156 }
  theme.accent       = { vim.g.theme['accent_color'], 209 }
  theme.accent_fg    = { vim.g.theme['accent_fg'], 210 }
  theme.tablinebg    = { vim.g.cokeline_colors['bg'], 214 }
  theme.contextbg    = { vim.g.theme['cold'].contextbg, 215 }
else
  theme.darkbg       = { '#131010', 237 }
  theme.darkred      = { '#601010', 249 }
  theme.darkestred   = { '#161616', 249 }
  theme.darkestblue  = { '#10101a', 247 }
  theme.bg           = { vim.g.theme['warm'].bg, 0 }
  theme.statuslinebg = { vim.g.statuslinebg, 208 }
  palette.fg         = { '#aaa0a5', 1 }
  palette.grey       = { '#707070', 2 }
  theme.pmenubg      = { '#241a20', 156 }
  theme.accent       = { vim.g.theme['accent_color'], 209 }
  theme.accent_fg    = { vim.g.theme['accent_fg'], 210 }
  theme.tablinebg    = { vim.g.cokeline_colors['bg'], 214 }
  theme.contextbg    = { vim.g.theme['warm'].contextbg, 215 }
end

if vim.g.theme_variant == 'cold' then
  palette = {
    black       = { '#121215', 232 },
    bg_dim      = { '#222327', 232 },
    bg0         = { '#2c2e34', 235 },
    bg1         = { '#33353f', 236 },
    bg2         = { '#363944', 236 },
    bg3         = { '#3b3e48', 237 },
    bg4         = { '#414550', 237 },
    bg_red      = { '#ff6077', 203 },
    diff_red    = { '#55393d', 52 },
    bg_green    = { '#a7df78', 107 },
    diff_green  = { '#697664', 22 },
    bg_blue     = { '#85d3f2', 110 },
    diff_blue   = { '#354157', 17 },
    diff_yellow = { '#4e432f', 54 },
    fg          = { '#d2c2c0', 250 },
    fg_dim      = { '#959290', 251 },
    red         = { theme.red[1], theme.red[2] },
    palered     = { '#8b2d3c', 203 },
    orange      = { theme.orange[1], theme.orange[2] },
    yellow      = { '#e7c664', 179 },
    darkyellow  = { '#a78624', 180 },
    green       = { '#9ed072', 107 },
    blue        = { '#469c70', 110 },
    purple      = { '#b39df3', 176 },
    grey        = { '#7f8490', 246 },
    grey_dim    = { '#595f6f', 240 },
    neotreebg   = { vim.g.theme['cold'].treebg, 232 },
    selfg       = { '#cccc20', 233 },
    selbg       = { vim.g.theme['selbg'], 234 },
    none        = { 'NONE', 'NONE' }
  }
else
  --the "warm" variant features a slight red-ish tint in the background colors
  --all other colors are identical to the cold variant.
  palette = {
    black       = { '#151212', 232 },
    bg_dim      = { '#242020', 232 },
    bg0         = { '#302c2e', 235 },
    bg1         = { '#322a2a', 236 },
    bg2         = { '#403936', 236 },
    bg3         = { '#483e3b', 237 },
    bg4         = { '#504531', 237 },
    bg_red      = { '#ff6077', 203 },
    diff_red    = { '#55393d', 52, },
    bg_green    = { '#a7df78', 107 },
    diff_green  = { '#697664', 22 },
    bg_blue     = { '#85d3f2', 110 },
    diff_blue   = { '#354157', 17 },
    diff_yellow = { '#4e432f', 54 },
    fg          = { '#d2c2c0', 250 },
    fg_dim      = { '#959290', 251 },
    red         = { theme.red[1], theme.red[2] },
    palered     = { '#8b2d3c', 203 },
    orange      = { theme.orange[1], theme.orange[2] },
    yellow      = { '#e7c664', 179 },
    darkyellow  = { '#a78624', 180 },
    green       = { '#9ed072', 107 },
    blue        = { '#469c70', 110 },
    purple      = { '#b39df3', 176 },
    grey        = { '#7f8490', 246 },
    grey_dim    = { '#595f6f', 240 },
    neotreebg   = { vim.g.theme['warm'].treebg, 232 },
    selfg       = { '#cccc20', 233 },
    selbg       = { vim.g.theme['selbg'], 234 },
    none        = { 'NONE', 0 }
  }
end
local function set_all()
  simple_hl("Braces", palette.red, palette.none)
  simple_hl('ScrollView', theme.teal, theme.blue)
  simple_hl('Normal', palette.fg, theme.bg)
  simple_hl('Accent', palette.black, theme.accent)
  simple_hl('Terminal', palette.fg, palette.neotreebg)
  simple_hl('EndOfBuffer', palette.bg4, palette.none)
  simple_hl('Folded', palette.fg, palette.diff_blue)
  simple_hl('ToolbarLine', palette.fg, palette.none)
  simple_hl('FoldColumn', palette.bg4, theme.darkbg)
  simple_hl('SignColumn', palette.fg, theme.darkbg)
  simple_hl('IncSearch', palette.yellow, theme.darkred)
  simple_hl('Search', palette.black, palette.diff_green)
  simple_hl('ColorColumn', palette.none, palette.bg1)
  simple_hl('Conceal', palette.grey_dim, palette.none)
  simple_hl('Cursor', palette.fg, palette.fg)
  simple_hl('nCursor', palette.fg, palette.fg)
  simple_hl('iCursor', palette.yellow, palette.yellow)
  simple_hl('vCursor', palette.red, palette.red)

  link_hl("CursorIM", "iCursor")

  merged_hl('FocusedSymbol', palette.yellow, palette.none, { bold = true })

  if diff then
    merged_hl('CursorLine', palette.none, palette.none, { underline = true })
    merged_hl('CursorColumn', palette.none, palette.none, { bold = true })
  else
    simple_hl('CursorLine', palette.none, palette.bg0)
    simple_hl('CursorColumn', palette.none, palette.bg1)
  end

  simple_hl('LineNr', palette.grey_dim, theme.darkbg)
  if diff then
    merged_hl('CursorLineNr', palette.yellow, palette.none, { underline = true })
  else
    simple_hl('CursorLineNr', palette.yellow, palette.none)
  end

  simple_hl('DiffAdd', palette.none, palette.diff_green)
  simple_hl('DiffChange', palette.none, palette.diff_blue)
  simple_hl('DiffDelete', palette.none, palette.diff_red)
  simple_hl('DiffText', palette.bg0, palette.blue)
  merged_hl('Directory', theme.blue, palette.none, { bold = true })
  merged_hl('ErrorMsg', palette.red, palette.none, { bold = true, underline = true })
  merged_hl('WarningMsg', palette.yellow, palette.none, { bold = true })
  merged_hl('ModeMsg', palette.fg, palette.none, { bold = true })
  merged_hl('MoreMsg', palette.blue, palette.none, { bold = true })
  simple_hl('MatchParen', palette.yellow, theme.darkred)

  simple_hl('NonText', palette.bg4, palette.none)
  simple_hl('Whitespace', palette.green, palette.none)
  simple_hl('ExtraWhitespace', palette.green, palette.none)
  simple_hl('SpecialKey', palette.green, palette.none)
  simple_hl('Pmenu', palette.fg, theme.pmenubg)
  simple_hl('PmenuSbar', palette.none, palette.bg2)
  simple_hl('PmenuSel', palette.yellow, theme.blue)

  link_hl("WildMenu", "PmenuSel")

  simple_hl('PmenuThumb', palette.none, palette.grey)
  simple_hl('NormalFloat', palette.fg, palette.bg_dim)
  simple_hl('FloatBorder', palette.grey_dim, palette.bg_dim)
  simple_hl('Question', palette.yellow, palette.none)
  merged_hl('SpellBad', palette.none, palette.none, { undercurl = true, sp = palette.red[1] })
  merged_hl('SpellCap', palette.none, palette.none, { undercurl = true, sp = palette.yellow[1] })
  merged_hl('SpellLocal', palette.none, palette.none, { undercurl = true, sp = palette.blue[1] })
  merged_hl('SpellRare', palette.none, palette.none, { undercurl = true, sp = palette.purple[1] })
  simple_hl('StatusLine', palette.fg, theme.statuslinebg)
  simple_hl('StatusLineTerm', palette.fg, palette.none)
  simple_hl('StatusLineNC', palette.grey, theme.statuslinebg)
  simple_hl('StatusLineTermNC', palette.grey, palette.none)
  simple_hl('TabLine', palette.fg, theme.statuslinebg)
  simple_hl('TabLineFill', palette.grey, theme.tablinebg)
  simple_hl('TabLineSel', palette.bg0, palette.bg_red)
  simple_hl('VertSplit', theme.statuslinebg, palette.neotreebg)

  link_hl("WinSeparator", "VertSplit")

  simple_hl('Visual', palette.selfg, palette.selbg)
  merged_hl('VisualNOS', palette.none, palette.bg3, { underline = true })
  merged_hl('QuickFixLine', palette.blue, palette.none, { bold = true })
  simple_hl('Debug', palette.yellow, palette.none)
  simple_hl('debugPC', palette.bg0, palette.green)
  simple_hl('debugBreakpoint', palette.bg0, palette.red)
  simple_hl('ToolbarButton', palette.bg0, palette.bg_blue)
  simple_hl('Substitute', palette.bg0, palette.yellow)

  link_hl("DiagnosticFloatingError", "ErrorFloat")
  link_hl("DiagnosticFloatingWarn", "WarningFloat")
  link_hl("DiagnosticFloatingInfo", "InfoFloat")
  link_hl("DiagnosticFloatingHint", "HintFloat")
  link_hl("DiagnosticError", "ErrorText")
  link_hl("DiagnosticWarn", "WarningText")
  link_hl("DiagnosticInfo", "InfoText")
  link_hl("DiagnosticHint", "HintText")
  link_hl("DiagnosticVirtualTextError", "VirtualTextError")
  link_hl("DiagnosticVirtualTextWarn", "VirtualTextWarning")
  link_hl("DiagnosticVirtualTextInfo", "VirtualTextInfo")
  link_hl("DiagnosticVirtualTextHint", "VirtualTextHint")
  link_hl("DiagnosticUnderlineError", "ErrorText")
  link_hl("DiagnosticUnderlineWarn", "WarningText")
  link_hl("DiagnosticUnderlineInfo", "InfoText")
  link_hl("DiagnosticUnderlineHint", "HintText")
  link_hl("DiagnosticSignError", "RedSign")
  link_hl("DiagnosticSignWarn", "YellowSign")
  link_hl("DiagnosticSignInfo", "BlueSign")
  link_hl("DiagnosticSignHint", "GreenSign")
  link_hl("LspDiagnosticsFloatingError", "DiagnosticFloatingError")
  link_hl("LspDiagnosticsFloatingWarning", "DiagnosticFloatingWarn")
  link_hl("LspDiagnosticsFloatingInformation", "DiagnosticFloatingInfo")
  link_hl("LspDiagnosticsFloatingHint", "DiagnosticFloatingHint")
  link_hl("LspDiagnosticsDefaultError", "DiagnosticError")
  link_hl("LspDiagnosticsDefaultWarning", "DiagnosticWarn")
  link_hl("LspDiagnosticsDefaultInformation", "DiagnosticInfo")
  link_hl("LspDiagnosticsDefaultHint", "DiagnosticHint")
  link_hl("LspDiagnosticsVirtualTextError", "DiagnosticVirtualTextError")
  link_hl("LspDiagnosticsVirtualTextWarning", "DiagnosticVirtualTextWarn")
  link_hl("LspDiagnosticsVirtualTextInformation", "DiagnosticVirtualTextInfo")
  link_hl("LspDiagnosticsVirtualTextHint", "DiagnosticVirtualTextHint")
  link_hl("LspDiagnosticsUnderlineError", "DiagnosticUnderlineError")
  link_hl("LspDiagnosticsUnderlineWarning", "DiagnosticUnderlineWarn")
  link_hl("LspDiagnosticsUnderlineInformation", "DiagnosticUnderlineInfo")
  link_hl("LspDiagnosticsUnderlineHint", "DiagnosticUnderlineHint")
  link_hl("LspDiagnosticsSignError", "DiagnosticSignError")
  link_hl("LspDiagnosticsSignWarning", "DiagnosticSignWarn")
  link_hl("LspDiagnosticsSignInformation", "DiagnosticSignInfo")
  link_hl("LspDiagnosticsSignHint", "DiagnosticSignHint")
  link_hl("LspReferenceText", "CurrentWord")
  link_hl("LspReferenceRead", "CurrentWord")
  link_hl("LspReferenceWrite", "CurrentWord")
  link_hl("LspCodeLens", "VirtualTextInfo")
  link_hl("LspCodeLensSeparator", "VirtualTextHint")
  link_hl("LspSignatureActiveParameter", "Yellow")
  link_hl("TermCursor", "Cursor")
  link_hl("healthError", "Red")
  link_hl("healthSuccess", "Green")
  link_hl("healthWarning", "Yellow")

  merged_hl('Type', theme.darkpurple, palette.none, { bold = true })
  merged_hl('Structure', theme.darkpurple, palette.none, { bold = true })
  merged_hl('StorageClass', theme.purple, palette.none, { bold = true })
  simple_hl('Identifier', palette.orange, palette.none)
  simple_hl('Constant', palette.purple, palette.none)
  merged_hl('PreProc', palette.darkyellow, palette.none, { bold = true })
  merged_hl('PreCondit', palette.darkyellow, palette.none, { bold = true })
  simple_hl('Include', palette.green, palette.none)
  merged_hl('Keyword', theme.blue, palette.none, { bold = true })
  simple_hl('Define', palette.red, palette.none)
  merged_hl('Typedef', palette.red, palette.none, { bold = true })
  simple_hl('Exception', palette.red, palette.none)
  merged_hl('Conditional', palette.darkyellow, palette.none, { bold = true })
  merged_hl('Repeat', palette.blue, palette.none, { bold = true })
  merged_hl('Statement', palette.blue, palette.none, { bold = true })
  simple_hl('Macro', palette.purple, palette.none)
  simple_hl('Error', palette.red, palette.none)
  simple_hl('Label', palette.purple, palette.none)
  merged_hl('Special', theme.darkpurple, palette.none, { bold = true })
  simple_hl('SpecialChar', palette.purple, palette.none)
  simple_hl('Boolean', palette.palered, palette.none)
  simple_hl('String', theme.string, palette.none)
  simple_hl('Character', palette.yellow, palette.none)
  merged_hl('Number', theme.purple, palette.none, { bold = true })
  simple_hl('Float', palette.purple, palette.none)
  merged_hl('Function', theme.teal, palette.none, { bold = true })
  merged_hl('Method', theme.brightteal, palette.none, { bold = true })

  merged_hl('Operator', palette.red, palette.none, { bold = true })
  merged_hl('Title', palette.red, palette.none, { bold = true })
  simple_hl('Tag', palette.orange, palette.none)
  merged_hl('Delimiter', palette.red, palette.none, { bold = true })
  simple_hl('Comment', palette.grey, palette.none)
  simple_hl('SpecialComment', palette.grey, palette.none)
  simple_hl('Todo', palette.blue, palette.none)
  simple_hl('Ignore', palette.grey, palette.none)
  merged_hl('Underlined', palette.none, palette.none, { underline = true })

  simple_hl('Fg', palette.fg, palette.none)
  merged_hl('FgBold', palette.fg, palette.none, { bold = true })
  merged_hl('FgItalic', palette.fg, palette.none, { italic = true })
  merged_hl('FgDimBold', palette.fg_dim, palette.none, { bold = true })
  merged_hl('FgDimBoldItalic', palette.fg_dim, palette.none, { bold = true, italic = true })
  simple_hl('Grey', palette.grey, palette.none)
  simple_hl('Red', palette.red, palette.none)
  merged_hl('PaleRed', palette.palered, palette.none, { bold = true })
  simple_hl('Orange', palette.orange, palette.none)
  merged_hl('OrangeBold', palette.orange, palette.none, { bold = true })
  simple_hl('Yellow', palette.yellow, palette.none)
  simple_hl('Green', palette.green, palette.none)
  simple_hl('Blue', theme.blue, palette.none)
  merged_hl('BlueBold', theme.blue, palette.none, { bold = true })
  simple_hl('Purple', theme.purple, palette.none)
  merged_hl('PurpleBold', theme.purple, palette.none, { bold = true })
  simple_hl('DarkPurple', theme.darkpurple, palette.none)
  merged_hl('DarkPurpleBold', theme.darkpurple, palette.none, { bold = true })
  merged_hl('RedBold', palette.red, palette.none, { bold = true })
  simple_hl('Teal', theme.teal, palette.none)
  merged_hl('TealBold', theme.teal, palette.none, { bold = true })

  simple_hl('RedItalic', palette.red, palette.none)
  simple_hl('OrangeItalic', palette.orange, palette.none)
  simple_hl('YellowItalic', palette.yellow, palette.none)
  simple_hl('GreenItalic', palette.green, palette.none)
  simple_hl('BlueItalic', palette.blue, palette.none)
  simple_hl('PurpleItalic', palette.purple, palette.none)
  simple_hl('RedSign', palette.red, palette.none)
  simple_hl('OrangeSign', palette.orange, palette.none)
  simple_hl('YellowSign', palette.yellow, palette.none)
  simple_hl('GreenSign', theme.string, palette.none)
  simple_hl('BlueSign', palette.blue, palette.none)
  simple_hl('PurpleSign', palette.purple, palette.none)
  merged_hl('ErrorText', palette.none, palette.none, { undercurl = true, sp = palette.red[1] })
  merged_hl('WarningText', palette.none, palette.none, { undercurl = true, sp = palette.yellow[1] })
  merged_hl('InfoText', palette.none, palette.none, { undercurl = true, sp = palette.blue[1] })
  merged_hl('HintText', palette.none, palette.none, { undercurl = true, sp = palette.green[1] })
  --highlight clear ErrorLine
  --highlight clear WarningLine
  --highlight clear InfoLine
  --highlight clear HintLine
  link_hl("VirtualTextWarning", "Grey")
  link_hl("VirtualTextError", "Grey")
  link_hl("VirtualTextInfo", "Grey")
  link_hl("VirtualTextHint", "Grey")

  simple_hl('ErrorFloat', palette.red, palette.none) -- was palette.bg2"
  simple_hl('WarningFloat', palette.yellow, palette.none)
  simple_hl('InfoFloat', palette.blue, palette.none)
  simple_hl('HintFloat', palette.green, palette.none)

  merged_hl('TSStrong', palette.none, palette.none, { bold = true })
  merged_hl('TSEmphasis', palette.none, palette.none, { italic = true })
  merged_hl('TSUnderline', palette.none, palette.none, { underline = true })
  merged_hl('TSNote', palette.bg0, palette.blue, { bold = true })
  merged_hl('TSWarning', palette.bg0, palette.yellow, { bold = true })
  merged_hl('TSDanger', palette.bg0, palette.red, { bold = true })

  link_hl("TSAnnotation", "BlueItalic")
  link_hl("TSAttribute", "BlueItalic")
  link_hl("TSBoolean", "PaleRed")
  link_hl("TSCharacter", "Yellow")
  link_hl("TSComment", "Comment")
  link_hl("TSConditional", "Conditional")
  link_hl("TSConstBuiltin", "OrangeItalic")
  link_hl("TSConstMacro", "OrangeItalic")
  link_hl("TSConstant", "Constant")
  link_hl("TSConstructor", "Yellow")
  link_hl("TSException", "Red")
  link_hl("TSField", "Orange")
  link_hl("TSFloat", "Purple")
  link_hl("TSFuncBuiltin", "TealBold")
  link_hl("TSFuncMacro", "TealBold")
  link_hl("TSFunction", "Teal")
  link_hl("TSInclude", "Green")
  link_hl("TSKeyword", "BlueBold")
  link_hl("TSKeywordFunction", "PaleRed")
  link_hl("TSKeywordOperator", "RedBold")
  link_hl("TSLabel", "Red")
  link_hl("TSMethod", "Method")
  link_hl("TSNamespace", "DarkPurpleBold")
  link_hl("TSNone", "Fg")
  link_hl("TSNumber", "Number")
  link_hl("TSOperator", "RedBold")
  link_hl("TSParameter", "FgDimBoldItalic")
  link_hl("TSParameterReference", "Fg")
  link_hl("TSProperty", "Orange")
  link_hl("TSPunctBracket", "RedBold")
  link_hl("TSPunctDelimiter", "RedBold")
  link_hl("TSPunctSpecial", "RedBold")
  link_hl("TSRepeat", "BlueBold")
  link_hl("TSStorageClass", "Purple")
  link_hl("TSString", "String")
  link_hl("TSStringEscape", "Green")
  link_hl("TSStringRegex", "String")
  link_hl("TSSymbol", "Fg")
  link_hl("TSTag", "BlueItalic")
  link_hl("TSTagDelimiter", "RedBold")
  link_hl("TSText", "Green")
  link_hl("TSStrike", "Grey")
  link_hl("TSMath", "Yellow")
  link_hl("TSType", "DarkPurpleBold")
  link_hl("TSTypeBuiltin", "BlueItalic")
  link_hl("TSTypeDefinition", "Red")
  link_hl("TSTypeQualifier", "BlueItalic")
  link_hl("TSURI", "markdownUrl")
  link_hl("TSVariable", "Fg")
  link_hl("TSVariableBuiltin", "Fg")
  link_hl("@annotation", "TSAnnotation")
  link_hl("@attribute", "TSAttribute")
  link_hl("@boolean", "TSBoolean")
  link_hl("@character", "TSCharacter")
  link_hl("@comment", "TSComment")
  link_hl("@conditional", "TSConditional")
  link_hl("@constant", "TSConstant")
  link_hl("@constant.builtin", "TSConstBuiltin")
  link_hl("@constant.macro", "TSConstMacro")
  link_hl("@constructor", "TSConstructor")
  link_hl("@exception", "TSException")
  link_hl("@field", "TSField")
  link_hl("@float", "TSFloat")
  link_hl("@function", "TSFunction")
  link_hl("@function.builtin", "TSFuncBuiltin")
  link_hl("@function.macro", "TSFuncMacro")
  link_hl("@include", "TSInclude")
  link_hl("@keyword", "TSKeyword")
  link_hl("@keyword.function", "TSKeywordFunction")
  link_hl("@keyword.operator", "TSKeywordOperator")
  link_hl("@label", "TSLabel")
  link_hl("@method", "TSMethod")
  link_hl("@namespace", "TSNamespace")
  link_hl("@none", "TSNone")
  link_hl("@number", "TSNumber")
  link_hl("@operator", "TSOperator")
  link_hl("@parameter", "TSParameter")
  link_hl("@parameter.reference", "TSParameterReference")
  link_hl("@property", "TSProperty")
  link_hl("@punctuation.bracket", "TSPunctBracket")
  link_hl("@punctuation.delimiter", "TSPunctDelimiter")
  link_hl("@punctuation.special", "TSPunctSpecial")
  link_hl("@repeat", "TSRepeat")
  link_hl("@storageclass", "TSStorageClass")
  link_hl("@string", "TSString")
  link_hl("@string.escape", "TSStringEscape")
  link_hl("@string.regex", "TSStringRegex")
  link_hl("@symbol", "TSSymbol")
  link_hl("@tag", "TSTag")
  link_hl("@tag.delimiter", "TSTagDelimiter")
  link_hl("@text", "TSText")
  link_hl("@strike", "TSStrike")
  link_hl("@math", "TSMath")
  link_hl("@type", "TSType")
  link_hl("@type.builtin", "TSTypeBuiltin")
  link_hl("@type.definition", "TSTypeDefinition")
  link_hl("@type.qualifier", "TSTypeQualifier")
  link_hl("@uri", "TSURI")
  link_hl("@variable", "TSVariable")
  link_hl("@variable.builtin", "TSVariableBuiltin")
  link_hl("@text.emphasis.latex", "TSEmphasis")

  link_hl("@lsp.type.parameter", "FgDimBoldItalic")
  link_hl("@lsp.type.variable", "Fg")
  link_hl("@lsp.type.selfKeyword", "TSTypeBuiltin")
  link_hl("@lsp.type.method", "Method")
  link_hl("multiple_cursors_cursor", "Cursor")
  link_hl("multiple_cursors_visual", "Visual")

  simple_hl('VMCursor', palette.blue, palette.grey_dim)

  link_hl("FloatermBorder", "Grey")
  link_hl("BookmarkSign", "BlueSign")
  link_hl("BookmarkAnnotationSign", "GreenSign")
  link_hl("BookmarkLine", "DiffChange")
  link_hl("BookmarkAnnotationLine", "DiffAdd")

  merged_hl('TelescopeMatching', palette.palered, palette.none, { bold = true })
  simple_hl('TelescopeBorder', theme.accent, palette.bg_dim)
  simple_hl('TelescopePromptBorder', theme.accent, palette.bg_dim)
  merged_hl('TelescopePromptNormal', palette.fg_dim, palette.bg_dim, { bold = true })
  simple_hl('TelescopeNormal', palette.fg_dim, palette.bg_dim)
  merged_hl('TelescopeTitle', theme.accent_fg, theme.accent, { bold = true })

  link_hl("MiniPickBorder", "TelescopeBorder")
  link_hl("MiniPickBorderBusy", "TelescopeBorder")
  link_hl("MiniPickBorderText", "TelescopeBorder")
  link_hl("MiniPickNormal", "TelescopeNormal")
  link_hl("MiniPickHeader", "TelescopeTitle")
  link_hl("MiniPickMatchCurrent", "Visual")

  link_hl("TelescopeResultsLineNr", "Yellow")
  link_hl("TelescopePromptPrefix", "Blue")
  link_hl("TelescopeSelection", "Visual")

  link_hl("FzfLuaNormal", "TelescopeNormal")
  link_hl("FzfLuaBorder", "TelescopeBorder")
  link_hl("FzfLuaSearch", "TelescopeMatching")
  -- lewis6991/gitsigns.nvim {{{
  link_hl("GitSignsAdd", "GreenSign")
  link_hl("GitSignsAddNr", "GreenSign")
  link_hl("GitSignsChange", "BlueBold")
  link_hl("GitSignsChangeNr", "BlueBold")
  link_hl("GitSignsDelete", "RedSign")
  link_hl("GitSignsDeleteNr", "Red")
  link_hl("GitSignsAddLn", "DiffAdd")
  link_hl("GitSignsChangeLn", "DiffChange")
  link_hl("GitSignsDeleteLn", "DiffDelete")
  link_hl("GitSignsCurrentLineBlame", "Grey")

  -- phaazon/hop.nvim {{{
  merged_hl('HopNextKey', palette.red, palette.none, { bold = true })
  merged_hl('HopNextKey1', palette.blue, palette.none, { bold = true })
  link_hl("HopNextKey2", "Blue")
  link_hl("HopUnmatched", "Grey")

  -- lukas-reineke/indent-blankline.nvim
  merged_hl('IndentBlanklineContextChar', palette.diff_green, palette.none, { nocombine = true })
  merged_hl('IndentBlanklineChar', palette.bg1, palette.none, { nocombine = true })
  link_hl("IndentBlanklineSpaceChar", "IndentBlanklineChar")
  link_hl("IndentBlanklineSpaceCharBlankline", "IndentBlanklineChar")
  -- rainbow colors, supported but not in use.
  set_hl(0, "IndentBlanklineIndent1", { fg = "#401C15", nocombine = true })
  set_hl(0, "IndentBlanklineIndent2", { fg = "#15401B", nocombine = true })
  set_hl(0, "IndentBlanklineIndent3", { fg = "#583329", nocombine = true })
  set_hl(0, "IndentBlanklineIndent4", { fg = "#163642", nocombine = true })
  set_hl(0, "IndentBlanklineIndent5", { fg = "#112F6F", nocombine = true })
  set_hl(0, "IndentBlanklineIndent6", { fg = "#56186D", nocombine = true })

  -- rcarriga/nvim-notify {{{
  link_hl("NotifyERRORBorder", "Red")
  link_hl("NotifyWARNBorder", "Yellow")
  link_hl("NotifyINFOBorder", "Green")
  link_hl("NotifyDEBUGBorder", "Grey")
  link_hl("NotifyTRACEBorder", "Purple")
  link_hl("NotifyERRORIcon", "Red")
  link_hl("NotifyWARNIcon", "Yellow")
  link_hl("NotifyINFOIcon", "Green")
  link_hl("NotifyDEBUGIcon", "Grey")
  link_hl("NotifyTRACEIcon", "Purple")
  link_hl("NotifyERRORTitle", "Red")
  link_hl("NotifyWARNTitle", "Yellow")
  link_hl("NotifyINFOTitle", "Green")
  link_hl("NotifyDEBUGTitle", "Grey")
  link_hl("NotifyTRACETitle", "Purple")

  simple_hl('InclineNormalNC', palette.grey, palette.bg2)

  link_hl("diffAdded", "Green")
  link_hl("diffRemoved", "Red")
  link_hl("diffChanged", "Blue")
  link_hl("diffOldFile", "Yellow")
  link_hl("diffNewFile", "Orange")
  link_hl("diffFile", "Purple")
  link_hl("diffLine", "Grey")
  link_hl("diffIndexLine", "Purple")

  -- https://github.com/kyazdani42/nvim-tree.lua
  simple_hl('NvimTreeNormal', palette.fg, palette.neotreebg)
  simple_hl('NvimTreeEndOfBuffer', palette.bg_dim, palette.neotreebg)
  simple_hl('NvimTreeVertSplit', palette.bg0, palette.bg0)
  link_hl("NvimTreeSymlink", "Fg")
  link_hl("NvimTreeFolderName", "BlueBold")
  link_hl("NvimTreeRootFolder", "Yellow")
  link_hl("NvimTreeFolderIcon", "Blue")
  link_hl("NvimTreeEmptyFolderName", "Green")
  link_hl("NvimTreeOpenedFolderName", "BlueBold")
  link_hl("NvimTreeExecFile", "Fg")
  link_hl("NvimTreeOpenedFile", "PurpleBold")
  link_hl("NvimTreeSpecialFile", "Fg")
  link_hl("NvimTreeImageFile", "Fg")
  link_hl("NvimTreeMarkdownFile", "Fg")
  link_hl("NvimTreeIndentMarker", "Grey")
  link_hl("NvimTreeGitDirty", "Yellow")
  link_hl("NvimTreeGitStaged", "Blue")
  link_hl("NvimTreeGitMerge", "Orange")
  link_hl("NvimTreeGitRenamed", "Purple")
  link_hl("NvimTreeGitNew", "Green")
  link_hl("NvimTreeGitDeleted", "Red")
  link_hl("NvimTreeLspDiagnosticsError", "RedSign")
  link_hl("NvimTreeLspDiagnosticsWarning", "YellowSign")
  link_hl("NvimTreeLspDiagnosticsInformation", "BlueSign")
  link_hl("NvimTreeLspDiagnosticsHint", "GreenSign")

  merged_hl('markdownH1', palette.red, palette.none, { bold = true })
  merged_hl('markdownH2', palette.orange, palette.none, { bold = true })
  merged_hl('markdownH3', palette.yellow, palette.none, { bold = true })
  merged_hl('markdownH4', palette.green, palette.none, { bold = true })
  merged_hl('markdownH5', palette.blue, palette.none, { bold = true })
  merged_hl('markdownH6', palette.purple, palette.none, { bold = true })
  merged_hl('markdownUrl', palette.blue, palette.none, { underline = true })
  merged_hl('markdownItalic', palette.none, palette.none, { italic = true })
  merged_hl('markdownBold', palette.none, palette.none, { bold = true })
  merged_hl('markdownItalicDelimiter', palette.grey, palette.none, { italic = true })
  link_hl("markdownCode", "Purple")
  link_hl("markdownCodeBlock", "Green")
  link_hl("markdownCodeDelimiter", "Green")
  link_hl("markdownBlockquote", "Grey")
  link_hl("markdownListMarker", "Red")
  link_hl("markdownOrderedListMarker", "Red")
  link_hl("markdownRule", "Purple")
  link_hl("markdownHeadingRule", "Grey")
  link_hl("markdownUrlDelimiter", "Grey")
  link_hl("markdownLinkDelimiter", "Grey")
  link_hl("markdownLinkTextDelimiter", "Grey")
  link_hl("markdownHeadingDelimiter", "Grey")
  link_hl("markdownLinkText", "Red")
  link_hl("markdownUrlTitleDelimiter", "Green")
  link_hl("markdownIdDeclaration", "markdownLinkText")
  link_hl("markdownBoldDelimiter", "Grey")
  link_hl("markdownId", "Yellow")
-- vim-markdown: https://github.com/gabrielelana/vim-markdown{{{
  merged_hl('mdURL', palette.blue, palette.none, { underline = true })
  merged_hl('mkdInineURL', palette.blue, palette.none, { underline = true })
  merged_hl('mkdItalic', palette.grey, palette.none, { italic = true })
  link_hl("mkdCodeDelimiter", "Green")
  link_hl("mkdBold", "Grey")
  merged_hl('mkdLink', theme.blue, palette.none, { underline = true })
  link_hl("mkdHeading", "Grey")
  link_hl("mkdListItem", "Red")
  link_hl("mkdRule", "Purple")
  link_hl("mkdDelimiter", "Grey")
  link_hl("mkdId", "Yellow")
  -- syn_begin: tex {{{
  -- builtin: http://www.drchip.org/astronaut/vim/index.html#SYNTAX_TEX{{{
  link_hl("texStatement", "BlueItalic")
  link_hl("texOnlyMath", "Grey")
  link_hl("texDefName", "Yellow")
  link_hl("texNewCmd", "Orange")
  link_hl("texCmdName", "BlueBold")
  link_hl("texBeginEnd", "Red")
  link_hl("texBeginEndName", "Green")
  link_hl("texDocType", "Type")
  link_hl("texDocZone", "BlueBold")
  link_hl("texDocTypeArgs", "Orange")
  link_hl("texInputFile", "Green")
  -- vimtex: https://github.com/lervag/vimtex {{{
  link_hl("texFileArg", "Green")
  link_hl("texCmd", "BlueItalic")
  link_hl("texCmdPackage", "BlueItalic")
  link_hl("texCmdDef", "Red")
  link_hl("texDefArgName", "Yellow")
  link_hl("texCmdNewcmd", "Red")
  link_hl("texCmdClass", "Red")
  link_hl("texCmdTitle", "Red")
  link_hl("texCmdAuthor", "Red")
  link_hl("texCmdEnv", "Red")
  link_hl("texCmdPart", "BlueBold")
  link_hl("texEnvArgName", "Green")

  -- syn_begin: html/markdown/javascriptreact/typescriptreact {{{
  -- builtin: https://notabug.org/jorgesumle/vim-html-syntax{{{
  merged_hl('htmlH1', palette.blue, palette.none, { bold = true })
  merged_hl('htmlH2', palette.orange, palette.none, { bold = true })
  merged_hl('htmlH3', palette.yellow, palette.none, { bold = true })
  merged_hl('htmlH4', palette.green, palette.none, { bold = true })
  merged_hl('htmlH5', palette.blue, palette.none, { bold = true })
  merged_hl('htmlH6', palette.purple, palette.none, { bold = true })
  merged_hl('htmlLink', palette.none, palette.none, { underline = true })
  merged_hl('htmlBold', palette.none, palette.none, { bold = true })
  merged_hl('htmlBoldUnderline', palette.none, palette.none, { bold = true, underline = true })
  merged_hl('htmlBoldItalic', palette.none, palette.none, { bold = true, italic = true })
  merged_hl('htmlBoldUnderlineItalic', palette.none, palette.none, { bold = true, underline = true, italic = true })
  merged_hl('htmlUnderline', palette.none, palette.none, { underline = true })
  merged_hl('htmlUnderlineItalic', palette.none, palette.none, { underline = true, italic = true })
  merged_hl('htmlItalic', palette.none, palette.none, { italic = true })
  link_hl("htmlTag", "Green")
  link_hl("htmlEndTag", "Blue")
  link_hl("htmlTagN", "RedItalic")
  link_hl("htmlTagName", "RedItalic")
  link_hl("htmlArg", "Blue")
  link_hl("htmlScriptTag", "Purple")
  link_hl("htmlSpecialTagName", "RedItalic")
  link_hl("htmlString", "Green")

  -- vim-less: https://github.com/groenewege/vim-less
  link_hl("lessMixinChar", "Grey")
  link_hl("lessClass", "Red")
  link_hl("lessFunction", "Orange")
  -- syn_begin: javascript/javascriptreact
  -- builtin: http://www.fleiner.com/vim/syntax/javascript.vim
  link_hl("javaScriptNull", "OrangeItalic")
  link_hl("javaScriptIdentifier", "BlueItalic")
  link_hl("javaScriptParens", "Fg")
  link_hl("javaScriptBraces", "Fg")
  link_hl("javaScriptNumber", "Purple")
  link_hl("javaScriptLabel", "Red")
  link_hl("javaScriptGlobal", "BlueItalic")
  link_hl("javaScriptMessage", "BlueItalic")
  -- syn_begin: objc
  link_hl("objcModuleImport", "Red")
  link_hl("objcException", "Red")
  link_hl("objcProtocolList", "Fg")
  link_hl("objcDirective", "Red")
  link_hl("objcPropertyAttribute", "Purple")
  link_hl("objcHiddenArgument", "Fg")
  -- syn_begin: python
  -- builtin
  link_hl("pythonBuiltin", "BlueItalic")
  link_hl("pythonExceptions", "Red")
  link_hl("pythonDecoratorName", "OrangeItalic")
  -- syn_begin: lua
  -- builtin:
  link_hl("luaFunc", "Green")
  link_hl("luaFunction", "Red")
  link_hl("luaTable", "Fg")
  link_hl("luaIn", "Red")
  -- syn_begin: java
  -- builtin:
  link_hl("javaClassDecl", "Red")
  link_hl("javaMethodDecl", "Red")
  link_hl("javaVarArg", "Fg")
  link_hl("javaAnnotation", "Purple")
  link_hl("javaUserLabel", "Purple")
  link_hl("javaTypedef", "OrangeItalic")
  link_hl("javaParen", "Fg")
  link_hl("javaParen1", "Fg")
  link_hl("javaParen2", "Fg")
  link_hl("javaParen3", "Fg")
  link_hl("javaParen4", "Fg")
  link_hl("javaParen5", "Fg")
  -- syn_begin: kotlin
  -- kotlin-vim: https://github.com/udalov/kotlin-vim
  link_hl("ktSimpleInterpolation", "Purple")
  link_hl("ktComplexInterpolation", "Purple")
  link_hl("ktComplexInterpolationBrace", "Purple")
  link_hl("ktStructure", "Red")
  link_hl("ktKeyword", "OrangeItalic")
  -- syn_begin: swift
  -- swift.vim: https://github.com/keith/swift.vim
  link_hl("swiftInterpolatedWrapper", "Purple")
  link_hl("swiftInterpolatedString", "Purple")
  link_hl("swiftProperty", "Fg")
  link_hl("swiftTypeDeclaration", "Red")
  link_hl("swiftClosureArgument", "OrangeItalic")
  link_hl("swiftStructure", "Red")
  -- syn_begin: matlab
  -- builtin:
  link_hl("matlabSemicolon", "Fg")
  link_hl("matlabFunction", "RedItalic")
  link_hl("matlabImplicit", "Green")
  link_hl("matlabDelimiter", "Fg")
  link_hl("matlabOperator", "Green")
  link_hl("matlabArithmeticOperator", "Red")
  link_hl("matlabArithmeticOperator", "Red")
  link_hl("matlabRelationalOperator", "Red")
  link_hl("matlabRelationalOperator", "Red")
  link_hl("matlabLogicalOperator", "Red")
end

local scheme = {}

function scheme.set()
  set_all()
end
return scheme

--print(vim.inspect(theme))
--print(vim.inspect(palette))
