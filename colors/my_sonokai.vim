" -----------------------------------------------------------------------------
" Name:         my_Sonokai
"
" BASED ON original work by:
" Name:         Sonokai
" Description:  High Contrast & Vivid Color Scheme based on Monokai Pro
" Author:       Sainnhepark <i@sainnhe.dev>
" Website:      https://github.com/sainnhe/sonokai/
" License:      MIT
" -----------------------------------------------------------------------------
" TODO: convert this to lua at some point, allow color overrides in the config, clean up
" things no longer used because of LSP.

" desaturate means that some colors are less intense and less vivid but retain their basic color
" tint, resulting in a more "pastel" look with less contrast. the basic color scheme is unaffected
" by this setting.
if g:theme_desaturate == v:true
  let s:orange = ['#ab6a6c', 215]
  if g:theme['string'] == 'yellow'
    let s:string = ['#9a9a60', 231]
  else
    let s:string = ['#40804f', 231]
  endif
  let s:blue =          ['#5a6acf', 239]
  let s:purple =        ['#b070b0', 241]
  let s:teal =          ['#508080', 238]
  let s:brightteal =    ['#70a0c0', 238]
  let s:darkpurple =    ['#705070', 240]
  let s:red =           ['#bb4d5c', 203]
else
  if g:theme['string'] == 'yellow'
    let s:string = ['#cccc60', 231]
  else
    let s:string = ['#10801f', 231]
  endif
  let s:orange =        ['#c36630', 215]
  let s:blue =          ['#4a4adf', 239]
  let s:purple =        ['#c030c0', 241]
  let s:teal =          ['#108080', 238]
  let s:brightteal =    ['#30a0c0', 238]
  let s:darkpurple =    ['#803090', 240]
  let s:red =           ['#cc2d4c', 203]
endif

" The default variant is "warm"
" cold is slightly blue-ish tinted in the backgrounds.
"
" about language support:
" for most languages, this colorscheme relies on treesitter highlighting.
if g:theme_variant == 'cold'
  let palette = {
        \ 'black':      ['#121215',   '232'],
        \ 'bg_dim':     ['#222327',   '232'],
        \ 'bg0':        ['#2c2e34',   '235'],
        \ 'bg1':        ['#33353f',   '236'],
        \ 'bg2':        ['#363944',   '236'],
        \ 'bg3':        ['#3b3e48',   '237'],
        \ 'bg4':        ['#414550',   '237'],
        \ 'bg_red':     ['#ff6077',   '203'],
        \ 'diff_red':   ['#55393d',   '52'],
        \ 'bg_green':   ['#a7df78',   '107'],
        \ 'diff_green': ['#697664',   '22'],
        \ 'bg_blue':    ['#85d3f2',   '110'],
        \ 'diff_blue':  ['#354157',   '17'],
        \ 'diff_yellow':['#4e432f',   '54'],
        \ 'fg':         ['#d2c2c0',   '250'],
        \ 'fg_dim':     ['#959290',   '251'],
        \ 'red':        s:red,
        \ 'palered':    ['#8b2d3c',   '203'],
        \ 'orange':     s:orange,
        \ 'yellow':     ['#e7c664',   '179'],
        \ 'darkyellow': ['#a78624',   '180'],
        \ 'green':      ['#9ed072',   '107'],
        \ 'blue':       ['#469c70',   '110'],
        \ 'purple':     ['#b39df3',   '176'],
        \ 'grey':       ['#7f8490',   '246'],
        \ 'grey_dim':   ['#595f6f',   '240'],
        \ 'neotreebg':  [g:theme['cold'].treebg,   '232'],
        \ 'selfg':      ['#cccc20',   '233'],
        \ 'selbg':      [g:theme['selbg'],   '234'],
        \ 'none':       ['NONE',      'NONE']
        \ }
else
  " the "warm" variant features a slight red-ish tint in the background colors
  " all other colors are identical to the cold variant.
  let palette = {
        \ 'black':      ['#151212',   '232'],
        \ 'bg_dim':     ['#242020',   '232'],
        \ 'bg0':        ['#302c2e',   '235'],
        \ 'bg1':        ['#322a2a',   '236'],
        \ 'bg2':        ['#403936',   '236'],
        \ 'bg3':        ['#483e3b',   '237'],
        \ 'bg4':        ['#504531',   '237'],
        \ 'bg_red':     ['#ff6077',   '203'],
        \ 'diff_red':   ['#55393d',   '52'],
        \ 'bg_green':   ['#a7df78',   '107'],
        \ 'diff_green': ['#697664',   '22'],
        \ 'bg_blue':    ['#85d3f2',   '110'],
        \ 'diff_blue':  ['#354157',   '17'],
        \ 'diff_yellow':['#4e432f',   '54'],
        \ 'fg':         ['#d2c2c0',   '250'],
        \ 'fg_dim':     ['#959290',   '251'],
        \ 'red':        s:red,
        \ 'palered':    ['#8b2d3c',   '203'],
        \ 'orange':     s:orange,
        \ 'yellow':     ['#e7c664',   '179'],
        \ 'darkyellow': ['#a78624',   '180'],
        \ 'green':      ['#9ed072',   '107'],
        \ 'blue':       ['#469c70',   '110'],
        \ 'purple':     ['#b39df3',   '176'],
        \ 'grey':       ['#7f8490',   '246'],
        \ 'grey_dim':   ['#595f6f',   '240'],
        \ 'neotreebg':  [g:theme['warm'].treebg,   '232'],
        \ 'selfg':      ['#cccc20',   '233'],
        \ 'selbg':      [g:theme['selbg'],   '234'],
        \ 'none':       ['NONE',      'NONE']
        \ }
endif

function! my_sonokai#highlight(group, fg, bg, ...)
  execute 'highlight' a:group
        \ 'guifg=' . a:fg[0]
        \ 'guibg=' . a:bg[0]
        \ 'ctermfg=' . a:fg[1]
        \ 'ctermbg=' . a:bg[1]
        \ 'gui=' . (a:0 >= 1 ?
          \ a:1 :
          \ 'NONE')
        \ 'cterm=' . (a:0 >= 1 ?
          \ a:1 :
          \ 'NONE')
        \ 'guisp=' . (a:0 >= 2 ?
          \ a:2[0] :
          \ 'NONE')
endfunction

