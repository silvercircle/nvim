local map = vim.api.nvim_set_keymap
local kms = vim.keymap.set

local opts = { noremap = true, silent = true }
local Utils = require('subspace.lib')
local utility_key = Tweaks.keymap.utility_key
local treename = Tweaks.tree.filetype
local Snacks = require("snacks")
local Tabs = require("subspace.lib.tabmanager")

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

local toggle_fo = CGLOBALS.toggle_fo

vim.g.setkey({ 'i', 'n' }, utility_key .. 'ft', function() toggle_fo('a') end, "Toggle 'a' format option")
vim.g.setkey({ 'i', 'n' }, utility_key .. 'fc', function() toggle_fo('c') end, "Toggle 'c' format option")
vim.g.setkey({ 'i', 'n' }, utility_key .. 'fw', function() toggle_fo('w') end, "Toggle 'w' format option")
vim.g.setkey({ 'i', 'n' }, utility_key .. 'ft', function() toggle_fo('t') end, "Toggle 't' format option")
vim.g.setkey({ 'i', 'n' }, utility_key .. 'fl', function() toggle_fo('l') end, "Toggle 'l' format option")
vim.g.setkey({ 'i', 'n' }, utility_key .. 'fr', function() toggle_fo('r') end, "Toggle 'r' format option")
vim.g.setkey({ 'i', 'n' }, utility_key .. 'fq', function() toggle_fo('q') end, "Toggle 'q' format option")
vim.g.setkey({ 'i', 'n' }, utility_key .. 'fo', function() toggle_fo('o') end, "Toggle 'o' format option")
vim.g.setkey({ 'i', 'n' }, utility_key .. 'fj', function() toggle_fo('j') end, "Toggle 'j' format option")

vim.g.setkey({ 'i', 'n' }, utility_key .. 'f1', function() CGLOBALS.set_fo('wat') end, "Set 'w', 't' and 'a' format options")
vim.g.setkey({ 'i', 'n' }, utility_key .. 'f2', function() CGLOBALS.clear_fo('wat') end, "Clear 'w', 't' and 'a' format options")

vim.g.setkey({ 'i', 'n' }, utility_key .. 'aa', function()
  CGLOBALS.clear_fo('wacqtl')
end, "Clear all formatting options")
vim.g.setkey({ 'i', 'n' }, utility_key .. 'an', function()
  CGLOBALS.set_fo('wacqtl')
end, "Set all formatting options")

map('v', '<leader>V', ":<Home>silent <End>!fmt -105<CR>", opts)
map('v', '<leader>y', ":<Home>silent <End>!fmt -85<CR>", opts)

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
  vim.schedule(function() Utils.BufClose() end)
end, "Close Buffer")
vim.g.setkey({'n', 'i', 'v'}, '<f5>', function() perform_command('nohl') end, "Clear highlighted search results")

vim.g.setkey('i', '<C-z>', function() perform_command("undo") end, "Undo (insert mode)")

-- various
map('i', '<C-y>-', '—', opts) -- emdash
map('i', '<C-y>"', '„”', opts) -- typographic quotes („”)
vim.g.setkey({ 'n', 'i' }, '<A-w>', function()
  if vim.fn.win_getid() ~= TABM.T[TABM.active].id_main then vim.cmd('close') end
end, "Close Window")

vim.g.setkey({'n', 'i'}, '<C-f>c', function()
  CGLOBALS.close_qf_or_loc()
end, "Close quickfix/loclist window")

--- mini picker shortcuts, all start with <C-a>
vim.g.setkey({ 'n', 'i' }, '<C-a>f', function()
  Utils.PickFoldingMode(vim.o.foldmethod)
end, "Pick folding mode")

vim.g.setkey({'n', 'i'}, '<C-a>e', function()
  require("fzf-lua").files({ formatter = "path.filename_first", cwd = vim.fn.expand("%:p:h"), winopts = Tweaks.fzf.winopts.very_narrow_no_preview })
end, "Open Mini File Browser at current directory")

