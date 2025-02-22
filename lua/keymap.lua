local map = vim.api.nvim_set_keymap
local kms = vim.keymap.set

local opts = { noremap = true, silent = true }
local utils = require('local_utils')
local utility_key = vim.g.tweaks.keymap.utility_key
local treename = vim.g.tweaks.tree.version == "Neo" and "neo-tree" or "NvimTree"

local function fkey_mappings()
  if vim.g.is_tmux == 1 then
    return {
      s_f1  = "<f13>",   -- shift-f1
      s_f2  = "<f14>",   -- shift-f2
      s_f3  = "<S-F3>",  -- shift-f3
      s_f4  = "<f16>",   -- shift-f3
      s_f6  = "<f18>",   -- shift-f6
      s_f7  = "<f19>",
      s_f8  = "<f20>",
      s_f9  = "<f21>",   -- shift-f9
      s_f11 = "<f23>",   -- shift-f11
      s_f12 = "<f24>",
      c_f3  = "<C-F3>",
      c_f6  = "<f30>",   -- ctrl-f6
      c_f8  = "<f32>"    -- ctrl-f8
    }
  else
    return {
      s_f1  = "<S-F1>",
      s_f2  = "<S-F2>",
      s_f3  = "<S-F3>",
      s_f4  = "<S-F4>",
      s_f6  = "<S-F6>",
      s_f7  = "<S-F7>",
      s_f8  = "<S-F8>",
      s_f9  = "<S-F9>",
      s_f11 = "<S-F11>",
      s_f12 = "<S-F12>",
      c_f3  = "<C-F3>",
      c_f6  = "<C-F6>",
      c_f8  = "<C-F8>"
    }
  end
end
vim.g.fkeys = fkey_mappings()
local fkeys = vim.g.fkeys

--- peform a key press
--- @param key string a key sequence
--- prefix <c-o> when in insert mode
local function perform_key(key)
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'i' then
    key = '<C-o>' .. key
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), mode, false)
end

--- perform a command
--- @param cmd string: a valid command
local function perform_command(cmd)
  vim.cmd(cmd)
end

-- kms("i", "<Esc>", function() vim.cmd.stopinsert() end, { noremap = true, expr = true, silent = true } )

kms({ "n", "i" }, "<C-c>", "<NOP>", opts)
kms({ "n", "i" }, "<C-l>", "<NOP>", opts)

-- disable <ins> toggling the (annoying) replace mode. Instead use <c-ins> to switch to replace
map("i", "<ins>", "<nop>", opts)
-- map("i", "<C-v>", "<c-r><c-p>+", opts)

vim.g.setkey({ 'i', 'n' }, '<C-f><C-a>', function() __Globals.toggle_fo('a') end, "Toggle 'a' format option")
vim.g.setkey({ 'i', 'n' }, '<C-f><C-c>', function() __Globals.toggle_fo('c') end, "Toggle 'c' format option")
vim.g.setkey({ 'i', 'n' }, '<C-f><C-w>', function() __Globals.toggle_fo('w') end, "Toggle 'w' format option")
vim.g.setkey({ 'i', 'n' }, '<C-f><C-t>', function() __Globals.toggle_fo('t') end, "Toggle 't' format option")
vim.g.setkey({ 'i', 'n' }, '<C-f><C-l>', function() __Globals.toggle_fo('l') end, "Toggle 'l' format option")

vim.g.setkey({ 'i', 'n' }, '<C-f>1', function() __Globals.set_fo('w')  __Globals.set_fo('a') end, "Set 'w' and 'a' format options")
vim.g.setkey({ 'i', 'n' }, '<C-f>2', function() __Globals.clear_fo('w') __Globals.clear_fo('a') end, "Clear 'w' and 'a' format options")

