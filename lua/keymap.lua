-- This version is needed when the command_center plugin is installed and configure. It will
-- overtake many of the original keyboar mappings.
-- The majority of the more complex mappings for LSP are in setup_command_center.lua

local map = vim.api.nvim_set_keymap
local kms = vim.keymap.set
local globals = require("globals")

local opts = { noremap = true, silent = true }
local utils = require('local_utils')
local utility_key = require("tweaks").utility_key


kms({ 'n', 'i' }, '<C-c>', '<NOP>', opts)
-- disable <ins> toggling the (annoying) replace mode. Instead use <c-ins> to switch to replace
map('i', '<ins>', '<nop>', opts)

-- file tree
map('n', '<leader>r', '<CMD>NvimTreeFindFile<CR>', opts) -- sync Nvim-Tree with current
kms('n', '<leader>,', function()
  -- when the buflist is open (which means, the tree is also open), close it.
  -- we do NOT auto-open the buflist when activating the tree. Use Alt-5 for quickly
  -- creating (and switching to) a buffer list
  require('nvim-tree.api').tree.toggle()
end, opts) -- toggle the Nvim-Tree

kms('n', '<leader>R', function()
  require('nvim-tree.api').tree.change_root(utils.getroot_current())
end, opts)
kms('n', '<leader>nr', function()
  require('nvim-tree.api').tree.change_root(vim.fn.expand('%:p:h'))
end, opts)
--end

map('n', '<C-Tab>', '<CMD>bnext<CR>', opts)
map('n', '<leader><Tab>', '<CMD>bnext<CR>', opts)

kms({ 'i', 'n' }, '<C-f><C-a>', function()
  globals.toggle_fo('a')
end, opts)
kms({ 'i', 'n' }, '<C-f><C-c>', function()
  globals.toggle_fo('c')
end, opts)
kms({ 'i', 'n' }, '<C-f><C-w>', function()
  globals.toggle_fo('w')
end, opts)
kms({ 'i', 'n' }, '<C-f><C-t>', function()
  globals.toggle_fo('t')
end, opts)

kms({ 'i', 'n' }, '<C-f>1', function()
  globals.set_fo('w')
  globals.set_fo('a')
end, opts)
kms({ 'i', 'n' }, '<C-f>2', function()
  globals.clear_fo('w')
  globals.clear_fo('a')
end, opts)

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

-- Ctrl-x Ctrl-s save the file if modified (use update command). Also,
-- create a view to save state
map('i', '<C-s><C-s>', '<c-o><CMD>update!<CR>', opts)
map('n', '<C-s><C-s>', '<CMD>update!<CR>', opts)

-- Ctrl-x Ctrl-c close the file, do NOT save it(!) but create the view to save folding state and
-- cursor position. if g.confirm_actions['buffer_close'] is true then a warning message and a
-- selection dialog will appear..
map('n', '<C-s><C-c>', '<CMD>lua require("local_utils").BufClose()<CR>', opts)

-- switch off highlighted search results
map('n', '<f5>', '<CMD>nohl<CR>', opts)
map('i', '<f5>', '<c-o><CMD>nohl<CR>', opts)
map('i', '<C-z>', '<c-o>:undo<CR>', opts)

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
map('n', '<C-S-Down>', '<CMD>cnext<CR>', opts)
map('i', '<C-S-Down>', '<c-o><CMD>cnext<CR>', opts)

map('n', '<C-S-Up>', '<CMD>cprev<CR>', opts)
map('i', '<C-S-Up>', '<c-o><CMD>cprev<CR>', opts)

map('n', '<C-S-PageDown>', '<CMD>lnext<CR>', opts)
map('i', '<C-S-PageDown>', '<c-o><CMD>lnext<CR>', opts)

map('n', '<C-S-PageUp>', '<CMD>lprev<CR>', opts)
map('i', '<C-S-PageUp>', '<c-o><CMD>lprev<CR>', opts)
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

-- the following is ALL related to folding and there are no command center equivalents

local function schedule_mkview()
  if vim.g.config.mkview_on_fold == true then
    vim.api.nvim_input('<f4>')
  end
end
kms({ 'n', 'i' }, '<f4>', function()
  globals.mkview()
end, opts)