vim.g.setkey({'n', 'i'}, '<C-a><C-e>', function()
  require("fzf-lua").files({ formatter = "path.filename_first", cwd = Utils.getroot_current(), winopts = Tweaks.fzf.winopts.very_narrow_no_preview })
end, "Open Mini File Browser at project root")

vim.g.setkey({'n', 'i'}, '<A-E>', function()
  local cwd = Utils.getroot_current()
  Snacks.picker.explorer({cwd = cwd,
    layout = SPL( { width = 70, psize = 12, input = "top", title = cwd }) })
end, "Open Snacks Explorer at project root")
-- this is a bit hacky. it tries to find the root directory of the sources
-- in the current project. it assumes that sources are located in one of the
-- subfolders listed in Tweaks.srclocations. You can customize this if you want
vim.g.setkey({'n', 'i'}, '<A-e>', function()
  local found = false
  local path = Utils.getroot_current()
  for _, v in ipairs(Tweaks.srclocations) do
    local res = vim.fs.joinpath(path, v)
    if vim.fn.isdirectory(res) == 1 then
      found = true
      require("fzf-lua").files({ formatter = "path.filename_first", cwd = res, winopts = Tweaks.fzf.winopts.very_narrow_no_preview })
    end
  end
  -- if we cannot find a source root, use the project root instead
  if found == false and path ~= nil and vim.fn.isdirectory(path) then
    require("fzf-lua").files({ cwd = path, winopts = Tweaks.fzf.winopts.very_narrow_no_preview })
  end
end, "Open Mini File Browser and guess sources root")

vim.g.setkey('n', '<C-a>w', function()
  require("mini.files").open(vim.fn.expand("%:p:h"))
end, "Open Mini.Files at current directory")

