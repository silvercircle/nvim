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
M.keys_set = false
M.palette = {}
M.localtheme = {}

M.theme = {
  -- accent color is used for important highlights like the currently selected tab (buffer)
  -- and more.
  --accent_color = '#cbaf00',
  accent_color = "#305030",
  --alt_accent_color = '#bd2f4f',
  alt_accent_color = "#501010",
  accent_fg = "#cccc80",
  lualine = "internal", -- use 'internal' for the integrated theme or any valid lualine theme name
  selbg = "#104090",
  cold = {
    statuslinebg = "#262630",
    bg = "#141414",
    treebg = "#18181c",
    gutterbg = "#101013",
    kittybg = "#18181c",
    fg = "#a2a0ac",
  },
  warm = {
    statuslinebg = "#2a2626",
    bg = "#161414",
    treebg = "#1b1818",
    gutterbg = "#131010",
    kittybg = "#1b1818",
    fg = "#aaa0a5",
  },
  deepblack = {
    statuslinebg = "#222228",
    bg = "#0a0a0a",
    treebg = "#121212",
    gutterbg = "#0f0f0f",
    kittybg = "#111111",
    fg = "#a2a0ac",
  },
}

-- the theme configuration. This can be changed by calling setup({...})
-- after changing the configuration configure() must be called before the theme
-- can be activated with set()
local conf = {
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
  kittysocket = nil,
  kittenexec = nil,
  -- when true, background colors will be set to none, making text area and side panels
  -- transparent.
  is_trans = false,
  -- the prefix key for accessing the keymappings (see below in setup() ). These mappings
  -- can be used to change theme settings at runtime.
  keyprefix = "<leader>",
  -- a table describing attributes for certain highlight groups
  -- these are directly passed to nvim_set_hl(), so all supported attributes can be used
  -- here. For example, if you don't want to have any italics, then you can redefine the
  -- italic and bolditalic groups respectively. Same goes for semantic types like keywords
  -- or strings
  special = {
    operator = "red",
    braces = "blue",
    delim = "red"
  },
  attrib = {
    keywords   = { bold = true },
    conditional= { bold = true },
    types      = { bold = true },
    storage    = { bold = true },
    number     = { bold = true },
    func       = { bold = true },
    method     = { },
    member     = { },
    operator   = { bold = true },
    string     = {},
    bold       = { bold = true },
    italic     = { italic = true },
    bolditalic = { bold = true, italic = true },
    attribute  = { bold = true },
    annotation = { bold = true, italic = true }
  },
  -- the callback will be called by all functions that change the theme's configuration
  -- Callback must be of type("function") and receives one parameter:
  -- a string describing what has changed. Possible values are "variant", "strings",
  -- "desaturate" and "trans"
  -- The callback can use get_conf() to retrieve the current configuration and setup() to
  -- change it.
  callback = nil,
  custom_colors = {
    '#ff0000', '#00ff00', '#0000ff', '#ff00ff'
  },
  -- plugins. there are 3 kinds of plugins:
  -- customize: executed after configure() but before colors are set. Allows
  --            you to customize the color tables.
  -- hl:        list of additional highlighting. This can be used to support plugins
  --            that are not supported by default. This 
  -- post:      called after theme has been set
  plugins = {
    customize =  {},
    hl = { "markdown", "syntax", "common" },
    post = {}
  }
}

M.cokeline_colors = {}
local LuaLineColors = {
  white = "#ffffff",
  darkestgreen = M.theme.accent_fg,
  brightgreen = M.theme.accent_color,
  darkestcyan = "#005f5f",
  mediumcyan = "#87dfff",
  darkestblue = "#005f87",
  darkred = "#870000",
  brightred = M.theme.alt_accent_color,
  brightorange = "#2f47df",
  gray1 = "#262626",
  gray2 = "#303030",
  gray4 = "#585858",
  gray5 = "#404050",
  gray7 = "#9e9e9e",
  gray10 = "#f0f0f0",
  statuslinebg = M.theme[conf.variant].statuslinebg,
}

local diff = vim.api.nvim_win_get_option(0, "diff")

