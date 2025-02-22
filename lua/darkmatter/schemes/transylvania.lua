-- darkmatter scheme configuration, inspired by the well known Dracula theme.
-- it is not a 1:1 port of Dracula, hence the different name. The vivid color
-- palette uses authentic Dracula colors, the medium and pastel palettes are
-- desaturated and darkened for lower contrast.

-- palette to use when basepalette() is called with an unknown name
local _p_fallback = 'vivid'

local schemeconfig = {
  -- name and desc are currently not used anywhere, but might be in the future
  name = "Transylvania",
  desc = "Dracula - inspired color theme for Neovim",
  -- palettes must be represented in colorvariant
  -- each palette must be fully defined.
  palettes = {
    { cmd = "vivid", text = "Vivid (original Dracula colors, high contrast)", p = 1 },
    { cmd = "medium", text = "Slightly reduced contrast and color intensity", p = 2 },
    { cmd = "pastel", text = "Low contrast, desaturated and darker colors", p = 3 }
  },
  -- the variants must be defined in bgtheme() (see below)
  variants = {
    { hl = "Fg", cmd = "warm", text = "Warm (red tint, low color temp)", p = 1 },
    { hl = "Fg", cmd = "cold", text = "Cold (blue tint, original Dracula theme background)", p = 1 },
    { hl = "Fg", cmd = "deepblack", text = "Deep dark (very dark background)", p = 1 },
    { hl = "Fg", cmd = "pitchblack", text = "OLED (pitch black background)", p = 1 },
  }
}

---@class colorvariant
local colorvariants = {
  vivid = {
    -- these are mostly 1:1 from Dracula specs. They are not desaturated or 
    -- otherwise modified.
    orange = { "#FFB86C", 215 },
    blue = { "#8D93F9", 239 },
    altblue = { "#83a598", 239 },
    altyellow = { "#fabd2d", 231 },
    altgreen = { "#98971a", 232 },
    lila = { "#7030e0", 241 },
    palegreen = { "#a8ab76", 242 },
    maroon = { "#dF59a6", 243 },
    purple = { "#9c6ddf", 241 },
    teal = { "#58d377", 238 },
    brightteal = { "#8BE9FD", 238 },
    darkpurple = { "#FF79C6", 240 },
    red = { "#FF5555", 203 },
    yellow = { "#F1FA8C", 231 },
    green = { "#50fa7b", 232 },
    darkyellow = { "#a78624", 180 },
    grey = { "#6272A4", 2 },
    grey_dim = { "#595f6f", 240 },
    diff_red = { "#45292d", 52 },
    diff_green = { "#10320a", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#cc241d", 203 },
    olive = { "#708422", 181 },
    lpurple = { "#d3969b", 176 },
    brown = { "#905010", 233 },
    pink =  { "#BD93F9", 234 },
    styled = {}
  },
  medium = {
    orange = { "#a58d80", 215 },
    blue = { "#458588", 239 },
    altblue = { "#83a598", 239 },
    altyellow = { "#da9d0d", 231 },
    altgreen = { "#88872a", 232 },
    lila = { "#7030e0", 241 },
    palegreen = { "#989b66", 242 },
    maroon = { "#904c6e", 243 },
    purple = { "#9c6ddf", 241 },
    teal = { "#588d6a", 238 },
    brightteal = { "#7eb07c", 238 },
    darkpurple = { "#b16286", 240 },
    red = { "#ab2914", 203 },
    yellow = { "#d8df93", 231 },
    green = { "#40804f", 232 },
    darkyellow = { "#a78624", 180 },
    grey = { "#6272A4", 2 },
    grey_dim = { "#595f6f", 240 },
    diff_red = { "#45292d", 52 },
    diff_green = { "#10320a", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#990403", 203 },
    olive = { "#708422", 181 },
    lpurple = { "#d3969b", 176 },
    brown = { "#905010", 233 },
    pink =  { "#a187c5", 234 },
    styled = {}
  },
  pastel = {
    orange = { "#957c6e", 215 },
    blue = { "#458588", 239 },
    altblue = { "#83a598", 239 },
    altyellow = { "#ba8d00", 231 },
    altgreen = { "#78772a", 232 },
    lila = { "#7030e0", 241 },
    palegreen = { "#888b56", 242 },
    maroon = { "#904c6e", 243 },
    purple = { "#9c6ddf", 241 },
    teal = { "#487d5a", 238 },
    brightteal = { "#6ea06c", 238 },
    darkpurple = { "#b16286", 240 },
    red = { "#9b1924", 203 },
    yellow = { "#9d9f86", 231 },      -- gruv   original
    green = { "#4c8058", 232 },
    darkyellow = { "#a78624", 180 },
    grey = { "#6272A4", 2 },
    grey_dim = { "#595f6f", 240 },
    diff_red = { "#45292d", 52 },
    diff_green = { "#10320a", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#882220", 203 },
    olive = { "#708422", 181 },
    lpurple = { "#9f7081", 176 },
    brown = { "#905010", 233 },
    pink =  { "#766391", 234 },
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
  keyword = "pink",
  kwspec = "maroon",
  kwconditional = "maroon",
  kwrepeat = "maroon",
  kwexception = "maroon",
  kwreturn = "pink",
  kwfunc = "maroon",
  member = "orange",
  staticmember = "orange",
  method = "teal",
  func = "green",
  operator = "brown",
  builtin = "lpurple",
  braces = "c4",
  delim = "c4",
  number = "lila",
  class = "blue",
  interface = "lila",
  storage = "purple",
  constant = "darkpurple",
  module = "olive",
  namespace = "olive",
  type = "altblue",
  struct = "altblue",
  bool = "darkyellow",
  constructor = "altyellow",
  macro = "lpurple",
  defaultlib = "darkyellow",
  staticmethod = "palegreen",
  attribute = "olive",
  strings   = "yellow",
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
  vivid  = "#F8F8F2",
  medium = "#ababa7",
  pastel = "#92928e"
}

local fg_dim_def = {
  vivid  = "#c8c8c2",
  medium = "#949490",
  pastel = "#7b7b77"
}

--- this regurns the background theme and some very basic colors. There are different
--- colors for each of the background variants
function M.bgtheme()
  return {
    -- accent color is used for important highlights like the currently selected tab (buffer)
    -- and more.
    fg_default = "#F8F8F2",
    fg_dim_default = "#c8c8c2",
    accent_color = "#502a50",
    alt_accent_color = "#501010",
    accent_fg = "#aaaa60",
    lualine = "internal", -- use 'internal' for the integrated theme or any valid lualine theme name
    selbg = "#44475A",
    cold = {
      black = { "#151212", 232 },
      bg_dim = { "#242020", 232 },
      bg0 = { "#2c2e34", 235 },
      bg1 = { "#322a2a", 236 },
      bg2 = { "#403936", 236 },
      bg4 = { "#555565", 237 },
      statuslinebg = "#242436",
      bg = "#282A36",
      treebg = "#2b2d39",
      floatbg = "#2b2d39",
      gutterbg = "#282a36",
      kittybg = "#2b2d39",
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
    }
  }
end

function M.custom_colors()
  return {
    c1 = '#ff0000',
    c2 = '#00ff00',
    c3 = '#4c4866',
    c4 = '#8383c0',
    c5 = '#ff00ff'
  }
end

---@return table: supported color variants
function M.schemeconfig()
  return schemeconfig
end

return M
