local map = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}
-- local expr = {noremap = true, silent = true, expr = true}

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
-- C-x-C-j Jumplist
map('n', "<C-x><C-j>", "<CMD>lua require'telescope.builtin'.jumplist{fname_width=40, show_line=false, layout_config={width=0.8, height=0.7, preview_width=0.6}}<CR>", opts)
-- C-x-C-r Registers
map('n', "<C-x><C-r>", "<CMD>lua require'telescope.builtin'.registers{layout_config={width=0.6, height=0.7}}<CR>", opts)
-- C-x-C-k Keymaps
map('n', "<C-x><C-k>", "<CMD>lua require'telescope.builtin'.keymaps{layout_config={width=0.8, height=0.7}}<CR>", opts)
-- Alt-f -> file  browser
map('n', "<A-f>", "<CMD>lua require('telescope').extensions.file_browser.file_browser{ winblend=20, hidden=true, path=vim.fn.expand('%:p:h'), layout_config={width=0.8, preview_width=0.6 } }<CR>", opts)
-- Alt-s show spelling suggestions
map('n', "<A-s>", "<CMD>lua require'telescope.builtin'.spell_suggest{winblend=20, layout_config={height=0.5,width=0.3}}<CR>", opts)
-- telescope-project extension (Alt-p)
map('n', "<A-p>", "<CMD>lua require'telescope'.extensions.project.project{ winblend=20, display_type='full', layout_config={width=0.5} }<CR>", opts)
-- telescope-fuzzy-find in buffer
map('n', "<C-x><C-f>", "<CMD>:lua require'telescope.builtin'.current_buffer_fuzzy_find{ winblend=20, layout_config={width=0.8, preview_width=0.4} }<CR>", opts)
-- telescope help tags
map('n', "<A-h>", "<CMD>:lua require'telescope.builtin'.help_tags{ winblend=20, layout_config={width=0.8, height=0.8, preview_width=0.8} }<CR>", opts)
-- telescpe-bookmarks:
-- Alt-b -> all bookmarks, Ctrl-b -> current file
-- bookmarks
map('n', "<A-b>", "<CMD>lua require('telescope').extensions.vim_bookmarks.all{hide_filename=false,layout_config={height=0.4, width=0.8,preview_width=0.3}}<CR>", opts)
map('n', "<C-b>", "<CMD>lua require('telescope').extensions.vim_bookmarks.current_file{layout_config={height=0.4, width=0.7}}<CR>", opts)

-- nerdtree
map('n', "<leader>r", "<CMD>Neotree reveal<CR>", opts)   -- sync NERDTree with current 

map('n', "<leader>.", "<CMD>SymbolsOutline<CR>", opts)    -- toggle the Outline View
map('n', "<leader>,", '<CMD>Neotree toggle<CR>', opts)    -- toggle the NERDTree

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
map('n', '<leader><Tab>', ":bnext<CR>", opts)

-- map some keys to toggle formatting options
-- the functions are defined in the init.vim
map('i', "<C-f><C-a>", '<c-o>:AFToggle<CR>', opts)
map('n', "<C-f><C-a>", ':AFToggle<CR>', opts)
map('i', "<C-f><C-w>", '<c-o>:HWToggle<CR>', opts)
map('i', "<C-f><C-t>", '<c-o>:HTToggle<CR>', opts)
map('i', "<C-f>1", '<c-o>:AutowrapOn<CR>', opts)
map('i', "<C-f>2", '<c-o>:AutowrapOff<CR>', opts)
map('n', "<leader>V", ':!fmt -110<CR>', opts)
map('n', "<leader>v", ':!fmt -100<CR>', opts)
map('n', "<leader>y", ':!fmt -85<CR>', opts)
map('i', "<C-f>f", '<c-o>:AFManual<CR>', opts)
map('i', "<C-f>a", '<c-o>:AFAuto<CR>', opts)

map('n', "<leader>v", "}kV{j", opts)        -- select current paragraph
map('n', "<C-A-w>", "}kV{jgq", opts)      -- select and format current paragraph

