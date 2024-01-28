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
--it features multiple background modes (cold, warm and deepdark) and three levels
--of color saturation: bright vivid and two desaturated modes
--
--TODO: * cleanup, organize the highlight groups better
--      * maybe (just maybe) a bright background variant

local M = {}

-- the "no color"
M.NONE = { "NONE", "NONE" }

local rainbowpalette = {
  dark = {
    low = {
     "#401C15",
     "#15401B",
     "#583329",
     "#163642",
     "#112F6F",
     "#56186D"
   },
   high = {
     "#701C15",
     "#15701B",
     "#783329",
     "#2646a2",
     "#707010",
     "#86188D"
   }
  },
  light = {
    low = {
     "#ddbbbb",
     "#bbddbb",
     "#ddddbb",
     "#bbdddd",
     "#bbbbdd",
     "#ddbbdd"
    },
    high = {
     "#ddbbbb",
     "#bbddbb",
     "#ddddbb",
     "#bbdddd",
     "#bbbbdd",
     "#ddbbdd"
    }
  }
}

M.keys_set = false
-- the color palette. Dynamically created in the configure() function
M.P = nil
-- the theme. Contains the variants and basic colors for backgrounds etc.
M.T = nil
M.attr_override = {}

-- the theme configuration. This can be changed by calling setup({...})
-- after changing the configuration configure() must be called before the theme
-- can be activated with set()
local conf = {
  disabled = false,
  -- the scheme name. Configuration is loaded from themes/conf.scheme.lua
  scheme = "dark",
  -- color variant. as of now, 3 types are supported:
  -- a) "warm" - the default, a medium-dark grey background with a slightly red-ish tint.
  -- b) "cold" - about the same, but with a blue-ish flavor
  -- c) "deepblack" - very dark, almost black background. neutral grey tone.
  variant = "warm",
  -- color brightness. Set to false to get very vivid and strong colors.
  desaturate = true,
  dlevel = 1, -- desaturation level (1 = mild, 2 = strong, pastel-like")
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
  style = {
    keyword = "blue",
    kwspec = "deepred",
    conditional = "blue",
    kwfunc = "deepred",
    member = "orange",
    method = "brightteal",
    func = "teal",
    operator = "brown",
    builtin = "darkyellow",
    braces = "altblue",
    delim = "red",
    number = "altgreen",
    class = "maroon",
    interface = "lila",
    storage = "palegreen",
    constant = "lpurple",
    module = "olive",
    namespace = "olive",
    type = "darkpurple",
    struct = "darkpurple",
    bool = "deepred",
    constructor = "altyellow"
  },
  usercolors = {},
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
  custom_colors = {
    c1 = '#ff0000',
    c2 = '#00ff00',
    c3 = '#303080',
    c4 = '#ff00ff'
  },
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

M.cokeline_colors = {}
local LuaLineColors = {}

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
  local theme = require("darkmatter.themes." .. conf.scheme)
  M.T = theme.theme()
  conf.attrib = vim.tbl_deep_extend("force", theme.attributes(), M.attr_override[conf.scheme])
  LuaLineColors = {
    white = "#ffffff",
    darkestgreen = M.T.accent_fg,
    brightgreen = M.T.accent_color,
    darkestcyan = "#005f5f",
    mediumcyan = "#87dfff",
    darkestblue = "#005f87",
    darkred = "#870000",
    brightred = M.T.alt_accent_color,
    brightorange = "#2f47df",
    gray1 = "#262626",
    gray2 = "#303030",
    gray4 = "#585858",
    gray5 = "#404050",
    gray7 = "#9e9e9e",
    gray10 = "#f0f0f0",
    statuslinebg = M.T[conf.variant].statuslinebg,
  }
  -- setup base palette
  M.P = theme.basepalette(conf.desaturate, conf.dlevel)

  M.P.special.fg = { M.T[conf.variant].fg , 1 }
  M.P.string = conf.theme_strings == "yellow" and M.P.yellow or M.P.green
  M.P.special.c1 = { conf.custom_colors.c1, 91 }
  M.P.special.c2 = { conf.custom_colors.c2, 92 }
  M.P.special.c3 = { conf.custom_colors.c3, 93 }
  M.P.special.c4 = { conf.custom_colors.c4, 94 }

  local seq = 245
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
    M.P.special[k] = M.P[v]
  end
  LuaLineColors.statuslinebg = M.T[conf.variant].statuslinebg

  -- TODO: allow cokeline colors per theme variant
  M.P.fg = { M.T[conf.variant].fg, 1 }
  M.P.darkbg = { M.T[conf.variant].gutterbg, 237 }
  M.P.bg = { M.T[conf.variant].bg, 0 }
  M.P.statuslinebg = { M.T[conf.variant].statuslinebg, 208 }
  M.P.accent = { M.T["accent_color"], 209 }
  M.P.accent_fg = { M.T["accent_fg"], 210 }
  M.P.tablinebg = M.P.statuslinebg
  M.P.fg_dim = { M.T[conf.variant].fg_dim, 2 }

  -- merge the variant-dependent colors
  M.P = vim.tbl_deep_extend("force", M.P, theme.variants(conf.variant))

  M.cokeline_colors = {
    bg = M.T[conf.variant].statuslinebg,
    inact_bg = M.P.statuslinebg[1],
    focus_bg = M.P.bg4[1],
    fg = LuaLineColors.gray4,
    focus_fg = M.T.accent_fg,
    focus_sp = M.P.altyellow[1],
    inact_sp = M.P.accent[1]
  }

  M.P.treebg = { M.T[conf.variant].treebg, 232 }
  M.P.selbg = { M.T["selbg"], 234 }
end

-- set all hl groups
local function set_all()
  -- basic highlights
  M.hl("Braces", M.P.special.braces, M.NONE, conf.attrib.brace)
  M.hl("Operator", M.P.special.operator, M.NONE, conf.attrib.operator)
  M.hl("PunctDelim", M.P.special.delim, M.NONE, conf.attrib.delim)
  M.hl("PunctSpecial", M.P.special.delim, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("ScrollView", M.P.teal, M.P.special.c3)
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
  M.hl("ErrorMsg", M.P.red, M.NONE, { bold = true, underline = true })
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
  M.hl_with_defaults("FloatTitle", M.P.accent_fg, M.P.bg_dim)
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
    M.hl_with_defaults("CursorLineNr", M.P.yellow, M.P.darkbg)
  end

  M.link("MsgArea", "StatusLine")
  M.link("WinSeparator", "VertSplit")

  M.hl_with_defaults("Visual", M.NONE, M.P.selbg)
  M.hl("VisualNOS", M.NONE, M.P.bg2, { underline = true })
  M.hl_with_defaults("Debug", M.P.yellow, M.NONE)
  M.hl_with_defaults("debugPC", M.P.bg0, M.P.green)
  M.hl_with_defaults("debugBreakpoint", M.P.bg0, M.P.red)
  M.hl_with_defaults("Substitute", M.P.bg0, M.P.yellow)

  M.hl("Type", M.P.special.type, M.NONE, conf.attrib.types)
  M.hl("Structure", M.P.special.struct, M.NONE, conf.attrib.struct)
  M.hl("Class", M.P.special.class, M.NONE, conf.attrib.class)
  M.hl("Interface", M.P.special.interface, M.NONE, conf.attrib.interface)
  M.hl("StorageClass", M.P.special.storage, M.NONE, conf.attrib.storage)
  M.hl_with_defaults("Identifier", M.P.orange, M.NONE)
  M.hl_with_defaults("Constant", M.P.special.constant, M.NONE)
  M.hl("Include", M.P.special.module, M.NONE, conf.attrib.module)
  M.hl("Boolean", M.P.special.bool, M.NONE, conf.attrib.bool)
  M.hl("Keyword", M.P.special.keyword, M.NONE, conf.attrib.keyword)
  M.hl("KeywordSpecial", M.P.special.kwspec, M.NONE, conf.attrib.keyword)
  -- use extra color for coditional keywords (if, else...)?
  M.hl("Conditional", M.P.special.conditional, M.NONE, conf.attrib.conditional)
  M.hl_with_defaults("Define", M.P.red, M.NONE)
  M.hl("Typedef", M.P.red, M.NONE, conf.attrib.types)
  M.hl("Exception", conf.theme_strings == "yellow" and M.P.green or M.P.yellow, M.NONE, conf.attrib.keyword)
  M.hl("Repeat", M.P.blue, M.NONE, conf.attrib.keyword)
  M.hl("Statement", M.P.blue, M.NONE, conf.attrib.keyword)
  M.hl_with_defaults("Macro", M.P.lpurple, M.NONE)
  M.hl_with_defaults("Error", M.P.red, M.NONE)
  M.hl_with_defaults("Label", M.P.lpurple, M.NONE)
  M.hl("Special", M.P.altblue, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("SpecialChar", M.P.lpurple, M.NONE)
  M.hl("String", M.P.string, M.NONE, conf.attrib.str)
  M.hl_with_defaults("Character", M.P.yellow, M.NONE)
  M.hl("Number", M.P.special.number, M.NONE, conf.attrib.number)
  M.hl_with_defaults("Float", M.P.lpurple, M.NONE)
  M.hl("Function", M.P.teal, M.NONE, conf.attrib.func)
  M.hl("Method", M.P.brightteal, M.NONE, conf.attrib.method)
  M.hl("StaticMethod", M.P.brightteal, M.NONE, conf.attrib.staticmethod)
  M.hl("Member", M.P.orange, M.NONE, conf.attrib.member)
  M.hl("StaticMember", M.P.orange, M.NONE, conf.attrib.staticmember)
  M.hl("Builtin", M.P.special.builtin, M.NONE, conf.attrib.bold)
  M.link("PreProc", "Include")
  M.hl("Title", M.P.red, M.NONE, conf.attrib.bold)
  M.hl_with_defaults("Tag", M.P.orange, M.NONE)
  M.hl_with_defaults("Comment", M.P.grey, M.NONE)
  M.hl_with_defaults("SpecialComment", M.P.grey, M.NONE)
  M.hl_with_defaults("Todo", M.P.blue, M.NONE)
  M.hl_with_defaults("Ignore", M.P.grey, M.NONE)
  M.hl("Underlined", M.NONE, M.NONE, { underline = true })
  M.hl("Parameter", M.P.fg_dim, M.NONE, conf.attrib.parameter)

  M.hl("Attribute", M.P.olive, M.NONE, conf.attrib.attribute)
  M.hl("Annotation", M.P.olive, M.NONE, conf.attrib.annotation)
  M.hl_with_defaults("Fg", M.P.fg, M.NONE)
  M.hl("FgBold", M.P.fg, M.NONE, conf.attrib.bold)
  M.hl("FgItalic", M.P.fg, M.NONE, conf.attrib.italic)
  M.hl_with_defaults("FgDim", M.P.fg_dim, M.NONE)
  M.hl("FgDimBold", M.P.fg_dim, M.NONE, conf.attrib.bold)
  M.hl("FgDimBoldItalic", M.P.fg_dim, M.NONE, conf.attrib.bolditalic)
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
  M.hl("ErrorText", M.NONE, M.NONE, { underline = true, sp = M.P.red[1] })
  M.hl("WarningText", M.NONE, M.NONE, { underline = true, sp = M.P.yellow[1] })
  M.hl("InfoText", M.P.blue, M.NONE, { italic = true })
  M.hl("HintText", M.P.green, M.NONE, { italic = true })
  M.link("VirtualTextWarning", "Grey")
  M.link("VirtualTextError", "Grey")
  M.link("VirtualTextInfo", "Grey")
  M.link("VirtualTextHint", "Grey")
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
  M.link("@conditional", "Conditional")
  M.link("@constant", "Constant")
  M.link("@constant.builtin", "Builtin")
  M.link("@constant.macro", "OrangeItalic")
  M.hl("@constructor", M.P.special.constructor, M.NONE, {} )
  M.link("@exception", "Exception")
  M.link("@field", "Member")
  M.link("@float", "Number")
  M.link("@function", "Teal")
  M.link("@function.builtin", "Builtin")
  M.link("@function.macro", "TealBold")
  M.link("@include", "Include")
  M.link("@module", "Include")
  M.link("@keyword", "Keyword")
  M.link("@keyword.function", "KeywordSpecial")
  M.link("@keyword.operator", "Operator")
  M.link("@keyword.conditional", "Conditional")
  M.link("@keyword.conditional.ternary", "Operator")
  M.link("@keyword.repeat", "Conditional")
  M.link("@keyword.storage", "StorageClass")
  M.link("@keyword.import", "Keyword")
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
  M.link("@repeat", "Conditional")
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
  M.link("@type.definition", "DeepRedBold")
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
  M.link("@lsp.type.method", "Method")
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
  M.link("@lsp.type.enum_name", "Structure")
  M.link("@lsp.type.enum_member_name", "Constant")
  M.link("@lsp.typemod.method.static", "StaticMethod")
  M.link("@lsp.typemod.method_name.static_symbol", "StaticMethod")
  M.link("@lsp.typemod.property.static", "StaticMember")
  M.link("@lsp.typemod.function.defaultLibrary", "Builtin")
  M.link("@lsp.typemod.function.global", "StaticMethod")
  M.link("@lsp.mod.defaultLibrary", "Function")

  M.link("BookmarkSign", "BlueSign")
  M.link("BookmarkAnnotationSign", "GreenSign")
  M.link("BookmarkLine", "DiffChange")
  M.link("BookmarkAnnotationLine", "DiffAdd")

  -- lukas-reineke/indent-blankline.nvim
  M.hl("IndentBlanklineContextChar", M.P.special.operator, M.NONE, { bold = true })
  M.set_hl(0, "IndentBlanklineChar", { fg = conf.indentguide_colors[conf.scheme], nocombine = true })
  M.link("IndentBlanklineSpaceChar", "IndentBlanklineChar")
  M.link("IndentBlanklineSpaceCharBlankline", "IndentBlanklineChar")
  -- rainbow colors
  M.set_hl(0, "IndentBlanklineIndent1", { fg = rainbowpalette[conf.scheme][conf.rainbow_contrast][1], nocombine = true })
  M.set_hl(0, "IndentBlanklineIndent2", { fg = rainbowpalette[conf.scheme][conf.rainbow_contrast][2], nocombine = true })
  M.set_hl(0, "IndentBlanklineIndent3", { fg = rainbowpalette[conf.scheme][conf.rainbow_contrast][4], nocombine = true })
  M.set_hl(0, "IndentBlanklineIndent4", { fg = rainbowpalette[conf.scheme][conf.rainbow_contrast][5], nocombine = true })
  M.set_hl(0, "IndentBlanklineIndent5", { fg = rainbowpalette[conf.scheme][conf.rainbow_contrast][6], nocombine = true })
  M.set_hl(0, "IndentBlanklineIndent6", { fg = rainbowpalette[conf.scheme][conf.rainbow_contrast][3], nocombine = true })

  M.link("diffAdded", "Green")
  M.link("diffRemoved", "Red")
  M.link("diffChanged", "Blue")
  M.link("diffOldFile", "Yellow")
  M.link("diffNewFile", "Orange")
  M.link("diffFile", "Purple")
  M.link("diffLine", "Grey")
  M.link("diffIndexLine", "Purple")

  -- allow neotree and other addon panels have different backgrounds
  M.hl_with_defaults("NeoTreeNormalNC", M.P.fg_dim, M.P.treebg)
  M.hl_with_defaults("NeoTreeNormal", M.P.fg, M.P.treebg)
  M.hl_with_defaults("NeoTreeFloatBorder", M.P.grey_dim, M.P.treebg)
  M.hl("NeoTreeFileNameOpened", M.P.blue, M.P.treebg, conf.attrib.italic)
  M.hl_with_defaults("SymbolsOutlineConnector", M.P.grey_dim, M.NONE)
  M.hl_with_defaults("TreeCursorLine", M.NONE, M.P.special.c3)
  M.hl_with_defaults("NotifierTitle", M.P.yellow, M.NONE)
  M.link("NotifierContent", "NeoTreeNormalNC")

  -- Treesitter stuff
  M.hl_with_defaults("TreesitterContext", M.NONE, M.P.bg)
  --M.hl("TreesitterContextBottom", M.NONE, M.localtheme.bg, { underline=true, sp=M.localtheme.lpurple[1] })
  M.link("TreesitterContextSeparator", "Type")
  M.link("OutlineGuides", "SymbolsOutlineConnector")
  M.link("OutlineFoldMarker", "SymbolsOutlineConnector")
  M.link("NeoTreeCursorLine", "TreeCursorLine")
  M.link("AerialGuide", "SymbolsOutlineConnector")

  -- WinBar
  M.hl_with_defaults("WinBarFilename", M.P.fg, M.P.accent)                                   -- Filename (right hand)
  M.hl("WinBarContext", M.P.accent, M.NONE, { underline = true, sp = M.P.accent[1] }) -- LSP context (left hand)
  -- WinBarInvis is for the central padding item. It should be transparent and invisible (fg = bg)
  -- This is a somewhat hack-ish way to make the lualine-controlle winbar transparent.
  M.hl("WinBarInvis", M.P.bg, M.P.bg, { underline = true, sp = M.P.accent[1] })
  M.link("WinBarNC", "StatusLineNC")
  M.link("WinBar", "WinBarContext")

  -- Lazy plugin manager
  M.link("LazyNoCond", "RedBold")
  M.link("VirtColumn", "IndentBlankLineChar")
  M.set_hl(0, "@ibl.scope.char.1", { bg = "none" })
end

-- this activates the theme.
function M.set()
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
  vim.cmd("hi! link NeoTreeNormalNC NeoTreeNormal")
end

local supported_variants = { "warm", "cold", "deepblack" }
--- setup the theme
--- @param opt table - the options to set. will be merged with local
--- conf table.
function M.setup(opt)
  opt = (opt ~= nil and type(opt) == "table") and opt or {}
  conf = vim.tbl_deep_extend("force", conf, opt)

  if opt.attrib ~= nil then
    M.attr_override = opt.attrib
  else
    M.attr_override = {}
  end

  -- both themes and palette modules must be present for a scheme to work
  local status, _ = pcall(require, "darkmatter.themes." .. conf.scheme)
  if status == false then
    vim.notify("The color scheme " .. conf.scheme .. " does not exist. Setting default")
    conf.scheme = "dark"
  end

  if vim.tbl_contains(supported_variants, conf.variant) == false then
    conf.variant = "cold"
  end

  -- bind keys, but do this only once
  if M.keys_set == false then
    M.keys_set = true
    vim.keymap.set({ "n" }, conf.keyprefix .. "tv", function()
      M.ui_select_variant()
    end, { silent = true, noremap = true, desc = "Select theme variant" })
    vim.keymap.set({ "n" }, conf.keyprefix .. "td", function()
      M.ui_select_colorweight()
    end, { silent = true, noremap = true, desc = "Select theme color weight" })
    vim.keymap.set({ "n" }, conf.keyprefix .. "ts", function()
      M.toggle_strings_color()
    end, { silent = true, noremap = true, desc = "Toggle theme strings color" })
    vim.keymap.set({ "n" }, conf.keyprefix .. "tt", function()
      M.toggle_transparency()
    end, { silent = true, noremap = true, desc = "Toggle theme transparency" })
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

--- internal global function to create the lualine color theme
--- @return table
function M.Lualine_internal_theme()
  return {
    normal = {
      a = {
        fg = LuaLineColors.darkestgreen,
        bg = LuaLineColors.brightgreen, --[[, gui = 'bold']]
      },
      b = { fg = LuaLineColors.gray10, bg = LuaLineColors.gray5 },
      c = "StatusLine",
      x = "StatusLine",
    },
    insert = {
      a = { fg = LuaLineColors.white, bg = LuaLineColors.brightred },
      b = { fg = LuaLineColors.gray10, bg = LuaLineColors.gray5 },
      c = "StatusLine",
      x = "StatusLine",
    },
    visual = {
      a = {
        fg = LuaLineColors.white,
        bg = LuaLineColors.brightorange, --[[, gui = 'bold']]
      },
    },
    replace = { a = { fg = LuaLineColors.white, bg = LuaLineColors.brightred } },
    inactive = {
      a = "StatusLine",
      b = "StatusLine",
      c = "StatusLine"
    }
  }
end

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
    set_signs_trans()
  else
    local variant = conf.variant
    vim.api.nvim_set_hl(0, "Normal", { bg = M.T[variant].bg, fg = "fg" })
    vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = M.T[variant].treebg, fg = "fg" })
    vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = M.T[variant].treebg, fg = "fg" })
    vim.cmd("hi VertSplit guibg=" .. M.T[variant].treebg)
    vim.cmd("hi LineNr guibg=" .. M.T[variant].gutterbg)
    vim.cmd("hi FoldColumn guibg=" .. M.T[variant].gutterbg)
    vim.cmd("hi SignColumn guibg=" .. M.T[variant].gutterbg)
    --for _, v in ipairs(signgroups) do
    --  vim.cmd("hi " .. v .. " guibg=" .. M.theme[variant].gutterbg)
    --end
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

  vim.ui.select({ "Warm (red tint)", "Cold (blue tint)", "Deep dark" }, {
    prompt = "Select a theme variant",
    border = "rounded",
    format_item = function(item)
      return utils.pad(item, 40, " ")
    end,
  }, function(choice)
    if choice == nil or #choice < 4 then
      return
    end
    local short = string.sub(choice, 1, 4)
    if short == "Warm" then
      conf.variant = "warm"
    elseif short == "Cold" then
      conf.variant = "cold"
    elseif short == "Deep" then
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
  vim.ui.select(
    { "Vivid (rich colors, high contrast)", "Medium (somewhat desaturated colors)", "Pastel (low intensity colors)" },
    {
      prompt = "Select a color intensity",
      border = "rounded",
      format_item = function(item)
        return utils.pad(item, 50, " ")
      end,
    },
    function(choice)
      if choice == nil or #choice < 6 then
        return
      end
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
    end
  )
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
