-------------------------------------------------------------------------------
--Name:         Darkmatter
--
--BASED ON original work by:
--Name:         Sonokai
--Description:  High Contrast & Vivid Color Scheme based on Monokai Pro
--Author:       Sainnhepark <i@sainnhe.dev>
--Website:      https://github.com/sainnhe/sonokai/
--License:      MIT
-------------------------------------------------------------------------------
--rewritten to lua and heavily modified for my personal Neovim config at:
--https://gitlab.com/silvercircle74/nvim
--License:      MIT
--it features multiple background modes (cold, warm and deepdark) and three levels of color saturation.
--bright vivid and two desaturated modes

local set_hl = vim.api.nvim_set_hl
local palette = {}
local localtheme = {}

local M = {}
M.keys_set = false

M.theme = {
  string = 'yellow',    -- yellow strings, default is green. Respects desaturate
  -- accent color is used for important highlights like the currently selected tab (buffer)
  -- and more.
  --accent_color = '#cbaf00',
  accent_color = '#305030',
  --alt_accent_color = '#bd2f4f',
  alt_accent_color = '#501010',
  accent_fg = '#cccc80',
  lualine = 'internal',  -- use 'internal' for the integrated theme or any valid lualine theme name
  selbg = '#104090',
  cold = {
    statuslinebg = '#262630',
    bg = '#141414',
    treebg = '#18181c',
    gutterbg = '#101013',
    kittybg = '#18181c'
  },
  warm = {
    statuslinebg = '#2a2626',
    bg = '#161414',
    treebg = '#1b1818',
    gutterbg = '#131010',
    kittybg = '#1b1818'
  },
  deepblack = {
    statuslinebg = '#222228',
    bg = '#0a0a0a',
    treebg = '#121212',
    gutterbg = '#0f0f0f',
    kittybg = '#111111'
  }
}

local conf = {
  -- color variant. as of now, 3 types are supported:
  -- a) "warm" - the default, a medium-dark grey background with a slightly red-ish tint.
  -- b) "cold" - about the same, but with a blue-ish flavor
  -- c) "deepblack" - very dark, almost black background. neutral grey tone.
  variant = 'warm',
  desaturate = true,
  dlevel = 1, -- desaturation level (1 = mild, 2 = strong, pastel-like")
  -- Supported are "yellow" and "green".
  theme_strings = 'yellow',
  -- kitty features are disabled by default.
  -- if configured properly, the theme's set() function can also set kitty's background
  -- color via remote control. It needs a valid unix socket and kitten executable.
  -- use setup() to set sync_kittybg to true and submit kittysocket and kittenexec.
  sync_kittybg = false,
  kittysocket = nil,
  kittenexec = nil,
  is_trans = false,
  keyprefix = "<leader>",
  -- the callback will be called by all functions that change the theme's configuration
  -- Callback must be of type("function") and receives one parameter:
  -- a string describing what has changed. Possible values are "variant", "strings",
  -- "desaturate" and "trans"
  -- The callback can use get_conf() to retrieve the current configuration and setup() to
  -- change it.
  callback = nil
}
M.cokeline_colors = {}
local  LuaLineColors = {
  white        = '#ffffff',
  darkestgreen = M.theme.accent_fg,
  brightgreen  = M.theme.accent_color,
  darkestcyan  = '#005f5f',
  mediumcyan   = '#87dfff',
  darkestblue  = '#005f87',
  darkred      = '#870000',
  brightred    = M.theme.alt_accent_color,
  brightorange = '#2f47df',
  gray1        = '#262626',
  gray2        = '#303030',
  gray4        = '#585858',
  gray5        = '#404050',
  gray7        = '#9e9e9e',
  gray10       = '#f0f0f0',
  statuslinebg = M.theme[conf.variant].statuslinebg
}

local diff = vim.api.nvim_win_get_option(0, "diff")

--- set a highlight group with only colors
--- @param hlg string: highlight group name
--- @param fg table: foreground color defintion containing a gui color and a cterm color index
--- @param bg table: as above, but for the background.
--- for both gui colors "none" is allowed to set no color.
local function hl_with_defaults(hlg, fg, bg)
  set_hl(0, hlg, { fg = fg[1], ctermfg = fg[2], bg = bg[1], ctermbg = bg[2] })
end

--- set a full highlight defintion
--- @param hlg string: highlight group to set
--- @param fg table: color definition for foreground
--- @param bg table: color definition for background
--- @param attr table: additional attributes like gui, sp bold etc.
local function hl(hlg, fg, bg, attr)
  local _t = {
    fg      = fg[1],
    ctermfg = fg[2],
    bg      = bg[1],
    ctermbg = bg[2]
  }
  set_hl(0, hlg, vim.tbl_extend("force", _t, attr))
end

--- create a highlight group link
--- @param hlg string: highlight group to set
--- @param target string: target highlight group
local function link(hlg, target)
  set_hl(0, hlg, { link = target })
end

