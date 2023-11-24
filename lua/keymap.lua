-- This version is needed when the command_center plugin is installed and configure. It will
-- overtake many of the original keyboar mappings.
-- The majority of the more complex mappings for LSP are in setup_command_center.lua

local map = vim.api.nvim_set_keymap
local kms = vim.keymap.set
local globals = require("globals")

local opts = { noremap = true, silent = true }
local utils = require('local_utils')
local utility_key = vim.g.tweaks.utility_key

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

kms({ 'n', 'i' }, '<C-c>', '<NOP>', opts)
-- disable <ins> toggling the (annoying) replace mode. Instead use <c-ins> to switch to replace
map('i', '<ins>', '<nop>', opts)

-- file tree
kms({'n', 'v'}, '<leader>r', function() perform_command('NvimTreeFindFile') end, opts) -- sync Nvim-Tree with current
-- toggle NvimTree
kms('n', '<leader>,', function() require('nvim-tree.api').tree.toggle() end, opts)

-- change NvimTree current directory to the root of current project
kms('n', '<leader>R', function() require('nvim-tree.api').tree.change_root(utils.getroot_current()) end, opts)
-- same, but use the directory of the current buffer
kms('n', '<leader>nr', function() require('nvim-tree.api').tree.change_root(vim.fn.expand('%:p:h')) end, opts)
--end

map('n', '<C-Tab>', '<CMD>bnext<CR>', opts)
map('n', '<leader><Tab>', '<CMD>bnext<CR>', opts)

kms({ 'i', 'n' }, '<C-f><C-a>', function() globals.toggle_fo('a') end, opts)
kms({ 'i', 'n' }, '<C-f><C-c>', function() globals.toggle_fo('c') end, opts)
kms({ 'i', 'n' }, '<C-f><C-w>', function() globals.toggle_fo('w') end, opts)
kms({ 'i', 'n' }, '<C-f><C-t>', function() globals.toggle_fo('t') end, opts)

kms({ 'i', 'n' }, '<C-f>1', function() globals.set_fo('w')  globals.set_fo('a') end, opts)
kms({ 'i', 'n' }, '<C-f>2', function() globals.clear_fo('w') globals.clear_fo('a') end, opts)

kms({ 'i', 'n' }, '<C-f>f', function()
  globals.clear_fo('w')
  globals.clear_fo('a')
  globals.clear_fo('c')
  globals.clear_fo('q')
  globals.clear_fo('t')
  globals.clear_fo('l')
end, opts)
kms({ 'i', 'n' }, '<C-f>a', function()
  globals.set_fo('w')
  globals.set_fo('a')
  globals.set_fo('c')
  globals.set_fo('q')
  globals.set_fo('t')
  globals.set_fo('l')
end, opts)

map('v', '<leader>V', ':!fmt -110<CR>', opts)
map('v', '<leader>y', ':!fmt -85<CR>', opts)

-- format a paragraph, different in normal and insert modes
kms('n', '<A-C-w>', function()
  vim.api.nvim_feedkeys('}kV{jgq', 'i', true)
end, opts)
kms('i', '<A-C-w>', function()
  local key = vim.api.nvim_replace_termcodes('<C-o>}<C-o>V{jgq', true, false, true)
  vim.api.nvim_feedkeys(key, 'i', false)
end, opts)

map('n', '<leader>v', '}kV{j', opts) -- select current paragraph

-- save file,
kms({'i', 'n', 'v'}, '<C-s><C-s>', function() perform_command("update!") end, opts)

-- Ctrl-x Ctrl-c close the file, do NOT save it(!) but create the view to save folding state and
-- cursor position. if g.confirm_actions['buffer_close'] is true then a warning message and a
-- selection dialog will appear..
kms({'n', 'i', 'v'}, '<C-s><C-c>', function() require("local_utils").BufClose() end, opts)

-- switch off highlighted search results

kms({'n', 'i', 'v'}, '<f5>', function() perform_command('nohl') end, opts)

kms('i', '<C-z>', function() perform_command("undo") end, opts)

-- various
map('i', '<C-y>-', '—', opts) -- emdash
map('i', '<C-y>"', '„”', opts) -- typographic quotes („”)
-- close window
kms({ 'n', 'i' }, '<A-w>', function()
  if vim.fn.win_getid() ~= globals.main_winid then
    vim.cmd('close')
  end
end, opts)

