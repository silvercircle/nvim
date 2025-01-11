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

map('n', '<leader><tab>', '<CMD>tabnext<CR>', opts)

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

vim.g.setkey({'n', 'i', 'v'}, '<C-s><C-c>', function() require("local_utils").BufClose() end, "Close Buffer")
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

--- mini picker shortcuts, all start with <C-m>
vim.g.setkey({ 'n', 'i' }, '<C-a>f', function()
  utils.PickFoldingMode(vim.o.foldmethod)
end, "Pick folding mode")

vim.g.setkey('n', '<C-a>e', function()
  require("mini.extra").pickers.explorer(
  { cwd = vim.fn.expand("%:p:h")  },
  { window = { config = __Globals.mini_pick_center(60, 0.7, 0.2) } })
end, "Open Mini.Explorer at current directory")

vim.g.setkey('n', '<C-a><C-e>', function()
  require("mini.extra").pickers.explorer(
  { cwd = utils.getroot_current()  },
  { window = { config = __Globals.mini_pick_center(60, 0.7, 0.2) } })
end, "Open Mini.Explorer at project root")

vim.g.setkey('n', '<C-a>w', function()
  require("mini.files").open(vim.fn.expand("%:p:h"))
end, "Open Mini.Files at current directory")

vim.g.setkey('n', '<C-a><C-w>', function()
  require("mini.files").open(utils.getroot_current())
end, "Open Mini.Files at project root")

--_Config_SetKey('n', '<C-a>m', function()
--  require("mini.extra").pickers.marks(
--  { },
--  { window = { config = __Globals.mini_pick_center(50, 0.6, 0.2) } })
--end, "Mini.Picker for marks")

vim.g.setkey('n', '<C-a>h', function()
  require("mini.pick").builtin.help(
  { },
  { window = { config = __Globals.mini_pick_center(60, 0.5, 0.2) } })
end, "Mini.Picker for help tags")
---
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

vim.g.setkey({ 'i', 'n' }, fkeys.s_f1, function() vim.lsp.buf.signature_help() end, "Show signature help")

vim.keymap.set({ "n", "i" }, '<f1>', function()
	local api = vim.api
	local hover_win = vim.b.hover_preview
	if hover_win and api.nvim_win_is_valid(hover_win) then
		api.nvim_set_current_win(hover_win)
	else
		require("hover").hover()
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
vim.g.setkey({ 'n', 'i' }, utility_key .. '<C-k>', function() __Globals.toggle_colorcolumn() end, "Toggle color column display")
vim.g.setkey({ 'n', 'i' }, utility_key .. '<C-p>', function() __Globals.toggle_ibl_rainbow() end, "Toggle indent-blankline rainbow mode")
vim.g.setkey({ 'n', 'i' }, utility_key .. '<C-o>', function() __Globals.toggle_ibl() end, "Toggle indent-blankline active")
vim.g.setkey({ 'n', 'i' }, utility_key .. '<C-u>', function() __Globals.toggle_ibl_context() end, "Toggle indent-blankline context")
vim.g.setkey({ 'n', 'i' }, utility_key .. '<C-z>', function()
  __Globals.perm_config.scrollbar = not __Globals.perm_config.scrollbar
  __Globals.set_scrollbar()             -- toggle scrollbar visibility
end, "Toggle scrollbar")
vim.g.setkey({ 'n', 'i' }, utility_key .. '<C-g>', function()
  -- declutter status line. There are 4 levels. 0 displays all components, 1-3 disables some
  -- lesser needed
  __Globals.perm_config.statusline_declutter = __Globals.perm_config.statusline_declutter + 1
  if __Globals.perm_config.statusline_declutter == 4 then
    __Globals.perm_config.statusline_declutter = 0
  end
end, "Declutter status line")

vim.g.setkey('n', '<A-q>', function()
  utils.Quitapp()
end, "Quit Neovim")
vim.g.setkey({ 'n', 'i' }, '<C-e>', function()
  require('telescope.builtin').buffers(
    __Telescope_dropdown_theme({
      title = 'Buffer list',
      width = 120,
      prompt_prefix = utils.getTelescopePromptPrefix(),
      height = 0.4,
      sort_lastused = true,
      sort_mru = true,
      show_all_buffers = true,
      ignore_current_buffer = true,
      sorter = require('telescope.sorters').get_substr_matcher(),
    })
  )
end, "Telescope Buffer list")

if vim.g.tweaks.fzf.prefer_for.selector == true then
  vim.g.setkey({'n', 'i'}, '<C-p>', function()
    require('fzf-lua').oldfiles( { winopts = vim.g.tweaks.fzf.winopts.small_no_preview })
  end, "Telescope old files")
else
  vim.g.setkey({'n', 'i'}, '<C-p>', function()
    require('telescope.builtin').oldfiles(
      __Telescope_dropdown_theme({ prompt_prefix = utils.getTelescopePromptPrefix(), title = 'Old files', width = 120, height = 0.5 })
    )
  end, "Telescope old files")
end
vim.g.setkey({'n', 'i', 'v' }, '<A-p>', function()
  -- require('telescope').extensions.command_center.command_center({ filter={ mode = 'n' }})
  require("local_utils.commandcenter").open()
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
  if vim.api.nvim_buf_get_option(0, "filetype") == __Globals.perm_config.outline_filetype then
    __Globals.close_outline()
    return
  end
  -- otherwise search it and if none is found, open it.
  if __Globals.findbufbyType(__Globals.perm_config.outline_filetype) == false then
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
  __Globals.perm_config.autopair = not __Globals.perm_config.autopair
  if __Globals.perm_config.autopair == true then
    require("nvim-autopairs").enable()
  else
    require("nvim-autopairs").disable()
  end
end, "Toggle autopairing")

-- toggle the display of single-letter status indicators in the winbar.
vim.g.setkey({ 'n', 'i', 't', 'v' }, utility_key .. 'wb', function()
  __Globals.perm_config.show_indicators = not __Globals.perm_config.show_indicators
  __Globals.notify("WinBar status indicators are now: " .. (__Globals.perm_config.show_indicators == true and "On" or "Off"),
    vim.log.levels.INFO)
end, "Toggle WinBar status indicators")

-- debug keymap, print the filetype of the current buffer
vim.g.setkey({ 'n', 'i', 't', 'v' }, '<C-x>ft', function()
  __Globals.notify("Filetype is: " .. vim.api.nvim_get_option_value("filetype", { buf = 0 }), 2, " ")
end, "Show filetype of current buffer")

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

vim.g.setkey({ 'n', 'i', 't', 'v' }, '<A-n>', function()
  if vim.g.tweaks.breadcrumb == "navic" then
    require("nvim-navbuddy").open()
  else
    require("aerial").nav_open()
  end
end, "Open Navbuddy window")

vim.g.setkey({ 'n', 'i' }, '<A-e>', function()
  require("mini.pick").builtin.buffers({include_current=false}, {window = { config = __Globals.mini_pick_center(100, 20, 0.1) } } )
end, "Mini.Picker Buffer list")

require("local_utils.marks").set_keymaps()
-- vim.cmd("nunmap <cr>")
