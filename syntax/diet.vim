" Vim syntax file for the diet template language used by vibe.d
"
" Language:     diet
" Maintainer:   Robin Schroer <sulamiification@gmail.com>
" Last Change:  2014-09-02
" Version:      0.1
" Filenames:    *.dt, *.diet
"
" Please submit bugs/comments/suggestions to the github repo:
" https://github.com/sulami/diet.vim
"

" Quit when a syntax file was already loaded
if exists("b:current_syntax")
    finish
endif

" Set the current syntax
let b:current_syntax = "diet"

syn case match

syn cluster dietTop contains=dietBegin,dietComment
syn match   dietBegin "^\s*\%([<>]\|&[^=~ ]\)\@!" nextgroup=dietTag,dietClassChar,dietIdChar,dietPlainChar
syn match   dietTag "\w\+\%(:\w\+\)\=" contained contains=htmlTagName,htmlSpecialTagName nextgroup=@dietComponent
syn cluster dietComponent contains=dietAttributes,dietIdChar,dietClassChar,dietPlainChar
syn match   dietComment ' *\/\/.*$'
syn region  dietAttributes matchgroup=dietAttributesDelimiter start="(" skip=+\%(\\\\\)*\\'+ end=")" contained contains=htmlArg,dietAttributeString,htmlEvent,htmlCssDefinition nextgroup=@dietComponent
syn match   dietClassChar "\." contained nextgroup=dietClass
syn match   dietIdChar "#{\@!" contained nextgroup=dietId
syn match   dietClass "\%(\w\|-\)\+" contained nextgroup=@dietComponent
syn match   dietId "\%(\w\|-\)\+" contained nextgroup=@dietComponent
syn region  dietDocType start="^\s*!!!" end="$"
syn match   dietContinuation "^\s*|"

syn match   dietPlainChar "\\" contained
syn region  dietInterpolation matchgroup=dietInterpolationDelimiter start="#{" end="}" contains=@htmlJavaScript
syn match   dietInterpolationEscape "\\\@<!\%(\\\\\)*\\\%(\\\ze#{\|#\ze{\)"

syn region  dietAttributeString start=+\%(=\s*\)\@<='+ skip=+\%(\\\\\)*\\'+ end=+'+ contains=dietInterpolation
syn region  dietAttributeString start=+\%(:\s*\)\@<='+ skip=+\%(\\\\\)*\\'+ end=+'+ contains=dietInterpolation
syn region  dietAttributeString start=+\%(=\s*\)\@<="+ skip=+\%(\\\\\)*\\'+ end=+"+ contains=dietInterpolation
syn region  dietAttributeString start=+\%(:\s*\)\@<="+ skip=+\%(\\\\\)*\\'+ end=+"+ contains=dietInterpolation

syn region  dietJavascriptFilter matchgroup=dietFilter start="^\z(\s*\):javascript\s*$" end="^\%(\z1 \| *$\)\@!" contains=@htmlJavaScript
syn region  dietMarkdownFilter matchgroup=dietFilter start="^\z(\s*\):markdown\s*$" end="^\%(\z1 \| *$\)\@!"

syn region  dietJavascriptBlock start="^\z(\s*\)script" nextgroup=@dietComponent,dietError end="^\%(\z1 \| *$\)\@!" contains=@dietTop,@htmlJavascript keepend
syn region  dietCssBlock        start="^\z(\s*\)style" nextgroup=@dietComponent,dietError  end="^\%(\z1 \| *$\)\@!" contains=@dietTop,@htmlCss keepend

syn match  dietError "\$" contained

hi def link dietTag                    Special
hi def link dietContinuation           Special
hi def link dietAttributeString        String
hi def link dietAttributesDelimiter    Identifier
hi def link dietIdChar                 Special
hi def link dietClassChar              Special
hi def link dietId                     Identifier
hi def link dietClass                  Type
hi def link dietInterpolationDelimiter Delimiter
hi def link dietFilter                 PreProc
hi def link dietDocType                PreProc
hi def link dietComment                Comment
