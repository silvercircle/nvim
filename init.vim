" Set configuration variables
let g:vim_markdown_folding_disabled = 1

lua << EOB
require('config')

require('load_lazy')
require('options')
require('plugins.default')
EOB

set guicursor=i:block-iCursor,v:block-vCursor,n-c:block-nCursor
set guifont=Iosevka:h11:#e-subpixelantialias:#h-full

run macros/justify.vim

" map <C-f> <NOP>
map <C-c> <NOP>
imap <C-c> <NOP>

lua require('keymap')

" enable plugin-based filetyp identification, syntax highlighting
filetype on
syntax on
filetype plugin indent on
" keep the command line clean, MODE is always visible on the status line.
set noshowmode

if exists('g:neoray')
  set guifont=Go_Mono:h11
  NeoraySet CursorAnimTime 0
  NeoraySet Transparency   1
  NeoraySet TargetTPS      120
  NeoraySet ContextMenu    TRUE
  NeoraySet BoxDrawing     TRUE
  NeoraySet ImageViewer    TRUE
  NeoraySet WindowSize     240x62
  NeoraySet WindowState    centered
endif
" a key mapping for the kwbd macro to close a buffer
command C Kwbd

" filetype related autocmds
augroup filetypes
  autocmd!
  autocmd FileType ada,d,nim,objc,objcpp,javascript,scala syn match Braces display '[{}()\[\]\.\:\;\=\>\<\,\!\~\&\|\*\-\+]'
  autocmd FileType lua syn match Braces display '[{}()\[\]\.\:\;\=\>\<\,\!\~\&\|\*\+]'
  autocmd FileType vim,nim,python,lua,json,html,css,dart,go setlocal tabstop=2 | setlocal shiftwidth=2 | setlocal expandtab | setlocal softtabstop=2 | setlocal fo-=c
  autocmd FileType tex,markdown,text,telekasten,liquid,org setlocal tabstop=2 | setlocal shiftwidth=2 | setlocal expandtab | setlocal softtabstop=2 | setlocal textwidth=105 | setlocal ff=unix | setlocal fo+=nwqtc | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de
  autocmd FileType markdown,telekasten,liquid setlocal conceallevel=2 | setlocal concealcursor=nc | setlocal formatexpr=
  autocmd FileType mail setlocal foldcolumn=0 | setlocal fo-=c | setlocal fo+=w | setlocal ff=unix | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de
  autocmd FileType Treesitter silent! setlocal signcolumn=no | silent! setlocal foldcolumn=0 | silent! setlocal nonumber | setlocal norelativenumber | silent setlocal statuscolumn= | setlocal statusline=Treesitter | setlocal winhl=Normal:NeoTreeNormalNC
  autocmd FileType Outline silent! setlocal colorcolumn=36 | silent! setlocal foldcolumn=0 | silent! setlocal signcolumn=no | silent! setlocal nonumber | silent! setlocal statuscolumn= | silent! setlocal statusline=Outline | setlocal winhl=Normal:NeoTreeNormalNC,CursorLine:Visual | hi nCursor blend=100
  autocmd FileType alpha silent! setlocal statuscolumn=
  " this might be nice, but too annoying. I prefer manual toggle (<C-l><C-l>)
  " autocmd InsertEnter * lua Set_statuscol('rel')
  " autocmd InsertLeave * lua Set_statuscol('normal')
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

" terminal stuff

let g:term_buf = 0
let g:term_win = 0
function! TermToggle(height)
  if win_gotoid(g:term_win)
      hide
  else
      belowright new
      exec "resize " . a:height
      set winfixheight
      try
          exec "buffer " . g:term_buf
      catch
          call termopen($SHELL, {"detach": 0})
          let g:term_buf = bufnr("")
          set nonumber
          set norelativenumber
          set foldcolumn=0
          set signcolumn=yes
          set winfixheight
          set nocursorline
          set winhl=SignColumn:NeoTreeNormalNC,Normal:NeoTreeNormalNC
          set filetype=terminal
          setlocal statusline=Terminal
          silent! set statuscolumn=
      endtry
      startinsert!
      let g:term_win = win_getid()
  endif
endfunction

command! Jsonf :execute '%!python -c "import json,sys,collections,re; sys.stdout.write(re.sub(r\"\\\u[0-9a-f]{4}\", lambda m:m.group().decode(\"unicode_escape\").encode(\"utf-8\"),json.dumps(json.load(sys.stdin, object_pairs_hook=collections.OrderedDict), indent=2)))"'
" see https://jackdevries.com/post/vimRipgrep
if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
