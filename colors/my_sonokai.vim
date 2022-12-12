" -----------------------------------------------------------------------------
" Name:         Sonokai
" Description:  High Contrast & Vivid Color Scheme based on Monokai Pro
" Author:       Sainnhepark <i@sainnhe.dev>
" Website:      https://github.com/sainnhe/sonokai/
" License:      MIT
" -----------------------------------------------------------------------------

" Initialization: {{{
let s:configuration = sonokai#get_configuration()
let s:palette = sonokai#get_palette(s:configuration.style, s:configuration.colors_override)
let s:path = expand('<sfile>:p') " the path of this script
let s:last_modified = 'Sun Nov 13 11:49:38 UTC 2022'
let g:sonokai_loaded_file_types = []
let s:darkbg = ['#111118', 237]
let s:teal = ['#109090', 238]
let s:blue = ['#4a4ac8', 239]
let s:darkpurple = ['#a030a0', 240]
let s:purple = ['#c030c0', 241]
let s:darkred = ['#601010', 249]
let s:darkestred = ['#161616', 249]
let s:darkestblue = ['#10101a', 247]
let s:string = ['#30a03f', 231]
let s:bg = ['#181822', 0]
let s:statuslinebg = [ '#262626', 208 ]
let s:palette.fg = [ '#a5a0b5', 1 ]
let s:palette.grey = [ '#707070', 2 ]