vim.g.setkey({ 'i', 'n' }, '<C-f>f', function()
  __Globals.clear_fo('w')
  __Globals.clear_fo('a')
  __Globals.clear_fo('c')
  __Globals.clear_fo('q')
  __Globals.clear_fo('t')
  __Globals.clear_fo('l')
end, "Clear all formatting options")
vim.g.setkey({ 'i', 'n' }, '<C-f>a', function()
  __Globals.set_fo('w')
  __Globals.set_fo('a')
  __Globals.set_fo('c')
  __Globals.set_fo('q')
  __Globals.set_fo('t')
  __Globals.set_fo('l')
end, "Set all formatting options")

map('v', '<leader>V', ':!fmt -110<CR>', opts)
map('v', '<leader>y', ':!fmt -85<CR>', opts)

vim.g.setkey('n', '<A-C-w>', function()
  vim.api.nvim_feedkeys('}kV{jgq', 'i', true)
end, "Format paragraph to textwidth")
vim.g.setkey('i', '<A-C-w>', function()
  local key = vim.api.nvim_replace_termcodes('<C-o>}<C-o>V{jgq', true, false, true)
  vim.api.nvim_feedkeys(key, 'i', false)
end, "Format paragraph to textwidth")

map('n', '<leader>v', '}kV{j', opts) -- select current paragraph

vim.g.setkey({'i', 'n', 'v'}, '<C-s><C-s>', function() perform_command("update!") end, "Save file")

vim.g.setkey({'n', 'i', 'v'}, '<C-s><C-c>', function()
  vim.cmd.stopinsert()
  vim.schedule(function() require("local_utils").BufClose() end)
end, "Close Buffer")
vim.g.setkey({'n', 'i', 'v'}, '<f5>', function() perform_command('nohl') end, "Clear highlighted search results")

vim.g.setkey('i', '<C-z>', function() perform_command("undo") end, "Undo (insert mode)")

-- various
map('i', '<C-y>-', '—', opts) -- emdash
map('i', '<C-y>"', '„”', opts) -- typographic quotes („”)
vim.g.setkey({ 'n', 'i' }, '<A-w>', function()
  if vim.fn.win_getid() ~= __Globals.main_winid then vim.cmd('close') end
end, "Close Window")

vim.g.setkey({'n', 'i'}, '<C-f>c', function()
  __Globals.close_qf_or_loc()
end, "Close quickfix/loclist window")

--- mini picker shortcuts, all start with <C-a>
vim.g.setkey({ 'n', 'i' }, '<C-a>f', function()
  utils.PickFoldingMode(vim.o.foldmethod)
end, "Pick folding mode")

vim.g.setkey({'n', 'i'}, '<C-a>e', function()
  require("fzf-lua").files({ formatter = "path.filename_first", cwd = vim.fn.expand("%:p:h"), winopts = vim.g.tweaks.fzf.winopts.very_narrow_no_preview })
end, "Open Mini File Browser at current directory")

vim.g.setkey({'n', 'i'}, '<C-a><C-e>', function()
  require("fzf-lua").files({ formatter = "path.filename_first", cwd = utils.getroot_current(), winopts = vim.g.tweaks.fzf.winopts.very_narrow_no_preview })
end, "Open Mini File Browser at project root")

vim.g.setkey({'n', 'i'}, '<A-E>', function()
  local cwd = utils.getroot_current()
  require("snacks").picker.explorer({cwd = cwd,
    layout = SPL( { width = 70, psize = 12, input = "top", title = cwd }) })
end, "Open Snacks Explorer at project root")
-- this is a bit hacky. it tries to find the root directory of the sources
-- in the current project. it assumes that sources are located in one of the
-- subfolders listed in Tweaks.srclocations. You can customize this if you want
vim.g.setkey({'n', 'i'}, '<A-e>', function()
  local found = false
  local path = utils.getroot_current()
  for _, v in ipairs(vim.g.tweaks.srclocations) do
    local res = vim.fs.joinpath(path, v)
    if vim.fn.isdirectory(res) == 1 then
      found = true
      require("fzf-lua").files({ formatter = "path.filename_first", cwd = res, winopts = vim.g.tweaks.fzf.winopts.very_narrow_no_preview })
    end
  end
  -- if we cannot find a source root, use the project root instead
  if found == false and path ~= nil and vim.fn.isdirectory(path) then
    require("fzf-lua").files({ cwd = path, winopts = vim.g.tweaks.fzf.winopts.very_narrow_no_preview })
  end
end, "Open Mini File Browser and guess sources root")

