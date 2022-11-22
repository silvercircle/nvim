local map = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}
local expr = {noremap = true, silent = true, expr = true}
-- Telescope pickers
-- Ctrl-e -> list of  buffers
map('n', "<C-e>", "<CMD>lua require'telescope.builtin'.buffers{layout_config={height=0.3, width=0.7}}<CR>", opts)
-- Ctrl-p -> old files
map('n', "<C-p>", "<CMD>lua require'telescope.builtin'.oldfiles{layout_config={height=0.4,width=0.7,preview_width=0.4}}<CR>", opts)
-- Ctrl-f -> browse files in current working  directory
map('n', "<leader>f", "<CMD>lua require'telescope.builtin'.find_files{cwd = vim.fn.expand('%:p:h') }<CR>", opts)
-- Alt-c -> command line  history
map('n', "<A-c>", "<CMD>lua require'telescope.builtin'.command_history{layout_config={width=0.4, height=0.7}}<CR>", opts)
-- Alt-f -> file  browser
map('n', "<A-f>", "<CMD>Telescope file_browser path=%:p:h<CR>", opts)
-- Alt-s show spelling suggestions
map('n', "<A-s>", "<CMD>lua require'telescope.builtin'.spell_suggest{layout_config={height=0.5,width=0.3}}<CR>", opts)
-- telescope-project extension (Alt-p)
map('n', "<A-p>", "<CMD>lua require'telescope'.extensions.project.project{ display_type='full', layout_config={width=0.5} }<CR>", opts)
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
map('i', "<C-x><C-q>", '<c-o>:update<CR><c-o>:BD<CR>', opts)
map('n', "<C-x><C-q>", ':update<CR>:BD<CR>', opts)
map('i', "<C-x><C-s>", '<c-o>:update<CR>', opts)
map('n', "<C-x><C-s>", ':update<CR>', opts)

map('n', "tsh", ':TSHighlightCapturesUnderCursor<CR>', opts)
map('n', "<C-x><C-c>", ':BD<CR>', opts)
map('i', "<C-x><C-c>", '<c-o>:BD<CR>', opts)

-- switch off highlighted search results
map('n', "<C-x><C-h>", ':nohl<CR>', opts)
map('i', "<C-x><C-h>", '<c-o>:nohl<CR>', opts)