-- configure the theme data. this must always be called after using setup() or
-- other means to change the conf table.
-- set() automatically calls it before setting any highlight groups.
local function configure()
  if conf.desaturate == true then
    localtheme = {
      orange     = (conf.dlevel == 1) and { '#ab6a6c', 215 } or { '#9b7a7c', 215 },
      blue       = { '#5a6acf', 239 },
      purple     = (conf.dlevl == 1) and { '#b070b0', 241 } or { '#a070a0', 241 },
      teal       = { '#508080', 238 },
      brightteal = { '#70a0c0', 238 },
      darkpurple = { '#705070', 240 },
      red        = (conf.dlevel == 1) and { '#bb4d5c', 203 } or { '#ab5d6c', 203 },
      yellow     = (conf.dlevel == 1) and { '#aaaa60', 231 } or { '#909870', 231 },
      green      = (conf.dlevel == 1) and { '#60906f', 231 } or { '#658075', 231 }
    }
  else
    localtheme = {
      orange     = { '#c36630', 215 },
      blue       = { '#4a4adf', 239 },
      purple     = { '#c030c0', 241 },
      teal       = { '#108080', 238 },
      brightteal = { '#30a0c0', 238 },
      darkpurple = { '#803090', 240 },
      red        = { '#cc2d4c', 203 },
      yellow     = { '#cccc60', 231 },
      green      = { '#10801f', 232 }
    }
  end

  localtheme.string = conf.theme_strings == "yellow" and localtheme.yellow or localtheme.green

  LuaLineColors.statuslinebg = M.theme[conf.variant].statuslinebg

  -- TODO: allow cokeline colors per theme variant
  M.cokeline_colors = {
    --bg = LuaLineColors.statuslinebg,
    bg = M.theme[conf.variant].statuslinebg,
    focus_bg = M.theme.selbg,
    fg = LuaLineColors.gray7,
    focus_fg = M.theme.accent_fg,
  }

  if conf.variant == 'cold' or conf.variant == 'deepblack' then
    localtheme.fg           = { '#a2a0ac', 1 }
    localtheme.darkbg       = { M.theme[conf.variant].gutterbg, 237 }
    localtheme.darkred      = { '#601010', 249 }
    localtheme.darkestred   = { '#161616', 249 }
    localtheme.darkestblue  = { '#10101a', 247 }
    localtheme.bg           = { M.theme[conf.variant].bg, 0 }
    localtheme.statuslinebg = { M.theme[conf.variant].statuslinebg, 208 }
    localtheme.pmenubg      = { '#241a20', 156 }
    localtheme.accent       = { M.theme['accent_color'], 209 }
    localtheme.accent_fg    = { M.theme['accent_fg'], 210 }
    localtheme.tablinebg    = { M.cokeline_colors['bg'], 214 }
    localtheme.black        = { '#121215', 232 }
    localtheme.bg_dim       = { '#222327', 232 }
    localtheme.bg0          = { '#2c2e34', 235 }
    localtheme.bg1          = { '#33353f', 236 }
    localtheme.bg2          = { '#363944', 236 }
    localtheme.bg3          = { '#3b3e48', 237 }
    localtheme.bg4          = { '#414550', 237 }
  else
    localtheme.fg           = { '#aaa0a5', 1 }
    localtheme.darkbg       = { M.theme[conf.variant].gutterbg, 237 }
    localtheme.darkred      = { '#601010', 249 }
    localtheme.darkestred   = { '#161616', 249 }
    localtheme.darkestblue  = { '#10101a', 247 }
    localtheme.bg           = { M.theme[conf.variant].bg, 0 }
    localtheme.statuslinebg = { M.theme[conf.variant].statuslinebg, 208 }
    localtheme.pmenubg      = { '#241a20', 156 }
    localtheme.accent       = { M.theme['accent_color'], 209 }
    localtheme.accent_fg    = { M.theme['accent_fg'], 210 }
    localtheme.tablinebg    = { M.cokeline_colors['bg'], 214 }
    localtheme.black        = { '#151212', 232 }
    localtheme.bg_dim       = { '#242020', 232 }
    localtheme.bg0          = { '#302c2e', 235 }
    localtheme.bg1          = { '#322a2a', 236 }
    localtheme.bg2          = { '#403936', 236 }
    localtheme.bg3          = { '#483e3b', 237 }
    localtheme.bg4          = { '#504531', 237 }
  end
  palette = {
    grey        = { '#707070', 2 },
    bg_red      = { '#ff6077', 203 },
    diff_red    = { '#55393d', 52 },
    bg_green    = { '#a7df78', 107 },
    diff_green  = { '#697664', 22 },
    bg_blue     = { '#85d3f2', 110 },
    diff_blue   = { '#253147', 17 },
    diff_yellow = { '#4e432f', 54 },
    fg_dim      = { '#959290', 251 },
    palered     = { '#8b2d3c', 203 },
    darkyellow  = { '#a78624', 180 },
    green       = { '#9ed072', 107 },
    purple      = { '#b39df3', 176 },
    grey_dim    = { '#595f6f', 240 },
    neotreebg   = { M.theme[conf.variant].treebg, 232 },
    selfg       = { '#cccc20', 233 },
    selbg       = { M.theme['selbg'], 234 },
    none        = { 'NONE', 'NONE' }
  }
end

