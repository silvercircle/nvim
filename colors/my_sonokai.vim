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
" TODO: convert this to lua at some point

function! my_sonokai#get_configuration()
  return {
        \ 'style': get(g:, 'sonokai_style', 'default'),
        \ 'colors_override': get(g:, 'sonokai_colors_override', {}),
        \ 'transparent_background': get(g:, 'sonokai_transparent_background', 0),
        \ 'dim_inactive_windows': get(g:, 'sonokai_dim_inactive_windows', 0),
        \ 'disable_italic_comment': get(g:, 'sonokai_disable_italic_comment', 0),
        \ 'enable_italic': get(g:, 'sonokai_enable_italic', 0),
        \ 'cursor': get(g:, 'sonokai_cursor', 'auto'),
        \ 'menu_selection_background': get(g:, 'sonokai_menu_selection_background', 'blue'),
        \ 'spell_foreground': get(g:, 'sonokai_spell_foreground', 'none'),
        \ 'show_eob': get(g:, 'sonokai_show_eob', 1),
        \ 'current_word': get(g:, 'sonokai_current_word', get(g:, 'sonokai_transparent_background', 0) == 0 ? 'grey background' : 'bold'),
        \ 'lightline_disable_bold': get(g:, 'sonokai_lightline_disable_bold', 0),
        \ 'diagnostic_text_highlight': get(g:, 'sonokai_diagnostic_text_highlight', 0),
        \ 'diagnostic_line_highlight': get(g:, 'sonokai_diagnostic_line_highlight', 0),
        \ 'diagnostic_virtual_text': get(g:, 'sonokai_diagnostic_virtual_text', 'grey'),
        \ 'disable_terminal_colors': get(g:, 'sonokai_disable_terminal_colors', 0),
        \ 'better_performance': get(g:, 'sonokai_better_performance', 0),
        \ }
endfunction

if g:theme_variant == 'cold'
  let palette = {
        \ 'black':      ['#18181c',   '232'],
        \ 'bg_dim':     ['#222327',   '232'],
        \ 'bg0':        ['#2c2e34',   '235'],
        \ 'bg1':        ['#33353f',   '236'],
        \ 'bg2':        ['#363944',   '236'],
        \ 'bg3':        ['#3b3e48',   '237'],
        \ 'bg4':        ['#414550',   '237'],
        \ 'bg_red':     ['#ff6077',   '203'],
        \ 'diff_red':   ['#55393d',   '52'],
        \ 'bg_green':   ['#a7df78',   '107'],
        \ 'diff_green': ['#394634',   '22'],
        \ 'bg_blue':    ['#85d3f2',   '110'],
        \ 'diff_blue':  ['#354157',   '17'],
        \ 'diff_yellow':['#4e432f',   '54'],
        \ 'fg':         ['#e2e2e3',   '250'],
        \ 'red':        ['#cc2d4c',   '203'],
        \ 'palered':    ['#8b2d3c',   '203'],
        \ 'orange':     ['#c36630',   '215'],
        \ 'yellow':     ['#e7c664',   '179'],
        \ 'darkyellow': ['#a78624',   '180'],
        \ 'green':      ['#9ed072',   '107'],
        \ 'blue':       ['#76cce0',   '110'],
        \ 'purple':     ['#b39df3',   '176'],
        \ 'grey':       ['#7f8490',   '246'],
        \ 'grey_dim':   ['#595f6f',   '240'],
        \ 'neotreebg':  ['#18181c',   '232'],
        \ 'selfg':      ['#cccc20',   '233'],
        \ 'selbg':      ['#3030b0',   '234'],
        \ 'none':       ['NONE',      'NONE']
        \ }
