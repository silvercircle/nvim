-- this is a sample scheme definition. It defines all colors in a theme
--
-- it must implement:
-- * basepalette(colorvariant)
-- * rainbowpalette()
-- * attributes()
-- * styles()
-- * variant(variant)
-- * config()

-- custom themes must be named as themename.lua and reside in the darkmatter/schemes
-- folder.

-- palette to use when basepalette() is called with an unknown name
local _p_fallback = 'vivid'

local colorvariants = {
  vivid = {
    orange = { "#bfaa60", 215 },
    blue = { "#458588", 239 },        -- gruv   original
    altblue = { "#83a598", 239 },     -- gruv   original
    altyellow = { "#fabd2d", 231 },   -- gruv   original
    altgreen = { "#98971a", 232 },    -- gruv   original
    lila = { "#7030e0", 241 },
    palegreen = { "#b8bb26", 242 },   -- gruv   original
    maroon = { "#903060", 243 },
    purple = { "#604040", 241 },
    teal = { "#689d7a", 238 },        -- gruv   original
    brightteal = { "#8ec08c", 238 },  -- gruv   original
    darkpurple = { "#b16286", 240 },  -- gruv   original
    red = { "#fb4934", 203 },         -- gruv   original
    yellow = { "#d79921", 231 },      -- gruv   original
    green = { "#40804f", 232 },       -- gruv   original
    darkyellow = { "#a78624", 180 },  -- gruv   original
    grey = { "#707069", 2 },
    grey_dim = { "#595f6f", 240 },
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
    orange = { "#a59680", 215 },
    blue = { "#5a6acf", 239 },
    altyellow = { "#aaaa20", 231 },
    altgreen = { "#309020", 232 },
    altblue = { "#6060cf", 239 },
    lila = { "#7050e0", 241 },
    palegreen = { "#607560", 242 },
    maroon = { "#804060", 243 },
    purple = { "#b070b0", 241 },
    teal = { "#509090", 238 },
    brightteal = { "#6090a0", 238 },
    darkpurple = { "#705070", 240 },
    red = { "#bb4d5c", 203 },
    yellow = { "#aaaa60", 231 },
    green = { "#60906f", 231 },
    darkyellow = { "#958434", 180 },
    grey = { "#707069", 2 },
    grey_dim = { "#595f6f", 240 },
    diff_red = { "#45292d", 52 },
    diff_green = { "#10320a", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#782d3c", 203 },
    olive = { "#708422", 181 },
    lpurple = { "#b39df3", 176 },
    brown = { "#905010", 233 },
    styled = { }
  },
  pastel = {
    orange = { "#958680", 215 },
    blue = { "#5a6acf", 239 },
    altyellow = { "#aaaa20", 231 },
    altgreen = { "#309020", 232 },
    altblue = { "#6060cf", 239 },
    lila = { "#7060e0", 241 },
    palegreen = { "#607560", 242 },
    maroon = { "#805060", 243 },
    purple = { "#a070a0", 241 },
    teal = { "#709090", 238 },
    brightteal = { "#608095", 238 },
    darkpurple = { "#806a80", 240 },
    red = { "#ab5d6c", 203 },
    yellow = { "#909870", 231 },
    green = { "#658075", 231 },
    darkyellow = { "#877634", 180 },
    grey = { "#707069", 2 },
    grey_dim = { "#595f6f", 240 },
    diff_red = { "#45292d", 52 },
    diff_green = { "#10320a", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#702d3c", 203 },
    olive = { "#708422", 181 },
    lpurple = { "#b39df3", 176 },
    brown = { "#905010", 233 },
    styled = { }
  }
}

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
  builtin = "darkyellow",
  braces = "darkyellow",
  delim = "red",
  number = "green",
  class = "blue",
  interface = "lila",
  storage = "purple",
  constant = "darkyellow",
  module = "olive",
  namespace = "olive",
  type = "altblue",
  struct = "darkpurple",
  bool = "deepred",
  constructor = "altyellow",
  macro = "lpurple",
  defaultlib = "darkyellow",
  staticmethod = "palegreen",
  attribute = "olive",
  strings   = "altgreen",
  parameter = "fg_dim",
}

local M = {}

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

function M.variants(variant)
  if variant ~= "warm" then
    return {
      black = { "#121215", 232 },
      bg_dim = { "#222327", 232 },
      bg0 = { "#202026", 235 },
      bg1 = { "#33353f", 236 },
      bg2 = { "#363944", 236 },
      bg4 = { "#414550", 237 }
    }
  else
    return {
      black = { "#151212", 232 },
      bg_dim = { "#242020", 232 },
      bg0 = { "#2c2e34", 235 },
      bg1 = { "#322a2a", 236 },
      bg2 = { "#403936", 236 },
      bg4 = { "#504531", 237 }
    }
  end
end

-- these are the base attributes for a scheme. The setup() function merges them
-- with user-provided options to build the final conf.attrib table.
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
    defaultlib   = { bold = true, italic = true }
  }
end

function M.bgtheme()
  return {
    -- accent color is used for important highlights like the currently selected tab (buffer)
    -- and more.
    accent_color = "#204050",
    alt_accent_color = "#501010",
    accent_fg = "#aaaa60",
    lualine = "internal", -- use 'internal' for the integrated theme or any valid lualine theme name
    selbg = "#4c4866",
    cold = {
      statuslinebg = "#262630",
      bg = "#141414",
      treebg = "#18181c",
      floatbg = "#18181d",
      gutterbg = "#101013",
      kittybg = "#18181c",
      fg = "#ebdbb2",
      fg_dim = "#ab9b72"
    },
    warm = {
      statuslinebg = "#2a2626",
      bg = "#141212",
      treebg = "#181515",
      floatbg = "#191515",
      gutterbg = "#131010",
      kittybg = "#181515",
      fg = "#ebdbb2",
      fg_dim = "#ab9b72"
    },
    deepblack = {
      statuslinebg = "#222228",
      bg = "#080808",
      treebg = "#121212",
      floatbg = "#131212",
      gutterbg = "#0f0f0f",
      kittybg = "#121212",
      fg = "#ebdbb2",
      fg_dim = "#ab9b72"
    },
    pitchblack = {
      statuslinebg = "#222228",
      bg = "#020202",
      treebg = "#0d0d0d",
      floatbg = "#0e0d0d",
      gutterbg = "#020202",
      kittybg = "#0d0d0d",
      fg = "#ebdbb2",
      fg_dim = "#ab9b72"
    }
  }
end

function M.config()
  return {
    palettes = {
      { cmd = "vivid", text = "Vivid (original gruvbox colors, high contrast)", p = 1 },
      { cmd = "medium", text = "Slightly reduced contrast and color intensity", p = 2 },
      { cmd = "pastel", text = "Very low contrast, colors desaturated", p = 3 }
    }
  }
end

return M