-- set all hl groups
local function set_all()
  hl_with_defaults("Braces", localtheme.red, palette.none)
  hl_with_defaults('ScrollView', localtheme.teal, localtheme.blue)
  hl_with_defaults('Normal', localtheme.fg, localtheme.bg)
  hl_with_defaults('Accent', localtheme.black, localtheme.accent)
  hl_with_defaults('Terminal', localtheme.fg, palette.neotreebg)
  hl_with_defaults('EndOfBuffer', localtheme.bg4, palette.none)
  hl_with_defaults('Folded', localtheme.fg, palette.diff_blue)
  hl_with_defaults('ToolbarLine', localtheme.fg, palette.none)
  hl_with_defaults('FoldColumn', localtheme.bg4, localtheme.darkbg)
  hl_with_defaults('SignColumn', localtheme.fg, localtheme.darkbg)
  hl_with_defaults('IncSearch', localtheme.yellow, localtheme.darkred)
  hl_with_defaults('Search', localtheme.black, palette.diff_green)
  hl_with_defaults('ColorColumn', palette.none, localtheme.bg1)
  hl_with_defaults('Conceal', palette.grey_dim, palette.none)
  hl_with_defaults('Cursor', localtheme.fg, localtheme.fg)
  hl_with_defaults('nCursor', localtheme.fg, localtheme.fg)
  hl_with_defaults('iCursor', localtheme.yellow, localtheme.yellow)
  hl_with_defaults('vCursor', localtheme.red, localtheme.red)

  link("CursorIM", "iCursor")

  hl('FocusedSymbol', localtheme.yellow, palette.none, { bold = true })

  if diff then
    hl('CursorLine', palette.none, palette.none, { underline = true })
    hl('CursorColumn', palette.none, palette.none, { bold = true })
  else
    hl_with_defaults('CursorLine', palette.none, localtheme.bg0)
    hl_with_defaults('CursorColumn', palette.none, localtheme.bg1)
  end

  hl_with_defaults('LineNr', palette.grey_dim, localtheme.darkbg)
  if diff then
    hl('CursorLineNr', localtheme.yellow, palette.none, { underline = true })
  else
    hl_with_defaults('CursorLineNr', localtheme.yellow, localtheme.darkbg)
  end

  hl_with_defaults('DiffAdd', palette.none, palette.diff_green)
  hl_with_defaults('DiffChange', palette.none, palette.diff_blue)
  hl_with_defaults('DiffDelete', palette.none, palette.diff_red)
  hl_with_defaults('DiffText', localtheme.bg0, localtheme.blue)
  hl('Directory', localtheme.blue, palette.none, { bold = true })
  hl('ErrorMsg', localtheme.red, palette.none, { bold = true, underline = true })
  hl('WarningMsg', localtheme.yellow, palette.none, { bold = true })
  hl('ModeMsg', localtheme.fg, palette.none, { bold = true })
  hl('MoreMsg', localtheme.blue, palette.none, { bold = true })
  hl_with_defaults('MatchParen', localtheme.yellow, localtheme.darkred)

  hl_with_defaults('NonText', localtheme.bg4, palette.none)
  hl_with_defaults('Whitespace', palette.green, palette.none)
  hl_with_defaults('ExtraWhitespace', palette.green, palette.none)
  hl_with_defaults('SpecialKey', palette.green, palette.none)
  hl_with_defaults('Pmenu', localtheme.fg, localtheme.pmenubg)
  hl_with_defaults('PmenuSbar', palette.none, localtheme.bg2)
  link('PmenuSel', "Visual")
  link("WildMenu", "PmenuSel")

  hl_with_defaults('PmenuThumb', palette.none, palette.grey)
  hl_with_defaults('NormalFloat', localtheme.fg, localtheme.bg_dim)
  hl_with_defaults('FloatBorder', palette.grey_dim, localtheme.bg_dim)
  hl_with_defaults('Question', localtheme.yellow, palette.none)
  hl('SpellBad', palette.none, palette.none, { undercurl = true, sp = localtheme.red[1] })
  hl('SpellCap', palette.none, palette.none, { undercurl = true, sp = localtheme.yellow[1] })
  hl('SpellLocal', palette.none, palette.none, { undercurl = true, sp = localtheme.blue[1] })
  hl('SpellRare', palette.none, palette.none, { undercurl = true, sp = palette.purple[1] })
  hl_with_defaults('StatusLine', localtheme.fg, localtheme.statuslinebg)
  hl_with_defaults('StatusLineTerm', localtheme.fg, palette.none)
  hl_with_defaults('StatusLineNC', palette.grey, localtheme.statuslinebg)
  hl_with_defaults('StatusLineTermNC', palette.grey, palette.none)
  hl_with_defaults('TabLine', localtheme.fg, localtheme.statuslinebg)
  hl_with_defaults('TabLineFill', palette.grey, localtheme.tablinebg)
  hl_with_defaults('TabLineSel', localtheme.bg0, palette.bg_red)
  hl_with_defaults('VertSplit', localtheme.statuslinebg, palette.neotreebg)

  link("MsgArea", "StatusLine")
  link("WinSeparator", "VertSplit")

  hl_with_defaults('Visual', palette.selfg, palette.selbg)
  hl('VisualNOS', palette.none, localtheme.bg3, { underline = true })
  hl_with_defaults('QuickFixLine', localtheme.blue, palette.neotreebg)
  hl_with_defaults('Debug', localtheme.yellow, palette.none)
  hl_with_defaults('debugPC', localtheme.bg0, palette.green)
  hl_with_defaults('debugBreakpoint', localtheme.bg0, localtheme.red)
  hl_with_defaults('ToolbarButton', localtheme.bg0, palette.bg_blue)
  hl_with_defaults('Substitute', localtheme.bg0, localtheme.yellow)

  link("DiagnosticFloatingError", "ErrorFloat")
  link("DiagnosticFloatingWarn", "WarningFloat")
  link("DiagnosticFloatingInfo", "InfoFloat")
  link("DiagnosticFloatingHint", "HintFloat")
  link("DiagnosticError", "ErrorText")
  link("DiagnosticWarn", "WarningText")
  link("DiagnosticInfo", "InfoText")
  link("DiagnosticHint", "HintText")
  link("DiagnosticVirtualTextError", "VirtualTextError")
  link("DiagnosticVirtualTextWarn", "VirtualTextWarning")
  link("DiagnosticVirtualTextInfo", "VirtualTextInfo")
  link("DiagnosticVirtualTextHint", "VirtualTextHint")
  link("DiagnosticUnderlineError", "ErrorText")
  link("DiagnosticUnderlineWarn", "WarningText")
  link("DiagnosticUnderlineInfo", "InfoText")
  link("DiagnosticUnderlineHint", "HintText")
  link("DiagnosticSignOk", "GreenSign")
  link("DiagnosticSignError", "RedSign")
  link("DiagnosticSignWarn", "YellowSign")
  link("DiagnosticSignInfo", "BlueSign")
  link("DiagnosticSignHint", "GreenSign")
  link("LspDiagnosticsFloatingError", "DiagnosticFloatingError")
  link("LspDiagnosticsFloatingWarning", "DiagnosticFloatingWarn")
  link("LspDiagnosticsFloatingInformation", "DiagnosticFloatingInfo")
  link("LspDiagnosticsFloatingHint", "DiagnosticFloatingHint")
  link("LspDiagnosticsDefaultError", "DiagnosticError")
  link("LspDiagnosticsDefaultWarning", "DiagnosticWarn")
  link("LspDiagnosticsDefaultInformation", "DiagnosticInfo")
  link("LspDiagnosticsDefaultHint", "DiagnosticHint")
  link("LspDiagnosticsVirtualTextError", "DiagnosticVirtualTextError")
  link("LspDiagnosticsVirtualTextWarning", "DiagnosticVirtualTextWarn")
  link("LspDiagnosticsVirtualTextInformation", "DiagnosticVirtualTextInfo")
  link("LspDiagnosticsVirtualTextHint", "DiagnosticVirtualTextHint")
  link("LspDiagnosticsUnderlineError", "DiagnosticUnderlineError")
  link("LspDiagnosticsUnderlineWarning", "DiagnosticUnderlineWarn")
  link("LspDiagnosticsUnderlineInformation", "DiagnosticUnderlineInfo")
  link("LspDiagnosticsUnderlineHint", "DiagnosticUnderlineHint")
  link("LspDiagnosticsSignError", "DiagnosticSignError")
  link("LspDiagnosticsSignWarning", "DiagnosticSignWarn")
  link("LspDiagnosticsSignInformation", "DiagnosticSignInfo")
  link("LspDiagnosticsSignHint", "DiagnosticSignHint")
  link("LspReferenceText", "CurrentWord")
  link("LspReferenceRead", "CurrentWord")
  link("LspReferenceWrite", "CurrentWord")
  link("LspCodeLens", "VirtualTextInfo")
  link("LspCodeLensSeparator", "VirtualTextHint")
  link("LspSignatureActiveParameter", "Yellow")
  link("TermCursor", "Cursor")
  link("healthError", "Red")
  link("healthSuccess", "Green")
  link("healthWarning", "Yellow")

  hl('Type', localtheme.darkpurple, palette.none, { bold = true })
  hl('Structure', localtheme.darkpurple, palette.none, { bold = true })
  hl('StorageClass', localtheme.purple, palette.none, { bold = true })
  hl_with_defaults('Identifier', localtheme.orange, palette.none)
  hl_with_defaults('Constant', palette.purple, palette.none)
  hl('PreProc', palette.darkyellow, palette.none, { bold = true })
  hl('PreCondit', palette.darkyellow, palette.none, { bold = true })
  hl_with_defaults('Include', palette.green, palette.none)
  hl('Keyword', localtheme.blue, palette.none, { bold = true })
  hl_with_defaults('Define', localtheme.red, palette.none)
  hl('Typedef', localtheme.red, palette.none, { bold = true })
  hl_with_defaults('Exception', localtheme.red, palette.none)
  hl('Conditional', palette.darkyellow, palette.none, { bold = true })
  hl('Repeat', localtheme.blue, palette.none, { bold = true })
  hl('Statement', localtheme.blue, palette.none, { bold = true })
  hl_with_defaults('Macro', palette.purple, palette.none)
  hl_with_defaults('Error', localtheme.red, palette.none)
  hl_with_defaults('Label', palette.purple, palette.none)
  hl('Special', localtheme.darkpurple, palette.none, { bold = true })
  hl_with_defaults('SpecialChar', palette.purple, palette.none)
  hl_with_defaults('Boolean', palette.palered, palette.none)
  hl_with_defaults('String', localtheme.string, palette.none)
  hl_with_defaults('Character', localtheme.yellow, palette.none)
  hl('Number', localtheme.purple, palette.none, { bold = true })
  hl_with_defaults('Float', palette.purple, palette.none)
  hl('Function', localtheme.teal, palette.none, { bold = true })
  hl('Method', localtheme.brightteal, palette.none, { bold = true })

  hl('Operator', localtheme.red, palette.none, { bold = true })
  hl('Title', localtheme.red, palette.none, { bold = true })
  hl_with_defaults('Tag', localtheme.orange, palette.none)
  hl('Delimiter', localtheme.red, palette.none, { bold = true })
  hl_with_defaults('Comment', palette.grey, palette.none)
  hl_with_defaults('SpecialComment', palette.grey, palette.none)
  hl_with_defaults('Todo', localtheme.blue, palette.none)
  hl_with_defaults('Ignore', palette.grey, palette.none)
  hl('Underlined', palette.none, palette.none, { underline = true })

  hl_with_defaults('Fg', localtheme.fg, palette.none)
  hl('FgBold', localtheme.fg, palette.none, { bold = true })
  hl('FgItalic', localtheme.fg, palette.none, { italic = true })
  hl('FgDimBold', palette.fg_dim, palette.none, { bold = true })
  hl('FgDimBoldItalic', palette.fg_dim, palette.none, { bold = true, italic = true })
  hl_with_defaults('Grey', palette.grey, palette.none)
  hl_with_defaults('Red', localtheme.red, palette.none)
  hl('PaleRed', palette.palered, palette.none, { bold = true })
  hl_with_defaults('Orange', localtheme.orange, palette.none)
  hl('OrangeBold', localtheme.orange, palette.none, { bold = true })
  hl_with_defaults('Yellow', localtheme.yellow, palette.none)
  hl_with_defaults('Green', palette.green, palette.none)
  hl_with_defaults('Blue', localtheme.blue, palette.none)
  hl('BlueBold', localtheme.blue, palette.none, { bold = true })
  hl_with_defaults('Purple', localtheme.purple, palette.none)
  hl('PurpleBold', localtheme.purple, palette.none, { bold = true })
  hl_with_defaults('DarkPurple', localtheme.darkpurple, palette.none)
  hl('DarkPurpleBold', localtheme.darkpurple, palette.none, { bold = true })
  hl('RedBold', localtheme.red, palette.none, { bold = true })
  hl_with_defaults('Teal', localtheme.teal, palette.none)
  hl('TealBold', localtheme.teal, palette.none, { bold = true })

  hl_with_defaults('RedItalic', localtheme.red, palette.none)
  hl_with_defaults('OrangeItalic', localtheme.orange, palette.none)
  hl_with_defaults('YellowItalic', localtheme.yellow, palette.none)
  hl_with_defaults('GreenItalic', palette.green, palette.none)
  hl_with_defaults('BlueItalic', localtheme.blue, palette.none)
  hl_with_defaults('PurpleItalic', palette.purple, palette.none)
  hl_with_defaults('RedSign', localtheme.red, localtheme.darkbg)
  hl_with_defaults('OrangeSign', localtheme.orange, localtheme.darkbg)
  hl_with_defaults('YellowSign', localtheme.yellow, localtheme.darkbg)
  hl_with_defaults('GreenSign', palette.green, localtheme.darkbg)
  hl_with_defaults('BlueSign', localtheme.blue, localtheme.darkbg)
  hl_with_defaults('PurpleSign', palette.purple, localtheme.darkbg)
  hl('ErrorText', palette.none, palette.none, { undercurl = true, sp = localtheme.red[1] })
  hl('WarningText', palette.none, palette.none, { undercurl = true, sp = localtheme.yellow[1] })
  hl('InfoText', palette.none, palette.none, { undercurl = true, sp = localtheme.blue[1] })
  hl('HintText', palette.none, palette.none, { undercurl = true, sp = palette.green[1] })
  --highlight clear ErrorLine
  --highlight clear WarningLine
  --highlight clear InfoLine
  --highlight clear HintLine
  link("VirtualTextWarning", "Grey")
  link("VirtualTextError", "Grey")
  link("VirtualTextInfo", "Grey")
  link("VirtualTextHint", "Grey")

  hl_with_defaults('ErrorFloat', localtheme.red, palette.none) -- was localtheme.bg2"
  hl_with_defaults('WarningFloat', localtheme.yellow, palette.none)
  hl_with_defaults('InfoFloat', localtheme.blue, palette.none)
  hl_with_defaults('HintFloat', palette.green, palette.none)

  hl('TSStrong', palette.none, palette.none, { bold = true })
  hl('TSEmphasis', palette.none, palette.none, { italic = true })
  hl('TSUnderline', palette.none, palette.none, { underline = true })
  hl('TSNote', localtheme.bg0, localtheme.blue, { bold = true })
  hl('TSWarning', localtheme.bg0, localtheme.yellow, { bold = true })
  hl('TSDanger', localtheme.bg0, localtheme.red, { bold = true })

  link("TSAnnotation", "BlueItalic")
  link("TSAttribute", "BlueItalic")
  link("TSBoolean", "PaleRed")
  link("TSCharacter", "Yellow")
  link("TSComment", "Comment")
  link("TSConditional", "Conditional")
  link("TSConstBuiltin", "OrangeItalic")
  link("TSConstMacro", "OrangeItalic")
  link("TSConstant", "Constant")
  link("TSConstructor", "Yellow")
  link("TSException", "Red")
  link("TSField", "Orange")
  link("TSFloat", "Purple")
  link("TSFuncBuiltin", "TealBold")
  link("TSFuncMacro", "TealBold")
  link("TSFunction", "Teal")
  link("TSInclude", "Green")
  link("TSKeyword", "BlueBold")
  link("TSKeywordFunction", "PaleRed")
  link("TSKeywordOperator", "RedBold")
  link("TSLabel", "Red")
  link("TSMethod", "Method")
  link("TSNamespace", "DarkPurpleBold")
  link("TSNone", "Fg")
  link("TSNumber", "Number")
  link("TSOperator", "RedBold")
  link("TSParameter", "FgDimBoldItalic")
  link("TSParameterReference", "Fg")
  link("TSProperty", "Orange")
  link("TSPunctBracket", "RedBold")
  link("TSPunctDelimiter", "RedBold")
  link("TSPunctSpecial", "RedBold")
  link("TSRepeat", "BlueBold")
  link("TSStorageClass", "Purple")
  link("TSString", "String")
  link("TSStringEscape", "Green")
  link("TSStringRegex", "String")
  link("TSSymbol", "Fg")
  link("TSTag", "BlueItalic")
  link("TSTagDelimiter", "RedBold")
  link("TSText", "Green")
  link("TSStrike", "Grey")
  link("TSMath", "Yellow")
  link("TSType", "DarkPurpleBold")
  link("TSTypeBuiltin", "BlueItalic")
  link("TSTypeDefinition", "Red")
  link("TSTypeQualifier", "BlueItalic")
  link("TSURI", "markdownUrl")
  link("TSVariable", "Fg")
  link("TSVariableBuiltin", "Fg")
  link("@annotation", "TSAnnotation")
  link("@attribute", "TSAttribute")
  link("@boolean", "TSBoolean")
  link("@character", "TSCharacter")
  link("@comment", "TSComment")
  link("@conditional", "TSConditional")
  link("@constant", "TSConstant")
  link("@constant.builtin", "TSConstBuiltin")
  link("@constant.macro", "TSConstMacro")
  link("@constructor", "TSConstructor")
  link("@exception", "TSException")
  link("@field", "TSField")
  link("@float", "TSFloat")
  link("@function", "TSFunction")
  link("@function.builtin", "TSFuncBuiltin")
  link("@function.macro", "TSFuncMacro")
  link("@include", "TSInclude")
  link("@keyword", "TSKeyword")
  link("@keyword.function", "TSKeywordFunction")
  link("@keyword.operator", "TSKeywordOperator")
  link("@label", "TSLabel")
  link("@method", "TSMethod")
  link("@namespace", "TSNamespace")
  link("@none", "TSNone")
  link("@number", "TSNumber")
  link("@operator", "TSOperator")
  link("@parameter", "TSParameter")
  link("@parameter.reference", "TSParameterReference")
  link("@property", "TSProperty")
  link("@punctuation.bracket", "TSPunctBracket")
  link("@punctuation.delimiter", "TSPunctDelimiter")
  link("@punctuation.special", "TSPunctSpecial")
  link("@repeat", "TSRepeat")
  link("@storageclass", "TSStorageClass")
  link("@string", "TSString")
  link("@string.escape", "TSStringEscape")
  link("@string.regex", "TSStringRegex")
  link("@symbol", "TSSymbol")
  link("@tag", "TSTag")
  link("@tag.delimiter", "TSTagDelimiter")
  link("@text", "TSText")
  link("@strike", "TSStrike")
  link("@math", "TSMath")
  link("@type", "TSType")
  link("@type.builtin", "TSTypeBuiltin")
  link("@type.definition", "TSTypeDefinition")
  link("@type.qualifier", "TSTypeQualifier")
  link("@uri", "TSURI")
  link("@variable", "TSVariable")
  link("@variable.builtin", "TSVariableBuiltin")
  link("@text.emphasis.latex", "TSEmphasis")

  link("@lsp.type.parameter", "FgDimBoldItalic")
  link("@lsp.type.variable", "Fg")
  link("@lsp.type.selfKeyword", "TSTypeBuiltin")
  link("@lsp.type.method", "Method")
  link("multiple_cursors_cursor", "Cursor")
  link("multiple_cursors_visual", "Visual")

  hl_with_defaults('VMCursor', localtheme.blue, palette.grey_dim)

  link("FloatermBorder", "Grey")
  link("BookmarkSign", "BlueSign")
  link("BookmarkAnnotationSign", "GreenSign")
  link("BookmarkLine", "DiffChange")
  link("BookmarkAnnotationLine", "DiffAdd")

  hl('TelescopeMatching', palette.palered, palette.none, { bold = true })
  hl_with_defaults('TelescopeBorder', localtheme.accent, localtheme.bg_dim)
  hl_with_defaults('TelescopePromptBorder', localtheme.accent, localtheme.bg_dim)
  hl('TelescopePromptNormal', palette.fg_dim, localtheme.bg_dim, { bold = true })
  hl_with_defaults('TelescopeNormal', palette.fg_dim, localtheme.bg_dim)
  hl('TelescopeTitle', localtheme.accent_fg, localtheme.accent, { bold = true })

  link("MiniPickBorder", "TelescopeBorder")
  link("MiniPickBorderBusy", "TelescopeBorder")
  link("MiniPickBorderText", "TelescopeBorder")
  link("MiniPickNormal", "TelescopeNormal")
  link("MiniPickHeader", "TelescopeTitle")
  link("MiniPickMatchCurrent", "Visual")

  link("TelescopeResultsLineNr", "Yellow")
  link("TelescopePromptPrefix", "Blue")
  link("TelescopeSelection", "Visual")

  link("FzfLuaNormal", "TelescopeNormal")
  link("FzfLuaBorder", "TelescopeBorder")
  link("FzfLuaSearch", "TelescopeMatching")
  -- lewis6991/gitsigns.nvim {{{
  link("GitSignsAdd", "GreenSign")
  link("GitSignsAddNr", "GreenSign")
  link("GitSignsChange", "BlueSign")
  link("GitSignsChangeNr", "BlueSign")
  link("GitSignsDelete", "RedSign")
  link("GitSignsDeleteNr", "RedSign")
  link("GitSignsAddLn", "GreenSign")
  link("GitSignsChangeLn", "BlueSign")
  link("GitSignsDeleteLn", "RedSign")
  link("GitSignsCurrentLineBlame", "Grey")

  -- phaazon/hop.nvim {{{
  hl('HopNextKey', localtheme.red, palette.none, { bold = true })
  hl('HopNextKey1', localtheme.blue, palette.none, { bold = true })
  link("HopNextKey2", "Blue")
  link("HopUnmatched", "Grey")

  -- lukas-reineke/indent-blankline.nvim
  hl('IndentBlanklineContextChar', palette.diff_green, palette.none, { nocombine = true })
  hl('IndentBlanklineChar', localtheme.bg1, palette.none, { nocombine = true })
  link("IndentBlanklineSpaceChar", "IndentBlanklineChar")
  link("IndentBlanklineSpaceCharBlankline", "IndentBlanklineChar")
  -- rainbow colors
  set_hl(0, "IndentBlanklineIndent1", { fg = "#401C15", nocombine = true })
  set_hl(0, "IndentBlanklineIndent2", { fg = "#15401B", nocombine = true })
  set_hl(0, "IndentBlanklineIndent3", { fg = "#583329", nocombine = true })
  set_hl(0, "IndentBlanklineIndent4", { fg = "#163642", nocombine = true })
  set_hl(0, "IndentBlanklineIndent5", { fg = "#112F6F", nocombine = true })
  set_hl(0, "IndentBlanklineIndent6", { fg = "#56186D", nocombine = true })

  -- rcarriga/nvim-notify {{{
  link("NotifyERRORBorder", "Red")
  link("NotifyWARNBorder", "Yellow")
  link("NotifyINFOBorder", "Green")
  link("NotifyDEBUGBorder", "Grey")
  link("NotifyTRACEBorder", "Purple")
  link("NotifyERRORIcon", "Red")
  link("NotifyWARNIcon", "Yellow")
  link("NotifyINFOIcon", "Green")
  link("NotifyDEBUGIcon", "Grey")
  link("NotifyTRACEIcon", "Purple")
  link("NotifyERRORTitle", "Red")
  link("NotifyWARNTitle", "Yellow")
  link("NotifyINFOTitle", "Green")
  link("NotifyDEBUGTitle", "Grey")
  link("NotifyTRACETitle", "Purple")

  hl_with_defaults('InclineNormalNC', palette.grey, localtheme.bg2)

  link("diffAdded", "Green")
  link("diffRemoved", "Red")
  link("diffChanged", "Blue")
  link("diffOldFile", "Yellow")
  link("diffNewFile", "Orange")
  link("diffFile", "Purple")
  link("diffLine", "Grey")
  link("diffIndexLine", "Purple")

  -- https://github.com/kyazdani42/nvim-tree.lua
  hl_with_defaults('NvimTreeNormal', localtheme.fg, palette.neotreebg)
  hl_with_defaults('NvimTreeEndOfBuffer', localtheme.bg_dim, palette.neotreebg)
  hl_with_defaults('NvimTreeVertSplit', localtheme.bg0, localtheme.bg0)
  link("NvimTreeSymlink", "Fg")
  link("NvimTreeFolderName", "BlueBold")
  link("NvimTreeRootFolder", "Yellow")
  link("NvimTreeFolderIcon", "Blue")
  link("NvimTreeEmptyFolderName", "Green")
  link("NvimTreeOpenedFolderName", "BlueBold")
  link("NvimTreeExecFile", "Fg")
  link("NvimTreeOpenedFile", "PurpleBold")
  link("NvimTreeSpecialFile", "Fg")
  link("NvimTreeImageFile", "Fg")
  link("NvimTreeMarkdownFile", "Fg")
  link("NvimTreeIndentMarker", "Grey")
  link("NvimTreeGitDirty", "Yellow")
  link("NvimTreeGitStaged", "Blue")
  link("NvimTreeGitMerge", "Orange")
  link("NvimTreeGitRenamed", "Purple")
  link("NvimTreeGitNew", "Green")
  link("NvimTreeGitDeleted", "Red")
  link("NvimTreeLspDiagnosticsError", "RedSign")
  link("NvimTreeLspDiagnosticsWarning", "YellowSign")
  link("NvimTreeLspDiagnosticsInformation", "BlueSign")
  link("NvimTreeLspDiagnosticsHint", "GreenSign")

  hl('markdownH1', localtheme.red, palette.none, { bold = true })
  hl('markdownH2', localtheme.orange, palette.none, { bold = true })
  hl('markdownH3', localtheme.yellow, palette.none, { bold = true })
  hl('markdownH4', palette.green, palette.none, { bold = true })
  hl('markdownH5', localtheme.blue, palette.none, { bold = true })
  hl('markdownH6', palette.purple, palette.none, { bold = true })
  hl('markdownUrl', localtheme.blue, palette.none, { underline = true })
  hl('markdownItalic', palette.none, palette.none, { italic = true })
  hl('markdownBold', palette.none, palette.none, { bold = true })
  hl('markdownItalicDelimiter', palette.grey, palette.none, { italic = true })
  link("markdownCode", "Purple")
  link("markdownCodeBlock", "Green")
  link("markdownCodeDelimiter", "Green")
  link("markdownBlockquote", "Grey")
  link("markdownListMarker", "Red")
  link("markdownOrderedListMarker", "Red")
  link("markdownRule", "Purple")
  link("markdownHeadingRule", "Grey")
  link("markdownUrlDelimiter", "Grey")
  link("markdownLinkDelimiter", "Grey")
  link("markdownLinkTextDelimiter", "Grey")
  link("markdownHeadingDelimiter", "Grey")
  link("markdownLinkText", "Red")
  link("markdownUrlTitleDelimiter", "Green")
  link("markdownIdDeclaration", "markdownLinkText")
  link("markdownBoldDelimiter", "Grey")
  link("markdownId", "Yellow")
  -- vim-markdown: https://github.com/gabrielelana/vim-markdown{{{
  hl('mdURL', localtheme.blue, palette.none, { underline = true })
  hl('mkdInineURL', localtheme.blue, palette.none, { underline = true })
  hl('mkdItalic', palette.grey, palette.none, { italic = true })
  link("mkdCodeDelimiter", "Green")
  link("mkdBold", "Grey")
  hl('mkdLink', localtheme.blue, palette.none, { underline = true })
  link("mkdHeading", "Grey")
  link("mkdListItem", "Red")
  link("mkdRule", "Purple")
  link("mkdDelimiter", "Grey")
  link("mkdId", "Yellow")
  -- syn_begin: tex {{{
  -- builtin: http://www.drchip.org/astronaut/vim/index.html#SYNTAX_TEX{{{
  link("texStatement", "BlueItalic")
  link("texOnlyMath", "Grey")
  link("texDefName", "Yellow")
  link("texNewCmd", "Orange")
  link("texCmdName", "BlueBold")
  link("texBeginEnd", "Red")
  link("texBeginEndName", "Green")
  link("texDocType", "Type")
  link("texDocZone", "BlueBold")
  link("texDocTypeArgs", "Orange")
  link("texInputFile", "Green")
  -- vimtex: https://github.com/lervag/vimtex {{{
  link("texFileArg", "Green")
  link("texCmd", "BlueItalic")
  link("texCmdPackage", "BlueItalic")
  link("texCmdDef", "Red")
  link("texDefArgName", "Yellow")
  link("texCmdNewcmd", "Red")
  link("texCmdClass", "Red")
  link("texCmdTitle", "Red")
  link("texCmdAuthor", "Red")
  link("texCmdEnv", "Red")
  link("texCmdPart", "BlueBold")
  link("texEnvArgName", "Green")

  -- syn_begin: html/markdown/javascriptreact/typescriptreact {{{
  -- builtin: https://notabug.org/jorgesumle/vim-html-syntax{{{
  hl('htmlH1', localtheme.blue, palette.none, { bold = true })
  hl('htmlH2', localtheme.orange, palette.none, { bold = true })
  hl('htmlH3', localtheme.yellow, palette.none, { bold = true })
  hl('htmlH4', palette.green, palette.none, { bold = true })
  hl('htmlH5', localtheme.blue, palette.none, { bold = true })
  hl('htmlH6', palette.purple, palette.none, { bold = true })
  hl('htmlLink', palette.none, palette.none, { underline = true })
  hl('htmlBold', palette.none, palette.none, { bold = true })
  hl('htmlBoldUnderline', palette.none, palette.none, { bold = true, underline = true })
  hl('htmlBoldItalic', palette.none, palette.none, { bold = true, italic = true })
  hl('htmlBoldUnderlineItalic', palette.none, palette.none, { bold = true, underline = true, italic = true })
  hl('htmlUnderline', palette.none, palette.none, { underline = true })
  hl('htmlUnderlineItalic', palette.none, palette.none, { underline = true, italic = true })
  hl('htmlItalic', palette.none, palette.none, { italic = true })
  link("htmlTag", "Green")
  link("htmlEndTag", "Blue")
  link("htmlTagN", "RedItalic")
  link("htmlTagName", "RedItalic")
  link("htmlArg", "Blue")
  link("htmlScriptTag", "Purple")
  link("htmlSpecialTagName", "RedItalic")
  link("htmlString", "Green")

  -- syn_begin: python
  -- builtin
  link("pythonBuiltin", "BlueItalic")
  link("pythonExceptions", "Red")
  link("pythonDecoratorName", "OrangeItalic")
  -- syn_begin: lua
  -- builtin:
  link("luaFunc", "Green")
  link("luaFunction", "Red")
  link("luaTable", "Fg")
  link("luaIn", "Red")
  -- syn_begin: java
  -- builtin:
  link("javaClassDecl", "Red")
  link("javaMethodDecl", "Red")
  link("javaVarArg", "Fg")
  link("javaAnnotation", "Purple")
  link("javaUserLabel", "Purple")
  link("javaTypedef", "OrangeItalic")
  link("javaParen", "Fg")
  link("javaParen1", "Fg")
  link("javaParen2", "Fg")
  link("javaParen3", "Fg")
  link("javaParen4", "Fg")
  link("javaParen5", "Fg")
  -- syn_begin: kotlin
  -- kotlin-vim: https://github.com/udalov/kotlin-vim
  link("ktSimpleInterpolation", "Purple")
  link("ktComplexInterpolation", "Purple")
  link("ktComplexInterpolationBrace", "Purple")
  link("ktStructure", "Red")
  link("ktKeyword", "OrangeItalic")
  -- syn_begin: swift
  -- swift.vim: https://github.com/keith/swift.vim
  link("swiftInterpolatedWrapper", "Purple")
  link("swiftInterpolatedString", "Purple")
  link("swiftProperty", "Fg")
  link("swiftTypeDeclaration", "Red")
  link("swiftClosureArgument", "OrangeItalic")
  link("swiftStructure", "Red")
  -- syn_begin: matlab
  -- builtin:
  link("matlabSemicolon", "Fg")
  link("matlabFunction", "RedItalic")
  link("matlabImplicit", "Green")
  link("matlabDelimiter", "Fg")
  link("matlabOperator", "Green")
  link("matlabArithmeticOperator", "Red")
  link("matlabArithmeticOperator", "Red")
  link("matlabRelationalOperator", "Red")
  link("matlabRelationalOperator", "Red")
  link("matlabLogicalOperator", "Red")

  -- syn_begin: help
  hl('helpNote', palette.purple, palette.none, { bold = true })
  hl('helpHeadline', localtheme.red, palette.none, { bold = true })
  hl('helpHeader', localtheme.orange, palette.none, { bold = true })
  hl('helpURL', palette.green, palette.none, { underline = true })
  hl('helpHyperTextEntry', localtheme.blue, palette.none, { bold = true })
  link("helpHyperTextJump", "Blue")
  link("helpCommand", "Yellow")
  link("helpExample", "Green")
  link("helpSpecial", "Purple")
  link("helpSectionDelim", "Grey")

  -- CMP (with custom menu setup)
  set_hl(0, "CmpItemKindDefault", { fg = "#cc5de8" })
  link("CmpItemKind", "CmpItemKindDefault")
  set_hl(0, "CmpItemMenu", { fg = "#ededcf" })
  set_hl(0, "CmpItemMenuDetail", { fg = "#ffe066" })
  set_hl(0, "CmpItemMenuBuffer", { fg = "#898989" })
  set_hl(0, "CmpItemMenuSnippet", { fg = "#cc5de8" })
  set_hl(0, "CmpItemMenuLSP", { fg = "#cfa050" })
  link("CmpItemMenuPath", "CmpItemMenu")

  hl_with_defaults('CmpPmenu', localtheme.fg, localtheme.bg_dim)
  hl_with_defaults('CmpPmenuBorder', palette.grey_dim, localtheme.bg_dim)
  hl_with_defaults('CmpGhostText', palette.grey, palette.none)
  set_hl(0, "CmpItemAbbr", { fg = "#d0b1d0" })

  set_hl(0, "CmpItemAbbrDeprecated", { bg = 'NONE', strikethrough = true, fg = "#808080" })
  set_hl(0, "mpItemAbbrMatch", { bg = 'NONE', fg = "#f03e3e", bold = true })
  set_hl(0, "CmpItemAbbrMatchFuzzy", { bg = 'NONE', fg = "#fd7e14", bold = true })

  set_hl(0, "CmpItemKindModule", { bg = 'NONE', fg = '#FF7F50' })
  set_hl(0, "CmpItemKindClass", { bg = 'none', fg = "#FFAF00" })
  link("CmpItemKindStruct", "CmpItemKindClass")
  set_hl(0, "CmpItemKindVariable", { bg = 'none', fg = "#9CDCFE" })
  set_hl(0, "CmpItemKindProperty", { bg = 'none', fg = "#9CDCFE" })
  set_hl(0, "CmpItemKindFunction", { bg = 'none', fg = "#C586C0" })
  link("CmpItemKindConstructor", "CmpItemKindFunction")
  link("CmpItemKindMethod", "CmpItemKindFunction")
  set_hl(0, "CmpItemKindKeyword", { bg = 'none', fg = "#FF5FFF" })
  set_hl(0, "CmpItemKindText", { bg = 'none', fg = "#D4D4D4" })
  set_hl(0, "CmpItemKindUnit", { bg = 'none', fg = "#D4D4D4" })
  set_hl(0, "CmpItemKindConstant", { bg = 'none', fg = "#409F31" })
  set_hl(0, "CmpItemKindSnippet", { bg = 'none', fg = "#E3E300" })

  -- Glance plugin: https://github.com/DNLHC/glance.nvim
  hl_with_defaults('GlancePreviewNormal', localtheme.fg, localtheme.black)
  hl_with_defaults('GlancePreviewMatch', localtheme.yellow, palette.none)
  hl_with_defaults('GlanceListMatch', localtheme.yellow, palette.none)
  link("GlanceListCursorLine", "Visual")

  -- allow neotree and other addon panels have different backgrounds
  hl_with_defaults('NeoTreeNormalNC', localtheme.fg, palette.neotreebg)
  hl_with_defaults('NeoTreeNormal', localtheme.fg, palette.neotreebg)
  hl_with_defaults('NeoTreeFloatBorder', palette.grey_dim, palette.neotreebg)
  hl('NeoTreeFileNameOpened', localtheme.blue, palette.neotreebg, { italic = true })
  hl_with_defaults('SymbolsOutlineConnector', localtheme.bg4, palette.none)

  -- Treesitter stuff
  hl_with_defaults('TreesitterContext', palette.none, localtheme.bg)
  link("TreesitterContextSeparator", "Type")
  link("NvimTreeIndentMarker", "SymbolsOutlineConnector")
  link("OutlineGuides", "SymbolsOutlineConnector")
  link("NeoTreeCursorLine", "Visual")
  link("AerialGuide", "SymbolsOutlineConnector")

  -- WinBar
  hl_with_defaults('WinBarFilename', localtheme.fg, localtheme.accent)                                                    -- Filename (right hand)
  hl('WinBarContext', palette.darkyellow, palette.none, { underline = true, sp = localtheme.accent[1] }) -- LSP context (left hand)
  -- WinBarInvis is for the central padding item. It should be transparent and invisible (fg = bg)
  -- This is a somewhat hack-ish way to make the lualine-controlle winbar transparent.
  hl('WinBarInvis', localtheme.bg, localtheme.bg, { underline = true, sp = localtheme.accent[1] })
  link("WinBarNC", "StatusLineNC")
  link("WinBar", "WinBarContext")

  -- Lazy plugin manager
  link("LazyNoCond", "RedBold")
  link("VirtColumn", "IndentBlankLineChar")
  link("SatelliteCursor", "WarningMsg")
  link("SatelliteSearch", "PurpleBold")
  link("SatelliteSearchCurrent", "PurpleBold")
  set_hl(0, "@ibl.scope.char.1", { bg = 'none' })

  -- multiple cursor plugin
  vim.g.VM_Mono_hl = 'DiffText'
  vim.g.VM_Extend_hl = 'DiffAdd'
  vim.g.VM_Cursor_hl = 'Visual'
  vim.g.VM_Insert_hl = 'DiffChange'
end

-- this activates the theme.
function M.set()
  configure()
  set_all()
  if conf.sync_kittybg == true and conf.kittysocket ~= nil and conf.kittenexec ~= nil then
    if vim.fn.filereadable(conf.kittysocket) == 1 and vim.fn.executable(conf.kittenexec) == 1 then
      vim.fn.jobstart(conf.kittenexec .. " @ --to unix:" .. conf.kittysocket .. " set-colors background=" .. M.theme[conf.variant].kittybg)
    else
      vim.notify("Either the kitty socket or the kitten executable is not available", vim.log.levels.WARN)
    end
  end
end

--- set color variant (warm or cold), desaturation and string color
--- @param opt table - the options to set
function M.setup(opt)
  conf = vim.tbl_deep_extend("force", conf, opt)
  -- bind keys, but do this only once
  if M.keys_set == false then
    M.keys_set = true
    vim.keymap.set({'n'}, conf.keyprefix .. "tv", function() M.ui_select_variant() end,
                   { silent = true, noremap = true, desc = "Select theme variant" })
    vim.keymap.set({'n'}, conf.keyprefix .. "td", function() M.ui_select_colorweight() end,
                   { silent = true, noremap = true, desc = "Select theme color weight" })
    vim.keymap.set({'n'}, conf.keyprefix .. "ts", function() M.toggle_strings_color() end,
                   { silent = true, noremap = true, desc = "Toggle theme strings color" })
    vim.keymap.set({'n'}, conf.keyprefix .. "tt", function() M.toggle_transparency() end,
                   { silent = true, noremap = true, desc = "Toggle theme transparency" })
  end
end

--- return the full configuration
--- @return table the color theme configuration
function M.get_conf()
  return conf
end

--- return a configuration value
--- @param val string: the value to get
function M.get_conf_value(val)
  if val ~= nil and conf[val] ~= nil then
    return conf[val]
  end
end

--- internal global function to create the lualine color theme
--- @return table
function M.Lualine_internal_theme()
  return {
    normal = {
      a = { fg = LuaLineColors.darkestgreen, bg = LuaLineColors.brightgreen --[[, gui = 'bold']] },
      b = { fg = LuaLineColors.gray10, bg = LuaLineColors.gray5 },
      c = "StatusLine",
      x = "StatusLine"
    },
    insert = {
      a = { fg = LuaLineColors.white, bg = LuaLineColors.brightred, gui = 'bold' },
      b = { fg = LuaLineColors.gray10, bg = LuaLineColors.gray5 },
      c = "StatusLine",
      x = "StatusLine",
    },
    visual = { a = { fg = LuaLineColors.white, bg = LuaLineColors.brightorange --[[, gui = 'bold']] } },
    replace = { a = { fg = LuaLineColors.white, bg = LuaLineColors.brightred, gui = 'bold' } },
    inactive = {
      a = "StatusLine",
      b = "StatusLine",
      c = "StatusLine"
    },
  }
end

-- these groups are all relevant to the signcolumn and need their bg updated when
-- switching from / to transparency mode. They are used for GitSigns, LSP diagnostics

-- marks among other things
local signgroups = { 'RedSign', 'OrangeSign', 'YellowSign', 'GreenSign', 'BlueSign', 'PurpleSign', 'CursorLineNr' }

--- set the background transparent or solid
--- this changes the relevant highlight groups to use a transparent background.
--- Needs terminal with transparency support (kitty, alacritty etc.)
function M.set_bg()
  if conf.is_trans == true then
    -- remove background colors from all relevant areas
    vim.api.nvim_set_hl(0, "Normal", { bg = "none", fg = "fg" })
    vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "none" })
    vim.cmd("hi VertSplit guibg=none")
    vim.cmd("hi LineNr guibg=none")
    vim.cmd("hi FoldColumn guibg=none")
    vim.cmd("hi SignColumn guibg=none")
    for _, v in ipairs(signgroups) do
      vim.cmd("hi " .. v .. " guibg=none")
    end
  else
    local variant = conf.variant
    vim.api.nvim_set_hl(0, "Normal", { bg = M.theme[variant].bg, fg = "fg" })
    vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = M.theme[variant].treebg, fg = "fg" })
    vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = M.theme[variant].treebg, fg = "fg" })
    vim.cmd("hi VertSplit guibg=" .. M.theme[variant].treebg)
    vim.cmd("hi LineNr guibg=" .. M.theme[variant].gutterbg)
    vim.cmd("hi FoldColumn guibg=" .. M.theme[variant].gutterbg)
    vim.cmd("hi SignColumn guibg=" .. M.theme[variant].gutterbg)
    for _, v in ipairs(signgroups) do
      vim.cmd("hi " .. v .. " guibg=" .. M.theme[variant].gutterbg)
    end
  end
end

--- call the configured (if any) callback function to indicate what
--- has changed in the theme's configuration
--- @param what string: what was changed. can be "variant", "strings"
--- "desaturate" or "trans"
local function conf_callback(what)
  if conf.callback ~= nil and type(conf.callback) == "function" then
    conf.callback(what)
  end
end

-- use vim.ui.select to choose from a list of themes
function M.ui_select_variant()
  local utils = require("local_utils")

  vim.ui.select({ "Warm (red tint)?", "Cold (blue tint)", "Deep dark" }, {
    prompt = "Select a theme variant",
    border = "rounded",
    format_item = function(item)
      return utils.pad(item, 40, " ")
    end
  }, function(choice)
    if choice == nil or #choice < 4 then return end
    local short = string.sub(choice, 1, 4)
    if short == "Warm" then
      conf.variant = "warm"
    elseif short == "Cold" then
      conf.variant = "cold"
    elseif short == 'Deep' then
      conf.variant = "deepblack"
    else
      return
    end
    M.set()
    conf_callback("variant")
  end)
  return conf.variant
end

-- use UI to present a selection of possible color configurations
-- this uses vim.ui.select and works best with plugins like dressing or
-- mini.picker that can enhance ui.select
function M.ui_select_colorweight()
  local utils = require("local_utils")
  vim.ui.select({ "Vivid (rich colors, high contrast)", "Medium (somewhat desaturated colors)", "Pastel (low intensity colors)" }, {
    prompt = "Select a color intensity",
    border = "rounded",
    format_item = function(item)
      return utils.pad(item, 50, " ")
    end
  }, function(choice)
    if choice == nil or #choice < 6 then return end
    local short = string.sub(choice, 1, 6)
    if short == "Vivid " then
      conf.desaturate = false
      conf.dlevel = 1
    elseif short == "Medium" then
      conf.desaturate = true
      conf.dlevel = 1
    elseif short == "Pastel" then
      conf.desaturate = true
      conf.dlevel = 2
    end
    M.set()
    conf_callback("desaturate")
  end)
  return conf.desaturate, conf.dlevel
end

-- toggle strings color. Allowed values are either "yellow" or "green"
function M.toggle_strings_color()
  if conf.theme_strings ~= "yellow" then
    conf.theme_strings = "yellow"
  else
    conf.theme_strings = "green"
  end
  M.set()
  conf_callback("strings")
end

-- toggle background transparency and notify the registered callback
-- subscriber.
function M.toggle_transparency()
  conf.is_trans = not conf.is_trans
  M.set_bg()
  conf_callback("trans")
end

return M
