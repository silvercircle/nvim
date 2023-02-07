-- light keyboard mappings.
-- This version is needed when the command_center plugin is installed and configure. It will
-- overtake many of the original keyboar mappings.
-- The majority of the more complex mappings for LSP are in setup_command_center.lua

local map = vim.api.nvim_set_keymap
local kms = vim.keymap.set

local opts = {noremap = true, silent = true}
local utils = require("local_utils")
local globals = require("globals")

kms({ 'n', 'i' },  "<C-c>", "<NOP>", opts)

-- file tree
--if vim.g.config.nvim_tree == false then
--  map('n', "<leader>r", "<CMD>Neotree reveal_force_cwd<CR>", opts)    -- sync Neotree dir to current buffer
--  map('n', "<leader>,", '<CMD>Neotree toggle dir=%:p:h<CR>', opts)              -- toggle the Neotree
--else
map('n', "<leader>r", "<CMD>NvimTreeFindFile<CR>", opts)            -- sync Nvim-Tree with current

kms('n', "<leader>,", function() require("nvim-tree.api").tree.toggle() end, opts)              -- toggle the Nvim-Tree
kms('n', "<leader>R", function() require("nvim-tree.api").tree.change_root(utils.getroot_current()) end, opts)
kms('n', "<leader>nr", function() require("nvim-tree.api").tree.change_root(vim.fn.expand("%:p:h")) end, opts)
--end

map('n', '<C-Tab>', '<CMD>bnext<CR>', opts)
map('n', '<leader><Tab>', "<CMD>bnext<CR>", opts)

kms({ 'i', 'n' }, "<C-f><C-a>", function() globals.toggle_fo('a') end, opts)
kms({ 'i', 'n' }, "<C-f><C-c>", function() globals.toggle_fo('c') end, opts)
kms({ 'i', 'n' }, "<C-f><C-w>", function() globals.toggle_fo('w') end, opts)
kms({ 'i', 'n' }, "<C-f><C-t>", function() globals.toggle_fo('t') end, opts)

kms({ 'i', 'n' }, "<C-f>1", function() globals.set_fo('w') globals.set_fo('a') end, opts)
kms({ 'i', 'n' }, "<C-f>2", function() globals.clear_fo('w') globals.clear_fo('a') end, opts)

kms({ 'i', 'n' }, "<C-f>f", function() globals.clear_fo('w') globals.clear_fo('a') globals.clear_fo('c') globals.clear_fo('q') globals.clear_fo('t') globals.clear_fo('l') end, opts)
kms({ 'i', 'n' }, "<C-f>a", function() globals.set_fo('w') globals.set_fo('a') globals.set_fo('c') globals.set_fo('q') globals.set_fo('t') globals.set_fo('l') end, opts)

map('v', "<leader>V", ':!fmt -110<CR>', opts)
map('v', "<leader>y", ':!fmt -85<CR>', opts)

-- format a paragraph, different in normal and insert modes
kms('n', "<A-C-w>", function() vim.api.nvim_feedkeys("}kV{jgq", 'i', true) end, opts)
kms('i', "<A-C-w>", function() local key = vim.api.nvim_replace_termcodes("<C-o>}<C-o>V{jgq", true, false, true) vim.api.nvim_feedkeys(key, 'i', false) end, opts)

map('n', "<leader>v", "}kV{j", opts)        -- select current paragraph

-- Ctrl-x Ctrl-s save the file if modified (use update command). Also,
-- create a view to save state
map('i', "<C-s><C-s>", '<c-o><CMD>update!<CR>', opts)
map('n', "<C-s><C-s>", '<CMD>update!<CR>', opts)

-- Ctrl-x Ctrl-c close the file, do NOT save it(!) but create the view to save folding state and
-- cursor position. if g.confirm_actions['buffer_close'] is true then a warning message and a
-- selection dialog will appear..
map('n', "<C-s><C-c>", '<CMD>lua require("local_utils").BufClose()<CR>', opts)

-- switch off highlighted search results
map('n', "<f5>", '<CMD>nohl<CR>', opts)
map('i', "<f5>", '<c-o><CMD>nohl<CR>', opts)

-- various
map('i', "<C-y>-", "—", opts)        -- emdash
map('i', "<C-y>\"", "„”", opts)       -- typographic quotes („”)
-- close window
map('n', "<A-w>", "<CMD>close<CR>", opts)

