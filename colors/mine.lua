-------------------------------------------------------------------------------
--Name:         my_Sonokai
--
--BASED ON original work by:
--Name:         Sonokai
--Description:  High Contrast & Vivid Color Scheme based on Monokai Pro
--Author:       Sainnhepark <i@sainnhe.dev>
--Website:      https://github.com/sainnhe/sonokai/
--License:      MIT
-------------------------------------------------------------------------------
--things no longer used because of LSP.
--desaturate means that some colors are less intense and less vivid but retain their basic color
--tint, resulting in a more "pastel" look with less contrast. the basic color scheme is unaffected
--by this setting.
--
local set_hl = vim.api.nvim_set_hl
local palette = {}
local theme = {}

local function simple_hl(hl, fg, bg)
  set_hl(0, hl, { fg = fg[1], ctermfg = fg[2], bg = bg[1], ctermbg = bg[2] })
end

if vim.g.theme_desaturate == true then
  theme = {
    orange        = {'#ab6a6c', 215},
    string        = vim.g.theme.string == "yellow" and {'#9a9a60', 231} or {'#40804f', 231},
    blue          = {'#5a6acf', 239},
    purple        = {'#b070b0', 241},
    teal          = {'#508080', 238},
    brightteal    = {'#70a0c0', 238},
    darkpurple    = {'#705070', 240},
    red           = {'#bb4d5c', 203}
  }
else
  theme = {
    string        = vim..theme.string == "yellow" and {'#cccc60', 231} or {'#10801f', 231},
    orange        = {'#c36630', 215},
    blue          = {'#4a4adf', 239},
    purple        = {'#c030c0', 241},
    teal          = {'#108080', 238},
    brightteal    = {'#30a0c0', 238},
    darkpurple    = {'#803090', 240},
    red           = {'#cc2d4c', 203}
  }
end

if vim.g.theme_variant == 'cold' then
  theme.darkbg      = {'#101013', 237}
  theme.darkred     = {'#601010', 249}
  theme.darkestred  = {'#161616', 249}
  theme.darkestblue = {'#10101a', 247}
  theme.bg          = {vim.g.theme['cold'].bg, 0}
  theme.statuslinebg= {vim.g.statuslinebg, 208}
  theme.palette.fg  = {'#a2a0ac', 1}
  theme.palette.grey= {'#707070', 2}
  theme.pmenubg     = {'#241a20', 156}
  theme.accent      = {vim.g.theme['accent_color'], 209}
  theme.accent_fg   = {vim.g.theme['accent_fg'], 210}
  theme.tablinebg   = {vim.g.cokeline_colors['bg'], 214}
  theme.contextbg   = {vim.g.theme['cold'].contextbg, 215}
else
  theme.darkbg      = {'#131010', 237}
  theme.darkred     = {'#601010', 249}
  theme.darkestred  = {'#161616', 249}
  theme.darkestblue = {'#10101a', 247}
  theme.bg          = {vim.g.theme['warm'].bg, 0}
  theme.statuslinebg= {vim.g.statuslinebg, 208}
  theme.palette.fg  = {'#aaa0a5', 1}
  theme.palette.grey= {'#707070', 2}
  theme.pmenubg     = {'#241a20', 156}
  theme.accent      = {vim.g.theme['accent_color'], 209}
  theme.accent_fg   = {vim.g.theme['accent_fg'], 210}
  theme.tablinebg   = {vim.g.cokeline_colors['bg'], 214}
  theme.contextbg   = {vim.g.theme['warm'].contextbg, 215}
end