vim.g.setkey('n', '<C-a><C-w>', function()
  require("mini.files").open(Utils.getroot_current())
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

map('n', utility_key .. '<C-h>', "<CMD>Inspect<CR>", opts)
map('i', utility_key .. '<C-h>', "<c-o><CMD>Inspect<CR>", opts)

if Tweaks.completion.version ~= "blink" then
  vim.g.setkey({ 'i', 'n' }, fkeys.s_f1, function() vim.lsp.buf.signature_help() end, "Show signature help")
end

--- opens a hover for the symbol under the cursor. if it's a closed UFO fold, then
--- show a hover for it instead.
--- press <F1> again to enter the hover window, press <q> to dismiss it.
vim.keymap.set({ "n", "i" }, "<f1>", function()
  local api = vim.api
  local hover_win = vim.b.hover_preview
  if hover_win and api.nvim_win_is_valid(hover_win) then
    api.nvim_set_current_win(hover_win)
  else
    require("hover").hover()
  end
end, { desc = "LSP hover window" })

vim.g.setkey({ 'i', 'n' }, '<C-x>d', function()
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

vim.g.setkey({ 'n', 'i' }, utility_key .. '<C-l>', function()
  CGLOBALS.toggle_statuscol()
end, "Toggle absolute/relative line numbers")
vim.g.setkey({ 'n', 'i' }, utility_key .. 'p', function()
  CGLOBALS.toggle_inlayhints()
end, "Toggle LSP inlay hints")

vim.g.setkey({ 'n', 'i' }, utility_key .. 'ca', function()
  PCFG.cmp_automenu = not PCFG.cmp_automenu
  STATMSG("**Blink.cmp** Menu auto_showis now: ", PCFG.cmp_automenu, 0, "Config")
end, "Toggle color column display")
vim.g.setkey({ 'n', 'i' }, utility_key .. 'cg', function()
  PCFG.cmp_ghost = not PCFG.cmp_ghost
  STATMSG("**Blink.cmp**: Ghost Text is now: ", PCFG.cmp_ghost, 0, "Config")
end, "Toggle color column display")
vim.g.setkey({ 'n', 'i' }, utility_key .. 'cc', function()
  local s, val = pcall(vim.api.nvim_buf_get_var, 0, "completion")
  local enabled = ((s == true and val == true ) or (s == false ))
  vim.api.nvim_buf_set_var(0, "completion", not enabled)
  STATMSG("**Blink.cmp**: Completion for this buffer is now: ", not enabled, 0, "Config")
end, "Toggle color column display")

vim.g.setkey({ 'n', 'i' }, utility_key .. 'w', function() CGLOBALS.toggle_wrap() end, "Toggle word wrap")
vim.g.setkey({ 'n', 'i' }, utility_key .. 'k', function() CGLOBALS.toggle_colorcolumn() end, "Toggle color column display")
vim.g.setkey({ 'n', 'i' }, utility_key .. 'o', function()
  local state = vim.b[0].snacks_indent
  if state == false then
    vim.notify("Indent guides disabled for this buffer, use " .. utility_key .. "u to re-enable", vim.log.levels.INFO)
  else
    CGLOBALS.toggle_ibl()
  end
end, "Toggle indent guides")
vim.g.setkey({ 'n', 'i' }, utility_key .. 'u', function()
  local state = vim.b[0].snacks_indent
  if state == nil or state == true then
    vim.b[0].snacks_indent = false
  else
    vim.b[0].snacks_indent = true
  end
  vim.cmd.redraw()
end, "Toggle indent guides per buffer buffer")
vim.g.setkey({ 'n', 'i' }, utility_key .. 'z', function()
  PCFG.scrollbar = not PCFG.scrollbar
  CGLOBALS.set_scrollbar()             -- toggle scrollbar visibility
end, "Toggle scrollbar")
vim.g.setkey({ 'n', 'i' }, utility_key .. 'g', function()
  -- declutter status line. There are 4 levels. 0 displays all components, 1-3 disables some
  -- lesser needed
  PCFG.statusline_verbosity = PCFG.statusline_verbosity + 1
  if PCFG.statusline_verbosity == 4 then
    PCFG.statusline_verbosity = 0
  end
  vim.notify("Lualine declutter level: " .. PCFG.statusline_verbosity, 0, { title = "Lualine" })
end, "Declutter status line")

vim.g.setkey({'n', 'i'}, '<A-q>', function()
  vim.cmd.stopinsert()
  vim.schedule(function() Utils.Quitapp() end)
end, "Quit Neovim")

vim.g.setkey({'n', 'i'}, '<C-p>', function()
  if vim.fn.win_getid() == TABM.T[TABM.active].id_main or vim.bo.buftype == "" or vim.bo.buftype == "acwrite" then
    require('fzf-lua').oldfiles( { formatter = "path.filename_first", winopts = FWO("small_no_preview", { title = "Recent files", width = 100 }) })
  end
end, "FZF-LUA old files")

vim.g.setkey({ "n", "i", "t", "v" }, "<C-e>", function()
  if vim.fn.win_getid() == TABM.T[TABM.active].id_main or vim.bo.buftype == "" or vim.bo.buftype == "acwrite" then
    require("fzf-lua").buffers({ formatter = "path.filename_first", mru = true, no_action_zz = true,
      no_action_set_cursor = true, winopts = FWO("small_no_preview", { title = "Buffers <C-d>:delete <C-w>:save when modified", width = 100 }) })
  end
end, "FZF buffer list")
vim.g.setkey({'n', 'i', 'v' }, '<A-p>', function()
  require("commandpicker").open()
end, "Command palette")

-- quick-focus the four main areas
vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-1>', function()
  TABM.findbufbyType(treename, true)
end, "Focus NvimTree") -- Nvim-tree

vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-2>', function()
  vim.fn.win_gotoid(Tabs.T[Tabs.active].id_main)
  vim.cmd("hi nCursor blend=0")
end, "Focus Main Window") -- main window