M.set_hl = vim.api.nvim_set_hl

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
-- other means to change the conf table.
-- set() automatically calls it before setting any highlight groups.
local function configure()
  if conf.desaturate == true then
    M.localtheme = {
      orange = (conf.dlevel == 1) and { "#ab6a6c", 215 } or { "#9b7a7c", 215 },
      blue = { "#5a6acf", 239 },
      purple = (conf.dlevel == 1) and { "#b070b0", 241 } or { "#a070a0", 241 },
      teal = (conf.dlevel == 1) and { "#609090", 238 } or { "#709090", 238 },
      brightteal = (conf.dlevel == 1) and { "#70a0c0", 238 } or { "#7090b0", 238 },
      darkpurple = (conf.dlevel == 1) and { "#705070", 240 } or { "#806a80", 240 },
      red = (conf.dlevel == 1) and { "#bb4d5c", 203 } or { "#ab5d6c", 203 },
      yellow = (conf.dlevel == 1) and { "#aaaa60", 231 } or { "#909870", 231 },
      green = (conf.dlevel == 1) and { "#60906f", 231 } or { "#658075", 231 },
      special = {
        red = { "#bb4d5c", 203 },
        yellow = { "#aaaa20", 231 },
        green = { "#309020", 232 },
        blue = { "#8a8adf", 239 },
        purple = { "#904090", 241 },
        storage = { "#855069", 241 },
        fg = { M.theme[conf.variant].fg , 1 },
      }
    }
  else
    M.localtheme = {
      orange = { "#c36630", 215 },
      blue = { "#4a4adf", 239 },
      purple = { "#c030c0", 241 },
      teal = { "#108080", 238 },
      brightteal = { "#30a0c0", 238 },
      darkpurple = { "#803090", 240 },
      red = { "#cc2d4c", 203 },
      yellow = { "#cccc60", 231 },
      green = { "#10801f", 232 },
      special = {
        red = { "#cc2d4c", 203 },
        yellow = { "#cccc60", 231 },
        green = { "#10801f", 232 },
        blue = { "#6060cf", 239 },
        purple = { "#c030c0", 241 },
        storage = { "#952060", 241 },
        fg = { M.theme[conf.variant].fg , 1 },
      }
    }
  end

  M.localtheme.string = conf.theme_strings == "yellow" and M.localtheme.yellow or M.localtheme.green
  M.localtheme.special.c1 = { conf.custom_colors[1], 91 }
  M.localtheme.special.c2 = { conf.custom_colors[2], 92 }
  M.localtheme.special.c3 = { conf.custom_colors[3], 93 }
  M.localtheme.special.c4 = { conf.custom_colors[4], 94 }

  LuaLineColors.statuslinebg = M.theme[conf.variant].statuslinebg

  -- TODO: allow cokeline colors per theme variant
  M.cokeline_colors = {
    --bg = LuaLineColors.statuslinebg,
    bg = M.theme[conf.variant].statuslinebg,
    focus_bg = M.theme.selbg,
    fg = LuaLineColors.gray7,
    focus_fg = M.theme.accent_fg,
  }

  if conf.variant == "cold" or conf.variant == "deepblack" then
    M.localtheme.fg = { M.theme[conf.variant].fg, 1 }
    M.localtheme.darkbg = { M.theme[conf.variant].gutterbg, 237 }
    M.localtheme.darkred = { "#601010", 249 }
    M.localtheme.bg = { M.theme[conf.variant].bg, 0 }
    M.localtheme.statuslinebg = { M.theme[conf.variant].statuslinebg, 208 }
    M.localtheme.pmenubg = { "#241a20", 156 }
    M.localtheme.accent = { M.theme["accent_color"], 209 }
    M.localtheme.accent_fg = { M.theme["accent_fg"], 210 }
    M.localtheme.tablinebg = { M.cokeline_colors["bg"], 214 }
    M.localtheme.black = { "#121215", 232 }
    M.localtheme.bg_dim = { "#222327", 232 }
    M.localtheme.bg0 = { "#2c2e34", 235 }
    M.localtheme.bg1 = { "#33353f", 236 }
    M.localtheme.bg2 = { "#363944", 236 }
    M.localtheme.bg3 = { "#3b3e48", 237 }
    M.localtheme.bg4 = { "#414550", 237 }
  else
    M.localtheme.fg = { M.theme[conf.variant].fg, 1 }
    M.localtheme.darkbg = { M.theme[conf.variant].gutterbg, 237 }
    M.localtheme.darkred = { "#601010", 249 }
    M.localtheme.bg = { M.theme[conf.variant].bg, 0 }
    M.localtheme.statuslinebg = { M.theme[conf.variant].statuslinebg, 208 }
    M.localtheme.pmenubg = { "#241a20", 156 }
    M.localtheme.accent = { M.theme["accent_color"], 209 }
    M.localtheme.accent_fg = { M.theme["accent_fg"], 210 }
    M.localtheme.tablinebg = { M.cokeline_colors["bg"], 214 }
    M.localtheme.black = { "#151212", 232 }
    M.localtheme.bg_dim = { "#242020", 232 }
    M.localtheme.bg0 = { "#302c2e", 235 }
    M.localtheme.bg1 = { "#322a2a", 236 }
    M.localtheme.bg2 = { "#403936", 236 }
    M.localtheme.bg3 = { "#483e3b", 237 }
    M.localtheme.bg4 = { "#504531", 237 }
  end
  M.palette = {
    grey = { "#707070", 2 },
    bg_red = { "#ff6077", 203 },
    diff_red = { "#45292d", 52 },
    bg_green = { "#a7df78", 107 },
    diff_green = { "#10320a", 22 },
    bg_blue = { "#75a3f2", 110 },
    diff_blue = { "#253147", 17 },
    diff_yellow = { "#4e432f", 54 },
    fg_dim = { "#959290", 251 },
    deepred = { "#8b2d3c", 203 },
    darkyellow = { "#a78624", 180 },
    olive = { "#708422", 181 },
    purple = { "#b39df3", 176 },
    grey_dim = { "#595f6f", 240 },
    neotreebg = { M.theme[conf.variant].treebg, 232 },
    selfg = { "#cccc20", 233 },
    selbg = { M.theme["selbg"], 234 },
    none = { "NONE", "NONE" },
  }
