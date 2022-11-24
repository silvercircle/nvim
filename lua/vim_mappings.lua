local map = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}
local expr = {noremap = true, silent = true, expr = true}

-- Telescope pickers
-- Ctrl-e -> list of  buffers
map('n', "<C-e>", "<CMD>lua require'telescope.builtin'.buffers{winblend=20, previewer=false, layout_config={height=0.4, width=0.4}}<CR>", opts)
-- Ctrl-p -> old files
map('n', "<C-p>", "<CMD>lua require'telescope.builtin'.oldfiles{winblend=20, previewer=false, layout_config={height=0.4,width=0.4,preview_width=0.4}}<CR>", opts)
-- Ctrl-f -> browse files in current working  directory
map('n', "<leader>f", "<CMD>lua require'telescope.builtin'.find_files{winblend=20, hidden=true, cwd = vim.fn.expand('%:p:h'), layout_config={ width=0.8, preview_width=0.6 } }<CR>", opts)
-- Alt-c -> command line  history
map('n', "<A-c>", "<CMD>lua require'telescope.builtin'.command_history{winblend=20, layout_config={width=0.4, height=0.7}}<CR>", opts)
-- Alt-Shift-c -> commands
map('n', "<A-C>", "<CMD>lua require'telescope.builtin'.commands{winblend=20, layout_config={width=0.6, height=0.7}}<CR>", opts)
-- Alt-Shift-J -> Jumplist
map('n', "<C-x><C-j>", "<CMD>lua require'telescope.builtin'.jumplist{layout_config={preview_width=0.4, width=0.8, height=0.7}}<CR>", opts)
-- Alt-f -> file  browser
map('n', "<A-f>", "<CMD>lua require('telescope').extensions.file_browser.file_browser{ winblend=20, hidden=true, path=vim.fn.expand('%:p:h'), layout_config={width=0.8, preview_width=0.6 } }<CR>", opts)
-- Alt-s show spelling suggestions
map('n', "<A-s>", "<CMD>lua require'telescope.builtin'.spell_suggest{layout_config={winblend=20, height=0.5,width=0.3}}<CR>", opts)
-- telescope-project extension (Alt-p)
map('n', "<A-p>", "<CMD>lua require'telescope'.extensions.project.project{ winblend=20, display_type='full', layout_config={width=0.5} }<CR>", opts)
-- telescope-fuzzy-find in buffer
map('n', "<C-x><C-f>", "<CMD>:lua require'telescope.builtin'.current_buffer_fuzzy_find{ winblend=20, layout_config={width=0.8, preview_width=0.4} }<CR>", opts)
-- telescpe-bookmarks:
-- Alt-b -> all bookmarks, Ctrl-b -> current file
-- bookmarks
map('n', "<A-b>", "<CMD>lua require('telescope').extensions.vim_bookmarks.all{hide_filename=false,layout_config={height=0.4, width=0.8,preview_width=0.3}}<CR>", opts)
map('n', "<C-b>", "<CMD>lua require('telescope').extensions.vim_bookmarks.current_file{layout_config={height=0.4, width=0.7}}<CR>", opts)

-- nerdtree
map('n', "<leader>r", "<CMD>NERDTreeFind <Bar> wincmd p<CR>", opts)

-- coc code navigation
map('n', "gd", '<Plug>(coc-definition)', { silent = true, noremap = false })
map('n', "gy", '<Plug>(coc-type-definition)', { silent = true, noremap = false })
map('n', "gi", '<Plug>(coc-implementation)', { silent = true, noremap = false })
map('n', "gr", '<Plug>(coc-references)', { silent = true, noremap = false })

--More COC Bindings
--Use `[g` and `]g` to navigate diagnostics
--Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.

map('n', "[g", '<Plug>(coc-diagnostic-prev)', { silent = true, noremap = false })
map('n', "]g", '<Plug>(coc-diagnostic-next)', { silent = true, noremap = false })

-- coc: autocomplete on ctrl-space
map('i', "<c-space>", 'coc#refresh()', expr)