" Initialization:
let s:palette = palette
let s:path = expand('<sfile>:p') " the path of this script
let s:last_modified = '2022-12-23T08:46:17+0100'
let g:sonokai_loaded_file_types = []
if g:theme_variant == 'cold'
  let s:darkbg = ['#101013', 237]
  let s:darkred = ['#601010', 249]
  let s:darkestred = ['#161616', 249]
  let s:darkestblue = ['#10101a', 247]
  let s:bg = [g:theme['cold'].bg, 0]
  let s:statuslinebg = [ g:statuslinebg, 208 ]
  let s:palette.fg = [ '#a2a0ac', 1 ]
  let s:palette.grey = [ '#707070', 2 ]
  let s:pmenubg = [ '#241a20', 156 ]
  let s:accent = [ g:theme['accent_color'], 209 ]
  let s:accent_fg = [ g:theme['accent_fg'], 210 ]
  let s:tablinebg = [ g:cokeline_colors['bg'], 214]
  let s:contextbg = [ g:theme['cold'].contextbg, 215]
else
  let s:darkbg = ['#131010', 237]
  let s:darkred = ['#601010', 249]
  let s:darkestred = ['#161616', 249]
  let s:darkestblue = ['#10101a', 247]
  let s:bg = [g:theme['warm'].bg, 0]
  let s:statuslinebg = [ g:statuslinebg, 208 ]
  let s:palette.fg = [ '#aaa0a5', 1 ]
  let s:palette.grey = [ '#707070', 2 ]
  let s:pmenubg = [ '#241a20', 156 ]
  let s:accent = [ g:theme['accent_color'], 209 ]
  let s:accent_fg = [ g:theme['accent_fg'], 210 ]
  let s:tablinebg = [ g:cokeline_colors['bg'], 214]
  let s:contextbg = [ g:theme['warm'].contextbg, 215]
endif

let g:colors_name = 'my_sonokai'

call my_sonokai#highlight("Braces", s:palette.red, s:palette.none)
call my_sonokai#highlight('ScrollView', s:teal, s:blue)

call my_sonokai#highlight('Normal', s:palette.fg, s:bg)
call my_sonokai#highlight('Accent', s:palette.black, s:accent)

call my_sonokai#highlight('Terminal', s:palette.fg, s:palette.neotreebg)
call my_sonokai#highlight('EndOfBuffer', s:palette.bg4, s:palette.none)
call my_sonokai#highlight('Folded', s:palette.fg, s:palette.diff_blue)
call my_sonokai#highlight('ToolbarLine', s:palette.fg, s:palette.none)
call my_sonokai#highlight('FoldColumn', s:palette.bg4, s:darkbg)
call my_sonokai#highlight('SignColumn', s:palette.fg, s:darkbg)
call my_sonokai#highlight('IncSearch', s:palette.yellow, s:darkred)
call my_sonokai#highlight('Search', s:palette.black, s:palette.diff_green)
call my_sonokai#highlight('ColorColumn', s:palette.none, s:palette.bg1)
call my_sonokai#highlight('Conceal', s:palette.grey_dim, s:palette.none)
call my_sonokai#highlight('Cursor', s:palette.fg, s:palette.fg)
call my_sonokai#highlight('nCursor', s:palette.fg, s:palette.fg)
call my_sonokai#highlight('iCursor', s:palette.yellow, s:palette.yellow)
call my_sonokai#highlight('vCursor', s:palette.red, s:palette.red)

highlight! link CursorIM iCursor
call my_sonokai#highlight('FocusedSymbol', s:palette.yellow, s:palette.none, 'bold')
if &diff
  call my_sonokai#highlight('CursorLine', s:palette.none, s:palette.none, 'underline')
  call my_sonokai#highlight('CursorColumn', s:palette.none, s:palette.none, 'bold')
else
  call my_sonokai#highlight('CursorLine', s:palette.none, s:palette.bg0)
  call my_sonokai#highlight('CursorColumn', s:palette.none, s:palette.bg1)
endif
call my_sonokai#highlight('LineNr', s:palette.grey_dim, s:darkbg)
if &diff
  call my_sonokai#highlight('CursorLineNr', s:palette.yellow, s:palette.none, 'underline')
else
  call my_sonokai#highlight('CursorLineNr', s:palette.yellow, s:palette.none)
endif
call my_sonokai#highlight('DiffAdd', s:palette.none, s:palette.diff_green)
call my_sonokai#highlight('DiffChange', s:palette.none, s:palette.diff_blue)
call my_sonokai#highlight('DiffDelete', s:palette.none, s:palette.diff_red)
call my_sonokai#highlight('DiffText', s:palette.bg0, s:palette.blue)
call my_sonokai#highlight('Directory', s:blue, s:palette.none, 'bold')
call my_sonokai#highlight('ErrorMsg', s:palette.red, s:palette.none, 'bold,underline')
call my_sonokai#highlight('WarningMsg', s:palette.yellow, s:palette.none, 'bold')
call my_sonokai#highlight('ModeMsg', s:palette.fg, s:palette.none, 'bold')
call my_sonokai#highlight('MoreMsg', s:palette.blue, s:palette.none, 'bold')
call my_sonokai#highlight('MatchParen', s:palette.yellow, s:darkred)
call my_sonokai#highlight('NonText', s:palette.bg4, s:palette.none)
call my_sonokai#highlight('Whitespace', s:palette.green, s:palette.none)
call my_sonokai#highlight('ExtraWhitespace', s:palette.green, s:palette.none)
call my_sonokai#highlight('SpecialKey', s:palette.green, s:palette.none)
call my_sonokai#highlight('Pmenu', s:palette.fg, s:pmenubg)
call my_sonokai#highlight('PmenuSbar', s:palette.none, s:palette.bg2)
call my_sonokai#highlight('PmenuSel', s:palette.yellow, s:blue)
highlight! link WildMenu PmenuSel
call my_sonokai#highlight('PmenuThumb', s:palette.none, s:palette.grey)
call my_sonokai#highlight('NormalFloat', s:palette.fg, s:palette.bg_dim)
call my_sonokai#highlight('FloatBorder', s:palette.grey_dim, s:palette.bg_dim)
call my_sonokai#highlight('Question', s:palette.yellow, s:palette.none)
call my_sonokai#highlight('SpellBad', s:palette.none, s:palette.none, 'undercurl', s:palette.red)
call my_sonokai#highlight('SpellCap', s:palette.none, s:palette.none, 'undercurl', s:palette.yellow)
call my_sonokai#highlight('SpellLocal', s:palette.none, s:palette.none, 'undercurl', s:palette.blue)
call my_sonokai#highlight('SpellRare', s:palette.none, s:palette.none, 'undercurl', s:palette.purple)
call my_sonokai#highlight('StatusLine', s:palette.fg, s:statuslinebg)
call my_sonokai#highlight('StatusLineTerm', s:palette.fg, s:palette.none)
call my_sonokai#highlight('StatusLineNC', s:palette.grey, s:statuslinebg)
call my_sonokai#highlight('StatusLineTermNC', s:palette.grey, s:palette.none)
call my_sonokai#highlight('TabLine', s:palette.fg, s:statuslinebg)
call my_sonokai#highlight('TabLineFill', s:palette.grey, s:tablinebg)
call my_sonokai#highlight('TabLineSel', s:palette.bg0, s:palette.bg_red)
call my_sonokai#highlight('VertSplit', s:statuslinebg, s:palette.neotreebg)
highlight! link WinSeparator VertSplit

