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
--TODO: 
--      * maybe (just maybe) a bright background variant
--      * add variants of well known themes (gruv <done>, dracula <wip>)
--      * outsource into a real plugin that can be loaded as a colorscheme.
--      * extract the UI parts, replace them with an API

-- while this was originally written as a single theme, it evolved into a theme
-- engine that can handle multiple schemes, each with an arbitrary number of color
-- palettes and background themes. This is still ongoing work and the code needs
-- a lot of polishing and maybe some cleanup. Some things are overly complex and
-- could be simplified.
--
-- Customization is possible, but lacks certain features. Right now, new highlight
-- groups require plugins while it should be possible to add them during theme setup

local M = {}

-- the "no color"
M.NONE = { "NONE", "NONE" }

local rainbowpalette = {}

M.keys_set = false
-- the color palette. Dynamically created in the configure() function
M.P = nil
-- the theme. Contains the variants and basic colors for backgrounds etc.
M.T = nil
M.attributes_ovr = {}

-- the theme configuration. This can be changed by calling setup({...})
-- after changing the configuration configure() must be called before the theme
-- can be (re)activated with set()
local conf = {
  disabled = false,
  -- the scheme name. Configuration is loaded from themes/conf.scheme.lua
  scheme = "dark",
  -- the scheme configuration
  schemeconfig = {},
  -- color variant. as of now, 3 types are supported:
  -- a) "warm" - the default, a medium-dark grey background with a slightly red-ish tint.
  -- b) "cold" - about the same, but with a blue-ish flavor
  -- c) "deepblack" - very dark, almost black background. neutral grey tone.
  variant = "warm",
  -- color brightness. Set to false to get very vivid and strong colors.
  colorpalette = "vivid",
  -- The color of strings. Some prefer yellow, others not so.
  -- Supported are "yellow" and "green".
  theme_strings = "yellow",
  -- kitty features are disabled by default.
  -- if configured properly, the theme's set() function can also set kitty's background
  -- color via remote control. It needs a valid unix socket and kitten executable.
  -- use setup() to set sync_kittybg to true and submit kittysocket and kittenexec.
  sync_kittybg = false,
  sync_alacrittybg = false,
  kittysocket = nil,
  kittenexec = nil,
  -- when true, background colors will be set to none, making text area and side panels
  -- transparent.
  is_trans = false,
  -- the prefix key for accessing the keymappings (see below in setup() ). These mappings
  -- can be used to change theme settings at runtime.
  keyprefix = "<leader>",

  -- the style table controls the special color table that is mostly for syntax
  -- highlight. It defines semantic colors using the basic color names.
  style = {},
  -- colorstyles overrides from setup()
  colorstyles_ovr = {},
  --- these colors will be added to the standard palette. They can be used for
  --- styled colors.
  usercolors = {
    user1 = "#ffffff"
  },
  indentguide_colors = {
    light = "#505050",
    dark = "#505050"
  },
  rainbow_contrast = "high",
  -- attributes for various highlight classes. They allow all standard
  -- highlighting attributes like bold, italic, underline, sp.
  attrib = {},
  -- the callback will be called by all functions that change the theme's configuration
  -- Callback must be of type("function") and receives one parameter:
  -- a string describing what has changed. Possible values are "variant", "strings",
  -- "desaturate" and "trans"
  -- The callback can use get_conf() to retrieve the current configuration and setup() to
  -- change it.
  callback = nil,
  -- plugins. there are 3 kinds of plugins:
  -- customize: executed after configure() but before colors are set. Allows
  --            you to customize the color tables.
  -- hl:        list of additional highlighting. This can be used to support plugins
  --            that are not supported by default.
  -- post:      called after theme has been set
  plugins = {
    customize =  {},
    hl = { "markdown", "syntax", "common" },
    post = {}
  }
}

local diff = vim.api.nvim_win_get_option(0, "diff")

M.set_hl = vim.api.nvim_set_hl

-- these groups are all relevant to the signcolumn and need their bg updated when
-- switching from / to transparency mode since we want a transparent gutter area with
-- no background. These hlg are used for GitSigns, LSP diagnostics, marks among 
-- other things.
local signgroups = { "RedSign", "OrangeSign", "YellowSign", "GreenSign", "BlueSign", "PurpleSign", "CursorLineNr" }

local function set_signs_trans()
  for _, v in ipairs(signgroups) do
    vim.cmd("hi " .. v .. " guibg=none")
  end
end

--- set a highlight group with only colors
--- @param hlg string: highlight group name
--- @param fg table: foreground color defintion containing a gui color and a cterm color index
--- @param bg table: as above, but for the background.
--- for both gui colors "none" is allowed to set no color.
function M.hl_with_defaults(hlg, fg, bg)
  M.set_hl(0, hlg, { fg = fg[1], ctermfg = fg[2], bg = bg[1], ctermbg = bg[2] })
end

--- set a full highlight defintion
--- @param hlg string: highlight group to set
--- @param fg table: color definition for foreground
--- @param bg table: color definition for background
--- @param attr table: additional attributes like gui, sp bold etc.
function M.hl(hlg, fg, bg, attr)
  local _t = {
    fg = fg[1],
    ctermfg = fg[2],
    bg = bg[1],
    ctermbg = bg[2],
  }
  M.set_hl(0, hlg, vim.tbl_extend("force", _t, attr))
end

--- create a highlight group link
--- @param hlg string: highlight group to set
--- @param target string: target highlight group
function M.link(hlg, target)
  M.set_hl(0, hlg, { link = target })
end

-- configure the theme data. this must always be called after using setup() or
-- after changing the configuration table.
-- set() automatically calls it before setting any highlight groups.
--
-- it uses the configured scheme (conf.scheme) to load basic color tables from 
-- themes/scheme.lua
local function configure()
  local Scheme = require("darkmatter.schemes." .. conf.scheme)
  local seq = 0

  M.T = Scheme.bgtheme()
  rainbowpalette = Scheme.rainbowpalette()
  conf.attrib = vim.tbl_deep_extend("force", Scheme.attributes(), M.attributes_ovr[conf.scheme] or {} )
  conf.schemeconfig = Scheme.schemeconfig()
  conf.style = Scheme.colorstyles()
  for k,v in pairs(conf.colorstyles_ovr) do
    conf.style[k] = v
  end
  -- setup base palette
  M.P = Scheme.basepalette(conf.colorpalette)

  -- TODO: allow cokeline colors per theme variant
  M.P.fg = { M.T[conf.variant].fg[conf.colorpalette] or M.T.fg_default, 1 }
  M.P.darkbg = { M.T[conf.variant].gutterbg, 237 }
  M.P.bg = { M.T[conf.variant].bg, 0 }
  M.P.statuslinebg = { M.T[conf.variant].statuslinebg, 208 }
  M.P.accent = { M.T["accent_color"], 209 }
  M.P.accent_fg = { M.T["accent_fg"], 210 }
  M.P.tablinebg = M.P.statuslinebg
  M.P.fg_dim = { M.T[conf.variant].fg_dim[conf.colorpalette] or M.T.fg_dim_default, 2 }

  M.P.styled.fg = { M.T[conf.variant].fg , 1 }
  --M.P.string = conf.theme_strings == "yellow" and M.P.yellow or M.P.green
  M.P.string = M.P[conf.style.strings]

  -- merge custom colors into the palette
  seq = 91
  if Scheme.custom_colors ~= nil then
    for k, v in pairs(Scheme.custom_colors()) do
      M.P[k] = { v, seq }
      seq = seq + 1
    end
  end

  -- merge the variant-dependent colors
  local to_merge = { "black", "bg_dim", "bg0", "bg1", "bg2", "bg3", "bg4" }
  for _, v in pairs(to_merge) do
    M.P[v] = M.T[conf.variant][v] or { "#ffffff", 256 }
  end

  M.P.treebg = { M.T[conf.variant].treebg, 232 }
  M.P.floatbg = { M.T[conf.variant].floatbg, 232 }
  M.P.selbg = { M.T["selbg"], 234 }

  seq = 245
  for k,v in pairs(conf.usercolors) do
    M.P[k] = { v, seq }
    seq = seq + 1
    if seq == 256 then
      break
    end
  end
  -- set up special colors that can be controlled via conf.style
  -- most of these colors are for syntax highlight
  for k,v in pairs(conf.style) do
    M.P.styled[k] = M.P[v]
  end
end