vim.g.setkey('n', '<C-a>w', function()
  require("mini.files").open(vim.fn.expand("%:p:h"))
end, "Open Mini.Files at current directory")

vim.g.setkey('n', '<C-a><C-w>', function()
  require("mini.files").open(utils.getroot_current())
end, "Open Mini.Files at project root")

vim.g.setkey({'n', 'i', 'v'}, '<C-S-Down>', function() perform_command('silent! cnext') end, "Quickfix next entry")
vim.g.setkey({'n', 'i', 'v'}, '<C-S-Up>', function() perform_command('silent! cprev') end, "Quickfix previous entry")
vim.g.setkey({'n', 'i', 'v'}, '<C-S-PageDown>', function() perform_command('silent! lnext') end, "Loclist next entry")
vim.g.setkey({'n', 'i', 'v'}, '<C-S-PageUp>', function() perform_command('silent! lprev') end, "Loclist previous entry")

-- hlslens
vim.api.nvim_set_keymap(
  'n',
  'n',
  [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
  opts
)
vim.api.nvim_set_keymap(
  'n',
  'N',
  [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
  opts
)
vim.g.setkey('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], "hlslens*")
vim.g.setkey('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], "hlslens#")
vim.g.setkey('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], "hlslens")
vim.g.setkey('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], "hlslens")

-- run `:nohlsearch` and export results to quickfix
vim.keymap.set({ 'n', 'x' }, '<Leader>#', function()
  vim.schedule(function()
    if require('hlslens').exportLastSearchToQuickfix() then
      vim.cmd('cw')
    end
  end)
  return ':noh<CR>'
end, { expr = true, desc = "Export HlsLens results to Quickfix list" })

map('n', 'hl', "<CMD>Inspect<CR>", opts)

if vim.g.tweaks.completion.version ~= "blink" then
  vim.g.setkey({ 'i', 'n' }, fkeys.s_f1, function() vim.lsp.buf.signature_help() end, "Show signature help")
end

--- opens a hover for the symbol under the cursor. if it's a closed UFO fold, then
--- show a hover for it instead.
--- press <F1> again to enter the hover window, press <q> to dismiss it.
vim.keymap.set({ "n", "i" }, '<f1>', function()
  local status, ufo = pcall(require, "ufo")
  local winid = (status == true) and ufo.peekFoldedLinesUnderCursor() or false
  if not winid then
  	local api = vim.api
	  local hover_win = vim.b.hover_preview
  	if hover_win and api.nvim_win_is_valid(hover_win) then
	  	api.nvim_set_current_win(hover_win)
  	else
	  	require("hover").hover()
  	end
  end
end, { desc = "LSP hover window" })

vim.g.setkey({ 'i', 'n' }, '<C-x>D', function()
  vim.lsp.buf.definition()
end, "LSP Goto definition")

-- toggle current fold
vim.g.setkey({'n', 'i', 'v'}, '<F2>', function() perform_key('za') end, "Toggle current fold")

-- open current fold (Shift-F2)
vim.g.setkey({'n', 'i', 'v'}, fkeys.s_f2, function() perform_key('zf') end, "Create Fold")

-- toggle all folds at current line
vim.g.setkey({'n', 'i', 'v'}, '<F3>', function() perform_key('zA') end, "Toggle all folds at current line")

-- close all folds at current line (Shift-F3)
vim.g.setkey({'n', 'i', 'v'}, fkeys.s_f3, function() perform_key('zC') end, "Close all folds at current line")

-- open all folds at current line (Ctrl-F3)
vim.g.setkey({'n', 'i', 'v'}, fkeys.c_f3, function() perform_key('zO') end, "Open all folds at current line")

-- jump list
vim.g.setkey({'n', 'i', 'v'}, '<C-S-Left>', function() perform_key('<C-o>') end, "Jump list back")
vim.g.setkey({'n', 'i', 'v'}, '<C-S-Right>', function() perform_key('<C-i>') end , "Jump list forward")

-- change list
vim.g.setkey({'n', 'i'}, '<A-Left>', function() perform_key('g;') end, "Change list prev")
vim.g.setkey({'n', 'i'}, '<A-Right>', function() perform_key('g,') end, "Change list next")

vim.g.setkey('n', fkeys.s_f11, function() perform_command('Lazy') end, "Open Lazy plugin manager UI")

-- utility functions
-- they use a prefix key, by default <C-l>. Can be customized in tweaks.lua

vim.g.setkey({ 'n', 'i' }, utility_key .. '<C-l>', function() __Globals.toggle_statuscol() end, "Toggle absolute/relative line numbers")
vim.g.setkey({ 'n', 'i' }, utility_key .. '<C-p>', function()
  __Globals.toggle_inlayhints()
end, "Toggle LSP inlay hints")

vim.g.setkey({ 'n', 'i' }, utility_key .. 'ca', function()
  PCFG.cmp_autocomplete = not PCFG.cmp_autocomplete
  STATMSG("**Blink.cmp** Menu auto_show is now", PCFG.cmp_autocomplete, 0, "Config")
end, "Toggle color column display")
vim.g.setkey({ 'n', 'i' }, utility_key .. 'cg', function()
  PCFG.cmp_ghost = not PCFG.cmp_ghost
  STATMSG("**Blink.cmp**: Ghost Text is now", PCFG.cmp_ghost, 0, "Config")
end, "Toggle color column display")
vim.g.setkey({ 'n', 'i' }, utility_key .. '<C-k>', function() __Globals.toggle_colorcolumn() end, "Toggle color column display")
vim.g.setkey({ 'n', 'i' }, utility_key .. '<C-o>', function() __Globals.toggle_ibl() end, "Toggle indent-blankline active")
vim.g.setkey({ 'n', 'i' }, utility_key .. '<C-u>', function() __Globals.toggle_ibl_context() end, "Toggle indent-blankline context")
vim.g.setkey({ 'n', 'i' }, utility_key .. '<C-z>', function()
  PCFG.scrollbar = not PCFG.scrollbar
  __Globals.set_scrollbar()             -- toggle scrollbar visibility
end, "Toggle scrollbar")
vim.g.setkey({ 'n', 'i' }, utility_key .. '<C-g>', function()
  -- declutter status line. There are 4 levels. 0 displays all components, 1-3 disables some
  -- lesser needed
  PCFG.statusline_declutter = PCFG.statusline_declutter + 1
  if PCFG.statusline_declutter == 4 then
    PCFG.statusline_declutter = 0
  end
end, "Declutter status line")

vim.g.setkey({'n', 'i'}, '<A-q>', function()
  vim.cmd.stopinsert()
  vim.schedule(function() utils.Quitapp() end)
end, "Quit Neovim")

vim.g.setkey({'n', 'i'}, '<C-p>', function()
  require('fzf-lua').oldfiles( { formatter = "path.filename_first", winopts = vim.g.tweaks.fzf.winopts.small_no_preview })
end, "FZF-LUA old files")

vim.g.setkey({ "n", "i", "t", "v" }, "<C-e>", function()
  require("fzf-lua").buffers({ formatter = "path.filename_first", mru = true, no_action_zz = true, no_action_set_cursor = true, winopts = vim.g.tweaks.fzf.winopts.small_no_preview })
end, "FZF buffer list")
vim.g.setkey({'n', 'i', 'v' }, '<A-p>', function()
  require("commandpicker").open()
end, "Telescope command palette")

-- quick-focus the four main areas
vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-1>', function()
  __Globals.findbufbyType(treename)
end, "Focus NvimTree") -- Nvim-tree

vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-2>', function()
  vim.fn.win_gotoid(__Globals.main_winid)
  vim.cmd("hi nCursor blend=0")
end, "Focus Main Window") -- main window

-- focus or toggle the outline window
vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-3>', function()
  -- if the outline window is focused, close it.
  if vim.api.nvim_buf_get_option(0, "filetype") == PCFG.outline_filetype then
    __Globals.close_outline()
    return
  end
  -- otherwise search it and if none is found, open it.
  if __Globals.findbufbyType(PCFG.outline_filetype) == false then
    __Globals.open_outline()
    local status = __Globals.is_outline_open()
    if status.aerial ~= 0 then
      require("aerial").refetch_symbols(0) -- aerial plugin, refresh symbols
    end
    if status.outline ~= 0 then
      require("outline").refresh_outline()
    end
  end
end, "Focus Outline window") -- Outline

local function focus_term_split(dir)
  if __Globals.findbufbyType('terminal') == false then
    vim.api.nvim_input('<f11>')
  end
  vim.cmd.startinsert()
  if dir and #dir > 0 then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("cd '" .. dir .. "'<cr>", true, false, true), 'i', false)
  end
end

vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-4>', function()
  focus_term_split(nil)
end, "Focus Terminal split")

vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-5>', function()
  local dir = vim.fn.expand("%:p:h")
  focus_term_split(dir)
end, "Focus Terminal split and change to current dir")

vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-6>', function()
  local dir = utils.getroot_current()
  focus_term_split(dir)
end, "Focus Terminal split and change to project root")