call my_sonokai#highlight('Visual', s:palette.selfg, s:palette.selbg)
call my_sonokai#highlight('VisualNOS', s:palette.none, s:palette.bg3, 'underline')
call my_sonokai#highlight('QuickFixLine', s:palette.blue, s:palette.none, 'bold')
call my_sonokai#highlight('Debug', s:palette.yellow, s:palette.none)
call my_sonokai#highlight('debugPC', s:palette.bg0, s:palette.green)
call my_sonokai#highlight('debugBreakpoint', s:palette.bg0, s:palette.red)
call my_sonokai#highlight('ToolbarButton', s:palette.bg0, s:palette.bg_blue)
call my_sonokai#highlight('Substitute', s:palette.bg0, s:palette.yellow)
highlight! link DiagnosticFloatingError ErrorFloat
highlight! link DiagnosticFloatingWarn WarningFloat
highlight! link DiagnosticFloatingInfo InfoFloat
highlight! link DiagnosticFloatingHint HintFloat
highlight! link DiagnosticError ErrorText
highlight! link DiagnosticWarn WarningText
highlight! link DiagnosticInfo InfoText
highlight! link DiagnosticHint HintText
highlight! link DiagnosticVirtualTextError VirtualTextError
highlight! link DiagnosticVirtualTextWarn VirtualTextWarning
highlight! link DiagnosticVirtualTextInfo VirtualTextInfo
highlight! link DiagnosticVirtualTextHint VirtualTextHint
highlight! link DiagnosticUnderlineError ErrorText
highlight! link DiagnosticUnderlineWarn WarningText
highlight! link DiagnosticUnderlineInfo InfoText
highlight! link DiagnosticUnderlineHint HintText
highlight! link DiagnosticSignError RedSign
highlight! link DiagnosticSignWarn YellowSign
highlight! link DiagnosticSignInfo BlueSign
highlight! link DiagnosticSignHint GreenSign
highlight! link LspDiagnosticsFloatingError DiagnosticFloatingError
highlight! link LspDiagnosticsFloatingWarning DiagnosticFloatingWarn
highlight! link LspDiagnosticsFloatingInformation DiagnosticFloatingInfo
highlight! link LspDiagnosticsFloatingHint DiagnosticFloatingHint
highlight! link LspDiagnosticsDefaultError DiagnosticError
highlight! link LspDiagnosticsDefaultWarning DiagnosticWarn
highlight! link LspDiagnosticsDefaultInformation DiagnosticInfo
highlight! link LspDiagnosticsDefaultHint DiagnosticHint
highlight! link LspDiagnosticsVirtualTextError DiagnosticVirtualTextError
highlight! link LspDiagnosticsVirtualTextWarning DiagnosticVirtualTextWarn
highlight! link LspDiagnosticsVirtualTextInformation DiagnosticVirtualTextInfo
highlight! link LspDiagnosticsVirtualTextHint DiagnosticVirtualTextHint
highlight! link LspDiagnosticsUnderlineError DiagnosticUnderlineError
highlight! link LspDiagnosticsUnderlineWarning DiagnosticUnderlineWarn
highlight! link LspDiagnosticsUnderlineInformation DiagnosticUnderlineInfo
highlight! link LspDiagnosticsUnderlineHint DiagnosticUnderlineHint
highlight! link LspDiagnosticsSignError DiagnosticSignError
highlight! link LspDiagnosticsSignWarning DiagnosticSignWarn
highlight! link LspDiagnosticsSignInformation DiagnosticSignInfo
highlight! link LspDiagnosticsSignHint DiagnosticSignHint
highlight! link LspReferenceText CurrentWord
highlight! link LspReferenceRead CurrentWord
highlight! link LspReferenceWrite CurrentWord
highlight! link LspCodeLens VirtualTextInfo
highlight! link LspCodeLensSeparator VirtualTextHint
highlight! link LspSignatureActiveParameter Yellow
highlight! link TermCursor Cursor
highlight! link healthError Red
highlight! link healthSuccess Green
highlight! link healthWarning Yellow
" Syntax: {{{
call my_sonokai#highlight('Type', s:darkpurple, s:palette.none, 'bold')
call my_sonokai#highlight('Structure', s:darkpurple, s:palette.none, 'bold')
call my_sonokai#highlight('StorageClass', s:purple, s:palette.none, 'bold')
call my_sonokai#highlight('Identifier', s:palette.orange, s:palette.none)
call my_sonokai#highlight('Constant', s:palette.purple, s:palette.none)
call my_sonokai#highlight('PreProc', s:palette.darkyellow, s:palette.none, 'bold')
call my_sonokai#highlight('PreCondit', s:palette.darkyellow, s:palette.none, 'bold')
call my_sonokai#highlight('Include', s:palette.green, s:palette.none)
call my_sonokai#highlight('Keyword', s:blue, s:palette.none, 'bold')
call my_sonokai#highlight('Define', s:palette.red, s:palette.none)
call my_sonokai#highlight('Typedef', s:palette.red, s:palette.none, 'bold')
call my_sonokai#highlight('Exception', s:palette.red, s:palette.none)
call my_sonokai#highlight('Conditional', s:palette.darkyellow, s:palette.none, 'bold')
call my_sonokai#highlight('Repeat', s:palette.blue, s:palette.none, 'bold')
call my_sonokai#highlight('Statement', s:palette.blue, s:palette.none, 'bold')
call my_sonokai#highlight('Macro', s:palette.purple, s:palette.none)
call my_sonokai#highlight('Error', s:palette.red, s:palette.none)
call my_sonokai#highlight('Label', s:palette.purple, s:palette.none)
call my_sonokai#highlight('Special', s:darkpurple, s:palette.none, 'bold')
call my_sonokai#highlight('SpecialChar', s:palette.purple, s:palette.none)
call my_sonokai#highlight('Boolean', s:palette.palered, s:palette.none)
call my_sonokai#highlight('String', s:string, s:palette.none)
call my_sonokai#highlight('Character', s:palette.yellow, s:palette.none)
call my_sonokai#highlight('Number', s:purple, s:palette.none, 'bold')
call my_sonokai#highlight('Float', s:palette.purple, s:palette.none)
call my_sonokai#highlight('Function', s:teal, s:palette.none, 'bold')
call my_sonokai#highlight('Method', s:brightteal, s:palette.none, 'bold')

