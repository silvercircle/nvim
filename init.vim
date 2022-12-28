" This REQUIRES Neovim version 0.8.0 or later. Might work with earlier
" versions, but this has not been tested or verified.

lua require('impatient_bootstrap')
lua require('impatient')

" Set configuration variables
lua require('config')
lua require('lib')
" load plugins (packer)
lua require('load_plugins')
" exec "source " . expand("<sfile>:h") . '/plugin/packer_compiled.lua'
lua require('vim_options')
" setup all default and optional plugins, based on g.features (see
" config.lua)
lua require('setup_plugins')
run macros/justify.vim

command AutowrapOn setlocal fo+=w | setlocal fo+=w
command AutowrapOff setlocal fo-=a | setlocal fo-=w

" toggle formatting options (a = auto, w = hard/soft wrap, t = use textwidth for wrapping, c = wrap comments)
command AFToggle if &fo =~ 'a' | setlocal fo-=a | else | setlocal fo+=a | endif
command CFToggle if &fo =~ 'c' | setlocal fo-=c | else | setlocal fo+=c | endif
command HWToggle if &fo =~ 'w' | setlocal fo-=w | else | setlocal fo+=w | endif
command HTToggle if &fo =~ 't' | setlocal fo-=t | else | setlocal fo+=t | endif

" quickly enable/disable automatic formatting modes.
command AFManual setlocal fo-=a | setlocal fo-=w | setlocal fo-=c | setlocal fo-=q | setlocal fo-=t | setlocal fo-=l
command AFAuto setlocal fo+=a | setlocal fo+=w | setlocal fo+=c | setlocal fo+=q | setlocal fo+=t | setlocal fo+=l

map <C-f> <NOP>
map <C-c> <NOP>
imap <C-p> <NOP>

lua require('vim_mappings')

set guifont=Hack\ NFM:h10:#e-subpixelantialias:#h-full

" enable plugin-based filetyp identification, syntax highlighting
filetype off
syntax on
filetype plugin indent on
" keep the command line clean, MODE is always visible on the status line.
set noshowmode

" neovide configuration. You can delete this if you do not use neovide
if exists("g:neovide")
    let g:neovide_remember_window_size = v:true
    let g:neovide_fullscreen = v:false
    let g:neovide_scroll_animation_length = 0.3
    let g:neovide_cursor_vfx_mode = "railgun"
    let g:neovide_transparency = 1
    let g:neovide_floating_blur_amount_x = 0
    let g:neovide_floating_blur_amount_y = 0
    hi Normal guibg=#10141E
    " system clipboard support - support Ctrl-V, Ctrl-V etc in all modes,
    " including the command line.

    nnoremap <C-v> "+p
    inoremap <S-Insert> "+p
    nnoremap <S-Insert> "+p
    inoremap <c-v> <c-r>+
    inoremap <S-Insert> <c-r>+
    cnoremap <c-v> <c-r>+
    let g:NERDTreeWinSize=40
else
    if $NVIM_NERD_WIDTH != ''
        let g:NERDTreeWinSize=$NVIM_NERD_WIDTH
    else
        let g:NERDTreeWinSize=40
    endif
endif

" show white spaces, but only trailing spaces, newlines and tabs
set list listchars=tab:·\ ,trail:▪,extends:>,precedes:<,eol:↴

" a key mapping for the kwbd macro to close a buffer
command C Kwbd

" filetype related autocmds
augroup filetypes
  autocmd!
  autocmd FileType ada,d,nim,objc,objcpp,javascript,scala syn match Braces display '[{}()\[\]\.\:\;\=\>\<\,\!\~\&\|\*\-\+]'
  autocmd FileType lua syn match Braces display '[{}()\[\]\.\:\;\=\>\<\,\!\~\&\|\*\+]'
  autocmd FileType vim,nim,python,markdown,tex,lua,json,html,css,dart,go,org setlocal tabstop=2 | setlocal shiftwidth=2 | setlocal expandtab | setlocal softtabstop=2 | setlocal fo-=c
  autocmd FileType noice silent! setlocal signcolumn=no | silent!  setlocal foldcolumn=0 | silent! setlocal nonumber
  autocmd FileType Outline,lspsagaoutline silent! setlocal colorcolumn=36 | silent! setlocal foldcolumn=0 | silent! setlocal signcolumn=no | silent! setlocal nonumber | silent! setlocal statusline=Outline
  autocmd FileType org,orgagenda silent! setlocal conceallevel=2 | silent! setlocal concealcursor='nc' | silent! setlocal tw=105 | setlocal ff=unix | setlocal fo+=nwqt | setlocal spell spelllang=en_us,de_de | setlocal fdm=manual
augroup end

" create a view (save folding state and cursor position)
function Mkview()
  if expand('%') != '' && &buftype !~ 'nofile'
    silent! mkview
  endif
endfunction

augroup folds
  autocmd!
  " make a view before saving a file
  autocmd BufWritePre * :call Mkview()
    
  " restore the view on load
  " views are created when saving or quitting a file
  autocmd BufRead *
  \   if expand('%') != '' && &buftype !~ 'nofile'
  \|    silent! loadview
  \|  endif
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

hi visual guifg=#cccc20 guibg=#3030b0

" terminal stuff

let g:term_buf = 0
let g:term_win = 0
function! TermToggle(height)
    if win_gotoid(g:term_win)
        hide
    else
        belowright new
        exec "resize " . a:height
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
        endtry
        startinsert!
        let g:term_win = win_getid()
    endif
endfunction

" Alt-t toggles the term in a 12 row split below
nnoremap <A-t> :call TermToggle(12)<CR>
inoremap <A-t> <Esc>:call TermToggle(12)<CR>
tnoremap <A-t> <C-\><C-n>:call TermToggle(12)<CR>
" remap <ESC> to escape terminal mode
tnoremap <Esc> <C-\><C-n>