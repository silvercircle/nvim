" Impatient is only necessary when using packer
" lua require('_deprecated/impatient_bootstrap')
" lua require('impatient')

" Set configuration variables
lua << EOB
require('config')

-- load plugins (packer)
-- lua require('_deprecated/load_packer')

-- OR load plugins with lazy. DO NOT use both.
require('load_lazy')

require('vim_options')
-- setup telescope as early as possible. it contains some globals (custom themes)
-- that might be needed by other setup modules
require("setup_telescope")
-- setup all mandatory plugins
-- require("setup_lsp")
-- require("setup_cmp")
require('setup_default_plugins')
EOB

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

" map <C-f> <NOP>
map <C-c> <NOP>
imap <C-c> <NOP>

lua require('vim_mappings_light')

set guifont=Iosevka:h11.2:#e-subpixelantialias:#h-full

" enable plugin-based filetyp identification, syntax highlighting
filetype on
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
"    hi Normal guibg=#10141E
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
" TAB is also disabled, because we use indent_blankline plugin for showing indentation guides
set list listchars=tab:\ \ ,trail:▪,extends:>,precedes:<,eol:↴
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
  autocmd FileType Outline,lspsagaoutline silent! setlocal colorcolumn=36 | silent! setlocal foldcolumn=0 | silent! setlocal signcolumn=no | silent! setlocal nonumber | silent! setlocal statuscolumn= | silent! setlocal statusline=Outline | setlocal winhl=Normal:NeoTreeNormalNC
  autocmd FileType alpha silent! setlocal statuscolumn=
  " this might be nice, but too annoying. I prefer manual toggle (<C-l><C-l>)
  " autocmd InsertEnter * lua Set_statuscol('rel')
  " autocmd InsertLeave * lua Set_statuscol('normal')
augroup end

" create a view (save folding state and cursor position)
function Mkview()
  if expand('%') != '' && &buftype !~ 'nofile'
    silent! mkview!
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
          set statusline=Terminal
          silent! set statuscolumn=
      endtry
      startinsert!
      let g:term_win = win_getid()
  endif
endfunction

" Alt-t toggles the term in a 12 row split below
nnoremap <f11> <CMD>call TermToggle(12)<CR>
inoremap <f11> <Esc><CMD>call TermToggle(12)<CR>
tnoremap <f11> <C-\><C-n><CMD>call TermToggle(12)<CR>
" remap <ESC> to escape terminal mode
tnoremap <Esc> <C-\><C-n>
" silent! set statuscolumn=%@SignCb@%=%s%=%T%#NumCb#%l\ %C%#IndentBlankLineChar#│\ 
command! Jsonf :execute '%!python -c "import json,sys,collections,re; sys.stdout.write(re.sub(r\"\\\u[0-9a-f]{4}\", lambda m:m.group().decode(\"unicode_escape\").encode(\"utf-8\"),json.dumps(json.load(sys.stdin, object_pairs_hook=collections.OrderedDict), indent=2)))"'
" see https://jackdevries.com/post/vimRipgrep
if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
