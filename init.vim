" Set configuration variables
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_frontmatter = 1
let g:tagbar_position = 'rightbelow vertical'

let g:rnvimr_enable_picker = 1
let g:rnvimr_draw_border = 1
" Customize the initial layout
let g:rnvimr_layout = {
            \ 'relative': 'editor',
            \ 'width': float2nr(round(0.8 * &columns)),
            \ 'height': float2nr(round(0.8 * &lines)),
            \ 'col': float2nr(round(0.1 * &columns)),
            \ 'row': float2nr(round(0.1 * &lines)),
            \ 'style': 'minimal'
            \ }

lua << EOB
require('config')

require('load_lazy')
require('options')
require('plugins.default')
require('keymap')
EOB

set guifont=Iosevka:h11:#e-subpixelantialias:#h-full

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

augroup filetypes
  autocmd!
  autocmd FileType ada,d,nim,objc,objcpp,javascript,scala,typescript syn match Braces display '[{}()\[\]\.\:\;\=\>\<\,\!\~\&\|\*\-\+]'
  autocmd FileType lua syn match Braces display '[{}()\[\]\.\:\;\=\>\<\,\!\~\&\|\*\+]'
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
  
  if a:height == 0
    let height = g:config['termheight']
  else
    let height = a:height
  endif

  if win_gotoid(g:term_win)
      setlocal statusline=Terminal
      hide
  else
      belowright new
      exec "resize " . height
      set winfixheight
      setlocal statusline=Terminal
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
          silent! set statuscolumn=
      endtry
      " startinsert!
      let g:term_win = win_getid()
  endif
endfunction

command! Jsonf :execute '%!python -c "import json,sys,collections,re; sys.stdout.write(re.sub(r\"\\\u[0-9a-f]{4}\", lambda m:m.group().decode(\"unicode_escape\").encode(\"utf-8\"),json.dumps(json.load(sys.stdin, object_pairs_hook=collections.OrderedDict), indent=2)))"'
" see https://jackdevries.com/post/vimRipgrep
if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