kms({ 'n', 'i', 't', 'v' }, '<A-0>', function()
  local wid = vim.fn.win_getid()
  vim.api.nvim_win_set_option(wid, "winfixwidth", false)
  __Globals.main_winid = wid
end, opts) -- save current winid as main window id

vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-9>', function()
  local uspl = require('local_utils.usplit')
  if uspl.winid == nil then
    uspl.open()
  else
    if uspl.winid ~= vim.fn.win_getid() then
      vim.fn.win_gotoid(uspl.winid)
    else
      uspl.close()
      vim.fn.win_gotoid(__Globals.main_winid)
    end
  end
end, "Open the sysmon/fortune window")

vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-8>', function()
  local wspl = require('local_utils.wsplit')
  if wspl.winid == nil then
    wspl.openleftsplit(Config.weather.file)
  else
    if wspl.winid ~= vim.fn.win_getid() then
      vim.fn.win_gotoid(wspl.winid)
    else
      wspl.close()
      vim.fn.win_gotoid(__Globals.main_winid)
    end
  end
end, "Open the info/weather window")

-- focus quickfix list (when open)
vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-7>', function()
  local curwin = vim.fn.win_getid()
  if __Globals.findbufbyType('qf') == false then
    vim.cmd('below 10 copen')
  else
    local winid = __Globals.findwinbyBufType('qf')[1]
    if curwin == winid then
      vim.cmd('ccl')
    else
      vim.fn.win_gotoid(winid)
    end
  end
