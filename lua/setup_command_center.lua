-- setup command center mappings. Outsourced from setup_telescope.lua
-- when this is in use, only vim_mappings_light is required for full keyboard configuration

Command_center = require("command_center")
local noremap = {noremap = true}
local lsputil = require('lspconfig.util')

Command_center.add({
  {
    desc = "Bookmark Toggle",
    cmd = "<Plug>BookmarkToggle",
    keys = { "n", "<leader>bt",  noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Bookmark Annotate",
    cmd = "<Plug>BookmarkAnnotate",
    keys = { "n", "<leader>by", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Bookmarks show all",
    cmd = "<Plug>BookmarkShowAll",
    keys = { "n", "<leader>ba", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Bookmark next",
    cmd = "<Plug>BookmarkNext",
    keys = { "n", "<leader>bn", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Bookmark previous",
    cmd = "<Plug>BookmarkPrev",
    keys = { "n", "<leader>bp", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Bookmark delete",
    cmd = "<Plug>BookmarkClear",
    keys = { "n", "<leader>bd", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Bookmark delete All",
    cmd = "<Plug>BookmarkClearAll",
    keys = { "n", "<leader>bx", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Bookmark move down",
    cmd = "<Plug>BookmarkMoveDown",
    keys = { "n", "<leader>bb",  noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Bookmark move up",
    cmd = "<Plug>BookmarkMoveUp",
    keys = { "n", "<leader>bu", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Bookmark move to line",
    cmd = "<Plug>BookmarkMoveToLine",
    keys = { "n", "<leader>bm", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Show all bookmarks (Telescope)",
    cmd = function() require('telescope').extensions.vim_bookmarks.all({hide_filename=false, width_text=80, layout_config={height=0.4, width=0.8,preview_width=0.3}}) end,
    keys = { "n", "<A-b>", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Show bookmarks in current file (Telescope)",
    cmd = function() require('telescope').extensions.vim_bookmarks.current_file({layout_config={height=0.4, width=0.7}}) end,
    keys = { "n", "<A-B>", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Show favorite folders",
    cmd = function() require "quickfavs".Quickfavs() end,
    keys = { "n", "<f12>",  },
    category = "@Bookmarks"
  },
  -- LSP
  {
    desc = "LSP Server Info",
    cmd = "<CMD>LspInfo<CR>",
    keys = { "n", "lsi", noremap },
    category = "@LSP"
  },
  {
    desc = "Peek definitions (Glance Plugin)",
    cmd = "<CMD>Glance definitions<CR>",
    keys = { "n", "GD", noremap },
    category = "@LSP"
  },
  {
    desc = "Peek references (Glance Plugin)",
    cmd = "<CMD>Glance references<CR>",
    keys = { "n", "GR", noremap },
    category = "@LSP"
  },
-- Telescope LSP code navigation and diagnostics
  {
    desc = "Jump to definition",
    cmd = function() require'telescope.builtin'.lsp_definitions({winblend=20, layout_config={height=0.6, width=0.8,preview_width=0.6}}) end,
    keys = { "n", "td", noremap },
    category = "@LSP"
  },
  {
    desc = "Show references",
    cmd = function() require'telescope.builtin'.lsp_references({winblend=20, layout_config={height=0.6, width=0.8,preview_width=0.6}}) end,
    keys = { "n", "tr", noremap },
    category = "@LSP"
  },
  {
    desc = "Document symbols",
    cmd = function() require'telescope.builtin'.lsp_document_symbols({winblend=20, layout_config={height=0.6, width=0.8,preview_width=0.6}}) end,
    keys = { "n", "ts", noremap },
    category = "@LSP"
  },
  {
    desc = "Dynamic workspace symbols",
    cmd = function() require'telescope.builtin'.lsp_dynamic_workspace_symbols({winblend=0, fname_width=80,layout_config={height=0.6, width=0.9,preview_width=0.3}}) end,
    keys = { "n", "tds", noremap },
    category = "@LSP"
  },
  {
    desc = "Workspace symbols",
    cmd = function() require'telescope.builtin'.lsp_workspace_symbols({winblend=0, fname_width=80,layout_config={height=0.6, width=0.9,preview_width=0.3}}) end,
    keys = { "n", "tws", noremap },
    category = "@LSP"
  },
  {
    desc = "Show implementations",
    cmd = function() require'telescope.builtin'.lsp_implementations({winblend=20, layout_config={height=0.6, width=0.8,preview_width=0.5}}) end,
    keys = { "n", "ti", noremap },
    category = "@LSP"
  },
  {
    desc = "Run diagnostics",
    cmd = function() require'telescope.builtin'.diagnostics({bufnr=0, winblend=20, layout_config={height=0.6, width=0.8,preview_width=0.5}}) end,
    keys = { "n", "te", noremap },
    category = "@LSP"
  },
  {
    desc = "Shutdown LSP server",
    cmd = function() require "local_utils".StopLsp() end,
    category = "@LSP"
  },
  {
    desc = "Show type definition",
    cmd = function() vim.lsp.buf.type_definition() end,
    keys = { "n", "TT",  },
    category = "@LSP"
  },
  {
    desc = "toggle outline view",
    cmd = "<CMD>SymbolsOutline<CR>",
    keys = { "n", "<leader>.", noremap },
    category = "@LSP"
  },
  {
    desc = "Signature help",
    cmd = function() vim.lsp.buf.signature_help() end,
    keys = { "i", "<C-p>", noremap  },
    category = "@LSP"
  },
  -- LSP Diagnostics
  {
    desc = "Show diagnostic popup",
    cmd = function() vim.diagnostic.open_float() end,
    keys = { "n", "DO",  noremap},
    category = "@LSP Diagnostics"
  },
  {
    desc = "Go to next diagnostic",
    cmd = function() vim.diagnostic.goto_next() end,
    keys = { "n", "DN", noremap },
    category = "@LSP Diagnostics"
  },
  {
    desc = "Go to previous diagnostic",
    cmd = function() vim.diagnostic.goto_prev() end,
    keys = { "n", "DP", noremap },
    category = "@LSP Diagnostics"
  },
  {
    desc = "Show hover info for current symbol",
    cmd = function() vim.lsp.buf.hover() end,
    keys = { "n", "DD", noremap },
    category = "@LSP Diagnostics"
  },
  {
    desc = "Code Action",
    cmd = function() vim.lsp.buf.code_action() end,
    keys = { "n", "DA",  },
    category = "@LSP Diagnostics"
  },
  -- GIT
  {
    desc = "GIT status (Telescope)",
    cmd = function() require'telescope.builtin'.git_status({layout_config={height=0.8, width=0.8}}) end,
    keys = { "n", "tgs", noremap },
    category = "@GIT"
  },
  {
    desc = "GIT commits (Telescope)",
    cmd = function() require'telescope.builtin'.git_commits({layout_config={height=0.8, width=0.8}}) end,
    keys = { "n", "tgc", noremap },
    category = "@GIT"
  },
  {
    -- open a float term with lazygit.
    -- use the path of the current buffer to find the .git root. The LSP utils are useful for
    -- such a case.
    desc = "FloatTerm lazygit",
    cmd = function() local cmd = "FloatermNew --name=GIT --width=0.9 --height=0.9 lazygit --path=" .. lsputil.root_pattern(".git")(vim.fn.expand("%:p")) vim.cmd(cmd) end,
    keys = { "n", "<f6>", noremap },
    category = "@GIT"
  },
  -- text formatting
  {
    -- select and format the current paragraph
    desc = "Format paragraph",
    cmd = "}kV{jgq",
    keys = { "n", "<A-C-w>", noremap },
    category = "@Formatting"
  },
  {
    -- select the current paragraph
    desc = "Select paragraph",
    cmd = "}kV{j",
    keys = { "n", "<leader>v", noremap },
    category = "@Formatting"
  },
  -- lsp formatters, this requires the null-ls plugin
  {
    desc = "LSP Format document",
    cmd = "<CMD>LspFormatDoc<CR>",
    keys = { "n", "DF", noremap },
    category = "@Formatting"
  },
  {
    desc = "LSP Format range",
    cmd = "<CMD>LspFormatRange<CR>",
    keys = { "n", "DR", noremap },
    category = "@Formatting"
  },
  -- Telescope pickers
  {
    desc = "Buffer list (Telescope)",
    cmd = function() require'telescope.builtin'.buffers(Telescope_dropdown_theme({title='Buffer list', width=0.6, height=0.3, sort_lastused=true, ignore_current_buffer=true, sorter=require'telescope.sorters'.get_substr_matcher()})) end,
    keys = { "n", "<C-e>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Recent files (Telescope)",
    cmd = function() require'telescope.builtin'.oldfiles(Telescope_dropdown_theme({title='Old files', width=0.6, height=0.5})) end,
    keys = { "n", "<C-p>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Find files in current directory (Telescope)",
    cmd = function() require'telescope.builtin'.find_files({hidden=true, cwd=vim.fn.expand('%:p:h'), layout_config={width=0.8, height=0.6,preview_width=0.7}}) end,
    keys = { "n", "<leader>f", noremap },
    category = "@Telescope"
  },
  {
    desc = "Jumplist (Telescope)",
    cmd = function() require'telescope.builtin'.jumplist({fname_width=70, show_line=false, layout_config={width=0.9, height=0.7, preview_width=0.5}}) end,
    keys = { "n", "<A-Backspace>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Command history (Telescope)",
    cmd = function() require'telescope.builtin'.command_history(Telescope_dropdown_theme{title='Command history', width=0.4, height=0.7}) end,
    keys = { "n", "<A-C>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Command list (Telescope)",
    cmd = function() require'telescope.builtin'.commands(Telescope_dropdown_theme{title='Commands', width=0.6, height=0.7}) end,
    keys = { "n", "<A-c>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Registers (Telescope)",
    cmd = function() require'telescope.builtin'.registers(Telescope_dropdown_theme{title='Registers',width=0.6, height=0.7}) end,
    keys = { "n", "<C-x><C-r>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Keymaps (Telescope",
    cmd = function() require'telescope.builtin'.keymaps({layout_config={width=0.8, height=0.7}}) end,
    keys = { "n", "<C-x><C-k>", noremap },
    category = "@Telescope"
  },
  {
    desc = "File Browser (Telescope)",
    cmd = function() require('telescope').extensions.file_browser.file_browser({hidden=true, path=vim.fn.expand('%:p:h'), layout_config={width=0.8, preview_width=0.6 } }) end,
    keys = { "n", "<A-f>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Fuzzy search in current buffer",
    cmd = function() require'telescope.builtin'.current_buffer_fuzzy_find({layout_config={width=0.8, preview_width=0.4} }) end,
    keys = { "n", "<C-x><C-f>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Help tags (@Telescope)",
    cmd = function() require'telescope.builtin'.help_tags({ winblend=20, layout_config={width=0.8, height=0.8, preview_width=0.7} }) end,
    keys = { "n", "<A-h>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Spell suggestions",
    cmd = function() require'telescope.builtin'.spell_suggest(Telescope_dropdown_theme{title='Spell suggestions', height=0.5,width=0.2}) end,
    keys = { "n", "<A-s>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Todo List",
    cmd = "<CMD>TodoTelescope cwd=%:p:h<CR>",
    keys = { "n", "tdo", noremap },
    category = "@Neovim"
  },
  {
    desc = "Quit Neovim",
    cmd = function() require "local_utils".Quitapp() end,
    keys = { "n", "<A-q>", noremap },
    category = "@Neovim"
  },
  {
    desc = "Command Palette (Insert Mode)",
    cmd = function() require("telescope").extensions.command_center.command_center({ mode='i' }) end,
    keys = { "i", "<A-p>", noremap },
    category = "@Neovim"
  },
  {
    desc = "Command Palette (Normal Mode)",
    cmd = function() require("telescope").extensions.command_center.command_center() end,
    keys = { "n", "<A-p>", noremap },
    category = "@Neovim"
  },
  {
    desc = "Neotree buffer list",
    cmd = "<CMD>Neotree buffers position=float<CR>",
    keys = { "n", "<C-t>", noremap },
    category = "@Neovim"
  },
  {
    desc = "Neotree Git status",
    cmd = "<CMD>Neotree git_status position=float<CR>",
    keys = { "n", "<C-g>", noremap },
    category = "@Neovim"
  },
  {
    desc = "Packer Sync",
    cmd = "<CMD>PackerSync<CR>",
    keys = {  },
    category = "@Neovim"
  }
})