call my_sonokai#highlight('Operator', s:palette.red, s:palette.none, 'bold')
call my_sonokai#highlight('Title', s:palette.red, s:palette.none, 'bold')
call my_sonokai#highlight('Tag', s:palette.orange, s:palette.none)
call my_sonokai#highlight('Delimiter', s:palette.red, s:palette.none, 'bold')
call my_sonokai#highlight('Comment', s:palette.grey, s:palette.none)
call my_sonokai#highlight('SpecialComment', s:palette.grey, s:palette.none)
call my_sonokai#highlight('Todo', s:palette.blue, s:palette.none)
call my_sonokai#highlight('Ignore', s:palette.grey, s:palette.none)
call my_sonokai#highlight('Underlined', s:palette.none, s:palette.none, 'underline')
" }}}
" Predefined Highlight Groups: {{{
call my_sonokai#highlight('Fg', s:palette.fg, s:palette.none)
call my_sonokai#highlight('FgBold', s:palette.fg, s:palette.none, 'bold')
call my_sonokai#highlight('FgItalic', s:palette.fg, s:palette.none, 'italic')
call my_sonokai#highlight('FgDimBold', s:palette.fg_dim, s:palette.none, 'bold')
call my_sonokai#highlight('FgDimBoldItalic', s:palette.fg_dim, s:palette.none, 'bold,italic')
call my_sonokai#highlight('Grey', s:palette.grey, s:palette.none)
call my_sonokai#highlight('Red', s:palette.red, s:palette.none)
call my_sonokai#highlight('PaleRed', s:palette.palered, s:palette.none, 'bold')
call my_sonokai#highlight('Orange', s:palette.orange, s:palette.none)
call my_sonokai#highlight('OrangeBold', s:palette.orange, s:palette.none, 'bold')
call my_sonokai#highlight('Yellow', s:palette.yellow, s:palette.none)
call my_sonokai#highlight('Green', s:palette.green, s:palette.none)
call my_sonokai#highlight('Blue', s:blue, s:palette.none)
call my_sonokai#highlight('BlueBold', s:blue, s:palette.none, 'bold')
call my_sonokai#highlight('Purple', s:purple, s:palette.none)
call my_sonokai#highlight('PurpleBold', s:purple, s:palette.none, 'bold')
call my_sonokai#highlight('DarkPurple', s:darkpurple, s:palette.none)
call my_sonokai#highlight('DarkPurpleBold', s:darkpurple, s:palette.none, 'bold')
call my_sonokai#highlight('RedBold', s:palette.red, s:palette.none, 'bold')
call my_sonokai#highlight('Teal', s:teal, s:palette.none)
call my_sonokai#highlight('TealBold', s:teal, s:palette.none, 'bold')

