-- this is a sample scheme definition. It defines all colors with the exception
-- of variant-dependent backgrounds and generic colors.
--
-- it must implement:
-- * basepalette(desaturate, dlevel)
-- * variants(variant_name)
-- * attributes()

-- custom themes must be named as themename.lua and reside in the darkmatter/themes
-- folder.

---@schemeconfig
local schemeconfig = {
  name = "Sonokai - dark",
  desc = "Sonokai - inspired color theme for Neovim",
  avail = { "vivid", "medium", "pastel", "experimental"},
  -- palettes must be represented in colorvariant
  -- each palette must be fully defined.
  palettes = {
    { cmd = "vivid", text = "Vivid (original gruvbox colors, high contrast)", p = 1 },
    { cmd = "medium", text = "Slightly reduced contrast and color intensity", p = 2 },
    { cmd = "pastel", text = "Very low contrast, colors desaturated", p = 3 },
    { cmd = "experimental", text = "Experimental scheme", p = 4 }
  },
  -- the variants must be defined in bgtheme() (see below)
  variants = {
    { hl = "Fg", cmd = "warm", text = "Warm (red tint, low color temp)", p = 1 },
    { hl = "Fg", cmd = "cold", text = "Cold (blue tint, high color temp)", p = 1 },
    { hl = "Fg", cmd = "deepblack", text = "Deep dark (very dark background)", p = 1 },
    { hl = "Fg", cmd = "pitchblack", text = "OLED (pitch black background)", p = 1 },
  }
}

local colorstyles = {
  __default = {
    identifier    = "fg_dim",
    comment       = "grey",
    keyword       = "blue",
    kwspec        = "deepred",
    kwconditional = "blue",
    kwrepeat      = "blue",
    kwexception   = "blue",
    kwreturn      = "blue",
    kwfunc        = "deepred",
    member        = "orange",
    staticmember  = "orange",
    method        = "brightteal",
    func          = "teal",
    operator      = "brown",
    builtin       = "darkyellow",
    braces        = "altblue",
    delim         = "red",
    number        = "altgreen",
    class         = "maroon",
    interface     = "lila",
    storage       = "palegreen",
    constant      = "lpurple",
    module        = "olive",
    namespace     = "olive",
    type          = "darkpurple",
    struct        = "darkpurple",
    bool          = "deepred",
    constructor   = "altyellow",
    macro         = "lpurple",
    defaultlib    = "palegreen",
    staticmethod  = "palegreen",
    attribute     = "olive",
    strings       = "yellow",
    parameter     = "fg_dim",
    url           = "blue",
    h1          =   "blue",
    h2          =   "red",
    h3          =   "green",
    h4          =   "brown",
    h5          =   "orange",
    h6          =   "olive"
  },
  experimental = {
    braces        = "lila",
    delim         = "lpurple"
  }
}

