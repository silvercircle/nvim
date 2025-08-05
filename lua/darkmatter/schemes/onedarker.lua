-- darkmatter scheme configuration, inspired by the well known One dark theme.

-- it is not a 1:1 port of One Dark, hence the different name. The color palette
-- uses authentic One Dark colors though.

-- Based on the now archived "One Dark" color scheme for the Atom text editor:
-- https://github.com/atom/atom/tree/master/packages/one-dark-syntax

-- palette to use when basepalette() is called with an unknown name
local _p_fallback = 'vivid'

local schemeconfig = {
  -- name and desc are currently not used anywhere, but might be in the future
  name  = "One Darker",
  desc  = "One Dark - inspired color theme for Neovim",
  avail = { "vivid", "medium", "pastel"},
  -- palettes must be represented in colorvariant
  -- each palette must be fully defined.
  palettes = {
    { cmd = "vivid", text = "Vivid (original Dracula colors, high contrast)", p = 1 },
    { cmd = "medium", text = "Slightly reduced contrast, brightness and color intensity", p = 1 },
    { cmd = "pastel", text = "Reduced contrast, brightness and color intensity", p = 2 }
  },
  -- the variants must be defined in bgtheme() (see below)
  variants = {
    { hl = "Fg", cmd = "warm", text = "Warm (red tint, low color temp)", p = 1 },
    { hl = "Fg", cmd = "cold", text = "Cold (blue tint, original Dracula theme background)", p = 1 },
    { hl = "Fg", cmd = "deepblack", text = "Deep dark (very dark background)", p = 1 },
    { hl = "Fg", cmd = "pitchblack", text = "OLED (pitch black background)", p = 1 },
    { hl = "Fg", cmd = "deepgreen", text = "Deep Green (very dark green background)", p = 1 },
  }
}

