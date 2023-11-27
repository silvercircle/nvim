" Set configuration variables
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_frontmatter = 1

let g:rnvimr_enable_picker = 1
let g:rnvimr_draw_border = 1

" Customize the initial layout
" Rnvimr plugin (ranger filemanager integration)
" Activate with <C-f8>
let g:rnvimr_layout = {
            \ 'relative': 'editor',
            \ 'width': float2nr(round(0.9 * &columns)),
            \ 'height': float2nr(round(0.9 * &lines)),
            \ 'col': float2nr(round(0.05 * &columns)),
            \ 'row': float2nr(round(0.05 * &lines)),
            \ 'style': 'minimal'
            \ }

lua << EOB
vim.loader.enable()
require('config')
require('options')
require('load_lazy')
require("auto")
require('plugins.default')
require('keymap')
EOB

set guifont=Iosevka\ Mayukai\ Sonata\ Medium:h11:#e-subpixelantialias:#h-full

run macros/justify.vim
filetype on
syntax on
filetype plugin indent on
set noshowmode

if exists('g:neoray')
  run gui/neoray.vim
endif
" a key mapping for the kwbd macro to close a buffer
command C Kwbd

" function! Foobar(event)
"   echo "UIEnter vimscript"
"   let chan = a:event["chan"]
"   lua __Globals.set_session(vim.fn.eval("chan"))
" endfunction

augroup filetypes
  autocmd!
  autocmd FileType ada,d,nim,objc,objcpp,javascript,scala,typescript syn match Braces display '[{}()\[\]\.\:\;\=\>\<\,\!\~\&\|\*\-\+]'
  autocmd FileType lua syn match Braces display '[{}()\[\]\.\:\;\=\>\<\,\!\~\&\|\*\+]'
  " autocmd UIEnter * call Foobar(v:event)
augroup end

" This is for adding fortune cookies. User will be prompted for a section
" (multiple sections can be entered separated with spaces) and the fortune
" cookie will be inserted at the current cursor position.
" This is for nostalgic reasons, it's a usenet thing.
function! Fortune()
    let section = input("Section: ")
    execute 'read !fortune -s ' . section
endfunction

command Fortune call Fortune()

" for plaintext mail / news postings..
" ensure all paragraphs are softwrapped with \s\n sequences to comply
" with format=flowed specification
"
" see: http://vim.wikia.com/wiki/Correct_format-flowed_email_function
function! Fixflowed()
  let pos = getpos(".")
  silent! %s/\([^]> :]\)\ze\n>[> ]*[^> ]/\1 /g
  silent! %s/ \+\ze\n[> ]*$//
  silent! %s/ \{2,}$/ /
  silent! %s/^[> ]*>\ze[^> ]/& /
  while search('^>\+ >', 'w') > 0
    s/^>\+\zs >/>/
  endwhile
  call setpos('.',pos)
endfunction

command Fixq call Fixflowed()

command! Jsonf :execute '%!python -c "import json,sys,collections,re; sys.stdout.write(re.sub(r\"\\\u[0-9a-f]{4}\", lambda m:m.group().decode(\"unicode_escape\").encode(\"utf-8\"),json.dumps(json.load(sys.stdin, object_pairs_hook=collections.OrderedDict), indent=2)))"'
" see https://jackdevries.com/post/vimRipgrep
if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