-- focus or toggle the outline window
vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-3>', function()
  -- if the outline window is focused, close it.
  if vim.api.nvim_get_option_value("filetype", { buf = 0 }) == PCFG.outline_filetype then
    TABM.close_outline()
    return
  end
  -- otherwise search it and if none is found, open it.
  if TABM.findbufbyType(PCFG.outline_filetype, true) == 0 then
    TABM.open_outline()
  end
end, "Focus Outline window") -- Outline

local function focus_term_split(dir)
  if TABM.findbufbyType('terminal', true) == 0 then
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
  local dir = Utils.getroot_current()
  focus_term_split(dir)
end, "Focus Terminal split and change to project root")

kms({ 'n', 'i', 't', 'v' }, '<A-0>', function()
  local wid = vim.fn.win_getid()
  vim.api.nvim_set_option_value("winfixwidth", false, { win = wid })
  CGLOBALS.main_winid[PCFG.tab] = wid
end, opts) -- save current winid as main window id

vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-9>', function()
  local uspl = TABM.get().usplit
  if not uspl.id_win or uspl.id_win == 0 then
    uspl:open()
  else
    if uspl.id_win ~= vim.fn.win_getid() then
      vim.fn.win_gotoid(uspl.id_win)
    else
      uspl:close()
      vim.fn.win_gotoid(TABM.T[TABM.active].id_main)
    end
  end
end, "Open the sysmon/fortune window")

vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-8>', function()
  local wspl = require('subspace.content.wsplit')
  local wsplit = TABM.get().wsplit
  if wsplit.id_win == nil then
    wspl.open(CFG.weather.file)
  else
    if wsplit.id_win ~= vim.fn.win_getid() then
      vim.fn.win_gotoid(wsplit.id_win)
    else
      wspl.close()
      vim.fn.win_gotoid(TABM.T[TABM.active].id_main)
    end
  end
end, "Open the info/weather window")

-- focus quickfix list (when open)
vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-7>', function()
  local curwin = vim.fn.win_getid()
  if TABM.findbufbyType('qf') == 0 then
    vim.cmd('below 10 copen')
  else
    local winid = TABM.findWinByFiletype('qf', true)[1]
    if curwin == winid then
      vim.cmd('ccl')
    else
      vim.fn.win_gotoid(winid)
    end
  end
end, "Focus the quickfix list")

vim.g.setkey({ 'n', 'i', 't' }, '<f11>', function() TABM.termToggle(12) end, "Toggle Terminal split at bottom")
map('t', '<Esc>', '<C-\\><C-n>', opts)

vim.g.setkey('n', fkeys.c_f8, function() require("oil").open() end, "Open Oil file manager")
vim.keymap.set('n', 'ren', function() return ':IncRename ' .. vim.fn.expand('<cword>') end,
  { expr = true, desc = "Inc Rename", noremap = true, silent = true })

-- Alt-d: Detach all TUI sessions from the (headless) master
vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-d>', function() CGLOBALS.detach_all_tui() end, "Detach all TUI")

local wordlist_module = Tweaks.completion == "nvim-cmp" and "cmp_wordlist" or "blink-cmp-wordlist"

vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. 'za', function()
  require(wordlist_module).add_cword()
end, "Add current word to wordlist")

vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. 'zt', function()
  require(wordlist_module).add_cword_with_translation()
end, "Add current word with translation to wordlist")

vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. 'wt', function()
  require("subspace.content.wsplit").toggle_content()
end, "Toggle weather/info content")
vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. 'st', function()
  local usplit = TABM.get().usplit
  usplit:toggle_content()
end, "Toggle sysmon/fortune content")
vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. 'sr', function()
  require("subspace.content.usplit").refresh_cookie()
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
  STATMSG("WinBar status indicators are now: " .. (PCFG.show_indicators == true and "On" or "Off"),
    vim.log.levels.INFO, "Config")