if !(exists('g:colors_name') && g:colors_name ==# 'my_sonokai' && s:configuration.better_performance)
  highlight clear
  if exists('syntax_on')
    syntax reset
  endif
endif

let g:colors_name = 'my_sonokai'

if !(has('termguicolors') && &termguicolors) && !has('gui_running') && &t_Co != 256
  finish
endif
" }}}
" Common Highlight Groups: {{{
" UI: {{{
call sonokai#highlight("Braces", s:palette.red, s:palette.none)
call sonokai#highlight('ScrollView', s:teal, s:blue)
if s:configuration.transparent_background >= 1
  call sonokai#highlight('Normal', s:palette.fg, s:bg)
  call sonokai#highlight('Terminal', s:palette.fg, s:palette.none)
  if s:configuration.show_eob
    call sonokai#highlight('EndOfBuffer', s:palette.bg4, s:palette.none)
  else
    call sonokai#highlight('EndOfBuffer', s:palette.bg0, s:palette.none)
  endif
  call sonokai#highlight('Folded', s:palette.yellow, s:darkred, 'bold')
  call sonokai#highlight('ToolbarLine', s:palette.fg, s:palette.none)
  call sonokai#highlight('FoldColumn', s:palette.grey_dim, s:darkestred)
else
  call sonokai#highlight('Normal', s:palette.fg, s:palette.bg0)
  call sonokai#highlight('Terminal', s:palette.fg, s:palette.bg0)
  if s:configuration.show_eob
    call sonokai#highlight('EndOfBuffer', s:palette.bg3, s:palette.bg0)
  else
    call sonokai#highlight('EndOfBuffer', s:palette.bg0, s:palette.bg0)
  endif
  call sonokai#highlight('Folded', s:palette.yellow, s:darkred, 'bold')
  call sonokai#highlight('ToolbarLine', s:palette.fg, s:palette.bg2)
  call sonokai#highlight('FoldColumn', s:palette.grey_dim, s:darkestred)
endif
call sonokai#highlight('SignColumn', s:palette.fg, s:palette.none)
call sonokai#highlight('IncSearch', s:palette.yellow, s:darkpurple)
call sonokai#highlight('Search', s:palette.yellow, s:blue)
call sonokai#highlight('ColorColumn', s:palette.none, s:palette.bg1)
call sonokai#highlight('Conceal', s:palette.grey_dim, s:palette.none)
if s:configuration.cursor ==# 'auto'
  call sonokai#highlight('Cursor', s:palette.none, s:palette.none, 'reverse')
else
  call sonokai#highlight('Cursor', s:palette.bg0, s:palette[s:configuration.cursor])
endif
highlight! link vCursor Cursor
highlight! link iCursor Cursor
highlight! link lCursor Cursor
highlight! link CursorIM Cursor
call sonokai#highlight('FocusedSymbol', s:palette.yellow, s:palette.bg1, 'bold')
if &diff
  call sonokai#highlight('CursorLine', s:palette.none, s:palette.none, 'underline')
  call sonokai#highlight('CursorColumn', s:palette.none, s:palette.none, 'bold')
else
  call sonokai#highlight('CursorLine', s:palette.none, s:palette.bg1)
  call sonokai#highlight('CursorColumn', s:palette.none, s:palette.bg1)
endif
call sonokai#highlight('LineNr', s:palette.grey_dim, s:palette.none)
if &diff
  call sonokai#highlight('CursorLineNr', s:palette.fg, s:palette.none, 'underline')
else
  call sonokai#highlight('CursorLineNr', s:palette.fg, s:palette.none)
endif
call sonokai#highlight('DiffAdd', s:palette.none, s:palette.diff_green)
call sonokai#highlight('DiffChange', s:palette.none, s:palette.diff_blue)
call sonokai#highlight('DiffDelete', s:palette.none, s:palette.diff_red)
call sonokai#highlight('DiffText', s:palette.bg0, s:palette.blue)
call sonokai#highlight('Directory', s:palette.green, s:palette.none)
call sonokai#highlight('ErrorMsg', s:palette.red, s:palette.none, 'bold,underline')
call sonokai#highlight('WarningMsg', s:palette.yellow, s:palette.none, 'bold')
call sonokai#highlight('ModeMsg', s:palette.fg, s:palette.none, 'bold')
call sonokai#highlight('MoreMsg', s:palette.blue, s:palette.none, 'bold')
call sonokai#highlight('MatchParen', s:palette.yellow, s:darkred)
call sonokai#highlight('NonText', s:palette.bg4, s:palette.none)
call sonokai#highlight('Whitespace', s:palette.green, s:palette.none)
call sonokai#highlight('SpecialKey', s:palette.bg4, s:palette.none)
call sonokai#highlight('Pmenu', s:palette.fg, s:palette.none)
call sonokai#highlight('PmenuSbar', s:palette.none, s:palette.bg2)
call sonokai#highlight('PmenuSel', s:palette.yellow, s:darkpurple)
highlight! link WildMenu PmenuSel
call sonokai#highlight('PmenuThumb', s:palette.none, s:palette.grey)
call sonokai#highlight('NormalFloat', s:palette.fg, s:darkestred)
call sonokai#highlight('FloatBorder', s:palette.grey, s:palette.none)
call sonokai#highlight('CocFloating', s:palette.fg, s:palette.none)
call sonokai#highlight('Question', s:palette.yellow, s:palette.none)
if s:configuration.spell_foreground ==# 'none'
  call sonokai#highlight('SpellBad', s:palette.none, s:palette.none, 'undercurl', s:palette.red)
  call sonokai#highlight('SpellCap', s:palette.none, s:palette.none, 'undercurl', s:palette.yellow)
  call sonokai#highlight('SpellLocal', s:palette.none, s:palette.none, 'undercurl', s:palette.blue)
  call sonokai#highlight('SpellRare', s:palette.none, s:palette.none, 'undercurl', s:palette.purple)
else
  call sonokai#highlight('SpellBad', s:palette.red, s:palette.none, 'undercurl', s:palette.red)
  call sonokai#highlight('SpellCap', s:palette.yellow, s:palette.none, 'undercurl', s:palette.yellow)
  call sonokai#highlight('SpellLocal', s:palette.blue, s:palette.none, 'undercurl', s:palette.blue)
  call sonokai#highlight('SpellRare', s:palette.purple, s:palette.none, 'undercurl', s:palette.purple)
endif
if s:configuration.transparent_background == 2
  call sonokai#highlight('StatusLine', s:palette.fg, s:statuslinebg)
  call sonokai#highlight('StatusLineTerm', s:palette.fg, s:palette.none)
  call sonokai#highlight('StatusLineNC', s:palette.grey, s:statuslinebg)
  call sonokai#highlight('StatusLineTermNC', s:palette.grey, s:palette.none)
  call sonokai#highlight('TabLine', s:palette.fg, s:palette.bg4)
  call sonokai#highlight('TabLineFill', s:palette.grey, s:palette.none)
  call sonokai#highlight('TabLineSel', s:palette.bg0, s:palette.bg_red)
else
  call sonokai#highlight('StatusLine', s:palette.fg, s:statuslinebg)
  call sonokai#highlight('StatusLineTerm', s:palette.fg, s:palette.bg3)
  call sonokai#highlight('StatusLineNC', s:palette.grey, s:statuslinebg)
  call sonokai#highlight('StatusLineTermNC', s:palette.grey, s:palette.bg1)
  call sonokai#highlight('TabLine', s:palette.fg, s:palette.bg4)
  call sonokai#highlight('TabLineFill', s:palette.grey, s:palette.bg1)
  call sonokai#highlight('TabLineSel', s:palette.bg0, s:palette.bg_red)
endif
call sonokai#highlight('VertSplit', s:statuslinebg, s:statuslinebg)
highlight! link WinSeparator VertSplit
call sonokai#highlight('Visual', s:palette.none, s:palette.bg3)
call sonokai#highlight('VisualNOS', s:palette.none, s:palette.bg3, 'underline')
call sonokai#highlight('QuickFixLine', s:palette.blue, s:palette.none, 'bold')
call sonokai#highlight('Debug', s:palette.yellow, s:palette.none)
call sonokai#highlight('debugPC', s:palette.bg0, s:palette.green)
call sonokai#highlight('debugBreakpoint', s:palette.bg0, s:palette.red)
call sonokai#highlight('ToolbarButton', s:palette.bg0, s:palette.bg_blue)
call sonokai#highlight('Substitute', s:palette.bg0, s:palette.yellow)
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
" }}}
" Syntax: {{{
if s:configuration.enable_italic
  call sonokai#highlight('Type', s:palette.blue, s:palette.none, 'italic')
  call sonokai#highlight('Structure', s:palette.blue, s:palette.none, 'italic')
  call sonokai#highlight('StorageClass', s:palette.blue, s:palette.none, 'italic')
  call sonokai#highlight('Identifier', s:palette.orange, s:palette.none, 'italic')
  call sonokai#highlight('Constant', s:palette.orange, s:palette.none, 'italic')
else
  call sonokai#highlight('Type', s:darkpurple, s:palette.none, 'bold')
  call sonokai#highlight('Structure', s:darkpurple, s:palette.none, 'bold')
  call sonokai#highlight('StorageClass', s:purple, s:palette.none, 'bold')
  call sonokai#highlight('Identifier', s:palette.orange, s:palette.none)
  call sonokai#highlight('Constant', s:palette.orange, s:palette.none)
endif
call sonokai#highlight('PreProc', s:palette.grey, s:palette.none, 'bold')
call sonokai#highlight('PreCondit', s:palette.red, s:palette.none)
call sonokai#highlight('Include', s:palette.green, s:palette.none)
call sonokai#highlight('Keyword', s:blue, s:palette.none, 'bold')
call sonokai#highlight('Define', s:palette.red, s:palette.none)
call sonokai#highlight('Typedef', s:palette.red, s:palette.none, 'bold')
call sonokai#highlight('Exception', s:palette.red, s:palette.none)
call sonokai#highlight('Conditional', s:palette.blue, s:palette.none, 'bold')
call sonokai#highlight('Repeat', s:palette.blue, s:palette.none, 'bold')
call sonokai#highlight('Statement', s:palette.blue, s:palette.none, 'bold')
call sonokai#highlight('Macro', s:palette.purple, s:palette.none)
call sonokai#highlight('Error', s:palette.red, s:palette.none)
call sonokai#highlight('Label', s:palette.purple, s:palette.none)
call sonokai#highlight('Special', s:palette.purple, s:palette.none)
call sonokai#highlight('SpecialChar', s:palette.purple, s:palette.none)
call sonokai#highlight('Boolean', s:palette.purple, s:palette.none)
call sonokai#highlight('String', s:string, s:palette.none)
call sonokai#highlight('Character', s:palette.yellow, s:palette.none)
call sonokai#highlight('Number', s:palette.purple, s:palette.none, 'bold')
call sonokai#highlight('Float', s:palette.purple, s:palette.none)
call sonokai#highlight('Function', s:teal, s:palette.none, 'bold')
call sonokai#highlight('Operator', s:palette.red, s:palette.none, 'bold')
call sonokai#highlight('Title', s:palette.red, s:palette.none, 'bold')
call sonokai#highlight('Tag', s:palette.orange, s:palette.none)
call sonokai#highlight('Delimiter', s:palette.red, s:palette.none, 'bold')
if s:configuration.disable_italic_comment
  call sonokai#highlight('Comment', s:palette.grey, s:palette.none)
  call sonokai#highlight('SpecialComment', s:palette.grey, s:palette.none)
  call sonokai#highlight('Todo', s:palette.blue, s:palette.none)
else
  call sonokai#highlight('Comment', s:palette.grey, s:palette.none, 'italic')
  call sonokai#highlight('SpecialComment', s:palette.grey, s:palette.none, 'italic')
  call sonokai#highlight('Todo', s:palette.blue, s:palette.none, 'italic')
endif
call sonokai#highlight('Ignore', s:palette.grey, s:palette.none)
call sonokai#highlight('Underlined', s:palette.none, s:palette.none, 'underline')
" }}}
" Predefined Highlight Groups: {{{
call sonokai#highlight('Fg', s:palette.fg, s:palette.none)
call sonokai#highlight('Grey', s:palette.grey, s:palette.none)
call sonokai#highlight('Red', s:palette.red, s:palette.none)
call sonokai#highlight('Orange', s:palette.orange, s:palette.none)
call sonokai#highlight('OrangeBold', s:palette.orange, s:palette.none, 'bold')
call sonokai#highlight('Yellow', s:palette.yellow, s:palette.none)
call sonokai#highlight('Green', s:palette.green, s:palette.none)
call sonokai#highlight('Blue', s:blue, s:palette.none)
call sonokai#highlight('BlueBold', s:blue, s:palette.none, 'bold')
call sonokai#highlight('Purple', s:purple, s:palette.none)
call sonokai#highlight('PurpleBold', s:purple, s:palette.none, 'bold')
call sonokai#highlight('DarkPurple', s:darkpurple, s:palette.none)
call sonokai#highlight('DarkPurpleBold', s:darkpurple, s:palette.none, 'bold')
call sonokai#highlight('RedBold', s:palette.red, s:palette.none, 'bold')
call sonokai#highlight('Teal', s:teal, s:palette.none)
call sonokai#highlight('TealBold', s:teal, s:palette.none, 'bold')

if s:configuration.enable_italic
  call sonokai#highlight('RedItalic', s:palette.red, s:palette.none, 'italic')
  call sonokai#highlight('OrangeItalic', s:palette.orange, s:palette.none, 'italic')
  call sonokai#highlight('YellowItalic', s:palette.yellow, s:palette.none, 'italic')
  call sonokai#highlight('GreenItalic', s:palette.green, s:palette.none, 'italic')
  call sonokai#highlight('BlueItalic', s:palette.blue, s:palette.none, 'italic')
  call sonokai#highlight('PurpleItalic', s:palette.purple, s:palette.none, 'italic')
else
  call sonokai#highlight('RedItalic', s:palette.red, s:palette.none)
  call sonokai#highlight('OrangeItalic', s:palette.orange, s:palette.none)
  call sonokai#highlight('YellowItalic', s:palette.yellow, s:palette.none)
  call sonokai#highlight('GreenItalic', s:palette.green, s:palette.none)
  call sonokai#highlight('BlueItalic', s:palette.blue, s:palette.none, 'bold')
  call sonokai#highlight('PurpleItalic', s:palette.purple, s:palette.none)
endif
call sonokai#highlight('RedSign', s:palette.red, s:palette.none)
call sonokai#highlight('OrangeSign', s:palette.orange, s:palette.none)
call sonokai#highlight('YellowSign', s:palette.yellow, s:palette.none)
call sonokai#highlight('GreenSign', s:palette.green, s:palette.none)
call sonokai#highlight('BlueSign', s:palette.blue, s:palette.none)
call sonokai#highlight('PurpleSign', s:palette.purple, s:palette.none)
if s:configuration.diagnostic_text_highlight
  call sonokai#highlight('ErrorText', s:palette.none, s:palette.diff_red, 'undercurl', s:palette.red)
  call sonokai#highlight('WarningText', s:palette.none, s:palette.diff_yellow, 'undercurl', s:palette.yellow)
  call sonokai#highlight('InfoText', s:palette.none, s:palette.diff_blue, 'undercurl', s:palette.blue)
  call sonokai#highlight('HintText', s:palette.none, s:palette.diff_green, 'undercurl', s:palette.green)
else
  call sonokai#highlight('ErrorText', s:palette.none, s:palette.none, 'undercurl', s:palette.red)
  call sonokai#highlight('WarningText', s:palette.none, s:palette.none, 'undercurl', s:palette.yellow)
  call sonokai#highlight('InfoText', s:palette.none, s:palette.none, 'undercurl', s:palette.blue)
  call sonokai#highlight('HintText', s:palette.none, s:palette.none, 'undercurl', s:palette.green)
endif
if s:configuration.diagnostic_line_highlight
  call sonokai#highlight('ErrorLine', s:palette.none, s:palette.diff_red)
  call sonokai#highlight('WarningLine', s:palette.none, s:palette.diff_yellow)
  call sonokai#highlight('InfoLine', s:palette.none, s:palette.diff_blue)
  call sonokai#highlight('HintLine', s:palette.none, s:palette.diff_green)
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
call sonokai#highlight('ErrorFloat', s:palette.red, s:palette.none) " was palette.bg2"
call sonokai#highlight('WarningFloat', s:palette.yellow, s:palette.none)
call sonokai#highlight('InfoFloat', s:palette.blue, s:palette.none)
call sonokai#highlight('HintFloat', s:palette.green, s:palette.none)
if &diff
  call sonokai#highlight('CurrentWord', s:palette.bg0, s:palette.green)
elseif s:configuration.current_word ==# 'grey background'
  call sonokai#highlight('CurrentWord', s:palette.none, s:palette.bg2)
else
  call sonokai#highlight('CurrentWord', s:palette.none, s:palette.none, s:configuration.current_word)
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
call sonokai#highlight('TSStrong', s:palette.none, s:palette.none, 'bold')
call sonokai#highlight('TSEmphasis', s:palette.none, s:palette.none, 'italic')
call sonokai#highlight('TSUnderline', s:palette.none, s:palette.none, 'underline')
call sonokai#highlight('TSNote', s:palette.bg0, s:palette.blue, 'bold')
call sonokai#highlight('TSWarning', s:palette.bg0, s:palette.yellow, 'bold')
call sonokai#highlight('TSDanger', s:palette.bg0, s:palette.red, 'bold')
highlight! link TSAnnotation BlueItalic
highlight! link TSAttribute BlueItalic
highlight! link TSBoolean Purple
highlight! link TSCharacter Yellow
highlight! link TSComment Comment
highlight! link TSConditional BlueBold
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
highlight! link TSKeywordFunction Red
highlight! link TSKeywordOperator Red
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
" vim-syntastic/syntastic {{{
highlight! link SyntasticError ErrorText
highlight! link SyntasticWarning WarningText
highlight! link SyntasticErrorSign RedSign
highlight! link SyntasticWarningSign YellowSign
highlight! link SyntasticErrorLine ErrorLine
highlight! link SyntasticWarningLine WarningLine
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
call sonokai#highlight('VMCursor', s:palette.blue, s:palette.grey_dim)
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
  call sonokai#highlight('IndentGuidesOdd', s:palette.bg0, s:palette.bg1)
  call sonokai#highlight('IndentGuidesEven', s:palette.bg0, s:palette.bg2)
endif
" }}}
" unblevable/quick-scope {{{
call sonokai#highlight('QuickScopePrimary', s:palette.green, s:palette.none, 'underline')
call sonokai#highlight('QuickScopeSecondary', s:palette.blue, s:palette.none, 'underline')
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
call sonokai#highlight('TelescopeMatching', s:palette.green, s:palette.none, 'bold')
highlight! link TelescopeBorder Grey
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
call sonokai#highlight('HopNextKey', s:palette.red, s:palette.none, 'bold')
call sonokai#highlight('HopNextKey1', s:palette.blue, s:palette.none, 'bold')
highlight! link HopNextKey2 Blue
highlight! link HopUnmatched Grey
" }}}
" lukas-reineke/indent-blankline.nvim {{{
call sonokai#highlight('IndentBlanklineContextChar', s:palette.bg4, s:palette.none, 'nocombine')
call sonokai#highlight('IndentBlanklineChar', s:palette.bg1, s:palette.none, 'nocombine')
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
call sonokai#highlight('InclineNormalNC', s:palette.grey, s:palette.bg2)
" }}}
" echasnovski/mini.nvim {{{
call sonokai#highlight('MiniIndentscopePrefix', s:palette.none, s:palette.none, 'nocombine')
call sonokai#highlight('MiniJump2dSpot', s:palette.red, s:palette.none, 'bold,nocombine')
call sonokai#highlight('MiniStarterCurrent', s:palette.none, s:palette.none, 'nocombine')
call sonokai#highlight('MiniStatuslineDevinfo', s:palette.fg, s:palette.bg3)
call sonokai#highlight('MiniStatuslineFileinfo', s:palette.fg, s:palette.bg3)
call sonokai#highlight('MiniStatuslineFilename', s:palette.grey, s:palette.bg1)
call sonokai#highlight('MiniStatuslineModeInactive', s:palette.grey, s:palette.bg1)
call sonokai#highlight('MiniStatuslineModeCommand', s:palette.bg0, s:palette.yellow, 'bold')
call sonokai#highlight('MiniStatuslineModeInsert', s:palette.bg0, s:palette.bg_green, 'bold')
call sonokai#highlight('MiniStatuslineModeNormal', s:palette.bg0, s:palette.bg_blue, 'bold')
call sonokai#highlight('MiniStatuslineModeOther', s:palette.bg0, s:palette.purple, 'bold')
call sonokai#highlight('MiniStatuslineModeReplace', s:palette.bg0, s:palette.orange, 'bold')
call sonokai#highlight('MiniStatuslineModeVisual', s:palette.bg0, s:palette.bg_red, 'bold')
call sonokai#highlight('MiniTablineCurrent', s:palette.fg, s:palette.bg4)
call sonokai#highlight('MiniTablineHidden', s:palette.grey, s:palette.bg2)
call sonokai#highlight('MiniTablineModifiedCurrent', s:palette.blue, s:palette.bg4)
call sonokai#highlight('MiniTablineModifiedHidden', s:palette.grey, s:palette.bg2)
call sonokai#highlight('MiniTablineModifiedVisible', s:palette.blue, s:palette.bg2)
call sonokai#highlight('MiniTablineTabpagesection', s:palette.bg0, s:palette.blue, 'bold')
call sonokai#highlight('MiniTablineVisible', s:palette.fg, s:palette.bg2)
call sonokai#highlight('MiniTestEmphasis', s:palette.none, s:palette.none, 'bold')
call sonokai#highlight('MiniTestFail', s:palette.red, s:palette.none, 'bold')
call sonokai#highlight('MiniTestPass', s:palette.green, s:palette.none, 'bold')
call sonokai#highlight('MiniTrailspace', s:palette.none, s:palette.red)
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
" Generate the `after/syntax` directory based on the comment tags in this file.
" For example, the content between `syn_begin: sh/zsh` and `syn_end` will be placed in `after/syntax/sh/sonokai.vim` and `after/syntax/zsh/sonokai.vim`.
if sonokai#syn_exists(s:path) " If the syntax files exist.
  if s:configuration.better_performance
    if !sonokai#syn_newest(s:path, s:last_modified) " Regenerate if it's not up to date.
      call sonokai#syn_clean(s:path, 0)
      call sonokai#syn_gen(s:path, s:last_modified, 'update')
    endif
    finish
  else
    call sonokai#syn_clean(s:path, 1)
  endif
else
  if s:configuration.better_performance
    call sonokai#syn_gen(s:path, s:last_modified, 'generate')
    finish
  endif
endif
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
call sonokai#highlight('UndotreeSavedBig', s:palette.red, s:palette.none, 'bold')
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
call sonokai#highlight('markdownH1', s:palette.red, s:palette.none, 'bold')
call sonokai#highlight('markdownH2', s:palette.orange, s:palette.none, 'bold')
call sonokai#highlight('markdownH3', s:palette.yellow, s:palette.none, 'bold')
call sonokai#highlight('markdownH4', s:palette.green, s:palette.none, 'bold')
call sonokai#highlight('markdownH5', s:palette.blue, s:palette.none, 'bold')
call sonokai#highlight('markdownH6', s:palette.purple, s:palette.none, 'bold')
call sonokai#highlight('markdownUrl', s:palette.blue, s:palette.none, 'underline')
call sonokai#highlight('markdownItalic', s:palette.none, s:palette.none, 'italic')
call sonokai#highlight('markdownBold', s:palette.none, s:palette.none, 'bold')
call sonokai#highlight('markdownItalicDelimiter', s:palette.grey, s:palette.none, 'italic')
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
call sonokai#highlight('mkdURL', s:palette.blue, s:palette.none, 'underline')
call sonokai#highlight('mkdInlineURL', s:palette.blue, s:palette.none, 'underline')
call sonokai#highlight('mkdItalic', s:palette.grey, s:palette.none, 'italic')
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
call sonokai#highlight('VimwikiHeader1', s:palette.red, s:palette.none, 'bold')
call sonokai#highlight('VimwikiHeader2', s:palette.orange, s:palette.none, 'bold')
call sonokai#highlight('VimwikiHeader3', s:palette.yellow, s:palette.none, 'bold')
call sonokai#highlight('VimwikiHeader4', s:palette.green, s:palette.none, 'bold')
call sonokai#highlight('VimwikiHeader5', s:palette.blue, s:palette.none, 'bold')
call sonokai#highlight('VimwikiHeader6', s:palette.purple, s:palette.none, 'bold')
call sonokai#highlight('VimwikiLink', s:palette.blue, s:palette.none, 'underline')
call sonokai#highlight('VimwikiItalic', s:palette.none, s:palette.none, 'italic')
call sonokai#highlight('VimwikiBold', s:palette.none, s:palette.none, 'bold')
call sonokai#highlight('VimwikiUnderline', s:palette.none, s:palette.none, 'underline')
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
call sonokai#highlight('rstStandaloneHyperlink', s:palette.purple, s:palette.none, 'underline')
call sonokai#highlight('rstEmphasis', s:palette.none, s:palette.none, 'italic')
call sonokai#highlight('rstStrongEmphasis', s:palette.none, s:palette.none, 'bold')
call sonokai#highlight('rstStandaloneHyperlink', s:palette.blue, s:palette.none, 'underline')
call sonokai#highlight('rstHyperlinkTarget', s:palette.blue, s:palette.none, 'underline')
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
highlight! link texDocType RedItalic
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
call sonokai#highlight('htmlH1', s:palette.red, s:palette.none, 'bold')
call sonokai#highlight('htmlH2', s:palette.orange, s:palette.none, 'bold')
call sonokai#highlight('htmlH3', s:palette.yellow, s:palette.none, 'bold')
call sonokai#highlight('htmlH4', s:palette.green, s:palette.none, 'bold')
call sonokai#highlight('htmlH5', s:palette.blue, s:palette.none, 'bold')
call sonokai#highlight('htmlH6', s:palette.purple, s:palette.none, 'bold')
call sonokai#highlight('htmlLink', s:palette.none, s:palette.none, 'underline')
call sonokai#highlight('htmlBold', s:palette.none, s:palette.none, 'bold')
call sonokai#highlight('htmlBoldUnderline', s:palette.none, s:palette.none, 'bold,underline')
call sonokai#highlight('htmlBoldItalic', s:palette.none, s:palette.none, 'bold,italic')
call sonokai#highlight('htmlBoldUnderlineItalic', s:palette.none, s:palette.none, 'bold,underline,italic')
call sonokai#highlight('htmlUnderline', s:palette.none, s:palette.none, 'underline')
call sonokai#highlight('htmlUnderlineItalic', s:palette.none, s:palette.none, 'underline,italic')
call sonokai#highlight('htmlItalic', s:palette.none, s:palette.none, 'italic')
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
" syn_begin: css/scss/sass/less {{{
" builtin: https://github.com/JulesWang/css.vim{{{
highlight! link cssStringQ Green
highlight! link cssStringQQ Green
highlight! link cssAttrComma Grey
highlight! link cssBraces Red
highlight! link cssTagName Purple
highlight! link cssClassNameDot Grey
highlight! link cssClassName Red
highlight! link cssFunctionName Orange
highlight! link cssAttr Green
highlight! link cssCommonAttr Green
highlight! link cssProp Blue
highlight! link cssPseudoClassId Yellow
highlight! link cssPseudoClassFn Green
highlight! link cssPseudoClass Yellow
highlight! link cssImportant Red
highlight! link cssSelectorOp Orange
highlight! link cssSelectorOp2 Orange
highlight! link cssColor Green
highlight! link cssUnitDecorators Green
highlight! link cssValueLength Green
highlight! link cssValueInteger Green
highlight! link cssValueNumber Green
highlight! link cssValueAngle Green
highlight! link cssValueTime Green
highlight! link cssValueFrequency Green
highlight! link cssVendor Grey
highlight! link cssNoise Grey
" }}}
" syn_end }}}
" syn_begin: scss {{{
" scss-syntax: https://github.com/cakebaker/scss-syntax.vim{{{
highlight! link scssMixinName Orange
highlight! link scssSelectorChar Grey
highlight! link scssSelectorName Red
highlight! link scssInterpolationDelimiter Yellow
highlight! link scssVariableValue Green
highlight! link scssNull Purple
highlight! link scssBoolean Purple
highlight! link scssVariableAssignment Grey
highlight! link scssAttribute Green
highlight! link scssFunctionName Orange
highlight! link scssVariable Fg
highlight! link scssAmpersand Purple
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
" syn_begin: cs {{{
" builtin: https://github.com/nickspoons/vim-cs{{{
highlight! link csUnspecifiedStatement Red
highlight! link csStorage Red
highlight! link csClass Red
highlight! link csNewType BlueItalic
highlight! link csContextualStatement Red
highlight! link csInterpolationDelimiter Purple
highlight! link csInterpolation Purple
highlight! link csEndColon Fg
" }}}
" syn_end }}}
" syn_begin: python {{{
" builtin: {{{
highlight! link pythonBuiltin BlueItalic
highlight! link pythonExceptions Red
highlight! link pythonDecoratorName OrangeItalic
" }}}
" python-syntax: https://github.com/vim-python/python-syntax{{{
highlight! link pythonExClass BlueItalic
highlight! link pythonBuiltinType BlueItalic
highlight! link pythonBuiltinObj OrangeItalic
highlight! link pythonDottedName OrangeItalic
highlight! link pythonBuiltinFunc Green
highlight! link pythonFunction Green
highlight! link pythonDecorator OrangeItalic
highlight! link pythonInclude Include
highlight! link pythonImport PreProc
highlight! link pythonOperator Red
highlight! link pythonConditional Red
highlight! link pythonRepeat Red
highlight! link pythonException Red
highlight! link pythonNone OrangeItalic
highlight! link pythonCoding Grey
highlight! link pythonDot Grey
" }}}
" semshi: https://github.com/numirias/semshi{{{
call sonokai#highlight('semshiUnresolved', s:palette.orange, s:palette.none, 'undercurl')
highlight! link semshiImported TSInclude
highlight! link semshiParameter TSParameter
highlight! link semshiParameterUnused Grey
highlight! link semshiSelf TSVariableBuiltin
highlight! link semshiGlobal TSType
highlight! link semshiBuiltin TSTypeBuiltin
highlight! link semshiAttribute TSAttribute
highlight! link semshiLocal TSKeyword
highlight! link semshiFree TSKeyword
highlight! link semshiSelected CurrentWord
highlight! link semshiErrorSign RedSign
highlight! link semshiErrorChar RedSign
" }}}
" syn_end }}}
" syn_begin: lua {{{
" builtin: {{{
highlight! link luaFunc Green
highlight! link luaFunction Red
highlight! link luaTable Fg
highlight! link luaIn Red
" }}}
" vim-lua: https://github.com/tbastos/vim-lua{{{
highlight! link luaFuncCall Green
highlight! link luaLocal Red
highlight! link luaSpecialValue Green
highlight! link luaBraces Fg
highlight! link luaBuiltIn BlueItalic
highlight! link luaNoise Grey
highlight! link luaLabel Purple
highlight! link luaFuncTable BlueItalic
highlight! link luaFuncArgName Fg
highlight! link luaEllipsis Red
highlight! link luaDocTag Green
" }}}
" syn_end }}}
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
" syn_begin: rust {{{
" builtin: https://github.com/rust-lang/rust.vim{{{
highlight! link rustStructure Red
highlight! link rustIdentifier OrangeItalic
highlight! link rustModPath BlueItalic
highlight! link rustModPathSep Grey
highlight! link rustSelf OrangeItalic
highlight! link rustSuper OrangeItalic
highlight! link rustDeriveTrait Purple
highlight! link rustEnumVariant Purple
highlight! link rustMacroVariable OrangeItalic
highlight! link rustAssert Green
highlight! link rustPanic Green
highlight! link rustPubScopeCrate BlueItalic
highlight! link rustAttribute Purple
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
" syn_begin: php {{{
" builtin: https://jasonwoof.com/gitweb/?p=vim-syntax.git;a=blob;f=php.vim;hb=HEAD{{{
highlight! link phpVarSelector Fg
highlight! link phpIdentifier Fg
highlight! link phpDefine Green
highlight! link phpStructure Red
highlight! link phpSpecialFunction Green
highlight! link phpInterpSimpleCurly Purple
highlight! link phpComparison Red
highlight! link phpMethodsVar Fg
highlight! link phpInterpVarname Fg
highlight! link phpMemberSelector Red
highlight! link phpLabel Red
" }}}
" php.vim: https://github.com/StanAngeloff/php.vim{{{
highlight! link phpParent Fg
highlight! link phpNowDoc Yellow
highlight! link phpFunction Green
highlight! link phpMethod Green
highlight! link phpClass BlueItalic
highlight! link phpSuperglobals BlueItalic
highlight! link phpNullValue OrangeItalic
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
" syn_end }}}
" syn_begin: haskell {{{
" haskell-vim: https://github.com/neovimhaskell/haskell-vim{{{
highlight! link haskellBrackets Fg
highlight! link haskellIdentifier OrangeItalic
highlight! link haskellDecl Red
highlight! link haskellType BlueItalic
highlight! link haskellDeclKeyword Red
highlight! link haskellWhere Red
highlight! link haskellDeriving Red
highlight! link haskellForeignKeywords Red
" }}}
" syn_end }}}
" syn_begin: perl/pod {{{
" builtin: https://github.com/vim-perl/vim-perl{{{
highlight! link perlStatementPackage Red
highlight! link perlStatementInclude Red
highlight! link perlStatementStorage Red
highlight! link perlStatementList Red
highlight! link perlMatchStartEnd Red
highlight! link perlVarSimpleMemberName Green
highlight! link perlVarSimpleMember Fg
highlight! link perlMethod Green
highlight! link podVerbatimLine Green
highlight! link podCmdText Yellow
highlight! link perlVarPlain Fg
highlight! link perlVarPlain2 Fg
" }}}
" syn_end }}}
" syn_begin: ocaml {{{
" builtin: https://github.com/rgrinberg/vim-ocaml{{{
highlight! link ocamlArrow Red
highlight! link ocamlEqual Red
highlight! link ocamlOperator Red
highlight! link ocamlKeyChar Red
highlight! link ocamlModPath Green
highlight! link ocamlFullMod Green
highlight! link ocamlModule BlueItalic
highlight! link ocamlConstructor Orange
highlight! link ocamlModParam Fg
highlight! link ocamlModParam1 Fg
highlight! link ocamlAnyVar Fg " aqua
highlight! link ocamlPpxEncl Red
highlight! link ocamlPpxIdentifier Fg
highlight! link ocamlSigEncl Red
highlight! link ocamlModParam1 Fg
" }}}
" syn_end }}}
" syn_begin: erlang {{{
" builtin: https://github.com/vim-erlang/vim-erlang-runtime{{{
highlight! link erlangAtom Fg
highlight! link erlangVariable Fg
highlight! link erlangLocalFuncRef Green
highlight! link erlangLocalFuncCall Green
highlight! link erlangGlobalFuncRef Green
highlight! link erlangGlobalFuncCall Green
highlight! link erlangAttribute BlueItalic
highlight! link erlangPipe Red
" syn_end }}}
" syn_begin: lisp {{{
" builtin: http://www.drchip.org/astronaut/vim/index.html#SYNTAX_LISP{{{
highlight! link lispAtomMark Purple
highlight! link lispKey Orange
highlight! link lispFunc Green
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
" syn_begin: vim {{{
call sonokai#highlight('vimCommentTitle', s:palette.grey, s:palette.none, 'bold')
highlight! link vimLet Red
highlight! link vimFunction Green
highlight! link vimIsCommand Fg
highlight! link vimUserFunc Green
highlight! link vimFuncName Green
highlight! link vimMap BlueItalic
highlight! link vimNotation Purple
highlight! link vimMapLhs Green
highlight! link vimMapRhs Green
highlight! link vimSetEqual BlueItalic
highlight! link vimSetSep Fg
highlight! link vimOption BlueItalic
highlight! link vimUserAttrbKey BlueItalic
highlight! link vimUserAttrb Green
highlight! link vimAutoCmdSfxList Orange
highlight! link vimSynType Orange
highlight! link vimHiBang Orange
highlight! link vimSet BlueItalic
highlight! link vimSetSep Grey
" syn_end }}}
" syn_begin: make {{{
highlight! link makeIdent Purple
highlight! link makeSpecTarget BlueItalic
highlight! link makeTarget Orange
highlight! link makeCommands Red
" syn_end }}}
" syn_begin: cmake {{{
highlight! link cmakeCommand Red
highlight! link cmakeKWconfigure_package_config_file BlueItalic
highlight! link cmakeKWwrite_basic_package_version_file BlueItalic
highlight! link cmakeKWExternalProject Green
highlight! link cmakeKWadd_compile_definitions Green
highlight! link cmakeKWadd_compile_options Green
highlight! link cmakeKWadd_custom_command Green
highlight! link cmakeKWadd_custom_target Green
highlight! link cmakeKWadd_definitions Green
highlight! link cmakeKWadd_dependencies Green
highlight! link cmakeKWadd_executable Green
highlight! link cmakeKWadd_library Green
highlight! link cmakeKWadd_link_options Green
highlight! link cmakeKWadd_subdirectory Green
highlight! link cmakeKWadd_test Green
highlight! link cmakeKWbuild_command Green
highlight! link cmakeKWcmake_host_system_information Green
highlight! link cmakeKWcmake_minimum_required Green
highlight! link cmakeKWcmake_parse_arguments Green
highlight! link cmakeKWcmake_policy Green
highlight! link cmakeKWconfigure_file Green
highlight! link cmakeKWcreate_test_sourcelist Green
highlight! link cmakeKWctest_build Green
highlight! link cmakeKWctest_configure Green
highlight! link cmakeKWctest_coverage Green
highlight! link cmakeKWctest_memcheck Green
highlight! link cmakeKWctest_run_script Green
highlight! link cmakeKWctest_start Green
highlight! link cmakeKWctest_submit Green
highlight! link cmakeKWctest_test Green
highlight! link cmakeKWctest_update Green
highlight! link cmakeKWctest_upload Green
highlight! link cmakeKWdefine_property Green
highlight! link cmakeKWdoxygen_add_docs Green
highlight! link cmakeKWenable_language Green
highlight! link cmakeKWenable_testing Green
highlight! link cmakeKWexec_program Green
highlight! link cmakeKWexecute_process Green
highlight! link cmakeKWexport Green
highlight! link cmakeKWexport_library_dependencies Green
highlight! link cmakeKWfile Green
highlight! link cmakeKWfind_file Green
highlight! link cmakeKWfind_library Green
highlight! link cmakeKWfind_package Green
highlight! link cmakeKWfind_path Green
highlight! link cmakeKWfind_program Green
highlight! link cmakeKWfltk_wrap_ui Green
highlight! link cmakeKWforeach Green
highlight! link cmakeKWfunction Green
highlight! link cmakeKWget_cmake_property Green
highlight! link cmakeKWget_directory_property Green
highlight! link cmakeKWget_filename_component Green
highlight! link cmakeKWget_property Green
highlight! link cmakeKWget_source_file_property Green
highlight! link cmakeKWget_target_property Green
highlight! link cmakeKWget_test_property Green
highlight! link cmakeKWif Green
highlight! link cmakeKWinclude Green
highlight! link cmakeKWinclude_directories Green
highlight! link cmakeKWinclude_external_msproject Green
highlight! link cmakeKWinclude_guard Green
highlight! link cmakeKWinstall Green
highlight! link cmakeKWinstall_files Green
highlight! link cmakeKWinstall_programs Green
highlight! link cmakeKWinstall_targets Green
highlight! link cmakeKWlink_directories Green
highlight! link cmakeKWlist Green
highlight! link cmakeKWload_cache Green
highlight! link cmakeKWload_command Green
highlight! link cmakeKWmacro Green
highlight! link cmakeKWmark_as_advanced Green
highlight! link cmakeKWmath Green
highlight! link cmakeKWmessage Green
highlight! link cmakeKWoption Green
highlight! link cmakeKWproject Green
highlight! link cmakeKWqt_wrap_cpp Green
highlight! link cmakeKWqt_wrap_ui Green
highlight! link cmakeKWremove Green
highlight! link cmakeKWseparate_arguments Green
highlight! link cmakeKWset Green
highlight! link cmakeKWset_directory_properties Green
highlight! link cmakeKWset_property Green
highlight! link cmakeKWset_source_files_properties Green
highlight! link cmakeKWset_target_properties Green
highlight! link cmakeKWset_tests_properties Green
highlight! link cmakeKWsource_group Green
highlight! link cmakeKWstring Green
highlight! link cmakeKWsubdirs Green
highlight! link cmakeKWtarget_compile_definitions Green
highlight! link cmakeKWtarget_compile_features Green
highlight! link cmakeKWtarget_compile_options Green
highlight! link cmakeKWtarget_include_directories Green
highlight! link cmakeKWtarget_link_directories Green
highlight! link cmakeKWtarget_link_libraries Green
highlight! link cmakeKWtarget_link_options Green
highlight! link cmakeKWtarget_precompile_headers Green
highlight! link cmakeKWtarget_sources Green
highlight! link cmakeKWtry_compile Green
highlight! link cmakeKWtry_run Green
highlight! link cmakeKWunset Green
highlight! link cmakeKWuse_mangled_mesa Green
highlight! link cmakeKWvariable_requires Green
highlight! link cmakeKWvariable_watch Green
highlight! link cmakeKWwrite_file Green
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
call sonokai#highlight('tomlTable', s:palette.purple, s:palette.none, 'bold')
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
call sonokai#highlight('dosiniHeader', s:palette.red, s:palette.none, 'bold')
highlight! link dosiniLabel Blue
highlight! link dosiniValue Green
highlight! link dosiniNumber Green
" syn_end }}}
" syn_begin: help {{{
call sonokai#highlight('helpNote', s:palette.purple, s:palette.none, 'bold')
call sonokai#highlight('helpHeadline', s:palette.red, s:palette.none, 'bold')
call sonokai#highlight('helpHeader', s:palette.orange, s:palette.none, 'bold')
call sonokai#highlight('helpURL', s:palette.green, s:palette.none, 'underline')
call sonokai#highlight('helpHyperTextEntry', s:palette.blue, s:palette.none, 'bold')
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

highlight! CmpPmenu         guibg=#241a20
highlight! CmpPmenuBorder   guibg=#241a20
highlight! CmpItemAbbr      guifg=#d0b0d0
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
" vim: set sw=2 ts=2 sts=2 et tw=80 ft=vim fdm=expr fmr={{{,}}}: