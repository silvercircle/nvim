
-- set vim options and autocommands. No plugins involved

local o = vim.o
local autocmd = vim.api.nvim_create_autocmd
local globals = require("globals")

o.shada = "!,'200,<20,s10,h,f1,%20,:500,rterm://"
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
vim.opt.guicursor="i:block-iCursor,v:block-vCursor,n-c:block-nCursor"
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
-- gutter config. set numbers (5 digits max)
o.numberwidth = 5
vim.opt.listchars = {tab = '  ', trail = '▪', extends = '>', precedes = '<', eol = '↴' }
vim.opt.list = true

-- statuscolumn stuff
if vim.fn.has('nvim-0.9') == 1 then
  if vim.g.use_private_forks == true then
    o.fillchars = [[eob: ,fold: ,foldopen:-,foldsep:│,foldclose:+,foldlevel:│]]
  else
    o.fillchars = [[eob: ,fold: ,foldopen:-,foldsep:│,foldclose:+]]
  end
  -- single-column fold guide, using a patched screen.c without the stupid numbers ;)
  -- foldcolumn can be set to 0
  o.foldcolumn="1"
  -- vim 0.9+ statuscolumn support. What this does:
  -- * set a right aligned (%=) sign column (%s)
  -- * followed by a right aligned absolute line number (%l)
  -- followed by a space
  -- followed by the fold gutter (foldlevel determines its width)
  -- followed by a vertical separator highlighted in the IndentBlankLineChar highlight groupo
--o.statuscolumn="%s%=%r %C%#IndentBlankLineChar#│ "
--print("set to " .. vim.g.config.statuscol_normal)
--o.statuscolumn = vim.g.config.statuscol_normal
  globals.set_statuscol(globals.statuscol_current)
-- this requires fakefold.lua
-- o.statuscolumn='%s%=%{v:wrap ? "" : v:lnum} %#FoldColumn#%@v:lua.StatusColumn.handler.fold@%{v:lua.StatusColumn.display.fold()}%#StatusColumnBorder#│%#StatusColumnBuffer#'
else
  o.fillchars = [[eob: ,fold: ,foldopen:-,foldsep:│,foldclose:+]]
  o.foldcolumn="5"
  o.number = true
end

-- configure folding. Use Treesitter expressions when treesitter is enabled. Otherwise use 
-- indentation-based folding.
--
if vim.g.config.treesitter == true then
  o.foldmethod = "expr"
  o.foldexpr = "nvim_treesitter#foldexpr()"
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
-- coc and also CMP respect this settings for the maximum autocomplete-popup height
o.pumheight = 15
-- allow two signcolumns, the first will be occupied by git signs
o.signcolumn = "yes:3"
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
o.cmdheight = 1
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

-- autogroups
local agroup_views = vim.api.nvim_create_augroup("views", {} )
local agroup_hl = vim.api.nvim_create_augroup("hl", {} )

-- on vimenter show a terminal split and a left-hand nvim-tree file explorer. Unless the
-- environment variable or command line option forbids it for better startup performance and
-- a clean UI
autocmd({ "vimenter" }, {
  pattern = "*",
  callback = function()
    if vim.g.config.plain == false then
      require('nvim-tree.api').tree.toggle({focus = false})
      vim.api.nvim_command("call TermToggle(12) | wincmd p")
      -- vim.schedule(function() vim.cmd.stopinsert() end )
      -- focus grabbing bug was fixed in nvim-tree
      -- vim.schedule(function() vim.cmd("wincmd p") end )
    end
  end,
})

autocmd( { 'UIEnter' }, {
  pattern = "*",
  callback = function() vim.g.ui_entered = true end
})

-- create a view to save folds when saving the file
autocmd( { 'bufwritepre' }, {
  pattern = "*",
  callback = function() globals.mkview() end,
  group = agroup_views
})

-- when config.mkview_on_leave is true, create a view when a buffer loses focus
autocmd( { 'bufwinleave' }, {
  pattern = "*",
  callback = function()
    if vim.g.config.mkview_on_leave == true then
      globals.mkview()
    end
  end,
  group = agroup_views
})