end, "Focus the quickfix list")

vim.g.setkey({ 'n', 'i', 't' }, '<f11>', function() __Globals.termToggle(12) end, "Toggle Terminal split at bottom")
map('t', '<Esc>', '<C-\\><C-n>', opts)

vim.g.setkey('n', fkeys.c_f8, '<CMD>RnvimrToggle<CR>', "Ranger in Floaterm")
vim.g.setkey('n', '<leader>wr', function() __Globals.toggle_wrap() end, "Toggle word wrap")
vim.keymap.set('n', 'ren', function() return ':IncRename ' .. vim.fn.expand('<cword>') end,
  { expr = true, desc = "Inc Rename", noremap = true, silent = true })

-- Alt-d: Detach all TUI sessions from the (headless) master
vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-d>', function() __Globals.detach_all_tui() end, "Detach all TUI")

local wordlist_module = vim.g.tweaks.completion == "nvim-cmp" and "cmp_wordlist" or "blink-cmp-wordlist"

vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. 'za', function()
  require(wordlist_module).add_cword()
end, "Add current word to wordlist")

vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. 'zt', function()
  require(wordlist_module).add_cword_with_translation()
end, "Add current word with translation to wordlist")

vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. 'wt', function()
  require("local_utils.wsplit").toggle_content()