call my_sonokai#highlight('RedItalic', s:palette.red, s:palette.none)
call my_sonokai#highlight('OrangeItalic', s:palette.orange, s:palette.none)
call my_sonokai#highlight('YellowItalic', s:palette.yellow, s:palette.none)
call my_sonokai#highlight('GreenItalic', s:palette.green, s:palette.none)
call my_sonokai#highlight('BlueItalic', s:palette.blue, s:palette.none)
call my_sonokai#highlight('PurpleItalic', s:palette.purple, s:palette.none)
call my_sonokai#highlight('RedSign', s:palette.red, s:palette.none)
call my_sonokai#highlight('OrangeSign', s:palette.orange, s:palette.none)
call my_sonokai#highlight('YellowSign', s:palette.yellow, s:palette.none)
call my_sonokai#highlight('GreenSign', s:string, s:palette.none)
call my_sonokai#highlight('BlueSign', s:palette.blue, s:palette.none)
call my_sonokai#highlight('PurpleSign', s:palette.purple, s:palette.none)
call my_sonokai#highlight('ErrorText', s:palette.none, s:palette.none, 'undercurl', s:palette.red)
call my_sonokai#highlight('WarningText', s:palette.none, s:palette.none, 'undercurl', s:palette.yellow)
call my_sonokai#highlight('InfoText', s:palette.none, s:palette.none, 'undercurl', s:palette.blue)
call my_sonokai#highlight('HintText', s:palette.none, s:palette.none, 'undercurl', s:palette.green)
highlight clear ErrorLine
highlight clear WarningLine
highlight clear InfoLine
highlight clear HintLine
highlight! link VirtualTextWarning Grey
highlight! link VirtualTextError Grey
highlight! link VirtualTextInfo Grey
highlight! link VirtualTextHint Grey
call my_sonokai#highlight('ErrorFloat', s:palette.red, s:palette.none) " was palette.bg2"
call my_sonokai#highlight('WarningFloat', s:palette.yellow, s:palette.none)
call my_sonokai#highlight('InfoFloat', s:palette.blue, s:palette.none)
call my_sonokai#highlight('HintFloat', s:palette.green, s:palette.none)
" Definition
" nvim-treesitter/nvim-treesitter {{{
call my_sonokai#highlight('TSStrong', s:palette.none, s:palette.none, 'bold')
call my_sonokai#highlight('TSEmphasis', s:palette.none, s:palette.none, 'italic')
call my_sonokai#highlight('TSUnderline', s:palette.none, s:palette.none, 'underline')
call my_sonokai#highlight('TSNote', s:palette.bg0, s:palette.blue, 'bold')
call my_sonokai#highlight('TSWarning', s:palette.bg0, s:palette.yellow, 'bold')
call my_sonokai#highlight('TSDanger', s:palette.bg0, s:palette.red, 'bold')
highlight! link TSAnnotation BlueItalic
highlight! link TSAttribute BlueItalic
highlight! link TSBoolean PaleRed
highlight! link TSCharacter Yellow
highlight! link TSComment Comment
highlight! link TSConditional Conditional
highlight! link TSConstBuiltin OrangeItalic
highlight! link TSConstMacro OrangeItalic
highlight! link TSConstant Constant
highlight! link TSConstructor Yellow
highlight! link TSException Red
highlight! link TSField Orange
highlight! link TSFloat Purple
highlight! link TSFuncBuiltin TealBold
highlight! link TSFuncMacro TealBold
highlight! link TSFunction Teal
highlight! link TSInclude Green
highlight! link TSKeyword BlueBold
highlight! link TSKeywordFunction PaleRed
highlight! link TSKeywordOperator RedBold
highlight! link TSLabel Red
highlight! link TSMethod Method
highlight! link TSNamespace DarkPurpleBold
highlight! link TSNone Fg
highlight! link TSNumber Number
highlight! link TSOperator RedBold
highlight! link TSParameter FgDimBoldItalic
highlight! link TSParameterReference Fg
highlight! link TSProperty Orange
highlight! link TSPunctBracket RedBold
highlight! link TSPunctDelimiter RedBold
highlight! link TSPunctSpecial RedBold
highlight! link TSRepeat BlueBold
highlight! link TSStorageClass Purple
highlight! link TSString String
highlight! link TSStringEscape Green
highlight! link TSStringRegex String
highlight! link TSSymbol Fg
highlight! link TSTag BlueItalic
highlight! link TSTagDelimiter RedBold
highlight! link TSText Green
highlight! link TSStrike Grey
highlight! link TSMath Yellow
highlight! link TSType DarkPurpleBold
highlight! link TSTypeBuiltin BlueItalic
highlight! link TSTypeDefinition Red
highlight! link TSTypeQualifier BlueItalic
highlight! link TSURI markdownUrl
highlight! link TSVariable Fg
highlight! link TSVariableBuiltin Fg
highlight! link @annotation TSAnnotation
highlight! link @attribute TSAttribute
highlight! link @boolean TSBoolean
highlight! link @character TSCharacter
highlight! link @comment TSComment
highlight! link @conditional TSConditional
highlight! link @constant TSConstant
highlight! link @constant.builtin TSConstBuiltin
highlight! link @constant.macro TSConstMacro
highlight! link @constructor TSConstructor
highlight! link @exception TSException
highlight! link @field TSField
highlight! link @float TSFloat
highlight! link @function TSFunction
highlight! link @function.builtin TSFuncBuiltin
highlight! link @function.macro TSFuncMacro
highlight! link @include TSInclude
highlight! link @keyword TSKeyword
highlight! link @keyword.function TSKeywordFunction
highlight! link @keyword.operator TSKeywordOperator
highlight! link @label TSLabel
highlight! link @method TSMethod
highlight! link @namespace TSNamespace
highlight! link @none TSNone
highlight! link @number TSNumber
highlight! link @operator TSOperator
highlight! link @parameter TSParameter
highlight! link @parameter.reference TSParameterReference
highlight! link @property TSProperty
highlight! link @punctuation.bracket TSPunctBracket
highlight! link @punctuation.delimiter TSPunctDelimiter
highlight! link @punctuation.special TSPunctSpecial
highlight! link @repeat TSRepeat
highlight! link @storageclass TSStorageClass
highlight! link @string TSString
highlight! link @string.escape TSStringEscape
highlight! link @string.regex TSStringRegex
highlight! link @symbol TSSymbol
highlight! link @tag TSTag
highlight! link @tag.delimiter TSTagDelimiter
highlight! link @text TSText
highlight! link @strike TSStrike
highlight! link @math TSMath
highlight! link @type TSType
highlight! link @type.builtin TSTypeBuiltin
highlight! link @type.definition TSTypeDefinition
highlight! link @type.qualifier TSTypeQualifier
highlight! link @uri TSURI
highlight! link @variable TSVariable
highlight! link @variable.builtin TSVariableBuiltin
highlight! link @text.emphasis.latex TSEmphasis

" Treesitter semantic
highlight! link @lsp.type.parameter FgDimBoldItalic
highlight! link @lsp.type.variable Fg
highlight! link @lsp.type.selfKeyword TSTypeBuiltin
highlight! link @lsp.type.method Method

" terryma/vim-multiple-cursors {{{
highlight! link multiple_cursors_cursor Cursor
highlight! link multiple_cursors_visual Visual
call my_sonokai#highlight('VMCursor', s:palette.blue, s:palette.grey_dim)
let g:VM_Mono_hl = 'DiffText'
let g:VM_Extend_hl = 'DiffAdd'
let g:VM_Cursor_hl = 'Visual'
let g:VM_Insert_hl = 'DiffChange'
" voldikss/vim-floaterm {{{
highlight! link FloatermBorder Grey
" }}}
" MattesGroeger/vim-bookmarks {{{
highlight! link BookmarkSign BlueSign
highlight! link BookmarkAnnotationSign GreenSign
highlight! link BookmarkLine DiffChange
highlight! link BookmarkAnnotationLine DiffAdd
" }}}
" nvim-telescope/telescope.nvim {{{
call my_sonokai#highlight('TelescopeMatching', s:palette.palered, s:palette.none, 'bold')
call my_sonokai#highlight('TelescopeBorder', s:accent, s:palette.bg_dim)
call my_sonokai#highlight('TelescopePromptBorder', s:accent, s:palette.bg_dim)
call my_sonokai#highlight('TelescopePromptNormal', s:palette.fg_dim, s:palette.bg_dim, 'bold')
call my_sonokai#highlight('TelescopeNormal', s:palette.fg_dim, s:palette.bg_dim)
call my_sonokai#highlight('TelescopeTitle', s:accent_fg, s:accent, 'bold')

hi! link MiniPickBorder TelescopeBorder
hi! link MiniPickBorderBusy TelescopeBorder
hi! link MiniPickBorderText TelescopeBorder
hi! link MiniPickNormal TelescopeNormal
hi! link MiniPickHeader TelescopeTitle
hi! link MiniPickMatchCurrent Visual

highlight! link TelescopeResultsLineNr Yellow
highlight! link TelescopePromptPrefix Blue
highlight! link TelescopeSelection Visual