kms({ 'i', 'n' }, '<f13>', function()
  vim.lsp.buf.signature_help()
end, opts) -- shift-f1
kms({ 'i', 'n' }, '<f1>', function()
  vim.lsp.buf.hover()
end, opts)

local function perform_fold(code)
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'n' or mode == 'v' then
    vim.api.nvim_feedkeys(code, mode, true)
    --vim.schedule(schedule_mkview)
  elseif mode == 'i' then
    local key = vim.api.nvim_replace_termcodes('<C-o>' .. code, true, false, true)
    vim.api.nvim_feedkeys(key, 'i', false)
    --vim.schedule(schedule_mkview)
  end
end
--
-- toggle current fold
kms({'n', 'i', 'v'}, '<F2>', function()
  perform_fold('za')
end, opts)

-- close current fold (Shift-F2)
kms({'n', 'i', 'v'}, '<f14>', function()
  perform_fold('zc')
end, opts)

-- open current fold (Ctrl-F2)
kms({'n', 'i', 'v'}, '<f26>', function()
  perform_fold('zo')
end, opts)

-- toggle all folds at current line
kms({'n', 'i', 'v'}, '<F3>', function()
  perform_fold('zA')
end, opts)

-- close all folds at current line (Shift-F3)
kms({'n', 'i', 'v'}, '<f15>', function()
  perform_fold('zC')
end, opts)

-- open all folds at current line (Ctrl-F3)
kms({'n', 'i', 'v'}, '<f27>', function()
  perform_fold('zO')
end, opts)

-- jump list
map('n', '<C-S-Left>', '<C-o>', opts)
map('n', '<C-S-Right>', '<C-i>', opts)
map('i', '<C-S-Left>', '<c-o><C-o>', opts)
map('i', '<C-S-Right>', '<c-o><C-i>', opts)

-- change list
map('n', '<A-Left>', 'g;', opts)
map('n', '<A-Right>', 'g,', opts)
map('i', '<A-Left>', '<C-o>g;', opts)
map('i', '<A-Right>', '<C-o>g,', opts)

map('n', '<f23>', '<CMD>Lazy<CR>', opts)

kms({ 'n', 'i' }, utility_key .. '<C-l>', function()
  globals.toggle_statuscol()
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-k>', function()
  globals.toggle_colorcolumn()
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-t>', function()
  globals.toggle_theme_variant()
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-d>', function()
  globals.toggle_theme_desaturate()
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-p>', function()
  globals.toggle_ibl_rainbow()
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-o>', function()
  globals.toggle_ibl()
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-u>', function()
  globals.toggle_ibl_context()
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-z>', function()
  globals.perm_config.scrollbar = not globals.perm_config.scrollbar
  globals.set_scrollbar()
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-h>', function()
  globals.perm_config.transbg = not globals.perm_config.transbg
  globals.set_bg()
end, opts)
kms({ 'n', 'i' }, utility_key .. '<C-g>', function()
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

kms({ 'n', 'i', 't', 'v' }, '<A-4>', function()
  if globals.findbufbyType('terminal') == false then
    vim.api.nvim_input('<f11>')
  end
  vim.cmd.startinsert()
end, opts) -- Terminal

kms({ 'n', 'i', 't', 'v' }, '<A-5>', function()
  local blist = require('local_utils.blist')
  if blist.main_win == nil then
    blist.open(true, 0, globals.perm_config.blist_height)
  else
    if blist.main_win ~= vim.fn.win_getid() then
      vim.fn.win_gotoid(blist.main_win)
    else
      blist.close()
      vim.fn.win_gotoid(globals.main_winid)
    end
  end
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
    wspl.openleftsplit(vim.g.config.weather.file)
  else
    if wspl.winid ~= vim.fn.win_getid() then
      vim.fn.win_gotoid(wspl.winid)
    else
      wspl.close()
      vim.fn.win_gotoid(globals.main_winid)
    end
  end
end, opts) -- wsplit (weather)

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
  print(vim.api.nvim_get_option_value("filetype", { buf = 0 }))
end, opts)

kms({ 'n', 'i', 't', 'v' }, utility_key .. '#', function()
  require("aerial").refetch_symbols(0)
end, opts)
kms({ 'n', 'i', 't', 'v' }, utility_key .. '+', function()
  globals.toggle_outline_type()
end, opts)

require("local_utils.marks").set_keymaps()