if vim.g.theme_variant == 'cold' then
  palette = {
    black      =  {'#121215',   232},
    bg_dim     =  {'#222327',   232},
    bg0        =  {'#2c2e34',   235},
    bg1        =  {'#33353f',   236},
    bg2        =  {'#363944',   236},
    bg3        =  {'#3b3e48',   237},
    bg4        =  {'#414550',   237},
    bg_red     =  {'#ff6077',   203},
    diff_red   =  {'#55393d',   52 },
    bg_green   =  {'#a7df78',   107},
    diff_green =  {'#697664',   22 },
    bg_blue    =  {'#85d3f2',   110},
    diff_blue  =  {'#354157',   17 },
    diff_yellow=  {'#4e432f',   54 },
    fg         =  {'#d2c2c0',   250},
    fg_dim     =  {'#959290',   251},
    red        =  {theme.red[1], theme.red[2] },
    palered    =  {'#8b2d3c',   203},
    orange     =  {theme.orange[1], theme.orange[2] },
    yellow     =  {'#e7c664',   179},
    darkyellow =  {'#a78624',   180},
    green      =  {'#9ed072',   107},
    blue       =  {'#469c70',   110},
    purple     =  {'#b39df3',   176},
    grey       =  {'#7f8490',   246},
    grey_dim   =  {'#595f6f',   240},
    neotreebg  =  {vim.g.theme['cold'].treebg,   '232'},
    selfg      =  {'#cccc20',   '233'},
    selbg      =  {vim.g.theme['selbg'],   '234'},
    none       =  {'NONE',      'NONE'}
  }
else
  --the "warm" variant features a slight red-ish tint in the background colors
  --all other colors are identical to the cold variant.
  palette = {
    black       = {'#151212',   232},
    bg_dim      = {'#242020',   232},
    bg0         = {'#302c2e',   235},
    bg1         = {'#322a2a',   236},
    bg2         = {'#403936',   236},
    bg3         = {'#483e3b',   237},
    bg4         = {'#504531',   237},
    bg_red      = {'#ff6077',   203},
    diff_red    = {'#55393d',   52,},
    bg_green    = {'#a7df78',   107},
    diff_green  = {'#697664',   22 },
    bg_blue     = {'#85d3f2',   110},
    diff_blue   = {'#354157',   17 },
    diff_yellow = {'#4e432f',   54 },
    fg          = {'#d2c2c0',   250},
    fg_dim      = {'#959290',   251},
    red        =  {theme.red[1], theme.red[2] },
    palered     = {'#8b2d3c',   203},
    orange     =  {theme.orange[1], theme.orange[2] },
    yellow      = {'#e7c664',   179},
    darkyellow  = {'#a78624',   180},
    green       = {'#9ed072',   107},
    blue        = {'#469c70',   110},
    purple      = {'#b39df3',   176},
    grey        = {'#7f8490',   246},
    grey_dim    = {'#595f6f',   240},
    neotreebg   = {vim.g.theme['warm'].treebg,   232},
    selfg       = {'#cccc20',   '233'},
    selbg       = {vim.g.theme['selbg'],   234},
    none        = {'NONE',      0  }
  }
end

simple_hl("Braces", palette.red, palette.none)
simple_hl('ScrollView', theme.teal, theme.blue)
simple_hl('Normal', s:palette.fg, s:bg)
simple_hl('Accent', s:palette.black, s:accent)
simple_hl('Terminal', s:palette.fg, s:palette.neotreebg)
simple_hl('EndOfBuffer', s:palette.bg4, s:palette.none)
simple_hl('Folded', s:palette.fg, s:palette.diff_blue)
simple_hl('ToolbarLine', s:palette.fg, s:palette.none)
simple_hl('FoldColumn', s:palette.bg4, s:darkbg)
simple_hl('SignColumn', s:palette.fg, s:darkbg)
simple_hl('IncSearch', s:palette.yellow, s:darkred)
simple_hl('Search', s:palette.black, s:palette.diff_green)
simple_hl('ColorColumn', s:palette.none, s:palette.bg1)
simple_hl('Conceal', s:palette.grey_dim, s:palette.none)
simple_hl('Cursor', s:palette.fg, s:palette.fg)
simple_hl('nCursor', s:palette.fg, s:palette.fg)
simple_hl('iCursor', s:palette.yellow, s:palette.yellow)
simple_hl('vCursor', s:palette.red, s:palette.red)
print(vim.inspect(theme))
print(vim.inspect(palette))
