" init.vim
"
" vim: fdm=indent:
"
" This REQUIRES Neovim version 0.8.0 or later. Might work with earlier
" versions, but this has not been tested or verified.
"
" The following plugins are required (if any of them is not installed, errors on
" startup may occur)

let mapleader = ','

set nocompatible
" the plugin manager

set shada='500,<50,s10,h,f1,%20

" set a cool color scheme

set termguicolors
set background=dark
" Enable CursorLine
set cursorline

" This implements the Justify command to justify a line of text
" I need this rarely, so no keyboard shortcut defined. The command
" it implements is Justify
run macros/justify.vim

set sessionoptions=folds,buffers

call plug#begin()
Plug 'nvim-lualine/lualine.nvim'

Plug 'mg979/vim-visual-multi', {'branch': 'master'}
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'qpkorr/vim-bufkill'
Plug 'lervag/vimtex'
Plug 'alaviss/nim.nvim'
Plug 'Iron-E/nvim-highlite'
Plug 'gpanders/editorconfig.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'tom-anders/telescope-vim-bookmarks.nvim'
Plug 'MattesGroeger/vim-bookmarks'
"Plug 'fannheyward/telescope-coc.nvim'
"Plug 'iamcco/coc-actions'
" telescope deps
Plug 'sharkdp/fd'
Plug 'BurntSushi/ripgrep'
Plug 'ryanoasis/vim-devicons'
" the same dev icons for lua plugins like Telescope
Plug 'nvim-tree/nvim-web-devicons'
Plug 'windwp/nvim-autopairs'
Plug 'lewis6991/impatient.nvim'
Plug 'sainnhe/sonokai'
Plug 'preservim/nerdtree'
Plug 'lewis6991/gitsigns.nvim'
Plug 'petertriho/nvim-scrollbar'
   
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'
"Plu gotor de snippets
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
Plug 'MunifTanjim/nui.nvim'
Plug 'simrat39/symbols-outline.nvim'
call plug#end()

let  gsonokai_menu_selection_background='red'
let g:sonokai_style='atlantis'
let g:sonokai_transparent_background=1
let g:sonokai_disable_italic_comment=1
let g:sonokai_cursor = "auto"
colorscheme my_sonokai

lua require('impatient')
lua require('plugins')
lua require('lsp')

" Telescope stuff
nnoremap <silent> <C-p> :lua require'telescope.builtin'.oldfiles{layout_config={height=0.4,width=0.7,preview_width=0.4}}<CR>
nnoremap <silent> <C-e> :lua require'telescope.builtin'.buffers{layout_config={height=0.3, width=0.7}}<CR>
nnoremap <silent> <C-f> :lua require'telescope.builtin'.find_files{cwd = vim.fn.expand('%:p:h') }<CR>
nnoremap <silent> <A-c> :lua require'telescope.builtin'.command_history{layout_config={width=0.4, height=0.7}}<CR>
nnoremap <silent> <A-f> :Telescope file_browser path=%:p:h<CR>
nnoremap <silent> <A-s> :lua require'telescope.builtin'.spell_suggest{layout_config={height=0.5,width=0.3}}<CR>

" this might help with vim running in terminals and Windows console
" a bit faster. Does not hurt when using gvim.
set ttyfast

set guioptions-=T
" no scrollbar on the left side. Ever. Because it's stupid :)
set guioptions-=LA

" allow the cursor to move beyond line endings and be placed
" everywhere in the text in all modes.
set virtualedit=all
" allow different colors for insert/visual/normal cursors.
set guicursor+=i:block-iCursor
"set guicursor+=v:block-vCursor
"set guicursor+=n:block-nCursor
" insert mode cursor should not blink
set guicursor+=i:blinkwait5-blinkon5-blinkoff5
" allow long lines, no forced soft-wrap at the right window border
" this enables horizontal scrolling
set nowrap

" set some seinsible defaults for indentation, tabs and other basic parameters
set autoindent
set copyindent
set shiftwidth=4
set backspace=indent,eol,start
set tabstop=4
set textwidth=76
set expandtab

" allow using the clipboard as default register.
set clipboard=unnamed

" which keys allow the cursor to wrap at the begin or ending of a line.
set whichwrap+=<,>,[,],b
setlocal fo-=t
set langmenu=en_US.UTF-8    " sets the language of the menu (gvim)

" enable plugin-based filetyp identification, syntax highlighting
filetype off
syntax on
filetype plugin indent on

" make sure we always encode in UTF-8
set enc=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf8,prc

" show white spaces, but only trailing spaces, newlines and tabs
set list listchars=tab:·\ ,trail:☼,extends:>,precedes:<,eol:¬