---@class colorvariant
local colorvariants = {
  vivid = {
    -- these are mostly 1:1 from Dracula specs. They are not desaturated or 
    -- otherwise modified.
    orange = { "#e5c07b", 215 },
    blue = { "#61afef", 239 },
    altblue = { "#6ca5d5", 239 },
    altyellow = { "#fabd2d", 231 },
    altgreen = { "#98971a", 232 },
    lila = { "#7030e0", 241 },
    dblue = { "#517da1", 242 },
    maroon = { "#dF59a6", 243 },
    purple = { "#9c6ddf", 241 },
    teal = { "#56b6c2", 238 },
    brightteal = { "#8BE9FD", 238 },
    darkpurple = { "#8a60c5", 240 },
    red = { "#e06c75", 203 },
    yellow = { "#aaaca2", 231 },
    green = { "#98c379", 232 },
    darkyellow = { "#d19a66", 180 },
    grey = { "#6272A4", 2 },
    grey_dim = { "#444455", 240 },
    diff_red = { "#45292d", 52 },
    diff_green = { "#10320a", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#7a3a3f", 203 },
    olive = { "#708422", 181 },
    lpurple = { "#7d79f8", 241 },
    brown = { "#905010", 233 },
    pink =  { "#BD93F9", 234 },
    styled = {}
  },
  medium = {
    orange = { "#e5c07b", 215 },
    blue = { "#59a1dd", 239 },
    altblue = { "#6297c3", 239 },
    altyellow = { "#dbad41", 231 },
    altgreen = { "#98971a", 232 },
    lila = { "#7030e0", 241 },
    dblue = { "#517da1", 242 },
    maroon = { "#c5629b", 243 },
    purple = { "#8a5fc5", 241 },
    teal = { "#56b6c2", 238 },
    brightteal = { "#8BE9FD", 238 },
    darkpurple = { "#7852ab", 240 },
    red = { "#c65f67", 203 },
    yellow = { "#909289", 231 },
    green = { "#84a969", 232 },
    darkyellow = { "#d19a66", 180 },
    grey = { "#6272A4", 2 },
    grey_dim = { "#444455", 240 },
    diff_red = { "#45292d", 52 },
    diff_green = { "#10320a", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#7a3a3f", 203 },
    olive = { "#708422", 181 },
    lpurple = { "#7d79f8", 241 },
    brown = { "#905010", 233 },
    pink =  { "#BD93F9", 234 },
    styled = {}
  },
  pastel = {
    orange = { "#e5c07b", 215 },
    blue = { "#5192c8", 239 },
    altblue = { "#5887ae", 239 },
    altyellow = { "#bc9947", 231 },
    altgreen = { "#98971a", 232 },
    lila = { "#7030e0", 241 },
    dblue = { "#517da1", 242 },
    maroon = { "#b16691", 243 },
    purple = { "#8159b8", 241 },
    teal = { "#56b6c2", 238 },
    brightteal = { "#8BE9FD", 238 },
    darkpurple = { "#6f4c9e", 240 },
    red = { "#b95860", 203 },
    yellow = { "#8c927a", 231 },
    green = { "#708f59", 232 },
    darkyellow = { "#d19a66", 180 },
    grey = { "#6272A4", 2 },
    grey_dim = { "#444455", 240 },
    diff_red = { "#45292d", 52 },
    diff_green = { "#10320a", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#7a3a3f", 203 },
    olive = { "#708422", 181 },
    lpurple = { "#7d79f8", 241 },
    brown = { "#905010", 233 },
    pink =  { "#BD93F9", 234 },
    styled = {}
  }
}

--- colorstyles assign highlight categories to specific colors in the palette
--- This table defines what colors hould be used for keywords, comments, variables
--- and other semantic elements like types, classes, interfaces and so on.
---@table colorstyles
local colorstyles = {
  __default = {
    identifier    = "fg_dim",
    comment       = "grey",
    keyword       = "purple",
    kwspec        = "purple",
    kwconditional = "darkpurple",
    kwrepeat      = "darkpurple",
    kwexception   = "purple",
    kwreturn      = "purple",
    kwfunc        = "purple",
    member        = "yellow",
    staticmember  = "orange",
    method        = "altblue",
    func          = "blue",
    operator      = "brown",
    builtin       = "pink",
    braces        = "altgreen",
    delim         = "altgreen",
    number        = "altyellow",
    class         = "darkyellow",
    interface     = "lila",
    storage       = "deepred",
    constant      = "lpurple",
    module        = "olive",
    namespace     = "olive",
    type          = "teal",
    struct        = "altblue",
    bool          = "altyellow",
    constructor   = "brightteal",
    macro         = "lpurple",
    defaultlib    = "maroon",
    staticmethod  = "dblue",
    attribute     = "olive",
    strings       = "green",
    parameter     = "lpurple",
    url           = "altblue",
    h1          =   "blue",
    h2          =   "red",
    h3          =   "green",
    h4          =   "brown",
    h5          =   "orange",
    h6          =   "olive"
  }
}

local M = {}

--- a special palette used to colorize "rainbow elements". Useful for 
--- indent guides or rainbow coloring of braces.
--- @return table
function M.rainbowpalette()
  return {
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
  }
end

---@param colorvariant string
---@return colorvariant
function M.basepalette(colorvariant)
  if colorvariants[colorvariant] ~= nil then
    return colorvariants[colorvariant]
  else
    return colorvariants[_p_fallback]
  end
end

function M.colorstyles()
  return colorstyles
end

--- these are the base attributes for a scheme. The setup() function merges them
--- with user-provided options to build the final conf.attrib table.
function M.attributes()
  return {
    __default = {
      comment       = {},
      keyword       = { bold = true }, -- keywords
      kwspecial     = { bold = true }, -- keywords
      kwconditional = { bold = true }, -- if/then
      kwrepeat      = { bold = true }, -- loops
      kwexception   = { bold = true },
      kwreturn      = { bold = true }, -- return keyword(s)
      types         = {},           -- types (classes, interfaces)
      storage       = { bold = true }, -- storage/visibility qualifiers (public, private...)
      struct        = {},
      class         = {},
      interface     = {},
      number        = {},
      func          = {}, -- functions
      method        = {}, -- class methods
      attribute     = { bold = true, italic = true },
      staticmethod  = { bold = true },
      member        = {},           -- class member (field, property...)
      staticmember  = { bold = true },
      operator      = { bold = true }, -- operators
      parameter     = { bold = true, italic = true},           -- function/method arguments
      delim         = { bold = true }, -- delimiters
      brace         = { bold = true }, -- braces, brackets, parenthesis
      str           = {},           -- strings
      bold          = { bold = true },
      italic        = { italic = true },
      bolditalic    = { bold = true, italic = true },
      tabline       = {},
      cmpkind       = {},
      uri           = {},
      bool          = { bold = true },
      module        = { bold = true },
      constant      = {},
      macro         = { bold = true },
      defaultlib    = {},
      url           = { bold = true, underline = true },
      headings      = { bold = true }
    }
  }
end

-- we use the same fg colors for all 3 variants, so just define them
-- once
local fg_def = {
  vivid   = "#979eab",
  medium  = "#8b929e",
  pastel  = "#808691"
}

local fg_dim_def = {
  vivid   = "#808691",
  medium  = "#747a84",
  pastel  = "#757677"
}

--- this regurns the background theme and some very basic colors. There are different
--- colors for each of the background variants
function M.bgtheme()
  return {
    -- accent color is used for important highlights like the currently selected tab (buffer)
    -- and more.
    fg_default = fg_def,
    fg_dim_default = fg_dim_def,
    accent_color = "#502a50",
    alt_accent_color = "#501010",
    accent_fg = "#aaaa60",
    lualine = "internal", -- use 'internal' for the integrated theme or any valid lualine theme name
    selbg = "#53575e",
    treeselbg = "#3a3e5a",
    cline = {
      normal = { "#2c2e34", 111},
      insert = { "#341e24", 112},
      visual = { "#2c2e44", 113}
    },
    cold = {
      black = { "#151212", 232 },
      bg_dim = { "#242020", 232 },
      bg0 = { "#2c2e34", 235 },
      bg1 = { "#322a2a", 236 },
      bg2 = { "#403936", 236 },
      bg4 = { "#555565", 237 },
      statuslinebg = "#242436",
      bg = "#121214",
      treebg = "#151518",
      floatbg = "#151519",
      gutterbg = "#121213",
      kittybg = "#151518",
      fg = fg_def,
      fg_dim = fg_dim_def
    },
    warm = {
      black = { "#121215", 232 },
      bg_dim = { "#222327", 232 },
      bg0 = { "#202026", 235 },
      bg1 = { "#33353f", 236 },
      bg2 = { "#363944", 236 },
      bg4 = { "#655555", 237 },
      statuslinebg = "#2a2626",
      bg = "#141212",
      treebg = "#181515",
      floatbg = "#191515",
      gutterbg = "#131010",
      kittybg = "#181515",
      fg = fg_def,
      fg_dim = fg_dim_def
    },
    deepblack = {
      black = { "#151212", 232 },
      bg_dim = { "#242020", 232 },
      bg0 = { "#2c2e34", 235 },
      bg1 = { "#322a2a", 236 },
      bg2 = { "#403936", 236 },
      bg4 = { "#555565", 237 },
      statuslinebg = "#222228",
      bg = "#080808",
      treebg = "#121212",
      floatbg = "#131212",
      gutterbg = "#0f0f0f",
      kittybg = "#121212",
      fg = fg_def,
      fg_dim = fg_dim_def
    },
    pitchblack = {
      black = { "#151212", 232 },
      bg_dim = { "#242020", 232 },
      bg0 = { "#2c2e34", 235 },
      bg1 = { "#322a2a", 236 },
      bg2 = { "#403936", 236 },
      bg4 = { "#555565", 237 },
      statuslinebg = "#222228",
      bg = "#020202",
      treebg = "#0d0d0d",
      floatbg = "#0e0d0d",
      gutterbg = "#020202",
      kittybg = "#0d0d0d",
      fg = fg_def,
      fg_dim = fg_dim_def
    },
    deepgreen = {
      black = { "#151212", 232 },
      bg_dim = { "#242020", 232 },
      bg0 = { "#2c2e34", 235 },
      bg1 = { "#322a2a", 236 },
      bg2 = { "#403936", 236 },
      bg4 = { "#555565", 237 },
      statuslinebg = "#222228",
      bg = "#080f08",
      treebg = "#0e130e",
      floatbg = "#0e0d0d",
      gutterbg = "#020202",
      kittybg = "#0d0d0d",
      fg = fg_def,
      fg_dim = fg_dim_def
    }
  }
end

function M.custom_colors()
  return {
    c1 = "#2f47df",
    c2 = "#cccc20",
    c3 = '#4c4866',
    c4 = '#4c2e2e',
    c5 = '#2c2e4c'
}
end

---@return table: supported color variants
function M.schemeconfig()
  return schemeconfig
end

--- this function is called from the theme engine at the end of set(). It allows
--- to override highlight groups. It is optional and does not have to exist in a scheme
--- definition.
--- @param theme type theme. The theme engine.
--- You can use theme.P, theme.T and all the methods.
function M.custom_hl(theme)
  theme.hl_with_defaults("iCursor", theme.NONE, theme.P.altyellow)
end

return M