-- set all hl groups
local function set_all()
  -- basic highlights
  M.hl("Braces", M.P.styled.braces, M.NONE, conf.attrib.brace)
  M.hl("Operator", M.P.styled.operator, M.NONE, conf.attrib.operator)
  M.hl("PunctDelim", M.P.styled.delim, M.NONE, conf.attrib.delim)
  M.hl("Delimiter", M.P.styled.delim, M.NONE, conf.attrib.delim)
  M.hl("PunctSpecial", M.P.styled.delim, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("ScrollView", M.P.teal, M.P.c3)
  M.hl_with_defaults("Normal", M.P.fg, M.P.bg)
  M.hl_with_defaults("Accent", M.P.black, M.P.accent)
  M.hl_with_defaults("Terminal", M.P.fg, M.P.treebg)
  M.hl_with_defaults("EndOfBuffer", M.P.bg4, M.NONE)
  M.hl_with_defaults("Folded", M.P.fg, M.P.diff_blue)
  M.hl_with_defaults("ToolbarLine", M.P.fg, M.NONE)
  M.hl_with_defaults("FoldColumn", M.P.bg4, M.NONE)
  M.hl_with_defaults("SignColumn", M.P.fg, M.NONE)
  M.hl_with_defaults("IncSearch", M.P.yellow, M.P.deepred)
  M.hl_with_defaults("Search", M.P.black, M.P.darkyellow)
  M.hl_with_defaults("ColorColumn", M.NONE, M.P.bg1)
  M.hl_with_defaults("Conceal", M.P.grey_dim, M.NONE)
  M.hl_with_defaults("Cursor", M.P.fg, M.P.fg)
  M.hl_with_defaults("nCursor", M.P.fg, M.P.fg)
  M.hl_with_defaults("iCursor", M.P.yellow, M.P.yellow)
  M.hl_with_defaults("vCursor", M.P.red, M.P.red)
  M.hl_with_defaults("LineNr", M.P.grey_dim, M.NONE)
  M.hl_with_defaults("DiffAdd", M.NONE, M.P.diff_green)
  M.hl_with_defaults("DiffChange", M.NONE, M.P.diff_blue)
  M.hl_with_defaults("DiffDelete", M.NONE, M.P.diff_red)
  M.hl_with_defaults("DiffText", M.P.bg0, M.P.blue)
  M.hl("Directory", M.P.blue, M.NONE, conf.attrib.bold)
  M.hl("ErrorMsg", M.P.red, M.NONE, { bold = true })
  M.hl("WarningMsg", M.P.yellow, M.NONE, conf.attrib.bold)
  M.hl("ModeMsg", M.P.fg, M.NONE, conf.attrib.bold)
  M.hl("MoreMsg", M.P.blue, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("MatchParen", M.P.yellow, M.P.deepred)
  M.hl_with_defaults("NonText", M.P.bg4, M.NONE)
  M.hl_with_defaults("Whitespace", M.P.green, M.NONE)
  M.hl_with_defaults("SpecialKey", M.P.green, M.NONE)
  M.link("WildMenu", "PmenuSel")

  M.hl_with_defaults("PmenuThumb", M.NONE, M.P.grey)
  M.hl_with_defaults("NormalFloat", M.P.fg, M.P.treebg)
  M.hl_with_defaults("FloatBorder", M.P.accent, M.P.treebg)
  M.link("LspInfoBorder", "FloatBorder")
  M.hl_with_defaults("FloatTitle", M.P.accent_fg, M.P.accent)
  M.hl_with_defaults("Question", M.P.yellow, M.NONE)
  M.hl("SpellBad", M.NONE, M.NONE, { undercurl = true, sp = M.P.red[1] })
  M.hl("SpellCap", M.NONE, M.NONE, { undercurl = true, sp = M.P.yellow[1] })
  M.hl("SpellLocal", M.NONE, M.NONE, { undercurl = true, sp = M.P.blue[1] })
  M.hl("SpellRare", M.NONE, M.NONE, { undercurl = true, sp = M.P.lpurple[1] })
  M.hl_with_defaults("StatusLine", M.P.fg, M.P.statuslinebg)
  M.hl_with_defaults("StatusLineTerm", M.P.fg, M.NONE)
  M.hl_with_defaults("StatusLineNC", M.P.grey, M.P.statuslinebg)
  M.hl_with_defaults("StatusLineTermNC", M.P.grey, M.NONE)
  M.hl_with_defaults("TabLine", M.P.fg, M.P.statuslinebg)
  M.hl("TabLineFill", M.P.grey, M.P.tablinebg, conf.attrib.tabline)
  M.hl_with_defaults("TabLineSel", M.P.accent_fg, M.P.accent)
  M.hl_with_defaults("VertSplit", M.P.statuslinebg, M.P.treebg)

  M.link("CursorIM", "iCursor")

  M.hl("FocusedSymbol", M.P.yellow, M.NONE, conf.attrib.bold)

  if diff then
    M.hl("CursorLine", M.NONE, M.NONE, { underline = true })
    M.hl("CursorColumn", M.NONE, M.NONE, conf.attrib.bold)
  else
    M.hl_with_defaults("CursorLine", M.NONE, M.P.bg0)
    M.hl_with_defaults("CursorColumn", M.NONE, M.P.bg1)
  end

  if diff then
    M.hl("CursorLineNr", M.P.yellow, M.NONE, { underline = true })
  else
    M.hl_with_defaults("CursorLineNr", M.P.olive, M.P.darkbg)
  end

  M.link("MsgArea", "StatusLine")
  M.link("WinSeparator", "VertSplit")

  M.hl_with_defaults("Visual", M.NONE, M.P.selbg)
  M.hl("VisualNOS", M.NONE, M.P.bg2, { underline = true })
  M.hl_with_defaults("Debug", M.P.yellow, M.NONE)
  M.hl_with_defaults("debugPC", M.P.bg0, M.P.green)
  M.hl_with_defaults("debugBreakpoint", M.P.bg0, M.P.red)
  M.hl_with_defaults("Substitute", M.P.bg0, M.P.yellow)
  M.hl("URL", M.P.styled.url, M.NONE, conf.attrib.url)
  M.hl("Type", M.P.styled.type, M.NONE, conf.attrib.types)
  M.hl("TypeDefinition", M.P.styled.type, M.NONE, { bold = true })
  M.hl("Structure", M.P.styled.struct, M.NONE, conf.attrib.struct)
  M.hl("Class", M.P.styled.class, M.NONE, conf.attrib.class)
  M.hl("Interface", M.P.styled.interface, M.NONE, conf.attrib.interface)
  M.hl("StorageClass", M.P.styled.storage, M.NONE, conf.attrib.storage)
  M.hl("DefaultLib", M.P.styled.defaultlib, M.NONE, conf.attrib.defaultlib)
  M.hl_with_defaults("Identifier", M.P.styled.identifier, M.NONE)
  M.hl_with_defaults("Constant", M.P.styled.constant, conf.attrib.constant)
  M.hl("Include", M.P.styled.module, M.NONE, conf.attrib.module)
  M.hl("Boolean", M.P.styled.bool, M.NONE, conf.attrib.bool)
  M.hl("Keyword", M.P.styled.keyword, M.NONE, conf.attrib.keyword)
  M.hl("KWSpecial", M.P.styled.kwspec, M.NONE, conf.attrib.kwspecial)
  M.hl("KWConditional", M.P.styled.kwconditional, M.NONE, conf.attrib.kwconditional)
  M.hl("KWRepeat", M.P.styled.kwrepeat, M.NONE, conf.attrib.kwrepeat)
  M.hl("KWException", M.P.styled.kwexception, M.NONE, conf.attrib.kwexception)
  M.hl("KWReturn", M.P.styled.kwreturn, M.NONE, conf.attrib.kwreturn)
  M.hl_with_defaults("Define", M.P.red, M.NONE)
  M.hl("Typedef", M.P.styled.type, M.NONE, conf.attrib.types)
  M.hl("Statement", M.P.styled.keyword, M.NONE, conf.attrib.keyword)
  M.hl_with_defaults("Macro", M.P.styled.macro, conf.attrib.macro)
  M.hl_with_defaults("Error", M.P.red, M.NONE)
  M.hl_with_defaults("Label", M.P.lpurple, M.NONE)
  M.hl("Special", M.P.altblue, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("SpecialChar", M.P.lpurple, M.NONE)
  M.hl("String", M.P.string, M.NONE, conf.attrib.str)
  M.hl_with_defaults("Character", M.P.yellow, M.NONE)
  M.hl("Number", M.P.styled.number, M.NONE, conf.attrib.number)
  M.link("Float", "Number")
  M.hl("Function", M.P.styled.func, M.NONE, conf.attrib.func)
  M.hl("Method", M.P.styled.method, M.NONE, conf.attrib.method)
  M.hl("StaticMethod", M.P.styled.staticmethod, M.NONE, conf.attrib.staticmethod)
  M.hl("Member", M.P.styled.member, M.NONE, conf.attrib.member)
  M.hl("StaticMember", M.P.styled.staticmember, M.NONE, conf.attrib.staticmember)
  M.hl("Builtin", M.P.styled.builtin, M.NONE, conf.attrib.bold)
  M.link("PreProc", "Include")
  M.hl("Title", M.P.red, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("Tag", M.P.orange, M.NONE)
  M.hl("Comment", M.P.styled.comment, M.NONE, conf.attrib.comment)
  M.hl_with_defaults("Todo", M.P.blue, M.NONE)
  M.hl_with_defaults("Ignore", M.P.grey, M.NONE)
  M.hl("Underlined", M.NONE, M.NONE, { underline = true })
  M.hl("Parameter", M.P.styled.parameter, M.NONE, conf.attrib.parameter)

  M.hl("Attribute", M.P.styled.attribute, M.NONE, conf.attrib.attribute)
  M.hl("Annotation", M.P.styled.attribute, M.NONE, conf.attrib.attribute)
  M.hl_with_defaults("Fg", M.P.fg, M.NONE)
  M.hl_with_defaults("FgDim", M.P.fg_dim, M.NONE)
  M.hl_with_defaults("Grey", M.P.grey, M.NONE)
  M.hl_with_defaults("Red", M.P.red, M.NONE)
  M.hl("RedBold", M.P.red, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("DeepRed", M.P.deepred, M.NONE)
  M.hl("DeepRedBold", M.P.deepred, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("Orange", M.P.orange, M.NONE)
  M.hl("OrangeBold", M.P.orange, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("Yellow", M.P.yellow, M.NONE)
  M.hl("YellowBold", M.P.yellow, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("Green", M.P.green, M.NONE)
  M.hl("GreenBold", M.P.green, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("Blue", M.P.blue, M.NONE)
  M.hl("BlueBold", M.P.blue, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("Purple", M.P.purple, M.NONE)
  M.hl("PurpleBold", M.P.purple, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("DarkPurple", M.P.darkpurple, M.NONE)
  M.hl("DarkPurpleBold", M.P.darkpurple, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("Darkyellow", M.P.darkyellow, M.NONE)
  M.hl("DarkyellowBold", M.P.darkyellow, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("Brown", M.P.brown, M.NONE)
  M.hl("BrownBold", M.P.brown, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("Teal", M.P.teal, M.NONE)
  M.hl("TealBold", M.P.teal, M.NONE, conf.attrib.bold)

  M.hl("RedItalic", M.P.red, M.NONE, conf.attrib.italic)
  M.hl("OrangeItalic", M.P.orange, M.NONE, conf.attrib.italic)
  M.hl("YellowItalic", M.P.yellow, M.NONE, conf.attrib.italic)
  M.hl("GreenItalic", M.P.green, M.NONE, conf.attrib.italic)
  M.hl("BlueItalic", M.P.blue, M.NONE, conf.attrib.italic)
  M.hl("PurpleItalic", M.P.lpurple, M.NONE, conf.attrib.italic)
  M.hl_with_defaults("RedSign", M.P.red, M.P.darkbg)
  M.hl_with_defaults("OrangeSign", M.P.orange, M.P.darkbg)
  M.hl_with_defaults("YellowSign", M.P.yellow, M.P.darkbg)
  M.hl_with_defaults("GreenSign", M.P.green, M.P.darkbg)
  M.hl_with_defaults("BlueSign", M.P.blue, M.P.darkbg)
  M.hl_with_defaults("PurpleSign", M.P.lpurple, M.P.darkbg)
  M.hl("ErrorText", M.P.red, M.NONE, { bold = true })
  M.hl("WarningText", M.P.yellow, M.NONE, { bold = true })
  M.hl("InfoText", M.P.blue, M.NONE, { })
  M.hl("HintText", M.P.green, M.NONE, { })
  M.link("VirtualTextWarning", "WarningText")
  M.link("VirtualTextError", "ErrorText")
  M.link("VirtualTextInfo", "InfoText")
  M.link("VirtualTextHint", "HintText")
  M.hl_with_defaults("ErrorFloat", M.P.red, M.NONE)
  M.hl_with_defaults("WarningFloat", M.P.yellow, M.NONE)
  M.hl_with_defaults("InfoFloat", M.P.blue, M.NONE)
  M.hl_with_defaults("HintFloat", M.P.green, M.NONE)

  M.hl("Strong", M.NONE, M.NONE, conf.attrib.bold)
  M.hl("Emphasis", M.NONE, M.NONE, conf.attrib.italic)
  M.hl("URI", M.P.altblue, M.NONE, conf.attrib.uri)

  -- LSP and diagnostics stuff
  M.link("DiagnosticFloatingError", "ErrorFloat")
  M.link("DiagnosticFloatingWarn", "WarningFloat")
  M.link("DiagnosticFloatingInfo", "InfoFloat")
  M.link("DiagnosticFloatingHint", "HintFloat")
  M.link("DiagnosticError", "ErrorText")
  M.link("DiagnosticWarn", "WarningText")
  M.link("DiagnosticInfo", "InfoText")
  M.link("DiagnosticHint", "HintText")
  M.link("DiagnosticVirtualTextError", "VirtualTextError")
  M.link("DiagnosticVirtualTextWarn", "VirtualTextWarning")
  M.link("DiagnosticVirtualTextInfo", "VirtualTextInfo")
  M.link("DiagnosticVirtualTextHint", "VirtualTextHint")
  M.link("DiagnosticUnderlineError", "ErrorText")
  M.link("DiagnosticUnderlineWarn", "WarningText")
  M.link("DiagnosticUnderlineInfo", "InfoText")
  M.link("DiagnosticUnderlineHint", "HintText")
  M.link("DiagnosticSignOk", "GreenSign")
  M.link("DiagnosticSignError", "RedSign")
  M.link("DiagnosticSignWarn", "YellowSign")
  M.link("DiagnosticSignInfo", "BlueSign")
  M.link("DiagnosticSignHint", "GreenSign")
  M.link("LspDiagnosticsFloatingError", "DiagnosticFloatingError")
  M.link("LspDiagnosticsFloatingWarning", "DiagnosticFloatingWarn")
  M.link("LspDiagnosticsFloatingInformation", "DiagnosticFloatingInfo")
  M.link("LspDiagnosticsFloatingHint", "DiagnosticFloatingHint")
  M.link("LspDiagnosticsDefaultError", "DiagnosticError")
  M.link("LspDiagnosticsDefaultWarning", "DiagnosticWarn")
  M.link("LspDiagnosticsDefaultInformation", "DiagnosticInfo")
  M.link("LspDiagnosticsDefaultHint", "DiagnosticHint")
  M.link("LspDiagnosticsVirtualTextError", "DiagnosticVirtualTextError")
  M.link("LspDiagnosticsVirtualTextWarning", "DiagnosticVirtualTextWarn")
  M.link("LspDiagnosticsVirtualTextInformation", "DiagnosticVirtualTextInfo")
  M.link("LspDiagnosticsVirtualTextHint", "DiagnosticVirtualTextHint")
  M.link("LspDiagnosticsUnderlineError", "DiagnosticUnderlineError")
  M.link("LspDiagnosticsUnderlineWarning", "DiagnosticUnderlineWarn")
  M.link("LspDiagnosticsUnderlineInformation", "DiagnosticUnderlineInfo")
  M.link("LspDiagnosticsUnderlineHint", "DiagnosticUnderlineHint")
  M.link("LspDiagnosticsSignError", "DiagnosticSignError")
  M.link("LspDiagnosticsSignWarning", "DiagnosticSignWarn")
  M.link("LspDiagnosticsSignInformation", "DiagnosticSignInfo")
  M.link("LspDiagnosticsSignHint", "DiagnosticSignHint")
  M.link("LspReferenceText", "CurrentWord")
  M.link("LspReferenceRead", "CurrentWord")
  M.link("LspReferenceWrite", "CurrentWord")
  M.link("LspCodeLens", conf.theme_strings == "yellow" and "Green" or "Yellow")
  M.link("LspCodeLensSeparator", "VirtualTextHint")
  M.link("LspSignatureActiveParameter", "Yellow")
  M.link("TermCursor", "Cursor")
  M.link("healthError", "Red")
  M.link("healthSuccess", "Green")
  M.link("healthWarning", "Yellow")

  -- Tree-sitter highlight classes
  M.link("@annotation", "Annotation")
  M.link("@attribute", "Attribute")
  M.link("@boolean", "Boolean")
  M.link("@character", "Yellow")
  M.link("@comment", "Comment")
  M.link("@conditional", "KWConditional")
  M.link("@constant", "Constant")
  M.link("@constant.builtin", "Builtin")
  M.link("@constant.macro", "Macro")
  M.hl("@constructor", M.P.styled.constructor, M.NONE, {} )
  M.link("@field", "Member")
  M.link("@float", "Number")
  M.link("@function", "Function")
  M.link("@function.builtin", "Builtin")
  M.link("@function.macro", "TealBold")
  M.link("@include", "Include")
  M.link("@module", "Include")
  M.link("@keyword", "Keyword")
  M.link("@keyword.function", "KWSpecial")
  M.link("@keyword.operator", "Operator")
  M.link("@keyword.conditional", "KWConditional")
  M.link("@keyword.conditional.ternary", "Operator")
  M.link("@keyword.repeat", "KWRepeat")
  M.link("@keyword.exception", "KWException")
  M.link("@keyword.return", "KWReturn")
  M.link("@keyword.storage", "StorageClass")
  M.link("@keyword.import", "@module")
  M.link("@keyword.directive", "Macro")
  M.link("@keyword.modifier", "StorageClass")
  M.link("@label", "Red")
  M.link("@method", "Method")
  M.link("@namespace", "@module")
  M.link("@none", "Fg")
  M.link("@number", "Number")
  M.link("@operator", "Operator")
  M.link("@parameter", "Parameter")
  M.link("@parameter.reference", "Fg")
  M.link("@property", "Member")
  M.link("@punctuation.bracket", "Braces")
  M.link("@punctuation.delimiter", "PunctDelim")
  M.link("@punctuation.special", "PunctSpecial")
  M.link("@repeat", "KWRepeat")
  M.link("@storageclass", "StorageClass")
  M.link("@string", "String")
  M.link("@string.escape", "Green")
  M.link("@string.regex", "String")
  M.link("@symbol", "Fg")
  M.link("@tag", "Keyword")
  M.link("@tag.delimiter", "Braces")
  M.link("@text", "Fg")
  M.link("@strike", "Grey")
  M.link("@math", "Yellow")
  M.link("@type", "Type")
  M.link("@type.builtin", "Builtin")
  M.link("@type.definition", "TypeDefintion")
  M.link("@type.qualifier", "StorageClass")
  M.link("@uri", "URI")
  M.link("@text.uri", "URI")
  M.link("@variable", conf.desaturate == true and "FgDim" or "Fg")
  M.link("@variable.builtin", "Builtin")
  M.link("@variable.parameter", "@parameter")
  M.link("@text.emphasis.latex", "Emphasis")
  M.link("@variable.member", "Member")
  M.link("@function.method", "Method")

  -- semantic lsp types
  M.link("@lsp.type.namespace_name", "Type")
  M.link("@lsp.type.namespace", "@namespace")
  M.link("@lsp.type.parameter", "@parameter")
  M.link("@lsp.type.variable", "@variable")
  M.link("@lsp.type.selfKeyword", "Builtin")
  M.link("@lsp.type.bracket", "Braces")
  M.link("@lsp.type.method", "Method")
  M.link("@lsp.type.function", "Function")
  M.link("@lsp.type.class", "Class")
  M.link("@lsp.type.class_name", "Class")
  M.link("@lsp.type.structure", "Structure")
  M.link("@lsp.type.interface", "Interface")
  M.link("@lsp.type.qualifier", "@type.qualifier")
  M.link("@lsp.type.field", "Member")
  M.link("@lsp.type.property", "Member")
  M.link("@lsp.type.fieldName", "Member")
  M.link("@lsp.type.property_name", "Member")
  M.link("@lsp.type.field_name", "Member")
  M.link("@lsp.type.operator", "Operator")
  M.link("@lsp.type.builtin", "Builtin")
  M.link("@lsp.type.enum_name", "Structure")
  M.link("@lsp.type.enum_member_name", "Constant")
  M.link("@lsp.type.delegateName", "Function")
  M.link("@lsp.type.macro", "Macro")
  M.link("@lsp.type.constructor", "@constructor")
  M.link("@lsp.typemod.method.static", "StaticMethod")
  M.link("@lsp.typemod.method_name.static_symbol", "StaticMethod")
  M.link("@lsp.typemod.property.static", "StaticMember")
  M.link("@lsp.typemod.function.defaultLibrary", "DefaultLib")
  M.link("@lsp.typemod.function.global", "StaticMethod")
  M.link("@lsp.typemod.function.static", "StaticMethod")
  M.link("@lsp.typemod.class.constructorOrDestructor", "@constructor")
  M.link("@lsp.mod.defaultLibrary", "DefaultLib")
  M.link("@lsp.mod.constructorOrDestructor", "@constructor")

  M.link("BookmarkSign", "BlueSign")
  M.link("BookmarkAnnotationSign", "GreenSign")
  M.link("BookmarkLine", "DiffChange")
  M.link("BookmarkAnnotationLine", "DiffAdd")

  -- lukas-reineke/indent-blankline.nvim
  M.hl("IndentBlanklineContextChar", M.P.styled.operator, M.NONE, { bold = true })
  M.set_hl(0, "IndentBlanklineChar", { fg = conf.indentguide_colors[conf.scheme], nocombine = true })
  M.link("IndentBlanklineSpaceChar", "IndentBlanklineChar")
  M.link("IndentBlanklineSpaceCharBlankline", "IndentBlanklineChar")
  -- rainbow colors
  M.set_hl(0, "IndentBlanklineIndent1", { fg = rainbowpalette[conf.rainbow_contrast][1], nocombine = true })
  M.set_hl(0, "IndentBlanklineIndent2", { fg = rainbowpalette[conf.rainbow_contrast][2], nocombine = true })
  M.set_hl(0, "IndentBlanklineIndent3", { fg = rainbowpalette[conf.rainbow_contrast][4], nocombine = true })
  M.set_hl(0, "IndentBlanklineIndent4", { fg = rainbowpalette[conf.rainbow_contrast][5], nocombine = true })
  M.set_hl(0, "IndentBlanklineIndent5", { fg = rainbowpalette[conf.rainbow_contrast][6], nocombine = true })
  M.set_hl(0, "IndentBlanklineIndent6", { fg = rainbowpalette[conf.rainbow_contrast][3], nocombine = true })

  M.link("diffAdded", "Green")
  M.link("diffRemoved", "Red")
  M.link("diffChanged", "Blue")
  M.link("diffOldFile", "Yellow")
  M.link("diffNewFile", "Orange")
  M.link("diffFile", "DarkPurple")
  M.link("diffLine", "Grey")
  M.link("diffIndexLine", "DarkPurple")

  -- allow neotree and other addon panels have different backgrounds
  M.hl_with_defaults("TreeNormalNC", M.P.fg_dim, M.P.treebg)
  M.hl_with_defaults("TreeNormal", M.P.fg, M.P.treebg)
  M.hl("NeoTreeFileNameOpened", M.P.blue, M.P.treebg, conf.attrib.italic)
  M.hl_with_defaults("SymbolsOutlineConnector", M.P.grey_dim, M.NONE)
  M.hl_with_defaults("TreeCursorLine", M.NONE, M.P.c3)
  M.hl_with_defaults("NotifierTitle", M.P.yellow, M.NONE)
  M.link("NotifierContent", "TreeNormalNC")

  -- Treesitter stuff
  M.hl_with_defaults("TreesitterContext", M.NONE, M.P.bg)
  --M.hl("TreesitterContextBottom", M.NONE, M.localtheme.bg, { underline=true, sp=M.localtheme.lpurple[1] })
  M.link("TreesitterContextSeparator", "Comment")
  M.link("OutlineGuides", "SymbolsOutlineConnector")
  M.link("OutlineFoldMarker", "SymbolsOutlineConnector")
  M.link("NeoTreeCursorLine", "TreeCursorLine")

  -- WinBar
  M.hl_with_defaults("WinBarFilename", M.P.fg, M.P.accent)                                   -- Filename (right hand)
  M.hl("WinBarContext", M.P.accent, M.NONE, { underline = true, sp = M.P.accent[1] }) -- LSP context (left hand)
  -- WinBarInvis is for the central padding item. It should be transparent and invisible (fg = bg)
  -- This is a somewhat hack-ish way to make the lualine-controlled winbar transparent.
  M.hl("WinBarInvis", M.P.bg, M.P.bg, { underline = true, sp = M.P.accent[1] })
  M.link("WinBarNC", "StatusLineNC")
  M.link("WinBar", "WinBarContext")

  -- Lazy plugin manager
  M.link("LazyNoCond", "RedBold")
  M.link("VirtColumn", "IndentBlankLineChar")
  M.set_hl(0, "@ibl.scope.char.1", { bg = "none" })
end

-- this activates the theme.
-- it always calls configure(), no need to call this explicitely
function M.set()
  if conf.disabled == true then
    return
  end
  configure()
  for _, v in ipairs(conf.plugins.customize) do
    require("darkmatter.plugins." .. v)
  end
  set_all()
  for _, v in ipairs(conf.plugins.hl) do
    require("darkmatter.plugins." .. v).set()
  end
  if conf.sync_kittybg == true and conf.kittysocket ~= nil and conf.kittenexec ~= nil then
    if vim.fn.filereadable(conf.kittysocket) == 1 and vim.fn.executable(conf.kittenexec) == 1 then
      vim.fn.jobstart(
        conf.kittenexec
        .. " @ --to unix:"
        .. conf.kittysocket
        .. " set-colors background="
        .. M.T[conf.variant].kittybg
      )
    end
    if conf.sync_alacrittybg then
      vim.fn.jobstart("alacritty msg config \"colors.primary.background='" .. M.T[conf.variant].kittybg .. "'\"")
    end
  end
  for _, v in ipairs(conf.plugins.post) do
    require("darkmatter.plugins." .. v)
  end
  set_signs_trans()
end

function M.disable()
  conf.disabled = true
  vim.cmd("hi! link TreeNormalNC TreeNormal")
end

--- call the configured (if any) callback function to indicate what
--- has changed in the theme's configuration
--- @param what string: what was changed. can be "variant", "strings"
--- "desaturate" or "trans"
local function default_conf_callback(what)
  vim.notify("Darkmatter: default configuration callback in use.")
end

local supported_variants = { "warm", "cold", "deepblack", "pitchblack" }
--- setup the theme
--- @param opt table - the options to set. will be merged with local
--- conf table.
function M.setup(opt)
  opt = (opt ~= nil and type(opt) == "table") and opt or {}
  conf = vim.tbl_deep_extend("force", conf, opt)

  if opt.attrib ~= nil then
    M.attributes_ovr = opt.attrib
  else
    M.attributes_ovr = {}
  end

  -- both themes and palette modules must be present for a scheme to work
  local status, _ = pcall(require, "darkmatter.schemes." .. conf.scheme)
  if status == false then
    vim.notify("The color scheme " .. conf.scheme .. " does not exist. Setting default")
    conf.scheme = "dark"
  end

  if vim.tbl_contains(supported_variants, conf.variant) == false then
    conf.variant = "cold"
  end
  if conf.callback == nil then
    conf.callback = default_conf_callback
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
  return nil
end

--- set the background transparent or solid
--- this changes the relevant highlight groups to use a transparent background.
--- Needs terminal with transparency support (kitty, alacritty etc.)
function M.set_bg()
  if conf.is_trans == true then
    -- remove background colors from all relevant areas
    vim.api.nvim_set_hl(0, "Normal", { bg = "none", fg = "fg" })
    vim.api.nvim_set_hl(0, "TreeNormal", { bg = "none" })
    vim.api.nvim_set_hl(0, "TreeNormalNC", { bg = "none" })
    vim.cmd("hi VertSplit guibg=none")
    vim.cmd("hi LineNr guibg=none")
    vim.cmd("hi FoldColumn guibg=none")
    vim.cmd("hi SignColumn guibg=none")
    set_signs_trans()
  else
    local variant = conf.variant
    vim.api.nvim_set_hl(0, "Normal", { bg = M.T[variant].bg, fg = "fg" })
    vim.api.nvim_set_hl(0, "TreeNormal", { bg = M.T[variant].treebg, fg = "fg" })
    vim.api.nvim_set_hl(0, "TreeNormalNC", { bg = M.T[variant].treebg, fg = "fg" })
    vim.cmd("hi VertSplit guibg=" .. M.T[variant].treebg)
    vim.cmd("hi LineNr guibg=" .. M.T[variant].gutterbg)
    vim.cmd("hi FoldColumn guibg=" .. M.T[variant].gutterbg)
    vim.cmd("hi SignColumn guibg=" .. M.T[variant].gutterbg)
    --for _, v in ipairs(signgroups) do
    --  vim.cmd("hi " .. v .. " guibg=" .. M.theme[variant].gutterbg)
    --end
  end
end

function M.reconfigure_and_set(opts)
  opts = opts or {}

  local new_variant = opts.variant or conf.variant
  local new_colorpalette = opts.colorpalette or conf.colorpalette

  if new_variant ~= conf.variant or new_colorpalette ~= conf.colorpalette then
    conf.variant = new_variant
    conf.colorpalette = new_colorpalette
    M.set()
  end
end

return M