end

-- set all hl groups
local function set_all()
  -- basic highlights
  M.hl("Braces", M.localtheme.special[conf.special.braces], M.palette.none, conf.attrib.bold)
  M.hl("Operator", M.localtheme.special[conf.special.operator], M.palette.none, conf.attrib.operator)
  M.hl("PunctDelim", M.localtheme.special[conf.special.delim], M.palette.none, conf.attrib.bold)
  M.hl("PunctSpecial", M.localtheme.special[conf.special.delim], M.palette.none, conf.attrib.bold)
  M.hl_with_defaults("ScrollView", M.localtheme.teal, M.localtheme.blue)
  M.hl_with_defaults("Normal", M.localtheme.fg, M.localtheme.bg)
  M.hl_with_defaults("Accent", M.localtheme.black, M.localtheme.accent)
  M.hl_with_defaults("Terminal", M.localtheme.fg, M.palette.neotreebg)
  M.hl_with_defaults("EndOfBuffer", M.localtheme.bg4, M.palette.none)
  M.hl_with_defaults("Folded", M.localtheme.fg, M.palette.diff_blue)
  M.hl_with_defaults("ToolbarLine", M.localtheme.fg, M.palette.none)
  M.hl_with_defaults("FoldColumn", M.localtheme.bg4, M.localtheme.darkbg)
  M.hl_with_defaults("SignColumn", M.localtheme.fg, M.localtheme.darkbg)
  M.hl_with_defaults("IncSearch", M.localtheme.yellow, M.localtheme.darkred)
  M.hl_with_defaults("Search", M.localtheme.black, M.palette.darkyellow)
  M.hl_with_defaults("ColorColumn", M.palette.none, M.localtheme.bg1)
  M.hl_with_defaults("Conceal", M.palette.grey_dim, M.palette.none)
  M.hl_with_defaults("Cursor", M.localtheme.fg, M.localtheme.fg)
  M.hl_with_defaults("nCursor", M.localtheme.fg, M.localtheme.fg)
  M.hl_with_defaults("iCursor", M.localtheme.yellow, M.localtheme.yellow)
  M.hl_with_defaults("vCursor", M.localtheme.red, M.localtheme.red)

  M.link("CursorIM", "iCursor")

  M.hl("FocusedSymbol", M.localtheme.yellow, M.palette.none, conf.attrib.bold)

  if diff then
    M.hl("CursorLine", M.palette.none, M.palette.none, { underline = true })
    M.hl("CursorColumn", M.palette.none, M.palette.none, conf.attrib.bold)
  else
    M.hl_with_defaults("CursorLine", M.palette.none, M.localtheme.bg0)
    M.hl_with_defaults("CursorColumn", M.palette.none, M.localtheme.bg1)
  end

  M.hl_with_defaults("LineNr", M.palette.grey_dim, M.localtheme.darkbg)
  if diff then
    M.hl("CursorLineNr", M.localtheme.yellow, M.palette.none, { underline = true })
  else
    M.hl_with_defaults("CursorLineNr", M.localtheme.yellow, M.localtheme.darkbg)
  end

  M.hl_with_defaults("DiffAdd", M.palette.none, M.palette.diff_green)
  M.hl_with_defaults("DiffChange", M.palette.none, M.palette.diff_blue)
  M.hl_with_defaults("DiffDelete", M.palette.none, M.palette.diff_red)
  M.hl_with_defaults("DiffText", M.localtheme.bg0, M.localtheme.blue)
  M.hl("Directory", M.localtheme.blue, M.palette.none, conf.attrib.bold)
  M.hl("ErrorMsg", M.localtheme.red, M.palette.none, { bold = true, underline = true })
  M.hl("WarningMsg", M.localtheme.yellow, M.palette.none, conf.attrib.bold)
  M.hl("ModeMsg", M.localtheme.fg, M.palette.none, conf.attrib.bold)
  M.hl("MoreMsg", M.localtheme.blue, M.palette.none, conf.attrib.bold)
  M.hl_with_defaults("MatchParen", M.localtheme.yellow, M.localtheme.darkred)

  M.hl_with_defaults("NonText", M.localtheme.bg4, M.palette.none)
  M.hl_with_defaults("Whitespace", M.localtheme.green, M.palette.none)
  M.hl_with_defaults("SpecialKey", M.localtheme.green, M.palette.none)
  M.hl_with_defaults("Pmenu", M.localtheme.fg, M.localtheme.pmenubg)
  M.hl_with_defaults("PmenuSbar", M.palette.none, M.localtheme.bg2)
  M.link("PmenuSel", "Visual")
  M.link("WildMenu", "PmenuSel")

  M.hl_with_defaults("PmenuThumb", M.palette.none, M.palette.grey)
  M.hl_with_defaults("NormalFloat", M.localtheme.fg, M.localtheme.bg_dim)
  M.hl_with_defaults("FloatBorder", M.palette.grey_dim, M.localtheme.bg_dim)
  M.hl_with_defaults("Question", M.localtheme.yellow, M.palette.none)
  M.hl("SpellBad", M.palette.none, M.palette.none, { undercurl = true, sp = M.localtheme.red[1] })
  M.hl("SpellCap", M.palette.none, M.palette.none, { undercurl = true, sp = M.localtheme.yellow[1] })
  M.hl("SpellLocal", M.palette.none, M.palette.none, { undercurl = true, sp = M.localtheme.blue[1] })
  M.hl("SpellRare", M.palette.none, M.palette.none, { undercurl = true, sp = M.palette.purple[1] })
  M.hl_with_defaults("StatusLine", M.localtheme.fg, M.localtheme.statuslinebg)
  M.hl_with_defaults("StatusLineTerm", M.localtheme.fg, M.palette.none)
  M.hl_with_defaults("StatusLineNC", M.palette.grey, M.localtheme.statuslinebg)
  M.hl_with_defaults("StatusLineTermNC", M.palette.grey, M.palette.none)
  M.hl_with_defaults("TabLine", M.localtheme.fg, M.localtheme.statuslinebg)
  M.hl_with_defaults("TabLineFill", M.palette.grey, M.localtheme.tablinebg)
  M.hl_with_defaults("TabLineSel", M.localtheme.bg0, M.palette.bg_red)
  M.hl_with_defaults("VertSplit", M.localtheme.statuslinebg, M.palette.neotreebg)

  M.link("MsgArea", "StatusLine")
  M.link("WinSeparator", "VertSplit")

  M.hl_with_defaults("Visual", M.palette.selfg, M.palette.selbg)
  M.hl("VisualNOS", M.palette.none, M.localtheme.bg3, { underline = true })
  M.hl_with_defaults("QuickFixLine", M.localtheme.blue, M.palette.neotreebg)
  M.hl_with_defaults("Debug", M.localtheme.yellow, M.palette.none)
  M.hl_with_defaults("debugPC", M.localtheme.bg0, M.localtheme.green)
  M.hl_with_defaults("debugBreakpoint", M.localtheme.bg0, M.localtheme.red)
  M.hl_with_defaults("ToolbarButton", M.localtheme.bg0, M.palette.bg_blue)
  M.hl_with_defaults("Substitute", M.localtheme.bg0, M.localtheme.yellow)

  M.hl("Type", M.localtheme.darkpurple, M.palette.none, conf.attrib.types)
  M.hl("Structure", M.localtheme.darkpurple, M.palette.none, conf.attrib.types)
  M.hl("StorageClass", M.localtheme.special.storage, M.palette.none, conf.attrib.storage)
  M.hl_with_defaults("Identifier", M.localtheme.orange, M.palette.none)
  M.hl_with_defaults("Constant", M.palette.purple, M.palette.none)
  M.hl("PreProc", M.palette.darkyellow, M.palette.none, conf.attrib.bold)
  M.hl("PreCondit", M.palette.darkyellow, M.palette.none, conf.attrib.bold)
  M.link("Include", "OliveBold")
  M.link("Boolean", "DeepRedBold")
  M.hl("Keyword", M.localtheme.blue, M.palette.none, conf.attrib.keywords)
  M.hl("Conditional", M.palette.darkyellow, M.palette.none, conf.attrib.conditional)
  M.hl_with_defaults("Define", M.localtheme.red, M.palette.none)
  M.hl("Typedef", M.localtheme.red, M.palette.none, conf.attrib.types)
  M.hl(
    "Exception",
    conf.theme_strings == "yellow" and M.localtheme.green or M.localtheme.yellow,
    M.palette.none,
    conf.attrib.keywords
  )
  M.hl("Repeat", M.localtheme.blue, M.palette.none, conf.attrib.keywords)
  M.hl("Statement", M.localtheme.blue, M.palette.none, conf.attrib.keywords)
  M.hl_with_defaults("Macro", M.palette.purple, M.palette.none)
  M.hl_with_defaults("Error", M.localtheme.red, M.palette.none)
  M.hl_with_defaults("Label", M.palette.purple, M.palette.none)
  M.hl("Special", M.localtheme.darkpurple, M.palette.none, conf.attrib.bold)
  M.hl_with_defaults("SpecialChar", M.palette.purple, M.palette.none)
  M.hl("String", M.localtheme.string, M.palette.none, conf.attrib.string)
  M.hl_with_defaults("Character", M.localtheme.yellow, M.palette.none)
  M.hl("Number", M.localtheme.purple, M.palette.none, conf.attrib.number)
  M.hl_with_defaults("Float", M.palette.purple, M.palette.none)
  M.hl("Function", M.localtheme.teal, M.palette.none, conf.attrib.func)
  M.hl("Method", M.localtheme.brightteal, M.palette.none, conf.attrib.method)
  M.hl("Member", M.localtheme.orange, M.palette.none, conf.attrib.member)
  M.hl("Builtin", M.palette.bg_blue, M.palette.none, conf.attrib.bold)

  M.hl("Title", M.localtheme.red, M.palette.none, conf.attrib.bold)
  M.hl_with_defaults("Tag", M.localtheme.orange, M.palette.none)
  M.hl_with_defaults("Comment", M.palette.grey, M.palette.none)
  M.hl_with_defaults("SpecialComment", M.palette.grey, M.palette.none)
  M.hl_with_defaults("Todo", M.localtheme.blue, M.palette.none)
  M.hl_with_defaults("Ignore", M.palette.grey, M.palette.none)
  M.hl("Underlined", M.palette.none, M.palette.none, { underline = true })

  M.hl("Attribute", M.palette.olive, M.palette.none, conf.attrib.attribute)
  M.hl("Annotation", M.palette.olive, M.palette.none, conf.attrib.annotation)
  M.hl_with_defaults("Fg", M.localtheme.fg, M.palette.none)
  M.hl("FgBold", M.localtheme.fg, M.palette.none, conf.attrib.bold)
  M.hl("FgItalic", M.localtheme.fg, M.palette.none, conf.attrib.italic)
  M.hl("FgDimBold", M.palette.fg_dim, M.palette.none, conf.attrib.bold)
  M.hl("FgDimBoldItalic", M.palette.fg_dim, M.palette.none, conf.attrib.bolditalic)
  M.hl_with_defaults("Grey", M.palette.grey, M.palette.none)
  M.hl_with_defaults("Red", M.localtheme.red, M.palette.none)
  M.hl("RedBold", M.localtheme.red, M.palette.none, conf.attrib.bold)
  M.hl_with_defaults("DeepRed", M.palette.deepred, M.palette.none)
  M.hl("DeepRedBold", M.palette.deepred, M.palette.none, conf.attrib.bold)
  M.hl_with_defaults("Orange", M.localtheme.orange, M.palette.none)
  M.hl("OrangeBold", M.localtheme.orange, M.palette.none, conf.attrib.bold)
  M.hl_with_defaults("Yellow", M.localtheme.yellow, M.palette.none)
  M.hl("YellowBold", M.localtheme.yellow, M.palette.none, conf.attrib.bold)
  M.hl_with_defaults("Green", M.localtheme.green, M.palette.none)
  M.hl("GreenBold", M.localtheme.green, M.palette.none, conf.attrib.bold)
  M.hl_with_defaults("Blue", M.localtheme.blue, M.palette.none)
  M.hl("BlueBold", M.localtheme.blue, M.palette.none, conf.attrib.bold)
  M.hl_with_defaults("Olive", M.palette.olive, M.palette.none)
  M.hl("OliveBold", M.palette.olive, M.palette.none, conf.attrib.bold)
  M.hl_with_defaults("Purple", M.localtheme.purple, M.palette.none)
  M.hl("PurpleBold", M.localtheme.purple, M.palette.none, conf.attrib.bold)
  M.hl_with_defaults("DarkPurple", M.localtheme.darkpurple, M.palette.none)
  M.hl("DarkPurpleBold", M.localtheme.darkpurple, M.palette.none, conf.attrib.bold)
  M.hl_with_defaults("Darkyellow", M.palette.darkyellow, M.palette.none)
  M.hl("DarkyellowBold", M.palette.darkyellow, M.palette.none, conf.attrib.bold)
  M.hl_with_defaults("Teal", M.localtheme.teal, M.palette.none)
  M.hl("TealBold", M.localtheme.teal, M.palette.none, conf.attrib.bold)

  M.hl("RedItalic", M.localtheme.red, M.palette.none, conf.attrib.italic)
  M.hl("OrangeItalic", M.localtheme.orange, M.palette.none, conf.attrib.italic)
  M.hl("YellowItalic", M.localtheme.yellow, M.palette.none, conf.attrib.italic)
  M.hl("GreenItalic", M.localtheme.green, M.palette.none, conf.attrib.italic)
  M.hl("BlueItalic", M.localtheme.blue, M.palette.none, conf.attrib.italic)
  M.hl("PurpleItalic", M.palette.purple, M.palette.none, conf.attrib.italic)
  M.hl_with_defaults("RedSign", M.localtheme.red, M.localtheme.darkbg)
  M.hl_with_defaults("OrangeSign", M.localtheme.orange, M.localtheme.darkbg)
  M.hl_with_defaults("YellowSign", M.localtheme.yellow, M.localtheme.darkbg)
  M.hl_with_defaults("GreenSign", M.localtheme.green, M.localtheme.darkbg)
  M.hl_with_defaults("BlueSign", M.localtheme.blue, M.localtheme.darkbg)
  M.hl_with_defaults("PurpleSign", M.palette.purple, M.localtheme.darkbg)
  M.hl("ErrorText", M.palette.none, M.palette.none, { undercurl = true, sp = M.localtheme.red[1] })
  M.hl("WarningText", M.palette.none, M.palette.none, { undercurl = true, sp = M.localtheme.yellow[1] })
  M.hl("InfoText", M.palette.none, M.palette.none, { undercurl = true, sp = M.localtheme.blue[1] })
  M.hl("HintText", M.palette.none, M.palette.none, { undercurl = true, sp = M.localtheme.green[1] })
  M.link("VirtualTextWarning", "Grey")
  M.link("VirtualTextError", "Grey")
  M.link("VirtualTextInfo", "Grey")
  M.link("VirtualTextHint", "Grey")

  M.hl_with_defaults("ErrorFloat", M.localtheme.red, M.palette.none) -- was localtheme.bg2"
  M.hl_with_defaults("WarningFloat", M.localtheme.yellow, M.palette.none)
  M.hl_with_defaults("InfoFloat", M.localtheme.blue, M.palette.none)
  M.hl_with_defaults("HintFloat", M.localtheme.green, M.palette.none)

  M.hl("TSStrong", M.palette.none, M.palette.none, conf.attrib.bold)
  M.hl("TSEmphasis", M.palette.none, M.palette.none, conf.attrib.italic)
  M.hl("TSUnderline", M.palette.none, M.palette.none, { underline = true })
  M.hl("TSNote", M.localtheme.bg0, M.localtheme.blue, conf.attrib.bold)
  M.hl("TSWarning", M.localtheme.bg0, M.localtheme.yellow, conf.attrib.bold)
  M.hl("TSDanger", M.localtheme.bg0, M.localtheme.red, conf.attrib.bold)

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
  M.link("LspCodeLens", "VirtualTextInfo")
  M.link("LspCodeLensSeparator", "VirtualTextHint")
  M.link("LspSignatureActiveParameter", "Yellow")
  M.link("TermCursor", "Cursor")
  M.link("healthError", "Red")
  M.link("healthSuccess", "Green")
  M.link("healthWarning", "Yellow")

  -- Treesitter highlight classes
  M.link("TSAnnotation", "Annotation")
  M.link("TSAttribute", "Attribute")
  M.link("TSBoolean", "DeepRedBold")
  M.link("TSCharacter", "Yellow")
  M.link("TSComment", "Comment")
  M.link("TSConditional", "Conditional")
  M.link("TSConstBuiltin", "Builtin")
  M.link("TSConstMacro", "OrangeItalic")
  M.link("TSConstant", "Constant")
  M.link("TSConstructor", "Yellow")
  M.link("TSException", "Exception")
  M.link("TSField", "Member")
  M.link("TSFloat", "Purple")
  M.link("TSFuncBuiltin", "Builtin")
  M.link("TSFuncMacro", "TealBold")
  M.link("TSFunction", "Teal")
  M.link("TSInclude", "OliveBold")
  M.link("TSKeyword", "Keyword")
  M.link("TSKeywordFunction", "DeepRedBold")
  M.link("TSKeywordOperator", "Operator")
  M.link("TSLabel", "Red")
  M.link("TSMethod", "Method")
  M.link("TSNamespace", "DarkPurpleBold")
  M.link("TSNone", "Fg")
  M.link("TSNumber", "Number")
  M.link("TSOperator", "Operator")
  M.link("TSParameter", "FgDimBoldItalic")
  M.link("TSParameterReference", "Fg")
  M.link("TSProperty", "Orange")
  M.link("TSPunctBracket", "Braces")
  M.link("TSPunctDelimiter", "PunctDelim")
  M.link("TSPunctSpecial", "PunctSpecial")
  M.link("TSRepeat", "BlueBold")
  M.link("TSStorageClass", "StorageClass")
  M.link("TSString", "String")
  M.link("TSStringEscape", "Green")
  M.link("TSStringRegex", "String")
  M.link("TSSymbol", "Fg")
  M.link("TSTag", "BlueItalic")
  M.link("TSTagDelimiter", "RedBold")
  M.link("TSText", "Green")
  M.link("TSStrike", "Grey")
  M.link("TSMath", "Yellow")
  M.link("TSType", "Type")
  M.link("TSTypeBuiltin", "Builtin")
  M.link("TSTypeDefinition", "DeepRedBold")
  M.link("TSTypeQualifier", "StorageClass")
  M.link("TSURI", "markdownUrl")
  M.link("TSVariable", "Fg")
  M.link("TSVariableBuiltin", "Builtin")
  M.link("@annotation", "TSAnnotation")
  M.link("@attribute", "TSAttribute")
  M.link("@boolean", "TSBoolean")
  M.link("@character", "TSCharacter")
  M.link("@comment", "TSComment")
  M.link("@conditional", "TSConditional")
  M.link("@constant", "TSConstant")
  M.link("@constant.builtin", "TSConstBuiltin")
  M.link("@constant.macro", "TSConstMacro")
  M.link("@constructor", "TSConstructor")
  M.link("@exception", "TSException")
  M.link("@field", "TSField")
  M.link("@float", "TSFloat")
  M.link("@function", "TSFunction")
  M.link("@function.builtin", "TSFuncBuiltin")
  M.link("@function.macro", "TSFuncMacro")
  M.link("@include", "TSInclude")
  M.link("@keyword", "TSKeyword")
  M.link("@keyword.function", "TSKeywordFunction")
  M.link("@keyword.operator", "TSKeywordOperator")
  M.link("@label", "TSLabel")
  M.link("@method", "TSMethod")
  M.link("@namespace", "TSNamespace")
  M.link("@none", "TSNone")
  M.link("@number", "TSNumber")
  M.link("@operator", "TSOperator")
  M.link("@parameter", "TSParameter")
  M.link("@parameter.reference", "TSParameterReference")
  M.link("@property", "TSProperty")
  M.link("@punctuation.bracket", "TSPunctBracket")
  M.link("@punctuation.delimiter", "TSPunctDelimiter")
  M.link("@punctuation.special", "TSPunctSpecial")
  M.link("@repeat", "TSRepeat")
  M.link("@storageclass", "TSStorageClass")
  M.link("@string", "TSString")
  M.link("@string.escape", "TSStringEscape")
  M.link("@string.regex", "TSStringRegex")
  M.link("@symbol", "TSSymbol")
  M.link("@tag", "TSTag")
  M.link("@tag.delimiter", "TSTagDelimiter")
  M.link("@text", "TSText")
  M.link("@strike", "TSStrike")
  M.link("@math", "TSMath")
  M.link("@type", "TSType")
  M.link("@type.builtin", "TSTypeBuiltin")
  M.link("@type.definition", "TSTypeDefinition")
  M.link("@type.qualifier", "TSTypeQualifier")
  M.link("@uri", "TSURI")
  M.link("@variable", "TSVariable")
  M.link("@variable.builtin", "TSVariableBuiltin")
  M.link("@text.emphasis.latex", "TSEmphasis")

  M.link("@lsp.type.parameter", "FgDimBoldItalic")
  M.link("@lsp.type.variable", "Fg")
  M.link("@lsp.type.selfKeyword", "TSTypeBuiltin")
  M.link("@lsp.type.method", "Method")
  M.link("multiple_cursors_cursor", "Cursor")
  M.link("multiple_cursors_visual", "Visual")

  M.hl_with_defaults("VMCursor", M.localtheme.blue, M.palette.grey_dim)

  M.link("FloatermBorder", "Grey")
  M.link("BookmarkSign", "BlueSign")
  M.link("BookmarkAnnotationSign", "GreenSign")
  M.link("BookmarkLine", "DiffChange")
  M.link("BookmarkAnnotationLine", "DiffAdd")

  -- lukas-reineke/indent-blankline.nvim
  M.hl("IndentBlanklineContextChar", M.localtheme.darkpurple, M.palette.none, { nocombine = true })
  M.hl("IndentBlanklineChar", M.localtheme.bg1, M.palette.none, { nocombine = true })
  M.link("IndentBlanklineSpaceChar", "IndentBlanklineChar")
  M.link("IndentBlanklineSpaceCharBlankline", "IndentBlanklineChar")
  -- rainbow colors
  M.set_hl(0, "IndentBlanklineIndent1", { fg = "#401C15", nocombine = true })
  M.set_hl(0, "IndentBlanklineIndent2", { fg = "#15401B", nocombine = true })
  M.set_hl(0, "IndentBlanklineIndent3", { fg = "#583329", nocombine = true })
  M.set_hl(0, "IndentBlanklineIndent4", { fg = "#163642", nocombine = true })
  M.set_hl(0, "IndentBlanklineIndent5", { fg = "#112F6F", nocombine = true })
  M.set_hl(0, "IndentBlanklineIndent6", { fg = "#56186D", nocombine = true })

  M.hl_with_defaults("InclineNormalNC", M.palette.grey, M.localtheme.bg2)

  M.link("diffAdded", "Green")
  M.link("diffRemoved", "Red")
  M.link("diffChanged", "Blue")
  M.link("diffOldFile", "Yellow")
  M.link("diffNewFile", "Orange")
  M.link("diffFile", "Purple")
  M.link("diffLine", "Grey")
  M.link("diffIndexLine", "Purple")

  -- Glance plugin: https://github.com/DNLHC/glance.nvim
  M.hl_with_defaults("GlancePreviewNormal", M.localtheme.fg, M.localtheme.black)
  M.hl_with_defaults("GlancePreviewMatch", M.localtheme.yellow, M.palette.none)
  M.hl_with_defaults("GlanceListMatch", M.localtheme.yellow, M.palette.none)
  M.link("GlanceListCursorLine", "Visual")

  -- allow neotree and other addon panels have different backgrounds
  M.hl_with_defaults("NeoTreeNormalNC", M.localtheme.fg, M.palette.neotreebg)
  M.hl_with_defaults("NeoTreeNormal", M.localtheme.fg, M.palette.neotreebg)
  M.hl_with_defaults("NeoTreeFloatBorder", M.palette.grey_dim, M.palette.neotreebg)
  M.hl("NeoTreeFileNameOpened", M.localtheme.blue, M.palette.neotreebg, conf.attrib.italic)
  M.hl_with_defaults("SymbolsOutlineConnector", M.localtheme.bg4, M.palette.none)
  M.hl_with_defaults("NotifierTitle", M.localtheme.yellow, M.palette.none)
  M.link("NotifierContent", "NeoTreeNormalNC")

  -- Treesitter stuff
  M.hl_with_defaults("TreesitterContext", M.palette.none, M.localtheme.bg)
  M.link("TreesitterContextSeparator", "Type")
  M.link("NvimTreeIndentMarker", "SymbolsOutlineConnector")
  M.link("OutlineGuides", "SymbolsOutlineConnector")
  M.link("NeoTreeCursorLine", "Visual")
  M.link("AerialGuide", "SymbolsOutlineConnector")

  -- WinBar
  M.hl_with_defaults("WinBarFilename", M.localtheme.fg, M.localtheme.accent)                                   -- Filename (right hand)
  M.hl("WinBarContext", M.palette.darkyellow, M.palette.none, { underline = true, sp = M.localtheme.accent[1] }) -- LSP context (left hand)
  -- WinBarInvis is for the central padding item. It should be transparent and invisible (fg = bg)
  -- This is a somewhat hack-ish way to make the lualine-controlle winbar transparent.
  M.hl("WinBarInvis", M.localtheme.bg, M.localtheme.bg, { underline = true, sp = M.localtheme.accent[1] })
  M.link("WinBarNC", "StatusLineNC")
  M.link("WinBar", "WinBarContext")

  -- Lazy plugin manager
  M.link("LazyNoCond", "RedBold")
  M.link("VirtColumn", "IndentBlankLineChar")
  M.link("SatelliteCursor", "WarningMsg")
  M.link("SatelliteSearch", "PurpleBold")
  M.link("SatelliteSearchCurrent", "PurpleBold")
  M.set_hl(0, "@ibl.scope.char.1", { bg = "none" })