-- Ctrl-s in normal and insert mode: save if modified
-- Ctrl-q in normal and insert mode: save if modified and close buffer
-- Ctrl-x Ctrl-q is deprecated, use Ctrl-s, Ctrl-x-Ctrl-c
map('i', "<C-x><C-s>", '<c-o>:update!<CR>', opts)
map('n', "<C-x><C-s>", ':update!<CR>', opts)

--map('n', "tsh", ':TSHighlightCapturesUnderCursor<CR>', opts)  -- show tree-sitter highlight class
map('n', "<C-x><C-c>", ':Kwbd<CR>', opts)
map('i', "<C-x><C-c>", '<c-o>:Kwbd<CR>', opts)

-- switch off highlighted search results
map('n', "<C-x><C-h>", ':nohl<CR>', opts)
map('i', "<C-x><C-h>", '<c-o>:nohl<CR>', opts)

-- various
map('i', "<C-y>-", "???", opts )        -- emdash
map('i', "<C-y>\"", "??????", opts)       -- typographic quotes (??????)

-- close window
map('n', "<A-w>", ":close<CR>", opts)
-- force exit, caution all unsaved buffers will be lost
map('n', "<A-q>", ":qa!<CR>", opts)

-- Telekasten mappings
map('n', "ZP", ":lua require('telekasten').panel()<CR>", opts)
map('n', "ZF", ":lua require('telekasten').find_notes()<CR>", opts)
map('n', "ZD", ":lua require('telekasten').find_daily_notes()<CR>", opts)
map('n', "ZS", ":lua require('telekasten').search_notes()<CR>", opts)
map('n', "ZL", ":lua require('telekasten').follow_link()<CR>", opts)

-- LSP mappings
map('n', "lsi", ":LspInfo<CR>", opts)     -- LspInfo

-- Glance plugin
map('n', "GD", ":Glance definitions<CR>", opts)       -- goto definition(s)
map('n', "GR", ":Glance references<CR>", opts)        -- show references

-- Telescope LSP code navigation and diagnostics
map('n', "TD", ":lua require'telescope.builtin'.lsp_definitions{winblend=20, layout_config={height=0.6, width=0.8,preview_width=0.6}}<CR>", opts)
map('n', "TR", ":lua require'telescope.builtin'.lsp_references{winblend=20, layout_config={height=0.6, width=0.8,preview_width=0.6}}<CR>", opts)
map('n', "TS", ":lua require'telescope.builtin'.lsp_ocument_symbols{winblend=20, layout_config={height=0.6, width=0.8,preview_width=0.6}}<CR>", opts)
map('n', "TW", ":lua require'telescope.builtin'.lsp_workspace_symbols{winblend=20, layout_config={height=0.6, width=0.8,preview_width=0.6}}<CR>", opts)
map('n', "TI", ":lua require'telescope.builtin'.lsp_implementations{winblend=20, layout_config={height=0.6, width=0.8,preview_width=0.5}}<CR>", opts)
map('n', "TW", ":lua require'telescope.builtin'.diagnostics{winblend=20, layout_config={height=0.6, width=0.8,preview_width=0.5}}<CR>", opts)
map('n', "TE", ":lua require'telescope.builtin'.diagnostics{bufnr=0, winblend=20, layout_config={height=0.6, width=0.8,preview_width=0.5}}<CR>", opts)

map('n', "TT", ":lua vim.lsp.buf.type_definition()<CR>", opts)

-- diagnostics (LSP)
map('n', "DO", ":lua vim.diagnostic.open_float()<CR>", opts)             -- show popup
map('n', "DN", ":lua vim.diagnostic.goto_next()<CR>", opts)              -- goto next
map('n', "DP", ":lua vim.diagnostic.goto_prev()<CR>", opts)              -- goto prev
map('n', "DD", ":lua vim.lsp.buf.hover()<CR>", opts)                     -- show hover info for symbol

map('n', "DF", ":LspFormatDoc<CR>", opts)         -- format the doc with null-ls provider
map('v', "DR", ":LspFormatRange<CR>", opts )      -- format the range with null-ls provider
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

vim.keymap.set("n",    "tsh",
    function()
        local result = vim.treesitter.get_captures_at_cursor(0)
        print(vim.inspect(result))
    end,
    { noremap = true, silent = false }
)