-- quickfix/loclist navigation
kms({'n', 'i'}, '<C-f>c', function()
  globals.close_qf_or_loc()
end, opts)

--- mini picker shortcuts, all start with <C-m>
kms({ 'n', 'i' }, '<C-a>f', function()
  utils.PickFoldingMode(vim.o.foldmethod)
end, opts)

--- open mini explorer at current directory
kms('n', '<C-a>e', function()
  require("mini.extra").pickers.explorer(
  { cwd = vim.fn.expand("%:p:h")  },
  { window = { config = globals.mini_pick_center(60, 0.6, 0.2) } })
end, opts)

--- open mini explorer at project root
kms( 'n', '<C-a><C-e>', function()
  require("mini.extra").pickers.explorer(
  { cwd = utils.getroot_current()  },
  { window = { config = globals.mini_pick_center(60, 0.6, 0.2) } })
end, opts)

--- open mini picker for marks
kms('n', '<C-a>m', function()
  require("mini.extra").pickers.marks(
  { },
  { window = { config = globals.mini_pick_center(50, 0.6, 0.2) } })
end, opts)
--- open mini picker help tags
kms('n', '<C-a>h', function()
  require("mini.pick").builtin.help(
  { },
  { window = { config = globals.mini_pick_center(60, 0.5, 0.2) } })
end, opts)
---
kms({'n', 'i', 'v'}, '<C-S-Down>', function() perform_command('cnext') end, opts)
kms({'n', 'i', 'v'}, '<C-S-Up>', function() perform_command('cprev') end, opts)
kms({'n', 'i', 'v'}, '<C-S-PageDown>', function() perform_command('lnext') end, opts)
kms({'n', 'i', 'v'}, '<C-S-PageUp>', function() perform_command('lprev') end, opts)

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
vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], opts)
vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], opts)
vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], opts)
vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], opts)

-- run `:nohlsearch` and export results to quickfix
kms({ 'n', 'x' }, '<Leader>#', function()
  vim.schedule(function()
    if require('hlslens').exportLastSearchToQuickfix() then
      vim.cmd('cw')
    end
  end)
  return ':noh<CR>'
end, { expr = true })

map('n', 'hl', "<CMD>Inspect<CR>", opts)

-- Shift-F1 show lsp signature help
kms({ 'i', 'n' }, '<f13>', function()
  vim.lsp.buf.signature_help()
end, opts)
-- F1 show lsp hover (symbol help in most cases)
kms({ 'i', 'n' }, '<f1>', function()
  vim.lsp.buf.hover()
end, opts)

kms({ 'n', 'i' }, '<f4>', function()
  globals.mkview()
end, opts)
--
-- toggle current fold
kms({'n', 'i', 'v'}, '<F2>', function() perform_key('za') end, opts)

-- close current fold (Shift-F2)
kms({'n', 'i', 'v'}, '<f14>', function() perform_key('zc') end, opts)

-- open current fold (Ctrl-F2)
kms({'n', 'i', 'v'}, '<f26>', function() perform_key('zo') end, opts)

-- toggle all folds at current line
kms({'n', 'i', 'v'}, '<F3>', function() perform_key('zA') end, opts)

-- close all folds at current line (Shift-F3)
kms({'n', 'i', 'v'}, '<f15>', function() perform_key('zC') end, opts)

-- open all folds at current line (Ctrl-F3)
kms({'n', 'i', 'v'}, '<f27>', function() perform_key('zO') end, opts)

-- jump list
kms({'n', 'i', 'v'}, '<C-S-Left>', function() perform_key('<C-o>') end, opts)
kms({'n', 'i', 'v'}, '<C-S-Right>', function() perform_key('<C-i>') end , opts)

-- change list
kms({'n', 'i'}, '<A-Left>', function() perform_key('g;') end, opts)
kms({'n', 'i'}, '<A-Right>', function() perform_key('g,') end, opts)

kms('n', '<f23>', function() perform_command('Lazy') end, opts)

-- utility functions
-- they use a prefix key, by default <C-l>. Can be customized in tweaks.lua

