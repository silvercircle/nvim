local map = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}
local expr = {noremap = true, silent = true, expr = true}
-- Telescope pickers
map('n', "<C-e>", "<CMD>lua require'telescope.builtin'.buffers{layout_config={height=0.3, width=0.7}}<CR>", opts)
map('n', "<C-p>", "<CMD>lua require'telescope.builtin'.oldfiles{layout_config={height=0.4,width=0.7,preview_width=0.4}}<CR>", opts)
map('n', "<C-f>", "<CMD>lua require'telescope.builtin'.find_files{cwd = vim.fn.expand('%:p:h') }<CR>", opts)
map('n', "<A-c>", "<CMD>lua require'telescope.builtin'.command_history{layout_config={width=0.4, height=0.7}}<CR>", opts)
map('n', "<A-f>", "<CMD>Telescope file_browser path=%:p:h<CR>", opts)
map('n', "<A-s>", "<CMD>lua require'telescope.builtin'.spell_suggest{layout_config={height=0.5,width=0.3}}<CR>", opts)

-- nerdtree
map('n', "<leader>r", "<CMD>NERDTreeFind <Bar> wincmd p<CR>", opts)

-- telescope + bookmarks
map('n', "<A-b>", "<CMD>lua require('telescope').extensions.vim_bookmarks.all{hide_filename=false,layout_config={height=0.4, width=0.8,preview_width=0.3}}<CR>", opts)
map('n', "<C-b>", "<CMD>lua require('telescope').extensions.vim_bookmarks.current_file{layout_config={height=0.4, width=0.7}}<CR>", opts)

map('n', "gd", '<Plug>(coc-definition)', { silent = true, noremap = false })
map('n', "gy", '<Plug>(coc-type-definition)', { silent = true, noremap = false })
map('n', "gi", '<Plug>(coc-implementation)', { silent = true, noremap = false })
map('n', "gr", '<Plug>(coc-references)', { silent = true, noremap = false })

--More COC Bindings
--Use `[g` and `]g` to navigate diagnostics
--Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.

map('n', "[g", '<Plug>(coc-diagnostic-prev)', { silent = true, noremap = false })
map('n', "]g", '<Plug>(coc-diagnostic-next)', { silent = true, noremap = false })

map('i', "<c-space>", 'coc#refresh()', expr)

map('n', "<leader>.", '<CMD>CocOutline<CR>', opts)
map('n', "<leader>-", '<CMD>Minimap<CR>', opts)
map('n', "<leader>,", '<CMD>NERDTreeToggle<CR>', opts)

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
map('n', "<leader>a", ':AFToggle<CR>', opts)
map('n', "<leader>w", ':HWToggle<CR>', opts)
map('n', "<leader>t", ':HTToggle<CR>', opts)
map('n', "<leader>1", ':AutowrapOn<CR>', opts)
map('n', "<leader>2", ':AutowrapOff<CR>', opts)
map('n', "<leader>V", ':!fmt -110<CR>', opts)
map('n', "<leader>v", ':!fmt -100<CR>', opts)
map('n', "<leader>y", ':!fmt -85<CR>', opts)
map('n', "<leader>fm", ':AFManual<CR>', opts)
map('n', "<leader>fa", ':AFAuto<CR>', opts)

-- Ctrl-s in normal and insert mode: save if modified
-- Ctrl-q in normal and insert mode: save if modified and close buffer
map('i', "<C-q>", "<c-o>:update<CR><c-o>:BD<CR>", opts)
map('n', "<C-q>", ":update<CR>:BD<CR>", opts)
map('i', "<C-s>", "<c-o>:update<CR>", opts)
map('n', "<C-s>", ":update<CR>", opts)