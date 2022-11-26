-- set vim options and autocommands. No plugins involved

local o = vim.opt

o.shada = "'500,<50,s10,h,f1,%20"
o.termguicolors = true
o.background = "dark"
o.cursorline = true
o.sessionoptions="buffers"
o.wildmenu = true
o.wildoptions:append('pum')
o.wildmode = "list:longest,full"
o.ttyfast = true
-- no scrollbar on the left side. Ever. Because it's stupid :)
o.virtualedit = 'all'
o.guicursor:append{'i:block-iCursor'}
o.autoindent = true
o.copyindent = true
o.shiftwidth=4
o.backspace = 'indent,eol,start'
o.tabstop = 4
o.textwidth = 76
o.expandtab = true
o.clipboard = 'unnamed'
-- which keys allow the cursor to wrap at the begin or ending of a line.
o.whichwrap = 'b,s,<,>,[,]'
vim.opt_local.formatoptions:remove{'t'}
o.langmenu = 'en_US.UTF-8'
o.enc = 'utf-8'
o.fileencoding = 'utf-8'
o.fileencodings = 'ucs-bom,utf8,prc'
-- search is case-insensitive by default...
o.ignorecase = true
-- ...but if the search term contains upper case letters it becomes case
-- sensitive. makes sense? yeah, i think so. lots of.
o.smartcase = true
--incremental search cannot hurt
o.incsearch = true
o.smarttab = true
o.hlsearch = true
o.backup = false
o.undofile = false
o.scrolloff=3
o.showmode = true
o.showcmd = true
o.hidden = true
o.wildmenu = true
o.ruler = true
o.tm = 500
o.wrap = false
-- This prevents the "2-spaces after end of sentence" rule. Basically, vim
-- would normally set 2 spaces after a period or question mark when
-- reformatting / joining lines.
o.formatprg = 'par'
o.number = true
o.numberwidth = 5
o.foldcolumn = '5'
o.foldmethod = 'expr'
o.foldexpr="nvim_treesitter#foldexpr()"
o.foldlevelstart = 20
o.viewoptions = 'folds,cursor'
-- no ~ at blank lines
o.fillchars = {eob = ' '}
o.completeopt='menuone,noinsert'
-- coc respects this settings for the autocomplete-popup height
o.pumheight = 15
-- allow two signcolumns, the first will be occupied by git signs
o.signcolumn='yes:2'
-- set &dictionary to allow auto-complete with coc-dictionary
o.dictionary:append(vim.fn.stdpath("data") .. "/dict")
-- do not use swap files.
o.swapfile = false
-- autogroups

local agroup_enter = vim.api.nvim_create_augroup("enter", {})
local agroup_files = vim.api.nvim_create_augroup("files", {})

-- open a 20 lines terminal at the bottom on enter
vim.api.nvim_create_autocmd(
  { 'vimenter' },
  {
    pattern = '*',
    callback = function()
      local no_term = os.getenv('NVIM_NO_TERM')
      if no_term == nil or no_term ~= 'yes'  then
        vim.api.nvim_command('call TermToggle(12) | wincmd p')
      end
    end,
    group = agroup_enter
  }
)
-- show the nerd tree unless environment variable forbid it
vim.api.nvim_create_autocmd(
    {'vimenter'},
    {
        pattern = '*',
        callback = function()
            local no_nerd = os.getenv('NVIM_NO_NERD')
            if no_nerd == nil or no_nerd ~= 'yes'  then
                vim.api.nvim_command('NERDTree ~/OneDrive | setlocal signcolumn=no | wincmd p')
            end
        end,
        group = agroup_enter
    }
)
-- never conceal anything. Conceal is evil :)
vim.api.nvim_create_autocmd(
    {'FileType'},
    {
        pattern = '*',
        callback = function()
            vim.opt_local.conceallevel = 0
        end,
        group = agroup_files
    }
)

vim.api.nvim_create_autocmd(
    {'FileType'},
    {
        pattern = 'mail',
        callback = function()
            vim.api.nvim_command('setlocal foldcolumn=0 | setlocal fo-=c | setlocal fo+=wa | setlocal ff=unix | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de')
        end,
        group = agroup_files
    }
)

vim.api.nvim_create_autocmd(
    {'FileType'},
    {
        pattern = 'python,nim,vim',
        callback = function()
            vim.api.nvim_command("setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal softtabstop=2 | setlocal expandtab | setlocal fo-=t")
        end,
        group = agroup_files
    }
)

vim.api.nvim_create_autocmd(
    {'FileType'},
    {
        pattern = 'tex,markdown,text,telekasten',
        callback = function()
            vim.api.nvim_command("setlocal textwidth=105 | setlocal ff=unix | setlocal fo+=nawqt | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de")
        end,
        group = agroup_files
    }
)

-- execute some vimscript not yet ported

vim.cmd([[
    inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()
    " coc mappings for auto-complete etc."
    
    let g:coc_snippet_next = '<tab>'
    
    " Make <CR> to accept selected completion item or notify coc.nvim to format
    " <C-g>u breaks current undo, please make your own choice.
    inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

    inoremap <silent> <C-p> <C-r>=CocActionAsync('showSignatureHelp')<CR>
    inoremap <silent><expr> <c-space> coc#refresh()
    " Use K to show documentation in preview window.
    nnoremap <silent> K :call ShowDocumentation()<CR>

    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Symbol renaming.
    nmap <leader>rn <Plug>(coc-rename)

    " Formatting selected code.
    xmap F  <Plug>(coc-format-selected)
    nmap F  <Plug>(coc-format-selected)
  
    nnoremap cd :call CocActionAsync('jumpDefinition')<CR>
    nnoremap ci :call CocActionAsync('jumpImplementation')<CR>

    command! -nargs=0 Prettier :CocCommand prettier.formatFile
]])