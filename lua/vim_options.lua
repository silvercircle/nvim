-- set vim options and autocommands. No plugins involved

local o = vim.opt

o.shada = "'500,<50,s10,h,f1,%20"
o.termguicolors = true
o.background = "dark"
o.cursorline = true
o.sessionoptions="folds,buffers"
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
o.foldmethod = 'indent'
o.foldlevelstart = 20
o.viewoptions = 'folds,cursor,curdir'
o.fillchars = {eob = ' '}
o.completeopt='menuone,noinsert'
o.pumheight = 15
o.signcolumn='yes'
o.dictionary:append('/.local/share/nvim/dict')
o.swapfile = false

-- autogroups

local agroup_enter = vim.api.nvim_create_augroup("enter", {})
local agroup_files = vim.api.nvim_create_augroup("files", {})

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
            vim.api.nvim_command('setlocal foldcolumn=0 | setlocal fo-=c | setlocal ff=unix | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de')
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
        pattern = 'tex,markdown,text',
        callback = function()
            vim.api.nvim_command("setlocal textwidth=105 | setlocal wrap | setlocal fo+=nawqt | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de")
        end,
        group = agroup_files
    }
)