kms({ 'n', 'i' }, utility_key .. '<C-l>', function()
  globals.toggle_statuscol()          -- switch status column absolute/relative line numbers
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-k>', function()
  globals.toggle_colorcolumn()        -- toggle the colorcolumn display
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-t>', function()
  globals.toggle_theme_variant()      -- toggle the theme variant ("warm" / "cold")
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-d>', function()
  globals.toggle_theme_desaturate()   -- desaturate theme colors
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-p>', function()
  globals.toggle_ibl_rainbow()        -- toggle indent-blankline rainbow guides
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-o>', function()
  globals.toggle_ibl()                -- toggle indent-blankline active
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-u>', function()
  globals.toggle_ibl_context()        -- toggle indent-blankline context display
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-z>', function()
  globals.perm_config.scrollbar = not globals.perm_config.scrollbar
  globals.set_scrollbar()             -- toggle scrollbar visibility
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-h>', function()
  globals.perm_config.transbg = not globals.perm_config.transbg
  globals.set_bg()                    -- toggle transparent background (may not work on all terminals)
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-g>', function()
  -- declutter status line. There are 4 levels. 0 displays all components, 1-3 disables some
  -- lesser needed
  globals.perm_config.statusline_declutter = globals.perm_config.statusline_declutter + 1
  if globals.perm_config.statusline_declutter == 4 then
    globals.perm_config.statusline_declutter = 0
  end
end, opts)

kms('n', '<A-q>', function()
  utils.Quitapp()
end, opts)
kms({ 'n', 'i' }, '<C-e>', function()
  require('telescope.builtin').buffers(
    Telescope_dropdown_theme({
      title = 'Buffer list',
      width = 100,
      prompt_prefix = utils.getTelescopePromptPrefix(),
      height = 0.4,
      sort_lastused = true,
      sort_mru = true,
      show_all_buffers = true,
      ignore_current_buffer = true,
      sorter = require('telescope.sorters').get_substr_matcher(),
    })
  )
end, opts)
kms({ 'n', 'i' }, '<A-e>', function()
  require("mini.pick").builtin.buffers({include_current=false}, {window = { config = require("globals").mini_pick_center(100, 20, 0.1) } } )
end, opts)

kms({'n', 'i'}, '<C-p>', function()
  require('telescope.builtin').oldfiles(
    Telescope_dropdown_theme({ prompt_prefix = utils.getTelescopePromptPrefix(), title = 'Old files', width = 100, height = 0.5 })
  )
end, opts)
kms('n', '<A-p>', function()
  require('telescope').extensions.command_center.command_center({ filter={ mode = 'n' }})
end, opts)

-- quick-focus the four main areas
kms({ 'n', 'i', 't', 'v' }, '<A-1>', function()
  globals.findbufbyType('NvimTree')
end, opts) -- Nvim-tree

kms({ 'n', 'i', 't', 'v' }, '<A-2>', function()
  vim.fn.win_gotoid(globals.main_winid)
end, opts) -- main window

-- focus or toggle the outline window
kms({ 'n', 'i', 't', 'v' }, '<A-3>', function()
  -- if the outline window is focused, close it.
  if vim.api.nvim_buf_get_option(0, "filetype") == globals.perm_config.outline_filetype then
    globals.close_outline()
    return
  end
  -- otherwise search it and if none is found, open it.
  if globals.findbufbyType(globals.perm_config.outline_filetype) == false then
    globals.open_outline()
  end
end, opts) -- Outline

local function focus_term_split(dir)
  if globals.findbufbyType('terminal') == false then
    vim.api.nvim_input('<f11>')
  end
  vim.cmd.startinsert()
  if dir and #dir > 0 then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("cd " .. dir .. "<cr>", true, false, true), 'i', false)
  end
end

-- focus the terminal split when available
kms({ 'n', 'i', 't', 'v' }, '<A-4>', function()
  focus_term_split(nil)
end, opts) -- Terminal

-- focus the terminal split and set root
kms({ 'n', 'i', 't', 'v' }, '<A-5>', function()
  local dir = vim.fn.expand("%:p:h")
  focus_term_split(dir)
end, opts) -- Buffer List

-- focus the terminal split and set root to project root
kms({ 'n', 'i', 't', 'v' }, '<A-6>', function()
  local dir = utils.getroot_current()
  focus_term_split(dir)
end, opts) -- Buffer List

kms({ 'n', 'i', 't', 'v' }, '<A-0>', function()
  globals.main_winid = vim.fn.win_getid()
end, opts) -- save current winid as main window id

