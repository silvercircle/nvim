" vim: fdm=indent:
"
" This REQUIRES Neovim version 0.8.0 or later. Might work with earlier
" versions, but this has not been tested or verified.

lua require('impatient_bootstrap')
lua require('impatient')
lua require('load_plugins')

lua require('vim_options')
lua require('globals')
lua require('setup_plugins')
run macros/justify.vim

colorscheme my_sonokai

command AutowrapOn setlocal fo+=aw
command AutowrapOff setlocal fo-=aw

" toggle formatting options (a = auto, w = hard/soft wrap, t = use textwidth for wrapping)
command AFToggle if &fo =~ 'a' | setlocal fo-=a | else | setlocal fo+=a | endif
command HWToggle if &fo =~ 'w' | setlocal fo-=w | else | setlocal fo+=w | endif
command HTToggle if &fo =~ 't' | setlocal fo-=t | else | setlocal fo+=t | endif
command Itime pu=strftime('%FT%T%z')

" quickly enable/disable automatic formatting modes.
command AFManual setlocal fo-=awcqtl
command AFAuto setlocal fo+=awcqtl

lua require('vim_mappings')

" enable plugin-based filetyp identification, syntax highlighting
filetype off
syntax on
filetype plugin indent on

" show white spaces, but only trailing spaces, newlines and tabs
set list listchars=tab:·\ ,trail:☼,extends:>,precedes:<,eol:¬

" NERDSymbols
let g:NERDTreeGitStatusIndicatorMapCustom = {
                        \ "Modified"  : "✹",
                        \ "Staged"    : "✚",
                        \ "Untracked" : "✭",
                        \ "Renamed"   : "➜",
                        \ "Unmerged"  : "═",
                        \ "Deleted"   : "✖",
                        \ "Dirty"     : "✗",
                        \ "Clean"     : "✔",
                        \ 'Ignored'   : '☒',
                        \ "Unknown"   : "?"}

" Auto commands when starting Vim:
" open a NERDTree by default (we are nerds, ain't we, otherwise we wouldn't use vim :) )
" also, change some colors for the tabline (airline extension)


" set the highlight color for these white spaces
highlight WhiteSpace guifg=#ffcc00 ctermfg=48

" filetype related autocmds
augroup filetypes
    autocmd!
    autocmd FileType ada,d,nim syn match Braces display '[{}()\[\]\.\:\;\=\>\<\,\!\~\&\|\*\-\+]'
augroup end

" this saves a view when a buffer loses focus or the file is written
" The view contains options, current cursor position and fold state
augroup folds
    autocmd!
    autocmd BufWritePost,BufWinLeave *
    \   if expand('%') != '' && &buftype !~ 'nofile'
    \|      mkview
    \|  endif
" restore the view on load
    autocmd BufRead *
    \   if expand('%') != '' && &buftype !~ 'nofile'
    \|      silent! loadview
    \|  endif
augroup end

" key mappings for folding
" F2 toggles a fold's state and can additionally be used to create
" a new fold in manual mode.

" toggle this fold
inoremap <F2> <C-O>za
nnoremap <F2> za
onoremap <F2> <C-C>za
vnoremap <F2> zf

" close current level
inoremap <S-F2> <C-O>zc
nnoremap <S-F2> zc
onoremap <S-F2> <C-C>zc
vnoremap <S-F2> zf

" open current level
inoremap <C-F2> <C-O>zo
nnoremap <C-F2> zo
onoremap <C-F2> <C-C>zo
vnoremap <C-F2> zf

" toggle all levels of current fold
inoremap <F3> <C-O>zA
nnoremap <F3> zA
onoremap <F3> <C-C>zA
vnoremap <F3> zf

" close all current levels
inoremap <S-F3> <C-O>zA
nnoremap <S-F3> zA
onoremap <S-F3> <C-C>zA
vnoremap <S-F3> zf

" open all current levels
inoremap <C-F3> <C-O>zO
nnoremap <C-F3> zO
onoremap <C-F3> <C-C>zO
vnoremap <C-F3> zf

nnoremap <A-Left> <c-w><Left>
nnoremap <A-Right> <c-w><Right>
nnoremap <A-Down> <c-w><Down>
nnoremap <A-Up> <c-w><Up>

" close window (split)
nnoremap <A-w> :close<CR>
" fast quit
nnoremap <A-q> :qa!<CR>

" don't let the nerd tree take over the last frame. Close vim when nothing but
" the nerd tree is left.
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Don't allow NerdTree to be replaced
" a key mapping for the kwbd macro to close a buffer
command C Kwbd

" set highlight color for braces and simple operators (see above)
hi Braces guifg='#ff2020'
" cursors and cursor line
hi CursorLine guibg='#303050'

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" coc autocomplete stuff
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

inoremap <silent> <C-p> <C-r>=CocActionAsync('showSignatureHelp')<CR>

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" latex:wq

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

if exists("g:neovide")
    set guifont=Hack\ NFM:h10:#e-subpixelantialias:#h-full
    let g:neovide_remember_window_size = v:true
    let g:neovide_fullscreen = v:false
    let g:neovide_scroll_animation_length = 0.3
    let g:neovide_cursor_vfx_mode = "railgun"
    let g:neovide_transparency = 1
    let g:neovide_floating_blur_amount_x = 2.0
    let g:neovide_floating_blur_amount_y = 2.0
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

hi VertSplit guibg=#30343e guifg=#808080
hi visual guifg=#202080 guibg=#dddd00

" always show the column for icons and signs


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

" after a re-source, fix syntax matching issues (concealing brackets):
if exists('g:loaded_webdevicons')
    call webdevicons#refresh()
endif

