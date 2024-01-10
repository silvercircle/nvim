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
--https://gitlab.com/silvercircle73/nvim
--License:      MIT
--it features multiple background modes (cold, warm and deepdark) and three levels
--of color saturation: bright vivid and two desaturated modes
--
--TODO: * cleanup, organize the highlight groups better
--      * maybe (just maybe) a bright background variant

local M = {}
local basepalette = {
  dark = {
    grey = { "#707070", 2 },
    bg_red = { "#ff6077", 203 },
    diff_red = { "#45292d", 52 },
    bg_green = { "#a7df78", 107 },
    diff_green = { "#10320a", 22 },
    bg_blue = { "#75a3f2", 110 },
    diff_blue = { "#253147", 17 },
    diff_yellow = { "#4e432f", 54 },
    deepred = { "#8b2d3c", 203 },
    darkyellow = { "#a78624", 180 },
    olive = { "#708422", 181 },
    purple = { "#b39df3", 176 },
    grey_dim = { "#595f6f", 240 },
    selfg = { "#cccc20", 233 },
    brown = { "#905010", 233 },
    none = { "NONE", "NONE" },
  },
  light = {
    grey = { "#707070", 2 },
    bg_red = { "#ff6077", 203 },
    diff_red = { "#45292d", 52 },
    bg_green = { "#a7df78", 107 },
    diff_green = { "#10320a", 22 },
    bg_blue = { "#75a3f2", 110 },
    diff_blue = { "#a0a0bb", 17 },
    diff_yellow = { "#4e432f", 54 },
    deepred = { "#8b2d3c", 203 },
    darkyellow = { "#a78624", 180 },
    olive = { "#708422", 181 },
    purple = { "#b39df3", 176 },
    grey_dim = { "#595f6f", 240 },
    selfg = { "#cccc20", 233 },
    brown = { "#704010", 233 },
    none = { "NONE", "NONE" },
  }
}

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
M.palette = {}
M.localtheme = {}
M.theme = nil

M.basetheme = {
  dark = {
    -- accent color is used for important highlights like the currently selected tab (buffer)
    -- and more.
    --accent_color = '#cbaf00',
    accent_color = '#204050',
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
      gutterbg = "#101013",
      kittybg = "#18181c",
      fg = "#a2a0ac",
      fg_dim = "#909096"
    },
    warm = {
      statuslinebg = "#2a2626",
      bg = "#161414",
      treebg = "#1b1818",
      gutterbg = "#131010",
      kittybg = "#1b1818",
      fg = "#aaa0a5",
      fg_dim = "#969090"
    },
    deepblack = {
      statuslinebg = "#222228",
      bg = "#0a0a0a",
      treebg = "#121212",
      gutterbg = "#0f0f0f",
      kittybg = "#121212",
      fg = "#b0b0b0",
      fg_dim = "#959595"
    }
  },
  light = {
    accent_color = "#103010",
    alt_accent_color = "#501010",
    accent_fg = "#cccc80",
    lualine = "internal", -- use 'internal' for the integrated theme or any valid lualine theme name
    selbg = "#202070",
    cold = {
      statuslinebg = "#b0b0b5",
      bg = "#e5e5ea",
      treebg = "#d0d0d5",
      gutterbg = "#e0e0e5",
      kittybg = "#18181c",
      fg = "#a2a0ac",
    },
    warm = {
      statuslinebg = "#b5b0b0",
      bg = "#eae5e5",
      treebg = "#d5d0d0",
      gutterbg = "#e5e0e0",
      kittybg = "#1b1818",
      fg = "#aaa0a5",
    },
    deepblack = {
      statuslinebg = "#b0b0b0",
      bg = "#e5e5e5",
      treebg = "#d0d0d0",
      gutterbg = "#e0e0e0",
      kittybg = "#111111",
      fg = "#0a0a0a",
    }
  }
}

