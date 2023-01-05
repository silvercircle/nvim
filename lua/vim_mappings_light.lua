-- light keyboard mappings.
-- This version is needed when the command_center plugin is installed and configure. It will
-- overtake many of the original keyboar mappings.
-- The majority of the more complex mappings for LSP are in setup_command_center.lua

local map = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}

-- local expr = {noremap = true, silent = true, expr = true}

-- Ctrl-Shift-E - neo-tree open buffers in current dir
map('n', "<C-T>", ":Neotree buffers position=float<CR>", opts )
map('n', "<C-G>", ":Neotree git_status position=float<CR>", opts )

-- command palette
map('n', "<A-p>", ":Telescope command_center<CR>", opts)
map('i', "<A-p>", "<c-o>:Telescope command_center<CR>", opts)

-- file tree
if vim.g.features['neotree']['enable'] == true then
  map('n', "<leader>r", "<CMD>Neotree reveal_force_cwd action=show<CR>", opts)    -- sync Neotree dir to current buffer
  map('n', "<leader>,", '<CMD>Neotree toggle<CR>', opts)              -- toggle the Neotree
elseif vim.g.features['nvimtree']['enable'] == true then
  map('n', "<leader>,", '<CMD>NvimTreeToggle<CR>', opts)              -- toggle the Nvim-Tree
  map('n', "<leader>r", "<CMD>NvimTreeFindFile<CR>", opts)            -- sync Nvim-Tree with current 
end
map('n', "<leader>.", "<CMD>SymbolsOutline<CR>", opts)    -- toggle the Outline View

map('n', '<C-Tab>', ':bnext<CR>', opts)
map('n', '<leader><Tab>', ":bnext<CR>", opts)

-- map some keys to toggle formatting options
-- the vimscript functions are defined in the init.vim
map('i', "<C-f><C-a>", '<c-o>:AFToggle<CR>', opts)
map('n', "<C-f><C-a>", ':AFToggle<CR>', opts)

map('i', "<C-f><C-c>", '<c-o>:CFToggle<CR>', opts)
map('n', "<C-f><C-c>", ':CFToggle<CR>', opts)

map('i', "<C-f><C-w>", '<c-o>:HWToggle<CR>', opts)
map('n', "<C-f><C-w>", ':HWToggle<CR>', opts)

map('i', "<C-f><C-t>", '<c-o>:HTToggle<CR>', opts)
map('n', "<C-f><C-t>", ':HTToggle<CR>', opts)

map('i', "<C-f>1", '<c-o>:AutowrapOn<CR>', opts)
map('n', "<C-f>1", ':AutowrapOn<CR>', opts)

map('i', "<C-f>2", '<c-o>:AutowrapOff<CR>', opts)
map('n', "<C-f>2", ':AutowrapOff<CR>', opts)

map('i', "<C-f>f", '<c-o>:AFManual<CR>', opts)
map('n', "<C-f>f", ':AFManual<CR>', opts)

map('i', "<C-f>a", '<c-o>:AFAuto<CR>', opts)
map('n', "<C-f>a", ':AFAuto<CR>', opts)

map('n', "<leader>V", ':!fmt -110<CR>', opts)
map('n', "<leader>v", ':!fmt -100<CR>', opts)
map('n', "<leader>y", ':!fmt -85<CR>', opts)

map('n', "<leader>v", "}kV{j", opts)        -- select current paragraph

-- Ctrl-x Ctrl-s save the file if modified (use update command). Also,
-- create a view to save state
map('i', "<C-x><C-s>", '<c-o>:update!<CR>', opts)
map('n', "<C-x><C-s>", ':update!<CR>', opts)

-- Ctrl-x Ctrl-c close the file, do NOT save it(!) but create the view to save folding state and
-- cursor position. if g.confirm_actions['buffer_close'] is true then a warning message and a 
-- selection dialog will appear..
map('n', "<C-x><C-c>", ':lua BufClose()<CR>', opts)
-- basically, we do not need this in insert mode
-- map('i', "<C-x><C-c>", '<c-o>:lua BufClose()<CR>', opts)

-- switch off highlighted search results
map('n', "<C-x><C-h>", ':nohl<CR>', opts)
map('i', "<C-x><C-h>", '<c-o>:nohl<CR>', opts)
map('n', "<f5>", ':nohl<CR>', opts)
map('i', "<f5>", '<c-o>:nohl<CR>', opts)

-- various
map('i', "<C-y>-", "—", opts)        -- emdash
map('i', "<C-y>\"", "„”", opts)       -- typographic quotes („”)

-- close window
map('n', "<A-w>", ":close<CR>", opts)
-- force exit, caution all unsaved buffers will be lost
map('n', "<A-q>", ":lua Quitapp()<CR>", opts)

-- diagnostics (LSP)
map('n', "DF", ":LspFormatDoc<CR>", opts)         -- format the doc with null-ls provider
map('v', "DR", ":LspFormatRange<CR>", opts )      -- format the range with null-ls provider

-- move left/right/up/down split window
map('n', "<A-Left>", "<c-w><Left>", opts)
map('n', "<A-Right>", "<c-w><Right>", opts)
map('n', "<A-Down>", "<c-w><Down>", opts)
map('n', "<A-Up>", "<c-w><Up>", opts)

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

map('i', "<C-p>", "<CMD>:lua vim.lsp.buf.signature_help()<CR>", opts)

-- if we have playgrund, use the special command to reveal the highlight group under the cursor
if vim.g.features['treesitter_playground']['enable'] == true then
  vim.keymap.set('n', "tsh", ":TSCaptureUnderCursor<CR>", opts)
else  -- otherwise, use the API (less pretty, but functional)
  vim.keymap.set("n", "tsh",
    function()
      local result = vim.treesitter.get_captures_at_cursor(0)
      print(vim.inspect(result))
    end,
    { noremap = true, silent = false }
  )
end

vim.cmd([[
   " mappings for folding {{{
  " toggle this fold
  inoremap <F2> <C-O>za
  nnoremap <F2> za
  onoremap <F2> <C-C>za
  vnoremap <F2> zf

  " close current level
  inoremap <S-F2> <C-O>zc
  nnoremap <S-F2> zc
  onoremap <S-F2> <C-C>zc
  vnoremap <S-F2> zf

  " open current level
  inoremap <C-F2> <C-O>zo
  nnoremap <C-F2> zo
  onoremap <C-F2> <C-C>zo
  vnoremap <C-F2> zf

  " toggle all levels of current fold
  inoremap <F3> <C-O>zA
  nnoremap <F3> zA
  onoremap <F3> <C-C>zA
  vnoremap <F3> zf

  " close all current levels
  inoremap <S-F3> <C-O>zA
  nnoremap <S-F3> zA
  onoremap <S-F3> <C-C>zA
  vnoremap <S-F3> zf

  " open all current levels
  inoremap <C-F3> <C-O>zO
  nnoremap <C-F3> zO
  onoremap <C-F3> <C-C>zO
  vnoremap <C-F3> zf
]])