-- restore view when reading a file
autocmd( { 'bufread' }, {
  pattern = "*",
  callback = function()
    if #vim.fn.expand("%") > 0 and vim.api.nvim_buf_get_option(0, "buftype") ~= 'nofile' then
      vim.cmd("silent! loadview")
    end
  end,
  group = agroup_views
})

autocmd( { 'FileType' }, {
  pattern = 'alpha',
  callback = function()
     vim.cmd("silent! setlocal statuscolumn=")
  end,
  group = agroup_views
})

autocmd( { 'FileType' }, {
  pattern = { 'Outline', 'tagbar' },
  callback = function()
    vim.cmd("silent! setlocal colorcolumn=36 | silent! setlocal foldcolumn=0 | silent! setlocal signcolumn=no | silent! setlocal nonumber | silent! setlocal statuscolumn= | silent! setlocal statusline=Outline | setlocal winhl=Normal:NeoTreeNormalNC,CursorLine:Visual | hi nCursor blend=100")
  end,
  group = agroup_views
})

autocmd( { 'FileType' }, {
  pattern = "Treesitter",
  callback = function()
    vim.cmd("silent! setlocal signcolumn=no | silent! setlocal foldcolumn=0 | silent! setlocal nonumber | setlocal norelativenumber | silent setlocal statuscolumn= | setlocal statusline=Treesitter | setlocal winhl=Normal:NeoTreeNormalNC")
  end,
  group = agroup_views
})

autocmd( { 'FileType' }, {
  pattern = 'mail',
  callback = function()
    vim.cmd("setlocal foldcolumn=0 | setlocal fo-=c | setlocal fo+=w | setlocal ff=unix | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de")
  end,
  group = agroup_views
})

autocmd( { 'FileType' }, {
  pattern = { 'markdown', 'telekasten', 'liquid' },
  callback = function()
    vim.cmd("setlocal conceallevel=2 | setlocal concealcursor=nc | setlocal formatexpr=")
  end,
  group = agroup_views
})

autocmd( { 'FileType' }, {
  pattern = { 'tex', 'markdown', 'text', 'telekasten', 'liquid' },
  callback = function()
    vim.cmd("setlocal tabstop=2 | setlocal shiftwidth=2 | setlocal expandtab | setlocal softtabstop=2 | setlocal textwidth=105 | setlocal ff=unix | setlocal fo+=nwqtc | setlocal foldmethod=manual | setlocal spell spelllang=en_us,de_de")
  end,
  group = agroup_views
})

autocmd( { 'FileType' }, {
  pattern = { 'vim', 'nim', 'python', 'lua', 'json', 'html', 'css', 'dart', 'go' },
  callback = function()
    vim.cmd("setlocal tabstop=2 | setlocal shiftwidth=2 | setlocal expandtab | setlocal softtabstop=2 | setlocal fo-=c")
  end,
  group = agroup_views
})

autocmd( { 'FileType' }, {
  pattern = "DressingSelect",
  callback = function()
    vim.cmd("setlocal winhl=CursorLine:Visual | hi nCursor blend=100")
  end,
  group = agroup_hl
})
autocmd( { 'FileType' } , {
  pattern = "DressgingInput",
  callback = function()
    vim.cmd("hi nCursor blend=0")
  end,
  group = agroup_hl
})

autocmd( { 'CmdLineEnter' }, {
  pattern = '*',
  callback = function()
    vim.cmd("hi nCursor blend = 0")
  end,
  group = agroup_hl
})

autocmd( { 'WinEnter' }, {
  pattern = '*',
  callback = function()
    local filetype = vim.bo.filetype
    if filetype == "DressingSelect" or filetype == "Outline" or filetype =="NvimTree" then
      vim.cmd("setlocal winhl=CursorLine:Visual,Normal:NeoTreeNormalNC | hi nCursor blend=100")
    end
  end,
  group = agroup_hl
})

autocmd( { 'WinLeave' }, {
  pattern = '*',
  callback = function()
    local filetype = vim.bo.filetype
    if filetype == "DressingSelect" or filetype == "Outline" or filetype =="NvimTree" then
      vim.cmd("hi nCursor blend=0")
    end
  end,
  group = agroup_hl
})

