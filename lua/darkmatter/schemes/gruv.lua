-- darkmatter scheme configuration, inspired by the well known Gruvbox theme.
-- this shall act als refernce for a scheme configuration and contains much of the 
-- documentation.

-- palette to use when basepalette() is called with an unknown name
local _p_fallback = 'vivid'

---@class schemeconfig
local schemeconfig = {
  -- name and desc are currently not used anywhere, but might be in the future
  name = "Frankengruv",
  desc = "Gruvbox-inspired color theme for Neovim",
  -- palettes must be represented in colorvariant
  -- each palette must be fully defined.
  palettes = {
    { cmd = "vivid", text = "Vivid (original gruvbox colors, high contrast)", p = 1 },
    { cmd = "medium", text = "Slightly reduced contrast and color intensity", p = 2 },
    { cmd = "pastel", text = "Low contrast, desaturated and darker colors", p = 3 }
  },
  -- the variants must be defined in bgtheme() (see below)
  variants = {
    { hl = "Fg", cmd = "warm", text = "Warm (red tint, low color temp)", p = 1 },
    { hl = "Fg", cmd = "cold", text = "Cold (blue tint, high color temp)", p = 1 },
    { hl = "Fg", cmd = "deepblack", text = "Deep dark (very dark background)", p = 1 },
    { hl = "Fg", cmd = "pitchblack", text = "OLED (pitch black background)", p = 1 },
    { hl = "Fg", cmd = "deepgreen", text = "Deep Green (very dark green background)", p = 1 }
  }
}

