-- this is a sample scheme definition. It defines all colors with the exception
-- of variant-dependent backgrounds and generic colors.
--
-- it must implement:
-- * basepalette(desaturate, dlevel)
-- * variants(variant_name)
-- * attributes()

-- custom themes must be named as themename.lua and reside in the darkmatter/themes
-- folder.
local vivid_colors = {
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
  styled = { }
}

local desaturated_colors = {
  low = {
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
  high = {
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

local M = {}
function M.basepalette(desaturate, dlevel)
  if desaturate == true then
    return (dlevel == 1) and desaturated_colors.low or desaturated_colors.high
  else
    return vivid_colors
  end
end

function M.variants(variant)
    if variant == "cold" or variant == "deepblack" then
      return {
        black = { "#121215", 232 },
        bg_dim = { "#222327", 232 },
        bg0 = { "#2c2e34", 235 },
        bg1 = { "#33353f", 236 },
        bg2 = { "#363944", 236 },
        bg4 = { "#414550", 237 }
      }
    else
      return {
        black = { "#151212", 232 },
        bg_dim = { "#242020", 232 },
        bg0 = { "#302c2e", 235 },
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
    parameter    = { italic = true }, -- function/method arguments
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

function M.theme()
  return {
    -- accent color is used for important highlights like the currently selected tab (buffer)
    -- and more.
    --accent_color = '#cbaf00',
    accent_color = "#204050",
    --accent_color = "#305030",
    --alt_accent_color = '#bd2f4f',
    alt_accent_color = "#501010",
    --accent_fg = "#cccc80",
    accent_fg = "#aaaa60",
    lualine = "internal", -- use 'internal' for the integrated theme or any valid lualine theme name
    selbg = "#202070",
    cold = {
      statuslinebg = "#262630",
      bg = "#141414",
      treebg = "#18181c",
      floatbg = "#22221f",
      gutterbg = "#101013",
      kittybg = "#18181c",
      fg = "#a2a0ac",
      fg_dim = "#909096"
    },
    warm = {
      statuslinebg = "#2a2626",
      bg = "#161414",
      treebg = "#1b1818",
      floatbg = "#1f2222",
      gutterbg = "#131010",
      kittybg = "#1b1818",
      fg = "#aaa0a5",
      fg_dim = "#969090"
    },
    deepblack = {
      statuslinebg = "#222228",
      bg = "#080808",
      treebg = "#121212",
      floatbg = "#191919",
      gutterbg = "#0f0f0f",
      kittybg = "#121212",
      fg = "#b0b0b5",
      fg_dim = "#95959c"
    },
    pitchblack = {
      statuslinebg = "#222228",
      bg = "#020202",
      treebg = "#0d0d0d",
      floatbg = "#101010",
      gutterbg = "#020202",
      kittybg = "#0d0d0d",
      fg = "#b0b0b5",
      fg_dim = "#95959c"
    }
  }
end
return M