else
  let palette = {
        \ 'black':      ['#1b1818',   '232'],
        \ 'bg_dim':     ['#252222',   '232'],
        \ 'bg0':        ['#322c2c',   '235'],
        \ 'bg1':        ['#3f3533',   '236'],
        \ 'bg2':        ['#403936',   '236'],
        \ 'bg3':        ['#483e3b',   '237'],
        \ 'bg4':        ['#504531',   '237'],
        \ 'bg_red':     ['#ff6077',   '203'],
        \ 'diff_red':   ['#55393d',   '52'],
        \ 'bg_green':   ['#a7df78',   '107'],
        \ 'diff_green': ['#394634',   '22'],
        \ 'bg_blue':    ['#85d3f2',   '110'],
        \ 'diff_blue':  ['#354157',   '17'],
        \ 'diff_yellow':['#4e432f',   '54'],
        \ 'fg':         ['#e5e2e0',   '250'],
        \ 'red':        ['#cc2d4c',   '203'],
        \ 'palered':    ['#8b2d3c',   '203'],
        \ 'orange':     ['#c36630',   '215'],
        \ 'yellow':     ['#e7c664',   '179'],
        \ 'darkyellow': ['#a78624',   '180'],
        \ 'green':      ['#9ed072',   '107'],
        \ 'blue':       ['#76cce0',   '110'],
        \ 'purple':     ['#b39df3',   '176'],
        \ 'grey':       ['#7f8490',   '246'],
        \ 'grey_dim':   ['#595f6f',   '240'],
        \ 'neotreebg':  ['#1b1818',   '232'],
        \ 'selfg':      ['#cccc20',   '233'],
        \ 'selbg':      ['#3030b0',   '234'],
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
let s:configuration = my_sonokai#get_configuration()
let s:palette = palette
let s:path = expand('<sfile>:p') " the path of this script
let s:last_modified = '2022-12-23T08:46:17+0100'
let g:sonokai_loaded_file_types = []
if g:theme_variant == 'cold'
  let s:darkbg = ['#111118', 237]
  let s:teal = ['#108080', 238]
  let s:blue = ['#5a6acf', 239]
  let s:darkpurple = ['#803090', 240]
  let s:purple = ['#c030c0', 241]
  let s:darkred = ['#601010', 249]
  let s:darkestred = ['#161616', 249]
  let s:darkestblue = ['#10101a', 247]
  let s:string = ['#10801f', 231]
  let s:bg = ['#141414', 0]
  let s:statuslinebg = [ g:statuslinebg, 208 ]
  let s:palette.fg = [ '#a5a0b5', 1 ]
  let s:palette.grey = [ '#707070', 2 ]
  let s:pmenubg = [ '#241a20', 156 ]
  let s:cmpbg = s:palette.bg4
else
  let s:darkbg = ['#181111', 237]
  let s:teal = ['#108080', 238]
  let s:blue = ['#5a6acf', 239]
  let s:darkpurple = ['#803090', 240]
  let s:purple = ['#c030c0', 241]
  let s:darkred = ['#601010', 249]
  let s:darkestred = ['#161616', 249]
  let s:darkestblue = ['#10101a', 247]
  let s:string = ['#10801f', 231]
  let s:bg = ['#181414', 0]
  let s:statuslinebg = [ g:statuslinebg, 208 ]
  let s:palette.fg = [ '#a5a0b5', 1 ]
  let s:palette.grey = [ '#707070', 2 ]
  let s:pmenubg = [ '#241a20', 156 ]
  let s:cmpbg = s:palette.bg4
endif

if !(exists('g:colors_name') && g:colors_name ==# 'my_sonokai' && s:configuration.better_performance)
  highlight clear
  if exists('syntax_on')
    syntax reset
  endif
endif

let g:colors_name = 'my_sonokai'

call my_sonokai#highlight("Braces", s:palette.red, s:palette.none)
call my_sonokai#highlight('ScrollView', s:teal, s:blue)

call my_sonokai#highlight('Normal', s:palette.fg, s:bg)
call my_sonokai#highlight('Terminal', s:palette.fg, s:palette.neotreebg)
if s:configuration.show_eob
  call my_sonokai#highlight('EndOfBuffer', s:palette.bg4, s:palette.none)
else
  call my_sonokai#highlight('EndOfBuffer', s:palette.bg0, s:palette.none)
endif
call my_sonokai#highlight('Folded', s:palette.yellow, s:darkred, 'bold')
call my_sonokai#highlight('ToolbarLine', s:palette.fg, s:palette.none)
call my_sonokai#highlight('FoldColumn', s:palette.bg4, s:bg)
call my_sonokai#highlight('SignColumn', s:palette.fg, s:palette.none)
call my_sonokai#highlight('IncSearch', s:palette.yellow, s:darkpurple)
call my_sonokai#highlight('Search', s:palette.yellow, s:blue)
call my_sonokai#highlight('ColorColumn', s:palette.none, s:palette.bg1)
call my_sonokai#highlight('Conceal', s:palette.grey_dim, s:palette.none)
if s:configuration.cursor ==# 'auto'
  call my_sonokai#highlight('Cursor', s:palette.none, s:palette.none, 'reverse')
else
  call my_sonokai#highlight('Cursor', s:palette.bg0, s:palette[s:configuration.cursor])
endif
highlight! link vCursor Cursor
highlight! link iCursor Cursor
highlight! link lCursor Cursor
highlight! link CursorIM Cursor
call my_sonokai#highlight('FocusedSymbol', s:palette.yellow, s:palette.bg1, 'bold')
if &diff
  call my_sonokai#highlight('CursorLine', s:palette.none, s:palette.none, 'underline')
  call my_sonokai#highlight('CursorColumn', s:palette.none, s:palette.none, 'bold')
else
  call my_sonokai#highlight('CursorLine', s:palette.none, s:palette.bg1)
  call my_sonokai#highlight('CursorColumn', s:palette.none, s:palette.bg1)
endif
call my_sonokai#highlight('LineNr', s:palette.grey_dim, s:palette.none)
if &diff
  call my_sonokai#highlight('CursorLineNr', s:palette.fg, s:palette.none, 'underline')
else
  call my_sonokai#highlight('CursorLineNr', s:palette.fg, s:palette.none)
endif
call my_sonokai#highlight('DiffAdd', s:palette.none, s:palette.diff_green)
call my_sonokai#highlight('DiffChange', s:palette.none, s:palette.diff_blue)
call my_sonokai#highlight('DiffDelete', s:palette.none, s:palette.diff_red)
call my_sonokai#highlight('DiffText', s:palette.bg0, s:palette.blue)
call my_sonokai#highlight('Directory', s:palette.green, s:palette.none)
call my_sonokai#highlight('ErrorMsg', s:palette.red, s:palette.none, 'bold,underline')
call my_sonokai#highlight('WarningMsg', s:palette.yellow, s:palette.none, 'bold')
call my_sonokai#highlight('ModeMsg', s:palette.fg, s:palette.none, 'bold')
call my_sonokai#highlight('MoreMsg', s:palette.blue, s:palette.none, 'bold')
call my_sonokai#highlight('MatchParen', s:palette.yellow, s:darkred)
call my_sonokai#highlight('NonText', s:palette.bg4, s:palette.none)
call my_sonokai#highlight('Whitespace', s:palette.green, s:palette.none)
call my_sonokai#highlight('SpecialKey', s:palette.bg4, s:palette.none)
call my_sonokai#highlight('Pmenu', s:palette.fg, s:pmenubg)
call my_sonokai#highlight('PmenuSbar', s:palette.none, s:palette.bg2)
call my_sonokai#highlight('PmenuSel', s:palette.yellow, s:blue)
highlight! link WildMenu PmenuSel
call my_sonokai#highlight('PmenuThumb', s:palette.none, s:palette.grey)
call my_sonokai#highlight('NormalFloat', s:palette.fg, s:palette.bg_dim)
call my_sonokai#highlight('FloatBorder', s:palette.grey_dim, s:palette.bg_dim)
call my_sonokai#highlight('Question', s:palette.yellow, s:palette.none)
if s:configuration.spell_foreground ==# 'none'
  call my_sonokai#highlight('SpellBad', s:palette.none, s:palette.none, 'undercurl', s:palette.red)
  call my_sonokai#highlight('SpellCap', s:palette.none, s:palette.none, 'undercurl', s:palette.yellow)
  call my_sonokai#highlight('SpellLocal', s:palette.none, s:palette.none, 'undercurl', s:palette.blue)
  call my_sonokai#highlight('SpellRare', s:palette.none, s:palette.none, 'undercurl', s:palette.purple)
else
  call my_sonokai#highlight('SpellBad', s:palette.red, s:palette.none, 'undercurl', s:palette.red)
  call my_sonokai#highlight('SpellCap', s:palette.yellow, s:palette.none, 'undercurl', s:palette.yellow)
  call my_sonokai#highlight('SpellLocal', s:palette.blue, s:palette.none, 'undercurl', s:palette.blue)
  call my_sonokai#highlight('SpellRare', s:palette.purple, s:palette.none, 'undercurl', s:palette.purple)
endif
if s:configuration.transparent_background == 2
  call my_sonokai#highlight('StatusLine', s:palette.fg, s:statuslinebg)
  call my_sonokai#highlight('StatusLineTerm', s:palette.fg, s:palette.none)
  call my_sonokai#highlight('StatusLineNC', s:palette.grey, s:statuslinebg)
  call my_sonokai#highlight('StatusLineTermNC', s:palette.grey, s:palette.none)
  call my_sonokai#highlight('TabLine', s:palette.fg, s:palette.bg4)
  call my_sonokai#highlight('TabLineFill', s:palette.grey, s:palette.none)
  call my_sonokai#highlight('TabLineSel', s:palette.bg0, s:palette.bg_red)
else
  call my_sonokai#highlight('StatusLine', s:palette.fg, s:statuslinebg)
  call my_sonokai#highlight('StatusLineTerm', s:palette.fg, s:palette.bg3)
  call my_sonokai#highlight('StatusLineNC', s:palette.grey, s:statuslinebg)
  call my_sonokai#highlight('StatusLineTermNC', s:palette.grey, s:palette.bg1)
  call my_sonokai#highlight('TabLine', s:palette.fg, s:palette.bg4)
  call my_sonokai#highlight('TabLineFill', s:palette.grey, s:palette.bg1)
  call my_sonokai#highlight('TabLineSel', s:palette.bg0, s:palette.bg_red)
endif
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
highlight! link WinBarNC Grey
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
highlight! link LspSignatureActiveParameter Search
highlight! link TermCursor Cursor
highlight! link healthError Red
highlight! link healthSuccess Green
highlight! link healthWarning Yellow
" Syntax: {{{
if s:configuration.enable_italic
  call my_sonokai#highlight('Type', s:palette.blue, s:palette.none, 'italic')
  call my_sonokai#highlight('Structure', s:palette.blue, s:palette.none, 'italic')
  call my_sonokai#highlight('StorageClass', s:palette.blue, s:palette.none, 'italic')
  call my_sonokai#highlight('Identifier', s:palette.orange, s:palette.none, 'italic')
  call my_sonokai#highlight('Constant', s:palette.orange, s:palette.none, 'italic')
else
  call my_sonokai#highlight('Type', s:darkpurple, s:palette.none, 'bold')
  call my_sonokai#highlight('Structure', s:darkpurple, s:palette.none, 'bold')
  call my_sonokai#highlight('StorageClass', s:purple, s:palette.none, 'bold')
  call my_sonokai#highlight('Identifier', s:palette.orange, s:palette.none)
  call my_sonokai#highlight('Constant', s:palette.orange, s:palette.none)
endif
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
call my_sonokai#highlight('Number', s:palette.purple, s:palette.none, 'bold')
call my_sonokai#highlight('Float', s:palette.purple, s:palette.none)
call my_sonokai#highlight('Function', s:teal, s:palette.none, 'bold')
call my_sonokai#highlight('Operator', s:palette.red, s:palette.none, 'bold')
call my_sonokai#highlight('Title', s:palette.red, s:palette.none, 'bold')
call my_sonokai#highlight('Tag', s:palette.orange, s:palette.none)
call my_sonokai#highlight('Delimiter', s:palette.red, s:palette.none, 'bold')
if s:configuration.disable_italic_comment
  call my_sonokai#highlight('Comment', s:palette.grey, s:palette.none)
  call my_sonokai#highlight('SpecialComment', s:palette.grey, s:palette.none)
  call my_sonokai#highlight('Todo', s:palette.blue, s:palette.none)
else
  call my_sonokai#highlight('Comment', s:palette.grey, s:palette.none, 'italic')
  call my_sonokai#highlight('SpecialComment', s:palette.grey, s:palette.none, 'italic')
  call my_sonokai#highlight('Todo', s:palette.blue, s:palette.none, 'italic')
endif
call my_sonokai#highlight('Ignore', s:palette.grey, s:palette.none)
call my_sonokai#highlight('Underlined', s:palette.none, s:palette.none, 'underline')
" }}}
" Predefined Highlight Groups: {{{
call my_sonokai#highlight('Fg', s:palette.fg, s:palette.none)
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

if s:configuration.enable_italic
  call my_sonokai#highlight('RedItalic', s:palette.red, s:palette.none, 'italic')
  call my_sonokai#highlight('OrangeItalic', s:palette.orange, s:palette.none, 'italic')
  call my_sonokai#highlight('YellowItalic', s:palette.yellow, s:palette.none, 'italic')
  call my_sonokai#highlight('GreenItalic', s:palette.green, s:palette.none, 'italic')
  call my_sonokai#highlight('BlueItalic', s:palette.blue, s:palette.none, 'italic')
  call my_sonokai#highlight('PurpleItalic', s:palette.purple, s:palette.none, 'italic')
else
  call my_sonokai#highlight('RedItalic', s:palette.red, s:palette.none)
  call my_sonokai#highlight('OrangeItalic', s:palette.orange, s:palette.none)
  call my_sonokai#highlight('YellowItalic', s:palette.yellow, s:palette.none)
  call my_sonokai#highlight('GreenItalic', s:palette.green, s:palette.none)
  call my_sonokai#highlight('BlueItalic', s:palette.blue, s:palette.none, 'bold')
  call my_sonokai#highlight('PurpleItalic', s:palette.purple, s:palette.none)
endif
call my_sonokai#highlight('RedSign', s:palette.red, s:palette.none)
call my_sonokai#highlight('OrangeSign', s:palette.orange, s:palette.none)
call my_sonokai#highlight('YellowSign', s:palette.yellow, s:palette.none)
call my_sonokai#highlight('GreenSign', s:palette.green, s:palette.none)
call my_sonokai#highlight('BlueSign', s:palette.blue, s:palette.none)
call my_sonokai#highlight('PurpleSign', s:palette.purple, s:palette.none)
if s:configuration.diagnostic_text_highlight
  call my_sonokai#highlight('ErrorText', s:palette.none, s:palette.diff_red, 'undercurl', s:palette.red)
  call my_sonokai#highlight('WarningText', s:palette.none, s:palette.diff_yellow, 'undercurl', s:palette.yellow)
  call my_sonokai#highlight('InfoText', s:palette.none, s:palette.diff_blue, 'undercurl', s:palette.blue)
  call my_sonokai#highlight('HintText', s:palette.none, s:palette.diff_green, 'undercurl', s:palette.green)
else
  call my_sonokai#highlight('ErrorText', s:palette.none, s:palette.none, 'undercurl', s:palette.red)
  call my_sonokai#highlight('WarningText', s:palette.none, s:palette.none, 'undercurl', s:palette.yellow)
  call my_sonokai#highlight('InfoText', s:palette.none, s:palette.none, 'undercurl', s:palette.blue)
  call my_sonokai#highlight('HintText', s:palette.none, s:palette.none, 'undercurl', s:palette.green)
endif
if s:configuration.diagnostic_line_highlight
  call my_sonokai#highlight('ErrorLine', s:palette.none, s:palette.diff_red)
  call my_sonokai#highlight('WarningLine', s:palette.none, s:palette.diff_yellow)
  call my_sonokai#highlight('InfoLine', s:palette.none, s:palette.diff_blue)
  call my_sonokai#highlight('HintLine', s:palette.none, s:palette.diff_green)
else
  highlight clear ErrorLine
  highlight clear WarningLine
  highlight clear InfoLine
  highlight clear HintLine
endif
if s:configuration.diagnostic_virtual_text ==# 'grey'
  highlight! link VirtualTextWarning Grey
  highlight! link VirtualTextError Grey
  highlight! link VirtualTextInfo Grey
  highlight! link VirtualTextHint Grey
else
  highlight! link VirtualTextWarning Yellow
  highlight! link VirtualTextError Red
  highlight! link VirtualTextInfo Blue
  highlight! link VirtualTextHint Green
endif
call my_sonokai#highlight('ErrorFloat', s:palette.red, s:palette.none) " was palette.bg2"
call my_sonokai#highlight('WarningFloat', s:palette.yellow, s:palette.none)
call my_sonokai#highlight('InfoFloat', s:palette.blue, s:palette.none)
call my_sonokai#highlight('HintFloat', s:palette.green, s:palette.none)
if &diff
  call my_sonokai#highlight('CurrentWord', s:palette.bg0, s:palette.green)
elseif s:configuration.current_word ==# 'grey background'
  call my_sonokai#highlight('CurrentWord', s:palette.none, s:palette.bg2)
else
  call my_sonokai#highlight('CurrentWord', s:palette.none, s:palette.none, s:configuration.current_word)
endif
" }}}
" Definition
let s:terminal = {
      \ 'black':           s:palette.black,
      \ 'red':             s:palette.red,
      \ 'yellow':          s:palette.yellow,
      \ 'green':           s:palette.green,
      \ 'cyan':            s:palette.orange,
      \ 'blue':            s:palette.blue,
      \ 'purple':          s:palette.purple,
      \ 'white':           s:palette.fg,
      \ 'bright_black':    s:palette.grey,
      \ }
" Implementation: {{{
let g:terminal_color_0 = s:terminal.black[0]
let g:terminal_color_1 = s:terminal.red[0]
let g:terminal_color_2 = s:terminal.green[0]
let g:terminal_color_3 = s:terminal.yellow[0]
let g:terminal_color_4 = s:terminal.blue[0]
let g:terminal_color_5 = s:terminal.purple[0]
let g:terminal_color_6 = s:terminal.cyan[0]
let g:terminal_color_7 = s:terminal.white[0]
let g:terminal_color_8 = s:terminal.bright_black[0]
let g:terminal_color_9 = s:terminal.red[0]
let g:terminal_color_10 = s:terminal.green[0]
let g:terminal_color_11 = s:terminal.yellow[0]
let g:terminal_color_12 = s:terminal.blue[0]
let g:terminal_color_13 = s:terminal.purple[0]
let g:terminal_color_14 = s:terminal.cyan[0]
let g:terminal_color_15 = s:terminal.white[0]
" Plugins: {{{
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
highlight! link TSConstant OrangeItalic
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
highlight! link TSMethod TealBold
highlight! link TSNamespace DarkPurpleBold
highlight! link TSNone Fg
highlight! link TSNumber PurpleBold
highlight! link TSOperator RedBold
highlight! link TSParameter Fg
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
highlight! link TSTypeQualifier Red
highlight! link TSURI markdownUrl
highlight! link TSVariable Fg
highlight! link TSVariableBuiltin OrangeItalic
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
" }}}
" prabirshrestha/vim-lsp {{{
highlight! link LspErrorVirtual VirtualTextError
highlight! link LspWarningVirtual VirtualTextWarning
highlight! link LspInformationVirtual VirtualTextInfo
highlight! link LspHintVirtual VirtualTextHint
highlight! link LspErrorHighlight ErrorText
highlight! link LspWarningHighlight WarningText
highlight! link LspInformationHighlight InfoText
highlight! link LspHintHighlight HintText
highlight! link lspReference CurrentWord
highlight! link lspInlayHintsType LineNr
highlight! link lspInlayHintsParameter LineNr
highlight! link LspSemanticType TSType
highlight! link LspSemanticClass TSType
highlight! link LspSemanticEnum TSType
highlight! link LspSemanticInterface TSType
highlight! link LspSemanticStruct TSType
highlight! link LspSemanticTypeParameter TSType
highlight! link LspSemanticParameter TSParameter
highlight! link LspSemanticVariable TSVariable
highlight! link LspSemanticProperty TSProperty
highlight! link LspSemanticEnumMember TSVariableBuiltin
highlight! link LspSemanticEvents TSLabel
highlight! link LspSemanticFunction TSFunction
highlight! link LspSemanticMethod TSMethod
highlight! link LspSemanticKeyword TSKeyword
highlight! link LspSemanticModifier TSOperator
highlight! link LspSemanticComment TSComment
highlight! link LspSemanticString TSString
highlight! link LspSemanticNumber TSNumber
highlight! link LspSemanticRegexp TSStringRegex
highlight! link LspSemanticOperator TSOperator
" }}}
highlight! link SignifySignAdd GreenSign
highlight! link SignifySignChange BlueSign
highlight! link SignifySignDelete RedSign
highlight! link SignifySignChangeDelete PurpleSign
highlight! link SignifyLineAdd DiffAdd
highlight! link SignifyLineChange DiffChange
highlight! link SignifyLineChangeDelete DiffChange
highlight! link SignifyLineDelete DiffDelete
" terryma/vim-multiple-cursors {{{
highlight! link multiple_cursors_cursor Cursor
highlight! link multiple_cursors_visual Visual
call my_sonokai#highlight('VMCursor', s:palette.blue, s:palette.grey_dim)
let g:VM_Mono_hl = 'VMCursor'
let g:VM_Extend_hl = 'Visual'
let g:VM_Cursor_hl = 'VMCursor'
let g:VM_Insert_hl = 'VMCursor'
" }}}
" dominikduda/vim_current_word {{{
highlight! link CurrentWordTwins CurrentWord
" }}}
" itchyny/vim-cursorword {{{
highlight! link CursorWord0 CurrentWord
highlight! link CursorWord1 CurrentWord
" }}}
" Yggdroot/indentLine {{{
let g:indentLine_color_gui = s:palette.grey_dim[0]
let g:indentLine_color_term = s:palette.grey_dim[1]
" }}}
" nathanaelkane/vim-indent-guides {{{
if get(g:, 'indent_guides_auto_colors', 1) == 0
  call my_sonokai#highlight('IndentGuidesOdd', s:palette.bg0, s:palette.bg1)
  call my_sonokai#highlight('IndentGuidesEven', s:palette.bg0, s:palette.bg2)
endif
" }}}
" unblevable/quick-scope {{{
call my_sonokai#highlight('QuickScopePrimary', s:palette.green, s:palette.none, 'underline')
call my_sonokai#highlight('QuickScopeSecondary', s:palette.blue, s:palette.none, 'underline')
" }}}
" APZelos/blamer.nvim {{{
highlight! link Blamer Grey
" }}}
" voldikss/vim-floaterm {{{
highlight! link FloatermBorder Grey
" }}}
" MattesGroeger/vim-bookmarks {{{
highlight! link BookmarkSign BlueSign
highlight! link BookmarkAnnotationSign GreenSign
highlight! link BookmarkLine DiffChange
highlight! link BookmarkAnnotationLine DiffAdd
" }}}
if has('nvim')
" }}}
" nvim-telescope/telescope.nvim {{{
call my_sonokai#highlight('TelescopeMatching', s:palette.green, s:palette.none, 'bold')
call my_sonokai#highlight('TelescopeBorder', s:palette.grey_dim, s:palette.bg_dim, 'bold')
call my_sonokai#highlight('TelescopeNormal', s:palette.fg, s:palette.bg_dim)
highlight! link TelescopePromptPrefix Blue
highlight! link TelescopeSelection DiffAdd
" }}}
" lewis6991/gitsigns.nvim {{{
highlight! link GitSignsAdd GreenSign
highlight! link GitSignsChange BlueSign
highlight! link GitSignsDelete RedSign
highlight! link GitSignsAddNr Green
highlight! link GitSignsChangeNr Blue
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
call my_sonokai#highlight('IndentBlanklineContextChar', s:palette.bg4, s:palette.none, 'nocombine')
call my_sonokai#highlight('IndentBlanklineChar', s:palette.bg1, s:palette.none, 'nocombine')
highlight! link IndentBlanklineSpaceChar IndentBlanklineChar
highlight! link IndentBlanklineSpaceCharBlankline IndentBlanklineChar
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
" echasnovski/mini.nvim {{{
call my_sonokai#highlight('MiniIndentscopePrefix', s:palette.none, s:palette.none, 'nocombine')
call my_sonokai#highlight('MiniJump2dSpot', s:palette.red, s:palette.none, 'bold,nocombine')
call my_sonokai#highlight('MiniStarterCurrent', s:palette.none, s:palette.none, 'nocombine')
call my_sonokai#highlight('MiniStatuslineDevinfo', s:palette.fg, s:palette.bg3)
call my_sonokai#highlight('MiniStatuslineFileinfo', s:palette.fg, s:palette.bg3)
call my_sonokai#highlight('MiniStatuslineFilename', s:palette.grey, s:palette.bg1)
call my_sonokai#highlight('MiniStatuslineModeInactive', s:palette.grey, s:palette.bg1)
call my_sonokai#highlight('MiniStatuslineModeCommand', s:palette.bg0, s:palette.yellow, 'bold')
call my_sonokai#highlight('MiniStatuslineModeInsert', s:palette.bg0, s:palette.bg_green, 'bold')
call my_sonokai#highlight('MiniStatuslineModeNormal', s:palette.bg0, s:palette.bg_blue, 'bold')
call my_sonokai#highlight('MiniStatuslineModeOther', s:palette.bg0, s:palette.purple, 'bold')
call my_sonokai#highlight('MiniStatuslineModeReplace', s:palette.bg0, s:palette.orange, 'bold')
call my_sonokai#highlight('MiniStatuslineModeVisual', s:palette.bg0, s:palette.bg_red, 'bold')
call my_sonokai#highlight('MiniTablineCurrent', s:palette.fg, s:palette.bg4)
call my_sonokai#highlight('MiniTablineHidden', s:palette.grey, s:palette.bg2)
call my_sonokai#highlight('MiniTablineModifiedCurrent', s:palette.blue, s:palette.bg4)
call my_sonokai#highlight('MiniTablineModifiedHidden', s:palette.grey, s:palette.bg2)
call my_sonokai#highlight('MiniTablineModifiedVisible', s:palette.blue, s:palette.bg2)
call my_sonokai#highlight('MiniTablineTabpagesection', s:palette.bg0, s:palette.blue, 'bold')
call my_sonokai#highlight('MiniTablineVisible', s:palette.fg, s:palette.bg2)
call my_sonokai#highlight('MiniTestEmphasis', s:palette.none, s:palette.none, 'bold')
call my_sonokai#highlight('MiniTestFail', s:palette.red, s:palette.none, 'bold')
call my_sonokai#highlight('MiniTestPass', s:palette.green, s:palette.none, 'bold')
call my_sonokai#highlight('MiniTrailspace', s:palette.none, s:palette.red)
highlight! link MiniStarterItemBullet Grey
highlight! link MiniStarterItemPrefix Yellow
highlight! link MiniStarterQuery Blue
highlight! link MiniCompletionActiveParameter LspSignatureActiveParameter
highlight! link MiniCursorword CurrentWord
highlight! link MiniCursorwordCurrent CurrentWord
highlight! link MiniIndentscopeSymbol Grey
highlight! link MiniJump Search
highlight! link MiniStarterFooter Yellow
highlight! link MiniStarterHeader Purple
highlight! link MiniStarterInactive Comment
highlight! link MiniStarterItem Normal
highlight! link MiniStarterSection Title
highlight! link MiniSurround IncSearch
highlight! link MiniTablineFill TabLineFill
" }}}
endif
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
" }}}
" syn_begin: packer {{{
" https://github.com/wbthomason/packer.nvim
highlight! link packerSuccess Green
highlight! link packerFail Red
highlight! link packerStatusSuccess Fg
highlight! link packerStatusFail Fg
highlight! link packerWorking Yellow
highlight! link packerString Yellow
highlight! link packerPackageNotLoaded Grey
highlight! link packerRelDate Grey
highlight! link packerPackageName Blue
highlight! link packerOutput Orange
highlight! link packerHash Blue
highlight! link packerTimeTrivial Blue
highlight! link packerTimeHigh Red
highlight! link packerTimeMedium Yellow
highlight! link packerTimeLow Green
" syn_end }}}
" syn_begin: dirvish {{{
" https://github.com/justinmk/vim-dirvish
highlight! link DirvishPathTail Blue
highlight! link DirvishArg Yellow
" syn_end }}}
" syn_begin: NvimTree {{{
" https://github.com/kyazdani42/nvim-tree.lua
if !s:configuration.transparent_background
  call sonokai#highlight('NvimTreeNormal', s:palette.fg, s:palette.bg_dim)
  call sonokai#highlight('NvimTreeEndOfBuffer', s:palette.bg_dim, s:palette.bg_dim)
  call sonokai#highlight('NvimTreeVertSplit', s:palette.bg0, s:palette.bg0)
  call sonokai#highlight('NvimTreeCursorLine', s:palette.none, s:palette.bg0)
endif
highlight! link NvimTreeSymlink Fg
highlight! link NvimTreeFolderName Green
highlight! link NvimTreeRootFolder Grey
highlight! link NvimTreeFolderIcon Blue
highlight! link NvimTreeEmptyFolderName Green
highlight! link NvimTreeOpenedFolderName Green
highlight! link NvimTreeExecFile Fg
highlight! link NvimTreeOpenedFile Fg
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
" syn_begin: startify/quickmenu {{{
" https://github.com/mhinz/vim-startify
" https://github.com/skywind3000/quickmenu.vim
highlight! link StartifyBracket Grey
highlight! link StartifyFile Green
highlight! link StartifyNumber Red
highlight! link StartifyPath Grey
highlight! link StartifySlash Grey
highlight! link StartifySection Blue
highlight! link StartifyHeader Purple
highlight! link StartifySpecial Grey
" syn_end }}}
" syn_begin: quickmenu {{{
" https://github.com/skywind3000/quickmenu.vim
highlight! link QuickmenuOption Green
highlight! link QuickmenuNumber Orange
highlight! link QuickmenuBracket Grey
highlight! link QuickmenuHelp Blue
highlight! link QuickmenuSpecial Grey
highlight! link QuickmenuHeader Purple
" syn_end }}}
" syn_begin: undotree {{{
" https://github.com/mbbill/undotree
call my_sonokai#highlight('UndotreeSavedBig', s:palette.red, s:palette.none, 'bold')
highlight! link UndotreeNode Blue
highlight! link UndotreeNodeCurrent Purple
highlight! link UndotreeSeq Green
highlight! link UndotreeCurrent Blue
highlight! link UndotreeNext Yellow
highlight! link UndotreeTimeStamp Grey
highlight! link UndotreeHead Purple
highlight! link UndotreeBranch Blue
highlight! link UndotreeSavedSmall Red
" syn_end }}}
" syn_begin: dashboard {{{
" https://github.com/glepnir/dashboard-nvim
highlight! link DashboardHeader Blue
highlight! link DashboardCenter Green
highlight! link DashboardShortcut Red
highlight! link DashboardFooter Yellow
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
highlight! link markdownCode Green
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
highlight! link mkdLink Red
highlight! link mkdHeading Grey
highlight! link mkdListItem Red
highlight! link mkdRule Purple
highlight! link mkdDelimiter Grey
highlight! link mkdId Yellow
" }}}
" syn_end }}}
" syn_begin: vimwiki {{{
call my_sonokai#highlight('VimwikiHeader1', s:palette.red, s:palette.none, 'bold')
call my_sonokai#highlight('VimwikiHeader2', s:palette.orange, s:palette.none, 'bold')
call my_sonokai#highlight('VimwikiHeader3', s:palette.yellow, s:palette.none, 'bold')
call my_sonokai#highlight('VimwikiHeader4', s:palette.green, s:palette.none, 'bold')
call my_sonokai#highlight('VimwikiHeader5', s:palette.blue, s:palette.none, 'bold')
call my_sonokai#highlight('VimwikiHeader6', s:palette.purple, s:palette.none, 'bold')
call my_sonokai#highlight('VimwikiLink', s:palette.blue, s:palette.none, 'underline')
call my_sonokai#highlight('VimwikiItalic', s:palette.none, s:palette.none, 'italic')
call my_sonokai#highlight('VimwikiBold', s:palette.none, s:palette.none, 'bold')
call my_sonokai#highlight('VimwikiUnderline', s:palette.none, s:palette.none, 'underline')
highlight! link VimwikiList Red
highlight! link VimwikiTag Blue
highlight! link VimwikiCode Green
highlight! link VimwikiHR Yellow
highlight! link VimwikiHeaderChar Grey
highlight! link VimwikiMarkers Grey
highlight! link VimwikiPre Green
highlight! link VimwikiPreDelim Green
highlight! link VimwikiNoExistsLink Red
" syn_end }}}
" syn_begin: rst {{{
" builtin: https://github.com/marshallward/vim-restructuredtext{{{
call my_sonokai#highlight('rstStandaloneHyperlink', s:palette.purple, s:palette.none, 'underline')
call my_sonokai#highlight('rstEmphasis', s:palette.none, s:palette.none, 'italic')
call my_sonokai#highlight('rstStrongEmphasis', s:palette.none, s:palette.none, 'bold')
call my_sonokai#highlight('rstStandaloneHyperlink', s:palette.blue, s:palette.none, 'underline')
call my_sonokai#highlight('rstHyperlinkTarget', s:palette.blue, s:palette.none, 'underline')
highlight! link rstSubstitutionReference Blue
highlight! link rstInterpretedTextOrHyperlinkReference Green
highlight! link rstTableLines Grey
highlight! link rstInlineLiteral Green
highlight! link rstLiteralBlock Green
highlight! link rstQuotedLiteralBlock Green
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
call my_sonokai#highlight('htmlH1', s:palette.red, s:palette.none, 'bold')
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
" syn_begin: htmldjango {{{
" builtin: https://github.com/vim/vim/blob/master/runtime/syntax/htmldjango.vim{{{
highlight! link djangoTagBlock Yellow
" }}}
" syn_end }}}
" syn_begin: xml {{{
" builtin: https://github.com/chrisbra/vim-xml-ftplugin{{{
highlight! link xmlTag Green
highlight! link xmlEndTag Blue
highlight! link xmlTagName RedItalic
highlight! link xmlEqual Orange
highlight! link xmlAttrib Blue
highlight! link xmlEntity Red
highlight! link xmlEntityPunct Red
highlight! link xmlDocTypeDecl Grey
highlight! link xmlDocTypeKeyword RedItalic
highlight! link xmlCdataStart Grey
highlight! link xmlCdataCdata Purple
highlight! link xmlString Green
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
" vim-jsx-pretty: https://github.com/maxmellon/vim-jsx-pretty{{{
highlight! link jsxTagName RedItalic
highlight! link jsxOpenPunct Green
highlight! link jsxClosePunct Blue
highlight! link jsxEscapeJs Purple
highlight! link jsxAttrib Blue
" }}}
" syn_end }}}
" syn_begin: typescript/typescriptreact {{{
" vim-typescript: https://github.com/leafgarland/typescript-vim{{{
highlight! link typescriptStorageClass Red
highlight! link typescriptEndColons Fg
highlight! link typescriptSource BlueItalic
highlight! link typescriptMessage Green
highlight! link typescriptGlobalObjects BlueItalic
highlight! link typescriptInterpolation Purple
highlight! link typescriptInterpolationDelimiter Purple
highlight! link typescriptBraces Fg
highlight! link typescriptParens Fg
" }}}
" syn_begin: dart {{{
" dart-lang: https://github.com/dart-lang/dart-vim-plugin{{{
highlight! link dartCoreClasses BlueItalic
highlight! link dartTypeName BlueItalic
highlight! link dartInterpolation Purple
highlight! link dartTypeDef Red
highlight! link dartClassDecl Red
highlight! link dartLibrary Red
highlight! link dartMetadata OrangeItalic
" }}}
" syn_end }}}
" syn_begin: c/cpp/objc/objcpp {{{
" vim-cpp-enhanced-highlight: https://github.com/octol/vim-cpp-enhanced-highlight{{{
highlight! link cLabel Red
highlight! link cppSTLnamespace BlueItalic
highlight! link cppSTLtype BlueItalic
highlight! link cppAccess Red
highlight! link cppStructure Red
highlight! link cppSTLios BlueItalic
highlight! link cppSTLiterator BlueItalic
highlight! link cppSTLexception Red
" }}}
" vim-cpp-modern: https://github.com/bfrg/vim-cpp-modern{{{
highlight! link cppSTLVariable BlueItalic
" }}}
" chromatica: https://github.com/arakashic/chromatica.nvim{{{
highlight! link Member TSVariable
highlight! link Variable TSVariable
highlight! link Namespace TSNamespace
highlight! link EnumConstant TSNumber
highlight! link chromaticaException TSException
highlight! link chromaticaCast TSLabel
highlight! link OperatorOverload TSOperator
highlight! link AccessQual TSOperator
highlight! link Linkage TSOperator
highlight! link AutoType TSType
" }}}
" vim-lsp-cxx-highlight https://github.com/jackguo380/vim-lsp-cxx-highlight{{{
highlight! link LspCxxHlSkippedRegion Grey
highlight! link LspCxxHlSkippedRegionBeginEnd TSKeyword
highlight! link LspCxxHlGroupEnumConstant OrangeItalic
highlight! link LspCxxHlGroupNamespace TSNamespace
highlight! link LspCxxHlGroupMemberVariable TSVariable
" }}}
" syn_end }}}
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
" syn_begin: scala {{{
" builtin: https://github.com/derekwyatt/vim-scala{{{
highlight! link scalaNameDefinition Fg
highlight! link scalaInterpolationBoundary Purple
highlight! link scalaInterpolation Purple
highlight! link scalaTypeOperator Red
highlight! link scalaOperator Red
highlight! link scalaKeywordModifier Red
" }}}
" syn_end }}}
" syn_begin: go {{{
" builtin: https://github.com/google/vim-ft-go{{{
highlight! link goDirective Red
highlight! link goConstants OrangeItalic
highlight! link goDeclType Red
" }}}
" coc-rust-analyzer: https://github.com/fannheyward/coc-rust-analyzer {{{
highlight! link CocRustChainingHint Grey
highlight! link CocRustTypeHint Grey
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
" syn_begin: ruby {{{
" builtin: https://github.com/vim-ruby/vim-ruby{{{
highlight! link rubyKeywordAsMethod Green
highlight! link rubyInterpolation Purple
highlight! link rubyInterpolationDelimiter Purple
highlight! link rubyStringDelimiter Yellow
highlight! link rubyBlockParameterList Fg
highlight! link rubyDefine Red
highlight! link rubyModuleName Red
highlight! link rubyAccess Red
highlight! link rubyMacro Red
highlight! link rubySymbol Fg
" }}}
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
" syn_begin: sh/zsh {{{
" builtin: http://www.drchip.org/astronaut/vim/index.html#SYNTAX_SH{{{
highlight! link shRange Fg
highlight! link shOption Purple
highlight! link shQuote Yellow
highlight! link shVariable BlueItalic
highlight! link shDerefSimple BlueItalic
highlight! link shDerefVar BlueItalic
highlight! link shDerefSpecial BlueItalic
highlight! link shDerefOff BlueItalic
highlight! link shVarAssign Red
highlight! link shFunctionOne Green
highlight! link shFunctionKey Red
" }}}
" syn_end }}}
" syn_begin: zsh {{{
" builtin: https://github.com/chrisbra/vim-zsh{{{
highlight! link zshOption BlueItalic
highlight! link zshSubst Orange
highlight! link zshFunction Green
" }}}
" syn_end }}}
" syn_begin: ps1 {{{
" vim-ps1: https://github.com/PProvost/vim-ps1{{{
highlight! link ps1FunctionInvocation Green
highlight! link ps1FunctionDeclaration Green
highlight! link ps1InterpolationDelimiter Purple
highlight! link ps1BuiltIn BlueItalic
" }}}
" syn_end }}}
" syn_begin: json {{{
highlight! link jsonKeyword Blue
highlight! link jsonString Green
highlight! link jsonBoolean Red
highlight! link jsonNoise Grey
highlight! link jsonQuote Grey
highlight! link jsonBraces Fg
" syn_end }}}
" syn_begin: yaml {{{
highlight! link yamlKey Red
highlight! link yamlConstant BlueItalic
highlight! link yamlString Green
" syn_end }}}
" syn_begin: toml {{{
call my_sonokai#highlight('tomlTable', s:palette.purple, s:palette.none, 'bold')
highlight! link tomlKey Red
highlight! link tomlBoolean Blue
highlight! link tomlString Green
highlight! link tomlTableArray tomlTable
" syn_end }}}
" syn_begin: gitcommit {{{
highlight! link gitcommitSummary Red
highlight! link gitcommitUntracked Grey
highlight! link gitcommitDiscarded Grey
highlight! link gitcommitSelected Grey
highlight! link gitcommitUnmerged Grey
highlight! link gitcommitOnBranch Grey
highlight! link gitcommitArrow Grey
highlight! link gitcommitFile Green
" syn_end }}}
" syn_begin: dosini {{{
call my_sonokai#highlight('dosiniHeader', s:palette.red, s:palette.none, 'bold')
highlight! link dosiniLabel Blue
highlight! link dosiniValue Green
highlight! link dosiniNumber Green
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

call my_sonokai#highlight('GlancePreviewNormal', s:palette.fg, s:palette.black)
call my_sonokai#highlight('GlancePreviewMatch', s:palette.fg, s:palette.black)

call my_sonokai#highlight('NeoTreeNormalNC', s:palette.fg, s:palette.neotreebg)
call my_sonokai#highlight('NeoTreeNormal', s:palette.fg, s:palette.neotreebg)
call my_sonokai#highlight('NeoTreeFloatBorder', s:palette.grey_dim, s:palette.neotreebg)

" Org mode
"
call my_sonokai#highlight('OrgTSHeadlineLevel1', s:blue, s:palette.none, 'bold')
hi! link OrgTSHeadlineLevel2 OrgTSHeadlineLevel1