end, "Toggle WinBar status indicators")

-- debug keymap, print the filetype of the current buffer
vim.g.setkey({ 'n', 'i', 't', 'v' }, '<C-x>ft', function()
  vim.notify("Filetype is: " .. vim.api.nvim_get_option_value("filetype", { buf = 0 }), 2, { title = "Buftype" })
end, "Show filetype of current buffer")

vim.g.setkey({ 'n', 'i', 't', 'v' }, '<C-x>bt', function()
  vim.notify("Buftype is: " .. vim.api.nvim_get_option_value("buftype", { buf = 0 }), 2, { title = "Buftype" })
end, "Show buftype of current buffer")

vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. '3', function()
  local status = TABM.is_outline_open()
  if status ~= false then
    -- simply fire BufWinEnter this will refresh the symbols sidebar
    vim.api.nvim_exec_autocmds({"BufWinEnter"}, {})
  elseif Tweaks.tree.version == "Neo" then
    vim.cmd("Neotree source=document_symbols")
  end
end, "Refresh outline symbols")

if Tweaks.tree.version == "Neo" then
  vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. '7', function()
    vim.cmd("Neotree source=filesystem")
  end)
  vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. '8', function()
    vim.cmd("Neotree source=buffers")
  end)
  vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. '9', function()
    vim.cmd("Neotree source=document_symbols")
  end)
end

vim.g.setkey( {'n', 'i'}, '<C-S-E>', function()
  Snacks.picker.smart({ layout = SPL( {width = 70, height = 20, row = 5, title = "Buffers", input = "top" } ) })
end, "Snacks buffer list")

vim.g.setkey( { 'i', 'n' }, "<C-S-P>", function()
  Snacks.picker.projects({
  confirm = function(picker, item)
    picker:close()
    CGLOBALS.open_with_fzf(item.file)
  end,
  layout = SPL( {width = 50, height = 20, row = 5, title = "Projects" } ) })
end, "Pick recent project")

-- allow to move the cursor during multicursor-editing, prevent <Left>, <Right> from
-- creating undo points..
vim.keymap.set('i', "<Left>",  "<C-g>U<Left>", { silent = true, noremap = true } )
vim.keymap.set('i', "<Right>",  "<C-g>U<Right>", { silent = true, noremap = true } )

vim.g.setkey("n", utility_key .. "ll", function() require("darkmatter.colortools").saturatehex(-0.05) end )
require("subspace.lib.darkmatter").map_keys()

vim.g.setkey( {"v", "n", "i"}, utility_key .. "mm", function() require("neominimap.api").toggle() end, "Toggle Minimap")

vim.g.setkey( {"v", "n", "i"}, utility_key .. "<tab>", ":tabnext<cr>", "Select next tab")
vim.g.setkey( {"v", "n", "i"}, utility_key .. "tn", function() vim.cmd("tabnew") end, "Open new tab page")
vim.g.setkey( {"v", "n", "i"}, utility_key .. "tx", function() vim.schedule(function() vim.cmd("tabclose!") end) end, "Close tab page")
vim.g.setkey( {"v", "n", "i"}, utility_key .. "tc", function() TABM.clonetab() end, "Close tab page")
vim.g.setkey( {"v", "n", "i"}, utility_key .. "td", function()
  vim.cmd("tabnew")
  require("dapui").open()
end, "Open new tab page")

require("subspace.lib.marks").set_keymaps()
vim.g.setkey( { "v", "n", "i" }, "<C-x><C-o>", function() Utils.obsidian_menu() end)
vim.keymap.set('x', 'z/', '<C-\\><C-n>`</\\%V', { desc = 'Search forward within visual selection' })
vim.keymap.set('x', 'z?', '<C-\\><C-n>`>?\\%V', { desc = 'Search backward within visual selection' })