hi! link FzfLuaNormal TelescopeNormal
hi! link FzfLuaBorder TelescopeBorder
hi! link FzfLuaSearch TelescopeMatching
" }}}
" lewis6991/gitsigns.nvim {{{
highlight! link GitSignsAdd GreenSign
highlight! link GitSignsAddNr GreenSign
highlight! link GitSignsChange BlueBold
highlight! link GitSignsChangeNr BlueBold
highlight! link GitSignsDelete RedSign
highlight! link GitSignsDeleteNr Red
highlight! link GitSignsAddLn DiffAdd
highlight! link GitSignsChangeLn DiffChange
highlight! link GitSignsDeleteLn DiffDelete
highlight! link GitSignsCurrentLineBlame Grey
" }}}
" phaazon/hop.nvim {{{
call my_sonokai#highlight('HopNextKey', s:palette.red, s:palette.none, 'bold')
call my_sonokai#highlight('HopNextKey1', s:palette.blue, s:palette.none, 'bold')
highlight! link HopNextKey2 Blue
highlight! link HopUnmatched Grey
" }}}
" lukas-reineke/indent-blankline.nvim {{{
call my_sonokai#highlight('IndentBlanklineContextChar', s:palette.diff_green, s:palette.none, 'nocombine')
call my_sonokai#highlight('IndentBlanklineChar', s:palette.bg1, s:palette.none, 'nocombine')
highlight! link IndentBlanklineSpaceChar IndentBlanklineChar
highlight! link IndentBlanklineSpaceCharBlankline IndentBlanklineChar
" rainbow colors, supported but not in use.
highlight IndentBlanklineIndent1 guifg=#401C15 gui=nocombine
highlight IndentBlanklineIndent2 guifg=#15401B gui=nocombine
highlight IndentBlanklineIndent3 guifg=#583329 gui=nocombine
highlight IndentBlanklineIndent4 guifg=#163642 gui=nocombine
highlight IndentBlanklineIndent5 guifg=#112F6F gui=nocombine
highlight IndentBlanklineIndent6 guifg=#56186D gui=nocombine
" }}}
" }}}
" rcarriga/nvim-notify {{{
highlight! link NotifyERRORBorder Red
highlight! link NotifyWARNBorder Yellow
highlight! link NotifyINFOBorder Green
highlight! link NotifyDEBUGBorder Grey
highlight! link NotifyTRACEBorder Purple
highlight! link NotifyERRORIcon Red
highlight! link NotifyWARNIcon Yellow
highlight! link NotifyINFOIcon Green
highlight! link NotifyDEBUGIcon Grey
highlight! link NotifyTRACEIcon Purple
highlight! link NotifyERRORTitle Red
highlight! link NotifyWARNTitle Yellow
highlight! link NotifyINFOTitle Green
highlight! link NotifyDEBUGTitle Grey
highlight! link NotifyTRACETitle Purple
" }}}
" b0o/incline.nvim {{{
call my_sonokai#highlight('InclineNormalNC', s:palette.grey, s:palette.bg2)
" }}}
" Extended File Types: {{{
" Whitelist: {{{ File type optimizations that will always be loaded.
" diff {{{
highlight! link diffAdded Green
highlight! link diffRemoved Red
highlight! link diffChanged Blue
highlight! link diffOldFile Yellow
highlight! link diffNewFile Orange
highlight! link diffFile Purple
highlight! link diffLine Grey
highlight! link diffIndexLine Purple
" }}}
" syn_begin: NvimTree {{{
" https://github.com/kyazdani42/nvim-tree.lua
call my_sonokai#highlight('NvimTreeNormal', s:palette.fg, s:palette.neotreebg)
call my_sonokai#highlight('NvimTreeEndOfBuffer', s:palette.bg_dim, s:palette.neotreebg)
call my_sonokai#highlight('NvimTreeVertSplit', s:palette.bg0, s:palette.bg0)
highlight! link NvimTreeSymlink Fg
highlight! link NvimTreeFolderName BlueBold
highlight! link NvimTreeRootFolder Yellow
highlight! link NvimTreeFolderIcon Blue
highlight! link NvimTreeEmptyFolderName Green
highlight! link NvimTreeOpenedFolderName BlueBold
highlight! link NvimTreeExecFile Fg
highlight! link NvimTreeOpenedFile PurpleBold
highlight! link NvimTreeSpecialFile Fg
highlight! link NvimTreeImageFile Fg
highlight! link NvimTreeMarkdownFile Fg
highlight! link NvimTreeIndentMarker Grey
highlight! link NvimTreeGitDirty Yellow
highlight! link NvimTreeGitStaged Blue
highlight! link NvimTreeGitMerge Orange
highlight! link NvimTreeGitRenamed Purple
highlight! link NvimTreeGitNew Green
highlight! link NvimTreeGitDeleted Red
highlight! link NvimTreeLspDiagnosticsError RedSign
highlight! link NvimTreeLspDiagnosticsWarning YellowSign
highlight! link NvimTreeLspDiagnosticsInformation BlueSign
highlight! link NvimTreeLspDiagnosticsHint GreenSign
" syn_end }}}
" syn_begin: markdown {{{
" builtin: {{{
call my_sonokai#highlight('markdownH1', s:palette.red, s:palette.none, 'bold')
call my_sonokai#highlight('markdownH2', s:palette.orange, s:palette.none, 'bold')
call my_sonokai#highlight('markdownH3', s:palette.yellow, s:palette.none, 'bold')
call my_sonokai#highlight('markdownH4', s:palette.green, s:palette.none, 'bold')
call my_sonokai#highlight('markdownH5', s:palette.blue, s:palette.none, 'bold')
call my_sonokai#highlight('markdownH6', s:palette.purple, s:palette.none, 'bold')
call my_sonokai#highlight('markdownUrl', s:palette.blue, s:palette.none, 'underline')
call my_sonokai#highlight('markdownItalic', s:palette.none, s:palette.none, 'italic')
call my_sonokai#highlight('markdownBold', s:palette.none, s:palette.none, 'bold')
call my_sonokai#highlight('markdownItalicDelimiter', s:palette.grey, s:palette.none, 'italic')
highlight! link markdownCode Purple
highlight! link markdownCodeBlock Green
highlight! link markdownCodeDelimiter Green
highlight! link markdownBlockquote Grey
highlight! link markdownListMarker Red
highlight! link markdownOrderedListMarker Red
highlight! link markdownRule Purple
highlight! link markdownHeadingRule Grey
highlight! link markdownUrlDelimiter Grey
highlight! link markdownLinkDelimiter Grey
highlight! link markdownLinkTextDelimiter Grey
highlight! link markdownHeadingDelimiter Grey
highlight! link markdownLinkText Red
highlight! link markdownUrlTitleDelimiter Green
highlight! link markdownIdDeclaration markdownLinkText
highlight! link markdownBoldDelimiter Grey
highlight! link markdownId Yellow
" }}}
" vim-markdown: https://github.com/gabrielelana/vim-markdown{{{
call my_sonokai#highlight('mkdURL', s:palette.blue, s:palette.none, 'underline')
call my_sonokai#highlight('mkdInlineURL', s:palette.blue, s:palette.none, 'underline')
call my_sonokai#highlight('mkdItalic', s:palette.grey, s:palette.none, 'italic')
highlight! link mkdCodeDelimiter Green
highlight! link mkdBold Grey
call my_sonokai#highlight('mkdLink', s:blue, s:palette.none, 'underline')
highlight! link mkdHeading Grey
highlight! link mkdListItem Red
highlight! link mkdRule Purple
highlight! link mkdDelimiter Grey
highlight! link mkdId Yellow
" }}}
" syn_end }}}
" syn_begin: tex {{{
" builtin: http://www.drchip.org/astronaut/vim/index.html#SYNTAX_TEX{{{
highlight! link texStatement BlueItalic
highlight! link texOnlyMath Grey
highlight! link texDefName Yellow
highlight! link texNewCmd Orange
highlight! link texCmdName BlueBold
highlight! link texBeginEnd Red
highlight! link texBeginEndName Green
highlight! link texDocType Type
highlight! link texDocZone BlueBold
highlight! link texDocTypeArgs Orange
highlight! link texInputFile Green
" }}}
" vimtex: https://github.com/lervag/vimtex {{{
highlight! link texFileArg Green
highlight! link texCmd BlueItalic
highlight! link texCmdPackage BlueItalic
highlight! link texCmdDef Red
highlight! link texDefArgName Yellow
highlight! link texCmdNewcmd Red
highlight! link texCmdClass Red
highlight! link texCmdTitle Red
highlight! link texCmdAuthor Red
highlight! link texCmdEnv Red
highlight! link texCmdPart BlueBold
highlight! link texEnvArgName Green
" }}}
" syn_end }}}
" syn_begin: html/markdown/javascriptreact/typescriptreact {{{
" builtin: https://notabug.org/jorgesumle/vim-html-syntax{{{
call my_sonokai#highlight('htmlH1', s:palette.blue, s:palette.none, 'bold')
call my_sonokai#highlight('htmlH2', s:palette.orange, s:palette.none, 'bold')
call my_sonokai#highlight('htmlH3', s:palette.yellow, s:palette.none, 'bold')
call my_sonokai#highlight('htmlH4', s:palette.green, s:palette.none, 'bold')
call my_sonokai#highlight('htmlH5', s:palette.blue, s:palette.none, 'bold')
call my_sonokai#highlight('htmlH6', s:palette.purple, s:palette.none, 'bold')
call my_sonokai#highlight('htmlLink', s:palette.none, s:palette.none, 'underline')
call my_sonokai#highlight('htmlBold', s:palette.none, s:palette.none, 'bold')
call my_sonokai#highlight('htmlBoldUnderline', s:palette.none, s:palette.none, 'bold,underline')
call my_sonokai#highlight('htmlBoldItalic', s:palette.none, s:palette.none, 'bold,italic')
call my_sonokai#highlight('htmlBoldUnderlineItalic', s:palette.none, s:palette.none, 'bold,underline,italic')
call my_sonokai#highlight('htmlUnderline', s:palette.none, s:palette.none, 'underline')
call my_sonokai#highlight('htmlUnderlineItalic', s:palette.none, s:palette.none, 'underline,italic')
call my_sonokai#highlight('htmlItalic', s:palette.none, s:palette.none, 'italic')
highlight! link htmlTag Green
highlight! link htmlEndTag Blue
highlight! link htmlTagN RedItalic
highlight! link htmlTagName RedItalic
highlight! link htmlArg Blue
highlight! link htmlScriptTag Purple
highlight! link htmlSpecialTagName RedItalic
highlight! link htmlString Green
" }}}
" syn_end }}}
" syn_begin: less {{{
" vim-less: https://github.com/groenewege/vim-less{{{
highlight! link lessMixinChar Grey
highlight! link lessClass Red
highlight! link lessFunction Orange
" }}}
" syn_end }}}
" syn_begin: javascript/javascriptreact {{{
" builtin: http://www.fleiner.com/vim/syntax/javascript.vim{{{
highlight! link javaScriptNull OrangeItalic
highlight! link javaScriptIdentifier BlueItalic
highlight! link javaScriptParens Fg
highlight! link javaScriptBraces Fg
highlight! link javaScriptNumber Purple
highlight! link javaScriptLabel Red
highlight! link javaScriptGlobal BlueItalic
highlight! link javaScriptMessage BlueItalic
" }}}
" syn_begin: objc {{{
" builtin: {{{
highlight! link objcModuleImport Red
highlight! link objcException Red
highlight! link objcProtocolList Fg
highlight! link objcDirective Red
highlight! link objcPropertyAttribute Purple
highlight! link objcHiddenArgument Fg
" }}}
" syn_end }}}
" syn_begin: python {{{
" builtin: {{{
highlight! link pythonBuiltin BlueItalic
highlight! link pythonExceptions Red
highlight! link pythonDecoratorName OrangeItalic
" }}}
" syn_begin: lua {{{
" builtin: {{{
highlight! link luaFunc Green
highlight! link luaFunction Red
highlight! link luaTable Fg
highlight! link luaIn Red
" }}}
" syn_begin: java {{{
" builtin: {{{
highlight! link javaClassDecl Red
highlight! link javaMethodDecl Red
highlight! link javaVarArg Fg
highlight! link javaAnnotation Purple
highlight! link javaUserLabel Purple
highlight! link javaTypedef OrangeItalic
highlight! link javaParen Fg
highlight! link javaParen1 Fg
highlight! link javaParen2 Fg
highlight! link javaParen3 Fg
highlight! link javaParen4 Fg
highlight! link javaParen5 Fg
" }}}
" syn_end }}}
" syn_begin: kotlin {{{
" kotlin-vim: https://github.com/udalov/kotlin-vim{{{
highlight! link ktSimpleInterpolation Purple
highlight! link ktComplexInterpolation Purple
highlight! link ktComplexInterpolationBrace Purple
highlight! link ktStructure Red
highlight! link ktKeyword OrangeItalic
" }}}
" syn_end }}}
" syn_begin: swift {{{
" swift.vim: https://github.com/keith/swift.vim{{{
highlight! link swiftInterpolatedWrapper Purple
highlight! link swiftInterpolatedString Purple
highlight! link swiftProperty Fg
highlight! link swiftTypeDeclaration Red
highlight! link swiftClosureArgument OrangeItalic
highlight! link swiftStructure Red
" }}}
" syn_end }}}
" syn_begin: matlab {{{
" builtin: {{{
highlight! link matlabSemicolon Fg
highlight! link matlabFunction RedItalic
highlight! link matlabImplicit Green
highlight! link matlabDelimiter Fg
highlight! link matlabOperator Green
highlight! link matlabArithmeticOperator Red
highlight! link matlabArithmeticOperator Red
highlight! link matlabRelationalOperator Red
highlight! link matlabRelationalOperator Red
highlight! link matlabLogicalOperator Red
" }}}
" syn_end }}}
" syn_begin: help {{{
call my_sonokai#highlight('helpNote', s:palette.purple, s:palette.none, 'bold')
call my_sonokai#highlight('helpHeadline', s:palette.red, s:palette.none, 'bold')
call my_sonokai#highlight('helpHeader', s:palette.orange, s:palette.none, 'bold')
call my_sonokai#highlight('helpURL', s:palette.green, s:palette.none, 'underline')
call my_sonokai#highlight('helpHyperTextEntry', s:palette.blue, s:palette.none, 'bold')
highlight! link helpHyperTextJump Blue
highlight! link helpCommand Yellow
highlight! link helpExample Green
highlight! link helpSpecial Purple
highlight! link helpSectionDelim Grey
" syn_end }}}
" }}}