kms({ 'n', 'i', 't', 'v' }, '<A-9>', function()
  local uspl = require('local_utils.usplit')
  if uspl.winid == nil then
    uspl.open()
  else
    if uspl.winid ~= vim.fn.win_getid() then
      vim.fn.win_gotoid(uspl.winid)
    else
      uspl.close()
      vim.fn.win_gotoid(globals.main_winid)
    end
  end
end, opts) -- usplit (system monitor)

kms({ 'n', 'i', 't', 'v' }, '<A-8>', function()
  local wspl = require('local_utils.wsplit')
  if wspl.winid == nil then
    wspl.openleftsplit(Config.weather.file)
  else
    if wspl.winid ~= vim.fn.win_getid() then
      vim.fn.win_gotoid(wspl.winid)
    else
      wspl.close()
      vim.fn.win_gotoid(globals.main_winid)
    end
  end
end, opts) -- wsplit (weather)

-- focus quickfix list (when open)
kms({ 'n', 'i', 't', 'v' }, '<A-7>', function()
  if globals.findbufbyType('qf') == false then
    vim.cmd('copen')
  else
    vim.fn.win_gotoid(globals.findwinbyBufType('qf')[1])
  end
end, opts) -- open or activate quickfix

-- terminal mappings
kms({ 'n', 'i', 't' }, '<f11>', function()
  globals.termToggle(12)
end, opts)
--map('t', "<f11>", "<C-\\><C-n><CMD>call TermToggle(12)<CR>", opts)
map('t', '<Esc>', '<C-\\><C-n>', opts)

map('n', '<f32>', '<CMD>RnvimrToggle<CR>', opts)
kms('n', '<leader>wr', function()
  globals.toggle_wrap()
end, opts)
kms('n', 'ren', function()
  return ':IncRename ' .. vim.fn.expand('<cword>')
end, { expr = true })

-- Alt-d: Detach all TUI sessions from the (headless) master
kms({ 'n', 'i', 't', 'v' }, '<A-d>', function()
  globals.detach_all_tui()
end, opts)

kms({ 'n', 'i', 't', 'v' }, utility_key .. 'za', function()
  require("cmp_wordlist").add_cword()
end, opts)

kms({ 'n', 'i', 't', 'v' }, utility_key .. 'zt', function()
  require("cmp_wordlist").add_cword_with_translation()
end, opts)

kms({ 'n', 'i', 't', 'v' }, utility_key .. 'wt', function()
  require("local_utils.wsplit").toggle_content()
end, opts)
kms({ 'n', 'i', 't', 'v' }, utility_key .. 'st', function()
  require("local_utils.usplit").toggle_content()
end, opts)
kms({ 'n', 'i', 't', 'v' }, utility_key .. 'sr', function()
  require("local_utils.usplit").refresh_cookie()
end, opts)

-- debug keymap, print the filetype of the current buffer
kms({ 'n', 'i', 't', 'v' }, '<C-x>ft', function()
  globals.notify("Filetype is: " .. vim.api.nvim_get_option_value("filetype", { buf = 0 }), 2, " ")
end, opts)

kms({ 'n', 'i', 't', 'v' }, utility_key .. '#', function()
  require("aerial").refetch_symbols(0) -- aerial plugin, refresh symbols
end, opts)
kms({ 'n', 'i', 't', 'v' }, utility_key .. '+', function()
  globals.toggle_outline_type()        -- toggle the outline plugin (aerial <> symbols-outline)
end, opts)

-- enable/disable treesitter-context plugin
kms({ 'n', 'i', 'v' }, "<C-x><C-c>", function() globals.toggle_treesitter_context() end, opts)
-- jump to current context start
kms({ 'n', 'i', 'v' }, "<C-x>c", function() require("treesitter-context").go_to_context() end, opts)

kms({ 'n', 'i', 'v' }, "<C-x>te",
  function()
    vim.cmd("TSBufEnable highlight")
    globals.notify("Highlights enabled", vim.log.levels.INFO, "Treesitter")
  end, opts)
kms({ 'n', 'i', 'v' }, "<C-x>td",
  function()
    vim.cmd("TSBufDisable highlight")
    globals.notify("Highlight disabled", vim.log.levels.INFO, "Treesitter")
  end, opts)

require("local_utils.marks").set_keymaps()

