-- set vim options and autocommands. No plugins involved

local o = vim.o

o.shada = "'500,<50,s10,h,f1,%20"
o.termguicolors = true
o.background = "dark"
o.cursorline = true
o.sessionoptions = "buffers"
o.wildmenu = true
vim.opt.wildoptions:append("pum")
o.wildmode = "list:longest,full"
o.ttyfast = true
-- no scrollbar on the left side. Ever. Because it's stupid :)
o.virtualedit = "all"
o.equalalways = false
vim.opt.guicursor:append({ "i:block-iCursor" })
o.autoindent = true
o.copyindent = true
o.shiftwidth = 4
o.helpheight = 45
o.backspace = "indent,eol,start"
o.tabstop = 4
o.textwidth = 76
o.expandtab = true
o.clipboard = "unnamed"
-- which keys allow the cursor to wrap at the begin or ending of a line.
o.whichwrap = "b,s,<,>,[,]"
vim.opt_local.formatoptions:remove({ "t" })
o.langmenu = "en_US.UTF-8"
o.enc = "utf-8"
o.fileencoding = "utf-8"
o.fileencodings = "ucs-bom,utf8,prc"
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
o.scrolloff = 3
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
--o.formatprg = 'par'
o.number = true
o.numberwidth = 5
o.foldcolumn = "5"
-- use treesitter for folding
o.foldmethod = "expr"
o.foldexpr = "nvim_treesitter#foldexpr()"
o.foldlevelstart = 99
o.foldnestmax = 5
-- mkview will only save current cursor position and folding state
-- this keeps views small
o.viewoptions = "folds,cursor"
-- no ~ at blank lines
vim.opt.fillchars = { eob = " " }
o.completeopt = "menu,menuone,noinsert"
-- coc and also CMP respect this settings for the maximum autocomplete-popup height
o.pumheight = 15
-- allow two signcolumns, the first will be occupied by git signs
o.signcolumn = "yes:2"
-- set &dictionary to allow auto-complete with coc-dictionary
vim.opt.dictionary:append(vim.fn.stdpath("data") .. "/dict")
-- do not use swap files.
o.swapfile = false
-- wait 800ms to show hover popups (diagnostics, for example) this would
-- also set the timeout after which the swapfile for the current buffer is
-- updated. But since we use none..
o.updatetime = 800
o.updatecount = 0
-- wait that many milliseconds for keq sequences to complete
o.timeoutlen = 1000
o.cmdheight = 1
o.scrolloff = 5
o.undolevels = 200
o.scrolljump = 5
o.sidescrolloff = 5
o.conceallevel = 0

-- autogroups
local agroup_enter = vim.api.nvim_create_augroup("enter", {})
local agroup_files = vim.api.nvim_create_augroup("files", {})

-- open a 20 lines terminal at the bottom on enter
-- respect environment variable $NVIM_NO_TERM to skip the terminal
vim.api.nvim_create_autocmd({ "vimenter" }, {
  pattern = "*",
  callback = function()
    local no_term = os.getenv("NVIM_NO_TERM")
    if no_term == nil or no_term ~= "yes" then
      vim.api.nvim_command("call TermToggle(12) | wincmd p")
    end
  end,
  group = agroup_enter,
})
-- show the left-hand Neotree tree unless environment variable forbids it
vim.api.nvim_create_autocmd({ "vimenter" }, {
  pattern = "*",
  callback = function()
    local no_nerd = os.getenv("NVIM_NO_NERD")
    if no_nerd == nil or no_nerd ~= "yes" then
      if vim.g.features['neotree']['enable'] == true then
        vim.api.nvim_command("NeoTreeShow")
      end
      if vim.g.features['nvimtree']['enable'] == true then
        require('nvim-tree').toggle(false, true)
      end
    end
  end,
  group = agroup_enter,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "mail",
  callback = function()
    vim.api.nvim_command(
      "setlocal foldcolumn=0 | setlocal fo-=c | setlocal fo+=w | setlocal ff=unix | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de"
    )
  end,
  group = agroup_files,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "python,nim,vim,lua",
  callback = function()
    vim.api.nvim_command(
      "setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal softtabstop=2 | setlocal expandtab | setlocal fo-=t"
    )
  end,
  group = agroup_files,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "tex,markdown,text,telekasten",
  callback = function()
    vim.api.nvim_command(
      "setlocal textwidth=105 | setlocal ff=unix | setlocal fo+=nwqt | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de"
    )
  end,
  group = agroup_files,
})