" CMP (with custom menu setup)
hi! CmpItemKindDefault    guifg=#cc5de8
hi! link CmpItemKind      CmpItemKindDefault
hi! CmpItemMenu           guifg=#ededcf
hi! CmpItemMenuDetail     guifg=#ffe066
hi! CmpItemMenuBuffer     guifg=#898989
hi! CmpItemMenuSnippet    guifg=#cc5de8
hi! CmpItemMenuLSP        guifg=#cfa050
hi link CmpItemMenuPath   CmpItemMenu

call my_sonokai#highlight('CmpPmenu', s:palette.fg, s:palette.bg_dim)
call my_sonokai#highlight('CmpPmenuBorder', s:palette.grey_dim, s:palette.bg_dim)
call my_sonokai#highlight('CmpGhostText', s:palette.grey, s:palette.none)
highlight! CmpItemAbbr      guifg=#d0b1d0
" gray
highlight! CmpItemAbbrDeprecated    guibg=NONE gui=strikethrough guifg=#808080
highlight! CmpItemAbbrMatch         guibg=NONE guifg=#f03e3e gui=bold
highlight! CmpItemAbbrMatchFuzzy    guibg=NONE guifg=#fd7e14 gui=bold

highlight!      CmpItemKindModule        guibg=NONE guifg=#FF7F50
highlight!      CmpItemKindClass         guibg=NONE guifg=#FFAF00
highlight! link CmpItemKindStruct        CmpItemKindClass
highlight!      CmpItemKindVariable      guibg=NONE guifg=#9CDCFE
highlight!      CmpItemKindProperty      guibg=NONE guifg=#9CDCFE
highlight!      CmpItemKindFunction      guibg=NONE guifg=#C586C0
highlight! link CmpItemKindConstructor   CmpItemKindFunction
highlight! link CmpItemKindMethod        CmpItemKindFunction
highlight!      CmpItemKindKeyword       guibg=NONE guifg=#FF5FFF
highlight!      CmpItemKindText          guibg=NONE guifg=#D4D4D4
highlight!      CmpItemKindUnit          guibg=NONE guifg=#D4D4D4
highlight!      CmpItemKindConstant      guibg=NONE guifg=#409F31
highlight!      CmpItemKindSnippet       guibg=NONE guifg=#E3E300