-- move left/right/up/down split window
map('n', "<A-Left>", "<c-w><Left>", opts)
map('n', "<A-Right>", "<c-w><Right>", opts)
map('n', "<A-Down>", "<c-w><Down>", opts)
map('n', "<A-Up>", "<c-w><Up>", opts)

-- quickfix navigation
map('n', "<C-f>c", "<CMD>cclose<CR>", opts)
map('i', "<C-f>c", "<c-o><CMD>cclose<CR>", opts)

map('n', "<C-S-Down>", "<CMD>cnext<CR>", opts)
map('i', "<C-S-Down>", "<c-o><CMD>cnext<CR>", opts)

map('n', "<C-S-Up>", "<CMD>cprev<CR>", opts)
map('i', "<C-S-Up>", "<c-o><CMD>cprev<CR>", opts)

-- hlslens

vim.api.nvim_set_keymap('n', 'n',
    [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
    opts)
vim.api.nvim_set_keymap('n', 'N',
    [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
    opts)
vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], opts)
vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], opts)
vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], opts)
vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], opts)

vim.keymap.set({ "s" }, "<C-i>", function() require'luasnip'.jump(1) end, { desc = "LuaSnip forward jump" })
vim.keymap.set({ "s" }, "<S-Tab>", function() require'luasnip'.jump(-1) end, { desc = "LuaSnip backward jump" })

-- run `:nohlsearch` and export results to quickfix
vim.keymap.set({'n', 'x'}, '<Leader>#', function()
    vim.schedule(function()
        if require('hlslens').exportLastSearchToQuickfix() then
            vim.cmd('cw')
        end
    end)
    return ':noh<CR>'
end, {expr = true})

-- if we have playgrund, use the special command to reveal the highlight group under the cursor
if vim.g.config.treesitter_playground == true then
  vim.keymap.set('n', "hl", ":TSCaptureUnderCursor<CR>", opts)
else  -- otherwise, use the API (less pretty, but functional)
  vim.keymap.set("n", "hl",
    function()
      local result = vim.treesitter.get_captures_at_cursor(0)
      print(vim.inspect(result))
    end,
    { noremap = true, silent = false }
  )
end

-- the following is ALL related to folding and there are no command center equivalents

local ibl = require("indent_blankline")

local function schedule_mkview()
  if vim.g.config.mkview_on_fold == true then
    vim.api.nvim_input("<f4>")
  end
end

kms('i', "<f13>", function() vim.lsp.buf.signature_help() end, opts) -- shift-f1
kms('i', "<f1>", function() vim.lsp.buf.hover() end, opts)
--
-- shift-F4: refresh indent guides
kms('n', "<f16>", function() ibl.refresh() end, opts)
kms('i', "<f16>", function() ibl.refresh() end, opts)
kms('v', "<f16>", function() ibl.refresh() end, opts)

kms('n', "<f4>", function() globals.mkview() end, opts)
kms('i', "<f4>", function() globals.mkview() end, opts)

-- toggle current fold
kms('n', "<F2>", function() vim.api.nvim_feedkeys('za', 'n', true) vim.api.nvim_input("<f16>") vim.schedule(schedule_mkview) end, opts)
kms('i', "<F2>", function() local key = vim.api.nvim_replace_termcodes("<C-o>za", true, false, true) vim.api.nvim_feedkeys(key, 'i', false) vim.schedule(schedule_mkview) end, opts)
kms('v', "<F2>", function() vim.api.nvim_feedkeys('zf', 'v', true) vim.api.nvim_input("<f16>") vim.schedule(schedule_mkview) end, opts)

-- close current fold (Shift-F2)
kms('n', "<f14>", function() vim.api.nvim_feedkeys('zc', 'n', true) vim.api.nvim_input("<f16>") vim.schedule(schedule_mkview) end, opts)
kms('i', "<f14>", function() local key = vim.api.nvim_replace_termcodes("<C-o>zc", true, false, true) vim.api.nvim_feedkeys(key, 'i', false) vim.schedule(schedule_mkview) end, opts)

