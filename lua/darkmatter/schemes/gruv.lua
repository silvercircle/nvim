-- darkmatter scheme configuration, inspired by the well known Gruvbox theme.
-- this shall act als refernce for a scheme configuration and contains much of the 
-- documentation.

-- palette to use when basepalette() is called with an unknown name
local _p_fallback = 'vivid'

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
    orange = { "#bfaa60", 215 },
    blue = { "#458588", 239 },
    altblue = { "#83a598", 239 },
    altyellow = { "#fabd2d", 231 },
    altgreen = { "#98971a", 232 },
    lila = { "#7030e0", 241 },
    palegreen = { "#a8ab76", 242 },
    maroon = { "#903060", 243 },
    purple = { "#705050", 241 },
    teal = { "#689d7a", 238 },
    brightteal = { "#8ec08c", 238 },
    darkpurple = { "#b16286", 240 },
    red = { "#fb4934", 203 },
    yellow = { "#d79921", 231 },
    green = { "#40804f", 232 },
    darkyellow = { "#a78624", 180 },
    grey = { "#707069", 2 },
    grey_dim = { "#595f6f", 240 },
    diff_red = { "#45292d", 52 },
    diff_green = { "#10320a", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#cc241d", 203 },
    olive = { "#708422", 181 },
    lpurple = { "#d3969b", 176 },
    brown = { "#905010", 233 },
    styled = {}
  },
  pastel = {
    orange = { "#bfaa60", 215 },
    blue = { "#458588", 239 },
    altblue = { "#83a598", 239 },
    altyellow = { "#fabd2d", 231 },
    altgreen = { "#98971a", 232 },
    lila = { "#7030e0", 241 },
    palegreen = { "#a8ab76", 242 },
    maroon = { "#903060", 243 },
    purple = { "#705050", 241 },
    teal = { "#689d7a", 238 },
    brightteal = { "#8ec08c", 238 },
    darkpurple = { "#b16286", 240 },
    red = { "#fb4934", 203 },
    yellow = { "#d79921", 231 },
    green = { "#40804f", 232 },
    darkyellow = { "#a78624", 180 },
    grey = { "#707069", 2 },
    grey_dim = { "#595f6f", 240 },
    diff_red = { "#45292d", 52 },
    diff_green = { "#10320a", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#cc241d", 203 },
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
  bool = "darkyellow",
  constructor = "altyellow",
  macro = "lpurple",
  defaultlib = "darkyellow",
  staticmethod = "palegreen",
  attribute = "olive",
  strings   = "altgreen",
  parameter = "fg_dim",
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
    defaultlib   = { bold = true, italic = true }
  }
end

--- this regurns the background theme and some very basic colors. There are different
--- colors for each of the background variants
function M.bgtheme()
  return {
    -- accent color is used for important highlights like the currently selected tab (buffer)
    -- and more.
    fg_default = "#ebdbb2",
    fg_dim_default = "#afab82",
    accent_color = "#204050",
    alt_accent_color = "#501010",
    accent_fg = "#aaaa60",
    lualine = "internal", -- use 'internal' for the integrated theme or any valid lualine theme name
    selbg = "#4c4866",
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
      fg = {
        vivid   = "#ebdbb2",
        medium  = "#ebdbb2",
        pastel  = "#ebdbb2"
      },
      fg_dim = {
        vivid   = "#afab82",
        medium  = "#afab82",
        pastel  = "#afab82"
      }
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
      fg = {
        vivid   = "#ebdbb2",
        medium  = "#cbbb92",
        pastel  = "#ab9b72"
      },
      fg_dim = {
        vivid   = "#afab82",
        medium  = "#9f9b72",
        pastel  = "#8f8b62"
      }
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
      fg = {
        vivid   = "#ebdbb2",
        medium  = "#ebdbb2",
        pastel  = "#ebdbb2"
      },
      fg_dim = {
        vivid   = "#afab82",
        medium  = "#afab82",
        pastel  = "#afab82"
      }
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
      fg = {
        vivid   = "#ebdbb2",
        medium  = "#ebdbb2",
        pastel  = "#ebdbb2"
      },
      fg_dim = {
        vivid   = "#afab82",
        medium  = "#afab82",
        pastel  = "#afab82"
      }
    }
  }
end

---@return table: supported color variants
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