end, "Toggle weather/info content")
vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. 'st', function()
  require("local_utils.usplit").toggle_content()
end, "Toggle sysmon/fortune content")
vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. 'sr', function()
  require("local_utils.usplit").refresh_cookie()
end, "Fortune refresh cookie")

vim.g.setkey({ 'n', 'i', 't', 'v' }, "<C-x>a", function()
  PCFG.autopair = not PCFG.autopair
  if PCFG.autopair == true then
    require("nvim-autopairs").enable()
  else
    require("nvim-autopairs").disable()
  end
end, "Toggle autopairing")

-- toggle the display of single-letter status indicators in the winbar.
vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. 'wb', function()
  PCFG.show_indicators = not PCFG.show_indicators
  __Globals.notify("WinBar status indicators are now: " .. (PCFG.show_indicators == true and "On" or "Off"),
    vim.log.levels.INFO)
end, "Toggle WinBar status indicators")

-- debug keymap, print the filetype of the current buffer
vim.g.setkey({ 'n', 'i', 't', 'v' }, '<C-x>ft', function()
  __Globals.notify("Filetype is: " .. vim.api.nvim_get_option_value("filetype", { buf = 0 }), 2, " ")
end, "Show filetype of current buffer")

vim.g.setkey({ 'n', 'i', 't', 'v' }, '<C-x>bt', function()
  __Globals.notify("Buftype is: " .. vim.api.nvim_get_option_value("buftype", { buf = 0 }), 2, " ")
end, "Show buftype of current buffer")

vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. '3', function()
  local status = __Globals.is_outline_open()
  if status.aerial ~= 0 then
    require("aerial").refetch_symbols(0) -- aerial plugin, refresh symbols
  elseif status.outline ~= 0 then
    require("outline").refresh_outline()
  end
end, "Refresh aerial outline symbols")
vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. '+', function()
  __Globals.toggle_outline_type()        -- toggle the outline plugin (aerial <> symbols-outline)
end, "Toggle Outline plugin type")

require("local_utils.marks").set_keymaps()
--vim.cmd("nunmap <cr>")

local status, snacks = pcall(require, "snacks")
if status == true then
  vim.g.setkey( {'n', 'i'}, '<C-S-E>', function()
    snacks.picker.smart({ layout = SPL( {width = 70, height = 20, row = 5, title = "Buffers", input = "top" } ) })
  end, "Snacks buffer list")
end

vim.g.setkey( { 'n', 'i' }, "<C-x>z", function()
  require("snacks").picker.zoxide({
  confirm = function(picker, item)
    picker:close()
    __Globals.open_with_fzf(item.file)
  end,
  layout = SPL({ input = "top", width = 80, height = 0.7, row = 7, preview = false, title="Zoxide history" }) })
end, "Pick from Zoxide")

vim.g.setkey( { 'i', 'n' }, "<C-S-P>", function()
  require("snacks").picker.projects({
  confirm = function(picker, item)
    picker:close()
    __Globals.open_with_fzf(item.file)
  end,
  layout = SPL( {width = 50, height = 20, row = 5, title = "Projects" } ) })
end, "Pick recent project")

-- allow to move the cursor during multicursor-editing, prevent <Left>, <Right> from
-- creating undo points..
vim.keymap.set('i', "<Left>",  "<C-g>U<Left>", { silent = true, noremap = true } )
vim.keymap.set('i', "<Right>",  "<C-g>U<Right>", { silent = true, noremap = true } )

vim.g.setkey("n", utility_key .. "ll", function() require("darkmatter.colortools").saturatehex(-0.05) end )