-- the theme configuration. This can be changed by calling setup({...})
-- after changing the configuration configure() must be called before the theme
-- can be activated with set()
local conf = {
  disabled = false,
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
  accent = "yellow",
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
  indentguide_colors = {
    light = "#505050",
    dark = "#505050"
  },
  rainbow_contrast = "high",
  -- attributes for various highlight classes. They allow all standard
  -- highlighting attributes like bold, italic, underline, sp.
  baseattrib = {
    dark = {
      keyword      = { bold = true },   -- keywords
      conditional  = { bold = true },   -- special keywords (if, then...)
      types        = {},                -- types (classes, interfaces)
      storage      = { bold = true },   -- storage/visibility qualifiers (public, private...)
      struct       = { bold = true },
      class        = { bold = true },
      interface    = { bold = true },
      number       = { bold = true },
      func         = { bold = true },   -- functions
      method       = { },               -- class methods
      staticmethod = { italic = true },
      member       = { },               -- class member (=field)
      staticmember = { italic = true },
      operator     = { bold = true },   -- operators
      delim        = { bold = true },   -- delimiters
      brace        = { bold = true },   -- braces, brackets, parenthesis
      string       = {},
      bold         = { bold = true },
      italic       = { italic = true },
      bolditalic   = { bold = true, italic = true },
      attribute    = { bold = true },
      annotation   = { bold = true, italic = true },
      cmpkind      = {},
      uri          = {}
    },
    -- for reasons of contrast and readability, the light scheme shall have
    -- different attributes.
    light = {
      keyword      = { bold = true },   -- keywords
      conditional  = { bold = true },   -- special keywords (if, then...)
      types        = {},                -- types (classes, interfaces)
      storage      = { bold = true },   -- storage/visibility qualifiers (public, private...)
      struct       = { bold = true },
      class        = { bold = true },
      interface    = { bold = true },
      number       = { bold = true },
      func         = { bold = true },   -- functions
      method       = { },               -- class methods
      staticmethod = { italic = true },
      member       = { },               -- class member (=field)
      staticmember = { italic = true },
      operator     = { bold = true },   -- operators
      delim        = { bold = true },   -- delimiters
      brace        = { bold = true },   -- braces, brackets, parenthesis
      string       = {},
      bold         = { bold = true },
      italic       = { italic = true },
      bolditalic   = { bold = true, italic = true },
      attribute    = { bold = true },
      annotation   = { bold = true, italic = true },
      cmpkind      = {},
      uri          = {}
    },
  },
  attrib = {},
  -- the callback will be called by all functions that change the theme's configuration
  -- Callback must be of type("function") and receives one parameter:
  -- a string describing what has changed. Possible values are "variant", "strings",
  -- "desaturate" and "trans"
  -- The callback can use get_conf() to retrieve the current configuration and setup() to
  -- change it.
  callback = nil,
  custom_colors = {
    '#ff0000', '#00ff00', '#303080', '#ff00ff'
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
-- other means to change the conf table.
-- set() automatically calls it before setting any highlight groups.
local function configure()
  M.theme = M.basetheme[conf.scheme]
  conf.attrib = conf.baseattrib[conf.scheme]
  LuaLineColors = {
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
  if conf.scheme == "dark" then
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
          blue = { "#6060cf", 239 },
          purple = { "#904090", 241 },
          storage = { "#607560", 242 },
          class = { "#905070", 243 },
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
        yellow = { "#aaaa20", 231 },
        green = { "#10801f", 232 },
        special = {
          red = { "#cc2d4c", 203 },
          yellow = { "#cccc60", 231 },
          green = { "#10801f", 232 },
          blue = { "#6060cf", 239 },
          purple = { "#c030c0", 241 },
          storage = { "#507050", 242 },
          class = { "#804060", 243 },
          fg = { M.theme[conf.variant].fg , 1 },
        }
      }
    end
  elseif conf.scheme == "light" then
    if conf.desaturate == true then
      M.localtheme = {
        orange = (conf.dlevel == 1) and { "#3b2a1c", 215 } or { "#3b2a25", 215 },
        blue = { "#2020cc", 239 },
        purple = (conf.dlevel == 1) and { "#b070b0", 241 } or { "#a070a0", 241 },
        teal = (conf.dlevel == 1) and { "#105050", 238 } or { "#206060", 238 },
        brightteal = (conf.dlevel == 1) and { "#70a0c0", 238 } or { "#7090b0", 238 },
        darkpurple = (conf.dlevel == 1) and { "#705070", 240 } or { "#806a80", 240 },
        red = (conf.dlevel == 1) and { "#bb4d5c", 203 } or { "#ab5d6c", 203 },
        yellow = (conf.dlevel == 1) and { "#404000", 231 } or { "#404010", 231 },
        green = (conf.dlevel == 1) and { "#105010", 231 } or { "#205020", 231 },
        special = {
          red = { "#aa2020", 203 },
          yellow = { "#aaaa20", 231 },
          green = { "#309020", 232 },
          blue = { "#2020cc", 239 },
          purple = { "#aa20aa", 241 },
          storage = { "#607560", 242 },
          class = { "#700050", 243 },
          fg = { M.theme[conf.variant].fg , 1 },
        }
      }
    else
      M.localtheme = {
        orange = { "#c36630", 215 },
        blue = { "#2020cc", 239 },
        purple = { "#c030c0", 241 },
        teal = { "#005050", 238 },
        brightteal = { "#006060", 238 },
        darkpurple = { "#803090", 240 },
        red = { "#aa2020", 203 },
        yellow = { "#cccc60", 231 },
        green = { "#107000", 232 },
        special = {
          red = { "#aa2020", 203 },
          yellow = { "#cccc60", 231 },
          green = { "#107000", 232 },
          blue = { "#2020cc", 239 },
          purple = { "#c030c0", 241 },
          storage = { "#507050", 242 },
          class = { "#700050", 243 },
          fg = { M.theme[conf.variant].fg , 1 },
        }
      }
    end
  end

  M.localtheme.string = conf.theme_strings == "yellow" and M.localtheme.yellow or M.localtheme.green
  M.localtheme.special.c1 = { conf.custom_colors[1], 91 }
  M.localtheme.special.c2 = { conf.custom_colors[2], 92 }
  M.localtheme.special.c3 = { conf.custom_colors[3], 93 }
  M.localtheme.special.c4 = { conf.custom_colors[4], 94 }

  LuaLineColors.statuslinebg = M.theme[conf.variant].statuslinebg

  -- TODO: allow cokeline colors per theme variant
  M.localtheme.fg = { M.theme[conf.variant].fg, 1 }
  M.localtheme.darkbg = { M.theme[conf.variant].gutterbg, 237 }
  M.localtheme.bg = { M.theme[conf.variant].bg, 0 }
  M.localtheme.statuslinebg = { M.theme[conf.variant].statuslinebg, 208 }
  M.localtheme.accent = { M.theme["accent_color"], 209 }
  M.localtheme.accent_fg = { M.theme["accent_fg"], 210 }
  M.localtheme.tablinebg = { M.cokeline_colors["bg"], 214 }
  M.localtheme.fg_dim = { M.theme[conf.variant].fg_dim, 2 }

  if conf.scheme == "dark" then
    if conf.variant == "cold" or conf.variant == "deepblack" then
      M.localtheme.darkred = { "#601010", 249 }
      M.localtheme.pmenubg = { "#241a20", 156 }
      M.localtheme.black = { "#121215", 232 }
      M.localtheme.bg_dim = { "#222327", 232 }
      M.localtheme.bg0 = { "#2c2e34", 235 }
      M.localtheme.bg1 = { "#33353f", 236 }
      M.localtheme.bg2 = { "#363944", 236 }
      M.localtheme.bg3 = { "#3b3e48", 237 }
      M.localtheme.bg4 = { "#414550", 237 }
    else
      M.localtheme.darkred = { "#601010", 249 }
      M.localtheme.pmenubg = { "#241a20", 156 }
      M.localtheme.black = { "#151212", 232 }
      M.localtheme.bg_dim = { "#242020", 232 }
      M.localtheme.bg0 = { "#302c2e", 235 }
      M.localtheme.bg1 = { "#322a2a", 236 }
      M.localtheme.bg2 = { "#403936", 236 }
      M.localtheme.bg3 = { "#483e3b", 237 }
      M.localtheme.bg4 = { "#504531", 237 }
    end
  elseif conf.scheme == "light" then
    if conf.variant == "cold" or conf.variant == "deepblack" then
      M.localtheme.darkred = { "#601010", 249 }
      M.localtheme.pmenubg = { "#241a20", 156 }
      M.localtheme.black = { "#121215", 232 }
      M.localtheme.bg_dim = { "#222327", 232 }
      M.localtheme.bg0 = { "#b0b0b0", 235 }
      M.localtheme.bg1 = { "#a0a0a0", 236 }
      M.localtheme.bg2 = { "#363944", 236 }
      M.localtheme.bg3 = { "#3b3e48", 237 }
      M.localtheme.bg4 = { "#b0b0b0", 237 }
    else
      M.localtheme.darkred = { "#601010", 249 }
      M.localtheme.pmenubg = { "#241a20", 156 }
      M.localtheme.black = { "#151212", 232 }
      M.localtheme.bg_dim = { "#242020", 232 }
      M.localtheme.bg0 = { "#b0b0b0", 235 }
      M.localtheme.bg1 = { "#a0a0a0", 236 }
      M.localtheme.bg2 = { "#403936", 236 }
      M.localtheme.bg3 = { "#483e3b", 237 }
      M.localtheme.bg4 = { "#b0b0b0", 237 }
    end
  end

  M.cokeline_colors = {
    --bg = LuaLineColors.statuslinebg,
    bg = M.theme[conf.variant].statuslinebg,
    --focus_bg = M.theme.selbg,
    focus_bg = M.theme.accent_color,
    fg = LuaLineColors.gray4,
    focus_fg = M.theme.accent_fg,
  }

  M.palette = basepalette[conf.scheme]
  M.palette.neotreebg = { M.theme[conf.variant].treebg, 232 }
  M.palette.selbg = { M.theme["selbg"], 234 }
end

-- set all hl groups
local function set_all()
  -- basic highlights
  M.hl("Braces", M.localtheme.special[conf.special.braces], M.palette.none, conf.attrib.brace)
  M.hl("Operator", M.localtheme.special[conf.special.operator], M.palette.none, conf.attrib.operator)
  M.hl("PunctDelim", M.localtheme.special[conf.special.delim], M.palette.none, conf.attrib.delim)
  M.hl("PunctSpecial", M.localtheme.special[conf.special.delim], M.palette.none, conf.attrib.bold)
  M.hl_with_defaults("ScrollView", M.localtheme.teal, M.localtheme.special.c3)
  M.hl_with_defaults("Normal", M.localtheme.fg, M.localtheme.bg)
  M.hl_with_defaults("Accent", M.localtheme.black, M.localtheme.accent)
  M.hl_with_defaults("Terminal", M.localtheme.fg, M.palette.neotreebg)
  M.hl_with_defaults("EndOfBuffer", M.localtheme.bg4, M.palette.none)
  M.hl_with_defaults("Folded", M.localtheme.fg, M.palette.diff_blue)
  M.hl_with_defaults("ToolbarLine", M.localtheme.fg, M.palette.none)
  M.hl_with_defaults("FoldColumn", M.localtheme.bg4, M.palette.none)
  M.hl_with_defaults("SignColumn", M.localtheme.fg, M.palette.none)
  M.hl_with_defaults("IncSearch", M.localtheme.yellow, M.localtheme.darkred)
  M.hl_with_defaults("Search", M.localtheme.black, M.palette.darkyellow)
  M.hl_with_defaults("ColorColumn", M.palette.none, M.localtheme.bg1)
  M.hl_with_defaults("Conceal", M.palette.grey_dim, M.palette.none)
  M.hl_with_defaults("Cursor", M.localtheme.fg, M.localtheme.fg)
  M.hl_with_defaults("nCursor", M.localtheme.fg, M.localtheme.fg)
  M.hl_with_defaults("iCursor", M.localtheme.yellow, M.localtheme.yellow)
  M.hl_with_defaults("vCursor", M.localtheme.red, M.localtheme.red)
  M.hl_with_defaults("LineNr", M.palette.grey_dim, M.palette.none)

  M.link("CursorIM", "iCursor")

  M.hl("FocusedSymbol", M.localtheme.yellow, M.palette.none, conf.attrib.bold)

  if diff then
    M.hl("CursorLine", M.palette.none, M.palette.none, { underline = true })
    M.hl("CursorColumn", M.palette.none, M.palette.none, conf.attrib.bold)
  else
    M.hl_with_defaults("CursorLine", M.palette.none, M.localtheme.bg0)
    M.hl_with_defaults("CursorColumn", M.palette.none, M.localtheme.bg1)
  end

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
  M.hl_with_defaults("FloatBorder", M.localtheme.accent, M.localtheme.bg_dim)
  M.hl_with_defaults("FloatTitle", M.localtheme.accent_fg, M.localtheme.bg_dim)
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
  M.hl_with_defaults("TabLineSel", M.localtheme.accent_fg, M.localtheme.accent)
  M.hl_with_defaults("VertSplit", M.localtheme.statuslinebg, M.palette.neotreebg)

  M.link("MsgArea", "StatusLine")
  M.link("WinSeparator", "VertSplit")

  M.hl_with_defaults("Visual", M.palette.none, M.palette.selbg)
  M.hl("VisualNOS", M.palette.none, M.localtheme.bg3, { underline = true })
  M.hl_with_defaults("QuickFixLine", M.localtheme.blue, M.palette.neotreebg)
  M.hl_with_defaults("Debug", M.localtheme.yellow, M.palette.none)
  M.hl_with_defaults("debugPC", M.localtheme.bg0, M.localtheme.green)
  M.hl_with_defaults("debugBreakpoint", M.localtheme.bg0, M.localtheme.red)
  M.hl_with_defaults("ToolbarButton", M.localtheme.bg0, M.palette.bg_blue)
  M.hl_with_defaults("Substitute", M.localtheme.bg0, M.localtheme.yellow)

  M.hl("Type", M.localtheme.darkpurple, M.palette.none, conf.attrib.types)
  M.hl("Structure", M.localtheme.darkpurple, M.palette.none, conf.attrib.struct)
  M.hl("Class", M.localtheme.special.class, M.palette.none, conf.attrib.class)
  M.hl("Interface", M.localtheme.purple, M.palette.none, conf.attrib.interface)
  M.hl("StorageClass", M.localtheme.special.storage, M.palette.none, conf.attrib.storage)
  M.hl_with_defaults("Identifier", M.localtheme.orange, M.palette.none)
  M.hl_with_defaults("Constant", M.palette.purple, M.palette.none)
  M.hl("PreProc", M.palette.darkyellow, M.palette.none, conf.attrib.bold)
  M.hl("PreCondit", M.palette.darkyellow, M.palette.none, conf.attrib.bold)
  M.link("Include", "OliveBold")
  M.link("Boolean", "DeepRedBold")
  M.hl("Keyword", M.localtheme.blue, M.palette.none, conf.attrib.keyword)
  M.hl("Conditional", M.palette.darkyellow, M.palette.none, conf.attrib.conditional)
  M.hl_with_defaults("Define", M.localtheme.red, M.palette.none)
  M.hl("Typedef", M.localtheme.red, M.palette.none, conf.attrib.types)
  M.hl(
    "Exception",
    conf.theme_strings == "yellow" and M.localtheme.green or M.localtheme.yellow,
    M.palette.none,
    conf.attrib.keyword
  )
  M.hl("Repeat", M.localtheme.blue, M.palette.none, conf.attrib.keyword)
  M.hl("Statement", M.localtheme.blue, M.palette.none, conf.attrib.keyword)
  M.hl_with_defaults("Macro", M.palette.purple, M.palette.none)
  M.hl_with_defaults("Error", M.localtheme.red, M.palette.none)
  M.hl_with_defaults("Label", M.palette.purple, M.palette.none)
  M.hl("Special", M.localtheme.special.blue, M.palette.none, conf.attrib.bold)
  M.hl_with_defaults("SpecialChar", M.palette.purple, M.palette.none)
  M.hl("String", M.localtheme.string, M.palette.none, conf.attrib.string)
  M.hl_with_defaults("Character", M.localtheme.yellow, M.palette.none)
  M.hl("Number", M.localtheme.special.green, M.palette.none, conf.attrib.number)
  M.hl_with_defaults("Float", M.palette.purple, M.palette.none)
  M.hl("Function", M.localtheme.teal, M.palette.none, conf.attrib.func)
  M.hl("Method", M.localtheme.brightteal, M.palette.none, conf.attrib.method)
  M.hl("StaticMethod", M.localtheme.brightteal, M.palette.none, conf.attrib.staticmethod)
  M.hl("Member", M.localtheme.orange, M.palette.none, conf.attrib.member)
  M.hl("StaticMember", M.localtheme.orange, M.palette.none, conf.attrib.staticmember)
  M.hl("Builtin", M.palette.brown, M.palette.none, conf.attrib.bold)

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
  M.hl_with_defaults("FgDim", M.localtheme.fg_dim, M.palette.none)
  M.hl("FgDimBold", M.localtheme.fg_dim, M.palette.none, conf.attrib.bold)
  M.hl("FgDimBoldItalic", M.localtheme.fg_dim, M.palette.none, conf.attrib.bolditalic)
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
  M.hl("ErrorText", M.palette.none, M.palette.none, { underline = true, sp = M.localtheme.red[1] })
  M.hl("WarningText", M.palette.none, M.palette.none, { underline = true, sp = M.localtheme.yellow[1] })
  M.hl("InfoText", M.localtheme.blue, M.palette.none, { italic = true })
  M.hl("HintText", M.localtheme.green, M.palette.none, { italic = true })
  M.link("VirtualTextWarning", "Grey")
  M.link("VirtualTextError", "Grey")
  M.link("VirtualTextInfo", "Grey")
  M.link("VirtualTextHint", "Grey")
  M.hl_with_defaults("ErrorFloat", M.localtheme.red, M.palette.none)
  M.hl_with_defaults("WarningFloat", M.localtheme.yellow, M.palette.none)
  M.hl_with_defaults("InfoFloat", M.localtheme.blue, M.palette.none)
  M.hl_with_defaults("HintFloat", M.localtheme.green, M.palette.none)

  M.hl("Strong", M.palette.none, M.palette.none, conf.attrib.bold)
  M.hl("Emphasis", M.palette.none, M.palette.none, conf.attrib.italic)
  M.hl("URI", M.localtheme.special.blue, M.palette.none, conf.attrib.uri)

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

  M.link("@annotation", "Annotation")
  M.link("@attribute", "Attribute")
  M.link("@boolean", "Boolean")
  M.link("@character", "Yellow")
  M.link("@comment", "Comment")
  M.link("@conditional", "Conditional")
  M.link("@constant", "Constant")
  M.link("@constant.builtin", "Builtin")
  M.link("@constant.macro", "OrangeItalic")
  M.link("@constructor", "Yellow")
  M.link("@exception", "Exception")
  M.link("@field", "Member")
  M.link("@float", "Number")
  M.link("@function", "Teal")
  M.link("@function.builtin", "Builtin")
  M.link("@function.macro", "TealBold")
  M.link("@include", "Include")
  M.link("@keyword", "Keyword")
  M.link("@keyword.function", "DeepRedBold")
  M.link("@keyword.operator", "Operator")
  M.link("@keyword.conditional", "Conditional")
  M.link("@keyword.repeat", "Conditional")
  M.link("@keyword.storage", "StorageClass")
  M.link("@label", "Red")
  M.link("@method", "Method")
  M.link("@namespace", "DarkPurpleBold")
  M.link("@none", "Fg")
  M.link("@number", "Number")
  M.link("@operator", "Operator")
  M.link("@parameter", "FgDimBoldItalic")
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
  M.link("@text.emphasis.latex", "Emphasis")

  -- semantic lsp types
  M.link("@lsp.type.namespace_name", "Type")
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
  M.link("@lsp.mod.defaultLibrary", "Function")

  M.link("FloatermBorder", "Grey")
  M.link("BookmarkSign", "BlueSign")
  M.link("BookmarkAnnotationSign", "GreenSign")
  M.link("BookmarkLine", "DiffChange")
  M.link("BookmarkAnnotationLine", "DiffAdd")

  -- lukas-reineke/indent-blankline.nvim
  M.hl("IndentBlanklineContextChar", M.localtheme.darkpurple, M.palette.none, { nocombine = true })
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
  M.hl_with_defaults("NeoTreeNormalNC", M.localtheme.fg_dim, M.palette.neotreebg)
  M.hl_with_defaults("NeoTreeNormal", M.localtheme.fg, M.palette.neotreebg)
  M.hl_with_defaults("NeoTreeFloatBorder", M.palette.grey_dim, M.palette.neotreebg)
  M.hl("NeoTreeFileNameOpened", M.localtheme.blue, M.palette.neotreebg, conf.attrib.italic)
  M.hl_with_defaults("SymbolsOutlineConnector", M.palette.grey_dim, M.palette.none)
  M.hl_with_defaults("TreeCursorLine", M.palette.none, M.localtheme.special.c3)
  M.hl_with_defaults("NotifierTitle", M.localtheme.yellow, M.palette.none)
  M.link("NotifierContent", "NeoTreeNormalNC")

  -- Treesitter stuff
  M.hl_with_defaults("TreesitterContext", M.palette.none, M.localtheme.bg)
  --M.hl("TreesitterContextBottom", M.palette.none, M.localtheme.bg, { underline=true, sp=M.palette.purple[1] })
  M.link("TreesitterContextSeparator", "Type")
  M.link("OutlineGuides", "SymbolsOutlineConnector")
  M.link("OutlineFoldMarker", "SymbolsOutlineConnector")
  M.link("NeoTreeCursorLine", "TreeCursorLine")
  M.link("AerialGuide", "SymbolsOutlineConnector")

  -- WinBar
  M.hl_with_defaults("WinBarFilename", M.localtheme.fg, M.localtheme.accent)                                   -- Filename (right hand)
  M.hl("WinBarContext", M.localtheme.accent, M.palette.none, { underline = true, sp = M.localtheme.accent[1] }) -- LSP context (left hand)
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
    require("colors.darkmatter.plugins." .. v).set()
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
    end
    if conf.sync_alacrittybg then
      vim.fn.jobstart("alacritty msg config \"colors.primary.background='" .. M.theme[conf.variant].kittybg .. "'\"")
    end
  end
  for _, v in ipairs(conf.plugins.post) do
    require("colors.darkmatter.plugins." .. v)
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

  -- TODO: sanitizing
  if conf.scheme ~= "dark" and conf.scheme ~= "light" then
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
    vim.api.nvim_set_hl(0, "Normal", { bg = M.theme[variant].bg, fg = "fg" })
    vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = M.theme[variant].treebg, fg = "fg" })
    vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = M.theme[variant].treebg, fg = "fg" })
    vim.cmd("hi VertSplit guibg=" .. M.theme[variant].treebg)
    vim.cmd("hi LineNr guibg=" .. M.theme[variant].gutterbg)
    vim.cmd("hi FoldColumn guibg=" .. M.theme[variant].gutterbg)
    vim.cmd("hi SignColumn guibg=" .. M.theme[variant].gutterbg)
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
