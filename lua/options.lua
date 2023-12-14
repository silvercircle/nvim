-- set vim options and autocommands. No plugins involved

local o = vim.o

o.shada = "!,'200,<20,s10,h,f1,%20,:500,rreplacer://,rterm://,rOUTLINE,rNvimTree_1,rMERGE_MSG"
o.termguicolors = true
if Config.nightly == 1 then
  o.termsync = false
end
o.background = "dark"
o.cursorline = true
o.sessionoptions = "buffers"
o.wildmenu = true
vim.opt.wildoptions:append("pum")
o.wildmode = "list:longest,full"
o.ttyfast = true
o.virtualedit = "all"
o.equalalways = false
vim.opt.guicursor="i:block-iCursor,v:block-vCursor,n-c:block-nCursor"
o.autoindent = true
o.copyindent = true
o.shiftwidth = 4
o.helpheight = 35
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
o.scrolloff = 3
o.showmode = true
o.showcmd = true
o.wildmenu = true
o.ruler = true
o.tm = 500
o.wrap = false
-- gutter config. set numbers (5 digits max)
o.numberwidth =  vim.g.tweaks.numberwidth
vim.opt.listchars = {tab = '  ', trail = '▪', extends = '>', precedes = '<', eol = '↴' }
vim.opt.list = true

-- statuscolumn stuff
-- this only customizes the fill chars. statuscolumn is set at the end
-- via the globals function
if vim.fn.has('nvim-0.9') == 1 then
  if vim.g.tweaks.use_foldlevel_patch == true then
    o.fillchars = [[eob: ,fold: ,foldopen:-,foldsep:│,foldclose:+,foldlevel:│]]
    --o.fillchars = [[eob: ,fold: ,foldopen:-,foldsep:│,foldclose:+]]
  else
    o.fillchars = [[eob: ,fold: ,foldopen:-,foldsep:│,foldclose:+]]
  end
  -- single-column fold guide, using a patched screen.c without the stupid numbers ;)
  o.foldcolumn="1"
end

-- configure folding. Use Treesitter expressions when treesitter is enabled. Otherwise use 
-- indentation-based folding.
if Config.treesitter == true then
  o.foldmethod = "expr"
  vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  -- vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"
else
  o.foldmethod = "indent"
  o.foldexpr = ""
end

o.foldlevelstart = 99
o.foldnestmax = 5
-- mkview will only save current cursor position and folding state
-- this keeps views small
o.viewoptions = "folds,cursor"
-- no ~ at blank lines
o.completeopt = "menu,menuone,noinsert"
o.complete=""
-- coc and also CMP respect this settings for the maximum autocomplete-popup height
o.pumheight = 15
o.signcolumn = vim.g.tweaks.signcolumn
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
o.timeoutlen = 800
o.scrolloff = 5
o.undolevels = 50
o.scrolljump = 1
o.sidescrolloff = 5
o.sidescroll = 5
o.conceallevel = 0
o.clipboard = "unnamedplus"
o.undodir = vim.fn.stdpath("data") .. "/undo/"
-- set this to true if you want to have persistent undo
o.undofile=false
o.exrc=true
o.cmdheight=vim.g.tweaks.cmdheight
-- o.secure=true