" Glance plugin: https://github.com/DNLHC/glance.nvim
call my_sonokai#highlight('GlancePreviewNormal', s:palette.fg, s:palette.black)
call my_sonokai#highlight('GlancePreviewMatch', s:palette.yellow, s:palette.none)
call my_sonokai#highlight('GlanceListMatch', s:palette.yellow, s:palette.none)
hi! link GlanceListCursorLine Visual

" allow neotree and other addon panels have different backgrounds
call my_sonokai#highlight('NeoTreeNormalNC', s:palette.fg, s:palette.neotreebg)
call my_sonokai#highlight('NeoTreeNormal', s:palette.fg, s:palette.neotreebg)
call my_sonokai#highlight('NeoTreeFloatBorder', s:palette.grey_dim, s:palette.neotreebg)
call my_sonokai#highlight('NeoTreeFileNameOpened', s:palette.blue, s:palette.neotreebg, 'italic')
call my_sonokai#highlight('SymbolsOutlineConnector', s:palette.bg4, s:palette.none)
call my_sonokai#highlight('TreesitterContext', s:palette.none, s:contextbg)
" call my_sonokai#highlight('TreesitterContextBottom', s:palette.none, s:palette.none, 'underline', s:palette.yellow)
hi! link TreesitterContextSeparator Type
hi! link NvimTreeIndentMarker SymbolsOutlineConnector
hi! link OutlineGuides SymbolsOutlineConnector
hi! link NeoTreeCursorLine Visual
hi! link AerialGuide SymbolsOutlineConnector

" winbar 
call my_sonokai#highlight('WinBarFilename', s:teal, s:palette.none, 'underline', s:accent)                      " Filename (right hand)
call my_sonokai#highlight('WinBarContext', s:palette.darkyellow, s:palette.none, 'underline', s:accent) " LSP context (left hand)
" WinBarInvis is for the central padding item. It should be transparent and invisible (fg = bg)
" This is a somewhat hack-ish way to make the lualine-controlle winbar transparent.
call my_sonokai#highlight('WinBarInvis', s:bg, s:palette.none, 'underline', s:accent)
hi! link WinBarNC StatusLineNC
hi! link WinBar WinBarContext
" Lazy
hi! link LazyNoCond RedBold
hi! link VirtColumn IndentBlankLineChar
hi! link SatelliteCursor WarningMsg
hi! link SatelliteSearch PurpleBold
hi! link SatelliteSearchCurrent PurpleBold

hi! @ibl.scope.char.1 guibg=none