" This is necessary for gvim on Windows to make the delete behave like
" a delete key actually *should* behave.
set backspace=2

" search is case-insensitive by default...
set ignorecase
" ...but if the search term contains upper case letters it becomes case
" sensitive. makes sense? yeah, i think so. lots of.
set smartcase
" incremental search cannot hurt
set incsearch

set smarttab
set hlsearch
set noswapfile
set nobackup
set scrolloff=3
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set ruler

" stop blinking, flashing, beeping, exploding... whatever.
set noerrorbells
set novisualbell
set tm=500

" This prevents the "2-spaces after end of sentence" rule. Basically, vim
" would normally set 2 spaces after a period or question mark when
" reformatting / joining lines.
set nojoinspaces
set formatprg=par

let g:coc_max_treeview_width = 30
"let g:coc_default_semantic_highlight_groups = 1

set number
set numberwidth=5

" execute 'sign place 9999 line=1 name=dummy buffer=' . bufnr('')
set foldcolumn=5
set foldmethod=indent
set foldlevelstart=20

" this prevents vim from saving all the options in views. Cursor
" position, folds and basic modes are all I want to have restored.
set viewoptions-=options

"NERDTree stuff
let NERDTreeMinimalUI = 0
let NERDTreeDirArrows = 1
let NERDTreeShowHidden = 1
let g:NERDTreeShowBookmarks = 1
let g:NERDTreeSortHiddenFirst = 1
let g:NERDTreeChDirMode = 2 
let g:NERDTreeMapOpenSplit='$'
let g:NERDTreeFileExtensionHighlightFullName = 1
map <leader>r :NERDTreeFind <Bar> wincmd p<CR>
"nmap <silent> <leader>r :NvimTreeFindFile!<CR> <bar> wincmd p
set wildignore+=*.pyc,*.o,*.obj,*.svn,*.swp,*.class,*.hg,*.DS_Store,*.min.*,.git
let NERDTreeRespectWildIgnore=1
" NERDColors

"hi Directory guifg=#dddd00 ctermfg=yellow gui=bold cterm=bold
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

augroup enter
    autocmd vimenter * call TermToggle(12) | wincmd p
    if $NVIM_NO_NERD != 'yes'
        autocmd vimenter * NERDTree ~/OneDrive | wincmd p
"        autocmd!
"        autocmd vimenter * call Local_open_tree() | wincmd p
    endif
augroup end

" filetype related autocmds
augroup filetypes
    autocmd!
    autocmd FileType mail setlocal fo-=c | setlocal ff=unix | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de
    autocmd FileType ada,d,nim syn match Braces display '[{}()\[\]\.\:\;\=\>\<\,\!\~\&\|\*\-\+]'
    autocmd FileType text,markdown,tex setlocal textwidth=105 | setlocal wrap | setlocal fo+=nawqt | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de
    autocmd FileType python,nim setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal softtabstop=2 | setlocal expandtab | setlocal fo-=t
    " Never conceal anything
    autocmd FileType * setlocal conceallevel=0
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

let javaScript_fold=1         " JavaScript
let perl_fold=1               " Perl
let r_syntax_folding=1        " R
let ruby_fold=1               " Ruby
let sh_fold_enabled=1         " sh
let vimsyn_folding='af'       " Vim script
let xml_syntax_folding=1      " XML

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

" we want the header of a folded region to stick out a bit more
highlight Folded guibg='#303080' guifg='#eeee80'

" don't let the nerd tree take over the last frame. Close vim when nothing but
" the nerd tree is left.
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Don't allow NerdTree to be replaced
" a key mapping for the kwbd macro to close a buffer
command C Kwbd

" toggle formatting options (a = auto, w = hard/soft wrap, t = use textwidth for wrapping)
command AFToggle if &fo =~ 'a' | setlocal fo-=a | else | setlocal fo+=a | endif
command HWToggle if &fo =~ 'w' | setlocal fo-=w | else | setlocal fo+=w | endif
command HTToggle if &fo =~ 't' | setlocal fo-=t | else | setlocal fo+=t | endif
command Itime pu=strftime('%FT%T%z')

command AutowrapOn setlocal fo+=aw
command AutowrapOff setlocal fo-=aw

" map some keys for these commands
map <leader>a :AFToggle<CR>
map <leader>w :HWToggle<CR>
map <leader>t :HTToggle<CR>
map <leader>1 :AutowrapOn<CR>
map <leader>2 :AutowrapOff<CR>