local colorvariants = {
  vivid = {
    orange = { "#dfa690", 215 },
    blue = { "#4a4adf", 239 },
    altblue = { "#6060cf", 239 },
    altyellow = { "#cccc60", 231 },
    altgreen = { "#10801f", 232 },
    lila = { "#7030e0", 241 },
    palegreen = { "#507050", 242 },
    maroon = { "#903060", 243 },
    purple = { "#c030c0", 241 },
    teal = { "#108080", 238 },
    brightteal = { "#30a0c0", 238 },
    darkpurple = { "#903090", 240 },
    red = { "#cc2d4c", 203 },
    yellow = { "#aaaa20", 231 },
    green = { "#10801f", 232 },
    darkyellow = { "#a78624", 180 },
    grey = { "#707069", 2 },
    grey_dim = { "#595f6f", 240 },
    diff_red = { "#45292d", 52 },
    diff_green = { "#10320a", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#8b2d3c", 203 },
    olive = { "#708422", 181 },
    lpurple = { "#b39df3", 176 },
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
  },
  experimental = {
    orange = { "#FF9C2A", 215 },
    blue = { "#0A85B9", 239 },
    altyellow = { "#ff9010", 231 },
    altgreen = { "#7d9654", 232 },
    altblue = { "#0974a1", 239 },
    lila = { "#7060e0", 241 },
    palegreen = { "#5e8888", 242 },
    maroon = { "#b84e36", 243 },
    purple = { "#177ab3", 241 },
    teal = { "#3c7478", 238 },
    brightteal = { "#4c969a", 238 },
    darkpurple = { "#146b9c", 240 },
    red = { "#e65e4f", 203 },
    yellow = { "#edc060", 231 },
    green = { "#8AA55F", 231 },
    darkyellow = { "#eab749", 180 },
    grey = { "#4d6263", 2 },
    grey_dim = { "#374646", 240 },
    diff_red = { "#e34a39", 52 },
    diff_green = { "#1c7060", 22 },
    diff_blue = { "#253147", 17 },
    deepred = { "#c75940", 203 },
    olive = { "#55a6ab", 181 },
    lpurple = { "#b39df3", 176 },
    brown = { "#905010", 233 },
    styled = { }
  }
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

function M.colorstyles()
  return colorstyles
end

  function M.basepalette(colorvariant)
  if colorvariants[colorvariant] ~= nil then
    return colorvariants[colorvariant]
  else
    return colorvariants['vivid']
  end
end

-- these are the base attributes for a scheme. The setup() function merges them
-- with user-provided options to build the final conf.attrib table.
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
      types         = {},              -- types (classes, interfaces)
      storage       = { bold = true }, -- storage/visibility qualifiers (public, private...)
      struct        = {},
      class         = {},
      interface     = {},
      number        = {},
      func          = {}, -- functions
      method        = {}, -- class methods
      attribute     = { bold = true, italic = true },
      staticmethod  = { bold = true },
      member        = {},                             -- class member (field, property...)
      staticmember  = { bold = true },
      operator      = { bold = true },                -- operators
      parameter     = { italic = true, bold = true }, -- function/method arguments
      delim         = { bold = true },                -- delimiters
      brace         = { bold = true },                -- braces, brackets, parenthesis
      str           = {},                             -- strings
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
      defaultlib    = { bold = true, italic = true },
      url           = { bold = true },
      headings      = { bold = true }
    }
  }
end

local fg_def = {
  vivid  = "#a2a0ac",
  pastel = "#a2a0ac",
  medium = "#a2a0ac",
  experimental = "#82808c"
}
local fg_dim_def = {
  vivid  = "#909096",
  medium = "#909096",
  pastel = "#909096",
  experimental = "#72707c"
}

function M.bgtheme()
  return {
    fg_default = "#a2a0ac",
    fg_dim_default = "#909096",
    accent_color = "#204050",
    alt_accent_color = "#501010",
    accent_fg = "#aaaa60",
    lualine = "internal", -- use 'internal' for the integrated theme or any valid lualine theme name
    selbg = "#202070",
    treeselbg = "#1c1c63",
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
      bg4 = { "#504531", 237 },
      statuslinebg = "#262630",
      bg = "#141414",
      treebg = "#18181c",
      floatbg = "#22221f",
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
      bg4 = { "#414550", 237 },
      statuslinebg = "#2a2626",
      bg = "#161414",
      treebg = "#1b1818",
      floatbg = "#1f2222",
      gutterbg = "#131010",
      kittybg = "#1b1818",
      fg = fg_def,
      fg_dim = fg_dim_def
    },
    deepblack = {
      black = { "#151212", 232 },
      bg_dim = { "#242020", 232 },
      bg0 = { "#2c2e34", 235 },
      bg1 = { "#322a2a", 236 },
      bg2 = { "#403936", 236 },
      bg4 = { "#504531", 237 },
      statuslinebg = "#222228",
      bg = "#080808",
      treebg = "#121212",
      floatbg = "#191919",
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
      bg4 = { "#504531", 237 },
      statuslinebg = "#222228",
      bg = "#020202",
      treebg = "#0d0d0d",
      floatbg = "#101010",
      gutterbg = "#020202",
      kittybg = "#0d0d0d",
      fg = fg_def,
      fg_dim = fg_dim_def
    }
  }
end

function M.schemeconfig()
  return schemeconfig
end

function M.custom_colors()
  return {
    c1 = "#2f47df",
    c2 = "#cccc20",
    c3 = '#5050a0',
    c4 = '#4c2e2e',
    c5 = '#2c2e4c'
  }
end

return M
