-- light keyboard mappings.
-- This version is needed when the command_center plugin is installed and configure. It will
-- overtake many of the original keyboar mappings.
-- The majority of the more complex mappings for LSP are in setup_command_center.lua

local map = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}

-- file tree
map('n', "<leader>r", "<CMD>Neotree reveal_force_cwd<CR>", opts)    -- sync Neotree dir to current buffer
map('n', "<leader>,", '<CMD>Neotree toggle dir=%:p:h<CR>', opts)              -- toggle the Neotree

--if vim.g.features['neotree']['enable'] == true then
--  map('n', "<leader>r", "<CMD>Neotree reveal_force_cwd<CR>", opts)    -- sync Neotree dir to current buffer
--  map('n', "<leader>,", '<CMD>Neotree toggle dir=%:p:h<CR>', opts)              -- toggle the Neotree
--elseif vim.g.features['nvimtree']['enable'] == true then
--  map('n', "<leader>,", '<CMD>NvimTreeToggle<CR>', opts)              -- toggle the Nvim-Tree
--  map('n', "<leader>r", "<CMD>NvimTreeFindFile<CR>", opts)            -- sync Nvim-Tree with current 
--end

map('n', '<C-Tab>', '<CMD>bnext<CR>', opts)
map('n', '<leader><Tab>', "<CMD>bnext<CR>", opts)

-- map some keys to toggle formatting options
-- the vimscript functions are defined in the init.vim
map('i', "<C-f><C-a>", '<c-o><CMD>AFToggle<CR>', opts)
map('n', "<C-f><C-a>", '<CMD>AFToggle<CR>', opts)

map('i', "<C-f><C-c>", '<c-o><CMD>CFToggle<CR>', opts)
map('n', "<C-f><C-c>", '<CMD>CFToggle<CR>', opts)

map('i', "<C-f><C-w>", '<c-o><CMD>HWToggle<CR>', opts)
map('n', "<C-f><C-w>", '<CMD>HWToggle<CR>', opts)

map('i', "<C-f><C-t>", '<c-o><CMD>HTToggle<CR>', opts)
map('n', "<C-f><C-t>", '<CMD>HTToggle<CR>', opts)

map('i', "<C-f>1", '<c-o><CMD>AutowrapOn<CR>', opts)
map('n', "<C-f>1", '<CMD>AutowrapOn<CR>', opts)

map('i', "<C-f>2", '<c-o><CMD>AutowrapOff<CR>', opts)
map('n', "<C-f>2", '<CMD>AutowrapOff<CR>', opts)

map('i', "<C-f>f", '<c-o><CMD>AFManual<CR>', opts)
map('n', "<C-f>f", '<CMD>AFManual<CR>', opts)

map('i', "<C-f>a", '<c-o><CMD>AFAuto<CR>', opts)
map('n', "<C-f>a", '<CMD>AFAuto<CR>', opts)

map('v', "<leader>V", ':!fmt -110<CR>', opts)
map('v', "<leader>y", ':!fmt -85<CR>', opts)

map('n', "<leader>v", "}kV{j", opts)        -- select current paragraph

-- Ctrl-x Ctrl-s save the file if modified (use update command). Also,
-- create a view to save state
map('i', "<C-x><C-s>", '<c-o><CMD>update!<CR>', opts)
map('n', "<C-x><C-s>", '<CMD>update!<CR>', opts)

-- Ctrl-x Ctrl-c close the file, do NOT save it(!) but create the view to save folding state and
-- cursor position. if g.confirm_actions['buffer_close'] is true then a warning message and a 
-- selection dialog will appear..
map('n', "<C-x><C-c>", ':lua require("local_utils").BufClose()<CR>', opts)

-- switch off highlighted search results
map('n', "<f5>", '<CMD>nohl<CR>', opts)
map('i', "<f5>", '<c-o><CMD>nohl<CR>', opts)

-- various
map('i', "<C-y>-", "—", opts)        -- emdash
map('i', "<C-y>\"", "„”", opts)       -- typographic quotes („”)
-- close window
map('n', "<A-w>", ":close<CR>", opts)

-- move left/right/up/down split window
map('n', "<A-Left>", "<c-w><Left>", opts)
map('n', "<A-Right>", "<c-w><Right>", opts)
map('n', "<A-Down>", "<c-w><Down>", opts)
map('n', "<A-Up>", "<c-w><Up>", opts)

-- quickfix navigation
map('n', "<C-f>c", "<CMD>cclose<CR>", opts)
map('i', "<C-f>c", "<c-o><CMD>cclose<CR>", opts)

map('n', "<C-f>d", "<CMD>cnext<CR>", opts)
map('i', "<C-f>d", "<c-o><CMD>cnext<CR>", opts)