map <silent> <leader>V :!fmt -110<CR>
map <silent> <leader>v :!fmt -100<CR>
map <silent> <leader>y :!fmt -85<CR>

" quickly enable/disable automatic formatting modes.
command AFManual setlocal fo-=awcqtl
command AFAuto setlocal fo+=awcqtl
map <leader>fm :AFManual<CR>
map <leader>fa :AFAuto<CR>

" set highlight color for braces and simple operators (see above)
hi Braces guifg='#ff2020'
" cursors and cursor line
hi CursorLine guibg='#303050'
"hi Cursor1 guibg='#4040ff'
"hi Cursor2 guibg='#4040ff'
"hi Cursor guibg='#4040ff'
"hi iCursor guibg='#ffff00'

" autocomplete stuff
set completeopt=menuone,noinsert
set omnifunc=v:lua.vim.lsp.omnifunc
set pumheight=15

" coc autocomplete stuff
"inoremap <silent><expr> <TAB>
"      \ coc#pum#visible() ? coc#pum#next(1) :
"      \ CheckBackspace() ? "\<Tab>" :
"      \ coc#refresh()
"inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
"inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
"                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use <c-space> to trigger completion.(coc)
"inoremap <silent><expr> <c-space> coc#refresh()

"inoremap <silent> <C-p> <C-r>=CocActionAsync('showSignatureHelp')<CR>

" vim-markdown
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_new_list_item_indent = 2
let g:vim_markdown_conceal = 0

" latex:wq
let g:tex_conceal = ''

" This is for adding fortune cookies. User will be prompted for a section
" (multiple sections can be entered separated with spaces) and the fortune
" cookie will be inserted at the current cursor position.
" This is for nostalgic reasons, it's a usenet thing.
function! Fortune()
    let section = input("Section: ")
    execute 'read !fortune -s ' . section
endfunction

command Fortune call Fortune()

map <leader>. :CocOutline<CR>
map <leader>- :Minimap<CR>
map <silent> <leader>, :NERDTreeToggle<CR>
"map <silent> <leader>, :lua require("nvim-tree.api").tree.toggle(false, true, '.')<CR>


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

map <C-L> :!clang-format-6.0 -style="{BasedOnStyle: WebKit, IndentWidth: 2, ColumnLimit: 120}"<cr>
imap <C-L> <c-o>:!clang-format-6.0 -style="{BasedOnStyle: WebKit, IndentWidth: 2, ColumnLimit: 120}"<cr>

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
    " use <c-r> to insert original character without triggering things like auto-pairs
"    inoremap <c-r> <c-v>
"    let g:neovide_cursor_animation_length=0
    let g:NERDTreeWinSize=40
else
    if $NVIM_NERD_WIDTH != ''
        let g:NERDTreeWinSize=$NVIM_NERD_WIDTH
    else
        let g:NERDTreeWinSize=40
    endif
endif

let g:minimap_width = 8

hi VertSplit guibg=#30343e guifg=#808080
hi visual guifg=#202080 guibg=#dddd00

" always show the column for icons and signs
set signcolumn=yes

set dictionary+=~/.local/share/nvim/dict

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
            set signcolumn=no
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

nmap <C-Tab> :bnext<CR>

" colors for multiple cursors

let g:VM_Mono_hl   = 'DiffText'
let g:VM_Extend_hl = 'DiffAdd'
let g:VM_Cursor_hl = 'Visual'
let g:VM_Insert_hl = 'DiffChange'

" Bookmarks plugin

nmap <Leader>bt <Plug>BookmarkToggle
nmap <Leader>by <Plug>BookmarkAnnotate
nmap <Leader>ba <Plug>BookmarkShowAll
nmap <Leader>bn <Plug>BookmarkNext
nmap <Leader>bp <Plug>BookmarkPrev
nmap <Leader>bd <Plug>BookmarkClear
nmap <Leader>bx <Plug>BookmarkClearAll
nmap <Leader>bu <Plug>BookmarkMoveUp
nmap <Leader>bb <Plug>BookmarkMoveDown
nmap <Leader>bm <Plug>BookmarkMoveToLine

" Telescope picker for bookmarks

nnoremap <silent> <A-b> :lua require('telescope').extensions.vim_bookmarks.all{hide_filename=false,layout_config={height=0.4, width=0.8,preview_width=0.3}}<CR>
nnoremap <silent> <C-b> :lua require('telescope').extensions.vim_bookmarks.current_file{layout_config={height=0.4, width=0.7}}<CR>
" after a re-source, fix syntax matching issues (concealing brackets):
if exists('g:loaded_webdevicons')
    call webdevicons#refresh()
endif