map('n', "<leader>.", '<CMD>CocOutline<CR>', opts)
map('n', "<leader>-", '<CMD>Minimap<CR>', opts)
map('n', "<leader>,", '<CMD>NERDTreeToggle<CR>', opts)

-- bookmark plugin, set and navigate bookmarks
map('n', "<Leader>bt", '<Plug>BookmarkToggle', { silent = true, noremap = false })
map('n', "<Leader>by", '<Plug>BookmarkAnnotate', { silent = true, noremap = false })
map('n', "<Leader>ba", '<Plug>BookmarkShowAll', { silent = true, noremap = false })
map('n', "<Leader>bn", '<Plug>BookmarkNext', { silent = true, noremap = false })
map('n', "<Leader>bp", '<Plug>BookmarkPrev', { silent = true, noremap = false })
map('n', "<Leader>bd", '<Plug>BookmarkClear', { silent = true, noremap = false })
map('n', "<Leader>bx", '<Plug>BookmarkClearAll', { silent = true, noremap = false })
map('n', "<Leader>bu", '<Plug>BookmarkMoveUp', { silent = true, noremap = false })
map('n', "<Leader>bb", '<Plug>BookmarkMoveDown', { silent = true, noremap = false })
map('n', "<Leader>bm", '<Plug>BookmarkMoveToLine', { silent = true, noremap = false })
map('n', '<C-Tab>', ':bnext<CR>', opts)

-- map some keys for formatting functions
-- the functions are defined in the init.vim
map('i', "<C-f><C-a>", '<c-o>:AFToggle<CR>', opts)
map('i', "<C-f><C-w>", '<c-o>:HWToggle<CR>', opts)
map('i', "<C-f><C-t>", '<c-o>:HTToggle<CR>', opts)
map('i', "<C-f>1", '<c-o>:AutowrapOn<CR>', opts)
map('i', "<C-f>2", '<c-o>:AutowrapOff<CR>', opts)
map('n', "<leader>V", ':!fmt -110<CR>', opts)
map('n', "<leader>v", ':!fmt -100<CR>', opts)
map('n', "<leader>y", ':!fmt -85<CR>', opts)
map('i', "<C-f>f", '<c-o>:AFManual<CR>', opts)
map('i', "<C-f>a", '<c-o>:AFAuto<CR>', opts)

-- Ctrl-s in normal and insert mode: save if modified
-- Ctrl-q in normal and insert mode: save if modified and close buffer
-- Ctrl-x Ctrl-q is deprecated, use Ctrl-s, Ctrl-x-Ctrl-c
-- map('i', "<C-x><C-q>", '<c-o>:update<CR><c-o>:BD<CR>', opts)
-- map('n', "<C-x><C-q>", ':update<CR>:BD<CR>', opts)
map('i', "<C-x><C-s>", '<c-o>:update!<CR>', opts)
map('n', "<C-x><C-s>", ':update!<CR>', opts)

map('n', "tsh", ':TSHighlightCapturesUnderCursor<CR>', opts)
map('n', "<C-x><C-c>", ':BD!<CR>', opts)
map('i', "<C-x><C-c>", '<c-o>:BD!<CR>', opts)

-- switch off highlighted search results
map('n', "<C-x><C-h>", ':nohl<CR>', opts)
map('i', "<C-x><C-h>", '<c-o>:nohl<CR>', opts)

-- snippets
map('i', "<C-l>", "<Plug>(coc-snippets-expand)", opts)

-- various
map('i', "<C-y>-", "—", opts )
map('i', "<C-y>\"", "„”", opts)

-- Telekasten mappings

map('n', "<A-z>z", ":lua require('telekasten').panel()<CR>", opts)
map('n', "<A-z>zf", ":lua require('telekasten').find_notes()<CR>", opts)
map('n', "<A-z>zd", ":lua require('telekasten').find_daily_notes()<CR>", opts)
map('n', "<A-z>zg", ":lua require('telekasten').search_notes()<CR>", opts)
map('n', "<A-z>zz", ":lua require('telekasten').follow_link()<CR>", opts)

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