map('n', "<C-f>u", "<CMD>cprev<CR>", opts)
map('i', "<C-f>u", "<c-o><CMD>cprev<CR>", opts)

-- hlslens
local kopts = {noremap = true, silent = true}

vim.api.nvim_set_keymap('n', 'n',
    [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
    kopts)
vim.api.nvim_set_keymap('n', 'N',
    [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
    kopts)
vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

vim.keymap.set({ "s" }, "<C-i>", function() require'luasnip'.jump(1) end, { desc = "LuaSnip forward jump" })
vim.keymap.set({ "s" }, "<S-Tab>", function() require'luasnip'.jump(-1) end, { desc = "LuaSnip backward jump" })

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
  vim.api.nvim_input("<f4>")
end
--
-- shift-F4: refresh indent guides
vim.keymap.set('n', "<f16>", function() ibl.refresh() end, opts)
vim.keymap.set('i', "<f16>", function() ibl.refresh() end, opts)
vim.keymap.set('v', "<f16>", function() ibl.refresh() end, opts)

vim.keymap.set('n', "<f4>", function() vim.cmd("call Mkview()") end, opts)
vim.keymap.set('i', "<f4>", function() vim.cmd("call Mkview()") end, opts)

-- toggle current fold
vim.keymap.set('n', "<F2>", function() vim.api.nvim_feedkeys('za', 'n', true) vim.api.nvim_input("<f16>") vim.schedule(schedule_mkview) end, opts)
vim.keymap.set('i', "<F2>", function() local key = vim.api.nvim_replace_termcodes("<C-o>za", true, false, true) vim.api.nvim_feedkeys(key, 'i', false) vim.schedule(schedule_mkview) end, opts)
vim.keymap.set('v', "<F2>", function() vim.api.nvim_feedkeys('zf', 'v', true) vim.api.nvim_input("<f16>") vim.schedule(schedule_mkview) end, opts)

-- close current fold (Shift-F2)
vim.keymap.set('n', "<f14>", function() vim.api.nvim_feedkeys('zc', 'n', true) vim.api.nvim_input("<f16>") vim.schedule(schedule_mkview) end, opts)
vim.keymap.set('i', "<f14>", function() local key = vim.api.nvim_replace_termcodes("<C-o>zc", true, false, true) vim.api.nvim_feedkeys(key, 'i', false) vim.schedule(schedule_mkview) end, opts)

-- open current fold (Ctrl-F2)
vim.keymap.set('n', "<f26>", function() vim.api.nvim_feedkeys('zo', 'n', true) vim.api.nvim_input("<f16>") vim.schedule(schedule_mkview) end, opts)
vim.keymap.set('i', "<f26>", function() local key = vim.api.nvim_replace_termcodes("<C-o>zo", true, false, true) vim.api.nvim_feedkeys(key, 'i', false) vim.schedule(schedule_mkview) end, opts)

-- toggle all folds at current line
vim.keymap.set('n', "<F3>", function() vim.api.nvim_feedkeys('zA', 'n', true) vim.api.nvim_input("<f16>") vim.schedule(schedule_mkview) end, opts)
vim.keymap.set('i', "<F3>", function() local key = vim.api.nvim_replace_termcodes("<C-o>zA", true, false, true) vim.api.nvim_feedkeys(key, 'i', false) vim.schedule(schedule_mkview) end, opts)

-- close all folds at current line (Shift-F3)
vim.keymap.set('n', "<f15>", function() vim.api.nvim_feedkeys('zC', 'n', true) vim.api.nvim_input("<f16>") vim.schedule(schedule_mkview) end, opts)
vim.keymap.set('i', "<f16>", function() local key = vim.api.nvim_replace_termcodes("<C-o>zC", true, false, true) vim.api.nvim_feedkeys(key, 'i', false) vim.schedule(schedule_mkview) end, opts)

-- open all folds at current line (Ctrl-F3)
vim.keymap.set('n', "<f27>", function() vim.api.nvim_feedkeys('zO', 'n', true) vim.api.nvim_input("<f16>") vim.schedule(schedule_mkview) end, opts)
vim.keymap.set('i', "<f27>", function() local key = vim.api.nvim_replace_termcodes("<C-o>zO", true, false, true) vim.api.nvim_feedkeys(key, 'i', false) vim.schedule(schedule_mkview) end, opts)

map('n', "<C-S-Left>", "<C-o>", opts)
map('n', "<C-S-Right>", "<C-i>", opts)
map('i', "<C-S-Left>", "<c-o><C-o>", opts)
map('i', "<C-S-Right>", "<c-o><C-i>", opts)

map('n', "<f23>", "<CMD>Lazy<CR>", opts)
vim.keymap.set('n', "<C-l><C-l>", function() Toggle_statuscol() end, opts)
vim.keymap.set('i', "<C-l><C-l>", function() Toggle_statuscol() end, opts)