-- open current fold (Ctrl-F2)
kms('n', "<f26>", function() vim.api.nvim_feedkeys('zo', 'n', true) vim.api.nvim_input("<f16>") vim.schedule(schedule_mkview) end, opts)
kms('i', "<f26>", function() local key = vim.api.nvim_replace_termcodes("<C-o>zo", true, false, true) vim.api.nvim_feedkeys(key, 'i', false) vim.schedule(schedule_mkview) end, opts)

-- toggle all folds at current line
kms('n', "<F3>", function() vim.api.nvim_feedkeys('zA', 'n', true) vim.api.nvim_input("<f16>") vim.schedule(schedule_mkview) end, opts)
kms('i', "<F3>", function() local key = vim.api.nvim_replace_termcodes("<C-o>zA", true, false, true) vim.api.nvim_feedkeys(key, 'i', false) vim.schedule(schedule_mkview) end, opts)

-- close all folds at current line (Shift-F3)
kms('n', "<f15>", function() vim.api.nvim_feedkeys('zC', 'n', true) vim.api.nvim_input("<f16>") vim.schedule(schedule_mkview) end, opts)
kms('i', "<f15>", function() local key = vim.api.nvim_replace_termcodes("<C-o>zC", true, false, true) vim.api.nvim_feedkeys(key, 'i', false) vim.schedule(schedule_mkview) end, opts)

-- open all folds at current line (Ctrl-F3)
kms('n', "<f27>", function() vim.api.nvim_feedkeys('zO', 'n', true) vim.api.nvim_input("<f16>") vim.schedule(schedule_mkview) end, opts)
kms('i', "<f27>", function() local key = vim.api.nvim_replace_termcodes("<C-o>zO", true, false, true) vim.api.nvim_feedkeys(key, 'i', false) vim.schedule(schedule_mkview) end, opts)

map('n', "<C-S-Left>", "<C-o>", opts)
map('n', "<C-S-Right>", "<C-i>", opts)
map('i', "<C-S-Left>", "<c-o><C-o>", opts)
map('i', "<C-S-Right>", "<c-o><C-i>", opts)

map('n', "<f23>", "<CMD>Lazy<CR>", opts)

kms({'n', 'i'}, "<C-l><C-l>", function() globals.toggle_statuscol() end, opts)
kms('n', "<A-q>", function() require "local_utils".Quitapp() end, opts)
kms({'n', 'i'}, "<C-e>", function() require'telescope.builtin'.buffers(Telescope_dropdown_theme({title='Buffer list', width=0.6, height=0.4, sort_lastused=true, sort_mru=true, show_all_buffers=true, ignore_current_buffer=true, sorter=require'telescope.sorters'.get_substr_matcher()})) end, opts)
kms('n', "<C-p>", function() require'telescope.builtin'.oldfiles(Telescope_dropdown_theme({title='Old files', width=0.6, height=0.5})) end, opts)
kms('n', "<A-p>", function() require("telescope").extensions.command_center.command_center({mode = 'n'}) end, opts)

-- quick-focus the four main areas
kms({'n', 'i', 't', 'v'}, "<A-1>", function() globals.findbufbyType('NvimTree') end, opts)      -- Nvim-tree
--kms({'n', 'i', 't', 'v'}, "<A-1>", function() FindbufbyType('neo-tree') end, opts)      -- Neotree
kms({'n', 'i', 't', 'v'}, "<A-2>", function() vim.fn.win_gotoid(1000) end, opts)        -- main window
kms({'n', 'i', 't', 'v'}, "<A-3>", function() if globals.findbufbyType('Outline') == false then vim.cmd("SymbolsOutlineOpen") end end, opts) -- Outline
kms({'n', 'i', 't', 'v'}, "<A-4>", function() if globals.findbufbyType('terminal') == false then vim.api.nvim_input("<f11>") end end, opts)  -- Terminal
kms({'n', 'i', 't', 'v'}, "<A-5>", function() globals.findbufbyType('BufList') end, opts)  -- Terminal

-- terminal mappings
map('n', "<f11>", "<CMD>call TermToggle(12)<CR>", opts)
map('i', "<f11>", "<Esc><CMD>call TermToggle(12)<CR>", opts)
map('t', "<f11>", "<C-\\><C-n><CMD>call TermToggle(12)<CR>", opts)
map('t', "<Esc>", "<C-\\><C-n>", opts)