end

-- this activates the theme.
function M.set()
  configure()
  for _, v in ipairs(conf.plugins.customize) do
    require("colors.darkmatter.plugins." .. v)
  end
  set_all()
  for _, v in ipairs(conf.plugins.hl) do
    require("colors.darkmatter.plugins." .. v)
  end
  if conf.sync_kittybg == true and conf.kittysocket ~= nil and conf.kittenexec ~= nil then
    if vim.fn.filereadable(conf.kittysocket) == 1 and vim.fn.executable(conf.kittenexec) == 1 then
      vim.fn.jobstart(
        conf.kittenexec
        .. " @ --to unix:"
        .. conf.kittysocket
        .. " set-colors background="
        .. M.theme[conf.variant].kittybg
      )
    else
      vim.notify("Either the kitty socket or the kitten executable is not available", vim.log.levels.WARN)
    end
  end
  for _, v in ipairs(conf.plugins.post) do
    require("colors.darkmatter.plugins." .. v)
  end
end

--- setup the theme
--- @param opt table - the options to set. will be merged with local
--- conf table.
function M.setup(opt)
  opt = (opt ~= nil and type(opt) == "table") and opt or {}
  conf = vim.tbl_deep_extend("force", conf, opt)
  -- TODO: validate and sanitize conf data
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
      a = { fg = LuaLineColors.white, bg = LuaLineColors.brightred, gui = "bold" },
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
    replace = { a = { fg = LuaLineColors.white, bg = LuaLineColors.brightred, gui = "bold" } },
    inactive = {
      a = "StatusLine",
      b = "StatusLine",
      c = "StatusLine",
    },
  }
end

-- these groups are all relevant to the signcolumn and need their bg updated when
-- switching from / to transparency mode since we want a transparent gutter area with
-- no background. These hlg are used for GitSigns, LSP diagnostics, marks among 
-- other things.
local signgroups = { "RedSign", "OrangeSign", "YellowSign", "GreenSign", "BlueSign", "PurpleSign", "CursorLineNr" }

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