---@class colorvariant
---this defines a base palette of colors for each color variant the scheme has.
---by default, a scheme has three variants: vivid, medium and pastel and they
---should provide different color intensities and contrast with vivid being the
---strongest. More are possible, but must be reflected in bgtheme() and config()
local colorvariants = {
  vivid = {
    orange = { "#dfaa80", 215 },
    blue = { "#458588", 239 },        -- gruv   original
    altblue = { "#83a598", 239 },     -- gruv   original
    altyellow = { "#fabd2d", 231 },   -- gruv   original
    altgreen = { "#98971a", 232 },    -- gruv   original
    lila = { "#7030e0", 241 },
    palegreen = { "#a8ab76", 242 },   -- gruv   original
    maroon = { "#903060", 243 },
    purple = { "#705050", 241 },
    teal = { "#689d7a", 238 },        -- gruv   original
    brightteal = { "#8ec08c", 238 },  -- gruv   original
    darkpurple = { "#b16286", 240 },  -- gruv   original
    red = { "#fb4934", 203 },         -- gruv   original
    yellow = { "#d79921", 231 },      -- gruv   original
    green = { "#40804f", 232 },       -- gruv   original
    darkyellow = { "#a78624", 180 },  -- gruv   original
    grey = { "#707069", 2 },
    grey_dim = { "#444955", 240 },
    diff_red = { "#45292d", 52 },
    diff_green = { "#10320a", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#cc241d", 203 },     -- gruv   original
    olive = { "#708422", 181 },
    lpurple = { "#d3969b", 176 },     -- gruv   original
    brown = { "#905010", 233 },
    styled = {}
  },
  medium = {
    orange = { "#a58370", 215 },
    blue = { "#458588", 239 },
    altblue = { "#83a598", 239 },
    altyellow = { "#da9d0d", 231 },
    altgreen = { "#88872a", 232 },
    lila = { "#7030e0", 241 },
    palegreen = { "#989b66", 242 },
    maroon = { "#903060", 243 },
    purple = { "#705050", 241 },
    teal = { "#588d6a", 238 },
    brightteal = { "#7eb07c", 238 },
    darkpurple = { "#b16286", 240 },
    red = { "#ab2914", 203 },
    yellow = { "#d79921", 231 },
    green = { "#40804f", 232 },
    darkyellow = { "#a78624", 180 },
    grey = { "#707069", 2 },
    grey_dim = { "#444955", 240 },
    diff_red = { "#45292d", 52 },
    diff_green = { "#10320a", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#990403", 203 },
    olive = { "#708422", 181 },
    lpurple = { "#d3969b", 176 },
    brown = { "#905010", 233 },
    styled = {}
  },
  pastel = {
    orange = { "#957360", 215 },
    blue = { "#458588", 239 },
    altblue = { "#83a598", 239 },
    altyellow = { "#ba8d00", 231 },
    altgreen = { "#78772a", 232 },
    lila = { "#7030e0", 241 },
    palegreen = { "#888b56", 242 },
    maroon = { "#903060", 243 },
    purple = { "#705050", 241 },
    teal = { "#487d5a", 238 },
    brightteal = { "#6ea06c", 238 },
    darkpurple = { "#b16286", 240 },
    red = { "#9b1924", 203 },
    yellow = { "#d79921", 231 },
    green = { "#40804f", 232 },
    darkyellow = { "#a78624", 180 },
    grey = { "#707069", 2 },
    grey_dim = { "#444955", 240 },
    diff_red = { "#45292d", 52 },
    diff_green = { "#10320a", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#882220", 203 },
    olive = { "#708422", 181 },
    lpurple = { "#d3969b", 176 },
    brown = { "#905010", 233 },
    styled = {}
  }
}

--- colorstyles assign highlight categories to specific colors in the palette
--- This table defines what colors hould be used for keywords, comments, variables
--- and other semantic elements like types, classes, interfaces and so on.
---@table colorstyles
local colorstyles = {
  identifier = "fg_dim",
  comment = "grey",
  keyword = "darkpurple",
  kwspec = "deepred",
  kwconditional = "maroon",
  kwrepeat = "maroon",
  kwexception = "maroon",
  kwreturn = "darkpurple",
  kwfunc = "maroon",
  member = "orange",
  staticmember = "orange",
  method = "brightteal",
  func = "teal",
  operator = "brown",
  builtin = "deepred",
  braces = "c4",
  delim = "c4",
  number = "green",
  class = "blue",
  interface = "lila",
  storage = "purple",
  constant = "darkyellow",
  module = "olive",
  namespace = "olive",
  type = "altblue",
  struct = "altblue",
  bool = "darkyellow",
  constructor = "altyellow",
  macro = "lpurple",
  defaultlib = "c6",
  staticmethod = "palegreen",
  attribute = "olive",
  strings   = "altgreen",
  parameter = "fg_dim",
  url       = "altblue"
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
    comment      = {},
    keyword      = { bold = true },   -- keywords
    kwspecial    = { bold = true },   -- keywords
    kwconditional= { bold = true },   -- if/then
    kwrepeat     = { bold = true },   -- loops
    kwexception  = { bold = true },
    kwreturn     = { bold = true },   -- return keyword(s)
    types        = {},                -- types (classes, interfaces)
    storage      = { bold = true },   -- storage/visibility qualifiers (public, private...)
    struct       = {},
    class        = {},
    interface    = {},
    number       = {},
    func         = {},   -- functions
    method       = {},                -- class methods
    attribute    = { bold = true, italic = true },
    staticmethod = { bold = true },
    member       = {},                -- class member (field, property...)
    staticmember = { bold = true },
    operator     = { bold = true },   -- operators
    parameter    = { italic = true, bold = true }, -- function/method arguments
    delim        = { bold = true },   -- delimiters
    brace        = { bold = true },   -- braces, brackets, parenthesis
    str          = {},                -- strings
    bold         = { bold = true },
    italic       = { italic = true },
    bolditalic   = { bold = true, italic = true },
    tabline      = {},
    cmpkind      = {},
    uri          = {},
    bool         = { bold = true },
    module       = { bold = true },
    constant     = {},
    macro        = { bold = true },
    defaultlib   = { bold = true },
    url          = { bold = true, underline = true }
  }
end

-- we use the same fg colors for all 3 variants, so just define them
-- once
local fg_def = {
  vivid  = "#e5dbca",
  medium = "#b5abaa",
  pastel = "#958b8a"
}

local fg_dim_def = {
  vivid  = "#9f9b82",
  medium = "#8f8b72",
  pastel = "#7f7b62"
}

--- this regurns the background theme and some very basic colors. There are different
--- colors for each of the background variants
function M.bgtheme()
  return {
    -- accent color is used for important highlights like the currently selected tab (buffer)
    -- and more.
    fg_default = "#ebdbb2",
    fg_dim_default = "#afab82",
    accent_color = "#502a50",
    alt_accent_color = "#501010",
    accent_fg = "#aaaa60",
    lualine = "internal", -- use 'internal' for the integrated theme or any valid lualine theme name
    selbg = "#32304c",
    treeselbg = "#38364c",
    cline = {
      normal = { "#2c2e34", 111},
      insert = { "#2e2020", 112},
      visual = { "#2c2e44", 113}
    },
    cold = {
      black = { "#151212", 232 },
      bg_dim = { "#242020", 232 },
      bg0 = { "#2c2e34", 235 },
      bg1 = { "#322a2a", 236 },
      bg2 = { "#403936", 236 },
      bg4 = { "#555565", 237 },
      statuslinebg = "#262630",
      bg = "#141414",
      treebg = "#18181c",
      floatbg = "#18181d",
      gutterbg = "#101013",
      kittybg = "#18181c",
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
    c4 = '#7070c0',
    c5 = '#ff00ff',
    c6 = '#b07070'
  }
end

---@return schemeconfig
function M.schemeconfig()
  return schemeconfig
end

return M
