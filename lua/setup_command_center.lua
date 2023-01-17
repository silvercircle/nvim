-- setup command center mappings. Outsourced from setup_telescope.lua
-- when this is in use, only vim_mappings_light is required for full keyboard configuration
-- most of these mappings are also in vim_mappings_full.lua so command_center is optional.
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
    cmd = function() require('telescope').extensions.vim_bookmarks.all(Telescope_vertical_dropdown_theme({prompt_title="All Bookmarks", hide_filename=false, width_text=120})) end,
    keys = { "n", "<A-b>", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Show bookmarks in current file (Telescope)",
    cmd = function() require('telescope').extensions.vim_bookmarks.current_file(Telescope_vertical_dropdown_theme({prompt_title="File Bookmarks"})) end,
    keys = { "n", "<A-B>", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Show favorite folders",
    cmd = function() require "quickfavs".Quickfavs(false) end,
    keys = { "n", "<f12>",  },
    category = "@Bookmarks"
  },
  {
    desc = "Show favorite folders (rescan fav file)",
    cmd = function() require "quickfavs".Quickfavs(true) end,
    keys = { "n", "<f24>",  },
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
  {
    desc = "LSP Jump to definition",
    cmd = function() vim.lsp.buf.definition() end,
    keys = { "n", "ld", noremap },
    category = "@LSP"
  },
  {
    desc = "LSP Jump to type definition",
    cmd = function() vim.lsp.buf.type_definition() end,
    keys = { "n", "lt", noremap },
    category = "@LSP"
  },

-- Telescope LSP code navigation and diagnostics
  {
    desc = "Jump to definition (Telescope)",
    cmd = function() require'telescope.builtin'.lsp_definitions(Telescope_vertical_dropdown_theme({})) end,
    keys = { "n", "tde", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Show references (Telescope)",
    cmd = function() require'telescope.builtin'.lsp_references(Telescope_vertical_dropdown_theme({fname_width=120,layout_config={width=0.9}})) end,
    keys = { "n", "tre", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Document symbols (Telescope)",
    cmd = function() require'telescope.builtin'.lsp_document_symbols({layout_config={height=0.6, width=0.8,preview_width=0.6}}) end,
    keys = { "n", "ts", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Mini Document symbols (Telescope)",
    cmd = function() require'telescope.builtin'.lsp_document_symbols(Telescope_vertical_dropdown_theme({prompt_prefix="$>",prompt_title="Document Symbols",layout_config={height=0.8, width=50,preview_height=0.22}})) end,
    keys = { "n", "<A-o>", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Mini Document symbols (insert) (Telescope)",
    cmd = function() require'telescope.builtin'.lsp_document_symbols(Telescope_vertical_dropdown_theme({prompt_prefix="@>",prompt_title="Document Symbols",layout_config={height=0.8, width=50,preview_height=0.22}})) end,
    keys = { "i", "<A-o>", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Mini Document references (Telescope)",
    cmd = function() require'telescope.builtin'.lsp_references(Telescope_vertical_dropdown_theme({prompt_prefix="$>",prompt_title="Symbol References",layout_config={height=0.8, width=50,preview_height=0.22}})) end,
    keys = { "n", "<A-r>", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Mini Document references (insert) (Telescope)",
    cmd = function() require'telescope.builtin'.lsp_references(Telescope_vertical_dropdown_theme({prompt_prefix="@>",prompt_title="Symbol References",layout_config={height=0.8, width=50,preview_height=0.22}})) end,
    keys = { "i", "<A-r>", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Dynamic workspace symbols (Telescope)",
    cmd = function() require'telescope.builtin'.lsp_dynamic_workspace_symbols(Telescope_vertical_dropdown_theme({})) end,
    keys = { "n", "tds", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Workspace symbols (Telescope)",
    cmd = function() require'telescope.builtin'.lsp_workspace_symbols(Telescope_vertical_dropdown_theme({})) end,
    keys = { "n", "tws", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Show implementations (Telescope)",
    cmd = function() require'telescope.builtin'.lsp_implementations({layout_config={height=0.6, width=0.8,preview_width=0.5}}) end,
    keys = { "n", "ti", noremap },
    category = "@LSP (Telescope)"
  },
  {
    desc = "Run diagnostics",
    cmd = function() require'telescope.builtin'.diagnostics({bufnr=0, layout_config={height=0.6, width=0.8,preview_width=0.5}}) end,
    keys = { "n", "te", noremap },
    category = "@LSP"
  },
  {
    desc = "Shutdown LSP server",
    cmd = function() require "local_utils".StopLsp() end,
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
    -- use the path of the current buffer to find the .git root. The LSP utils are useful here
    desc = "FloatTerm lazygit",
    cmd = function() local path = lsputil.root_pattern(".git")(vim.fn.expand("%:p"))
      path = path or "."
      local cmd = "FloatermNew --name=GIT --width=0.9 --height=0.9 lazygit --path=" .. path
      vim.cmd(cmd)
    end,
    keys = { "n", "<f6>", noremap },
    category = "@GIT"
  },
  {
    -- open a float term with ranger in the project root.
    -- use the path of the current buffer to find the .git root. The LSP utils are useful here
    desc = "FloatTerm Ranger",
    cmd = function() local path = lsputil.root_pattern(".git")(vim.fn.expand("%:p"))
      path = path or "."
      local cmd = "FloatermNew --name=RANGER --width=0.9 --height=0.9 ranger " .. path
      vim.cmd(cmd)
    end,
    keys = { "n", "<f18>", noremap },
    category = "@Neovim"
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
    cmd = function() require'telescope.builtin'.buffers(Telescope_dropdown_theme({title='Buffer list', width=0.6, height=0.4, sort_lastused=true, sort_mru=true, show_all_buffers=true, ignore_current_buffer=true, sorter=require'telescope.sorters'.get_substr_matcher()})) end,
    keys = {
      {"n", "<C-e>", noremap },
      {"i", "<C-e>", noremap }
    },
    category = "@Telescope"
  },
  {
    desc = "Recent files (Telescope)",
    cmd = function() require'telescope.builtin'.oldfiles(Telescope_dropdown_theme({title='Old files', width=0.6, height=0.5})) end,
    keys = {
      { "n", "<C-p>", noremap },
      { "i", "<C-p>", noremap }
    },
    category = "@Telescope"
  },
  {
    desc = "Find files in current directory (Telescope)",
    cmd = function() require'telescope.builtin'.find_files(Telescope_vertical_dropdown_theme({hidden=true, prompt_title="Find Files", cwd=vim.fn.expand('%:p:h')})) end,
    keys = { "n", "<f20>", noremap },  --shift-f8
    category = "@Telescope"
  },
  {
    desc = "Find files from current project root",
    cmd = function() require("telescope.builtin").find_files(Telescope_vertical_dropdown_theme({path_display={absolute=true},prompt_title="Find Files", cwd = require("local_utils").getroot_current()})) end,
    keys = { "n", "<f8>", noremap },
    category = "@Telescope"
  },
  {
    desc = "File browser in the current project root",
    cmd = function() require("telescope").extensions.file_browser.file_browser(Telescope_vertical_dropdown_theme({grouped=true, prompt_title="File Browser", hidden=true, path = require("local_utils").getroot_current()})) end,
    keys = { "n", "<f32>", noremap },  -- ctrl-f8
    category = "@Telescope"
  },
  {
    desc = "Jumplist (Telescope)",
    cmd = function() require'telescope.builtin'.jumplist(Telescope_vertical_dropdown_theme({show_line=false, layout_config={preview_height=0.4}})) end,
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
    cmd = function() require'telescope.builtin'.registers(Telescope_vertical_dropdown_theme{prompt_title='Registers',layout_config={width=0.6, height=0.7,preview_height=0.3}}) end,
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
    cmd = function() require('telescope').extensions.file_browser.file_browser(Telescope_vertical_dropdown_theme({hidden=true, prompt_title="File Browser", path=vim.fn.expand('%:p:h')})) end,
    keys = { "n", "<A-f>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Fuzzy search in current buffer",
    cmd = function() require'telescope.builtin'.current_buffer_fuzzy_find(Telescope_vertical_dropdown_theme({prompt_title="Fuzzy Find in current buffer"})) end,
    keys = { "n", "<C-x><C-f>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Help tags (@Telescope)",
    cmd = function() require'telescope.builtin'.help_tags({layout_config={width=0.8, height=0.8, preview_width=0.7} }) end,
    keys = { "n", "tht", noremap },
    category = "@Telescope"
  },
  {
    desc = "Live Grep (current directory)",
    cmd = function() require("telescope.builtin").live_grep(Telescope_vertical_dropdown_theme({prompt_title="Live Grep Folder (current)", search_dirs={vim.fn.expand("%:p:h")}})) end,
    keys = { "n", "<C-x>g", noremap },
    category = "@Telescope"
  },
  {
    desc = "Live Grep (project root)",
    cmd = function() require("telescope.builtin").live_grep(Telescope_vertical_dropdown_theme({prompt_title="Live Grep Folder (project root)", search_dirs={ require("local_utils").getroot_current() }})) end,
    keys = { "n", "<C-x><C-g>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Spell suggestions",
    cmd = function() require'telescope.builtin'.spell_suggest(Telescope_dropdown_theme{title='Spell suggestions', height=0.5,width=0.2}) end,
    keys = { "n", "<A-s>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Tags list (Telescope)",
    cmd = function() require'telescope.builtin'.tags(Telescope_vertical_dropdown_theme({prompt_title="Tags", cwd = require("local_utils").getroot_current()})) end,
    keys = { "n", "<leader>t",  },
    category = "@Telescope"
  },
  {
    desc = "Todo List",
    cmd = function() require('telescope._extensions.todo-comments').exports.todo(Telescope_vertical_dropdown_theme({prompt_title="Todo Comments",cwd = require("local_utils").getroot_current(), hidden=true})) end,
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
    cmd = function() require("telescope").extensions.command_center.command_center({mode='i' }) end,
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
    cmd = "<CMD>Neotree buffers dir=%:p:h position=float<CR>",
    keys = { "n", "<C-t>", noremap },
    category = "@Neovim"
  },
  {
    desc = "Neotree Git status",
    cmd = "<CMD>Neotree git_status dir=%:p:h position=float<CR>",
    keys = { "n", "<C-g>", noremap },
    category = "@Neovim"
  },
  {
    desc = "Packer Sync",
    cmd = "<CMD>PackerSync<CR>",
    keys = {  },
    category = "@Neovim"
  },
  {
    desc = "List all Highlight groups",
    cmd = function() require('telescope.builtin').highlights() end,
    keys = { "n", "thl", noremap },
    category = "@Neovim"
  },
  {
    desc = "Inspect Auto Word list",
    cmd = function() require("cmp_wordlist").autolist() end,
    keys = { "n", "zal", noremap },
    category = "@Neovim"
  },
  {
    desc = "Colorizer Toggle",
    cmd = function() local c = require("colorizer") if c.is_buffer_attached(0) then c.detach_from_buffer(0) else c.attach_to_buffer(0) end end,
    keys = { "n", "ct", noremap },
    category = "@Neovim"
  },
  {
    desc = "Telekasten panel",
    cmd = function() require('telekasten').panel() end,
    keys = { "n", "<f7>", noremap },
    category = "@Telekasten"
  },
  {
    desc = "Telekasten find notes",
    cmd = function() require('telekasten').find_notes() end,
    keys = { "n", "<leader>zf", noremap },
    category = "@Telekasten"
  },
  {
    desc = "Telekasten find daily notes",
    cmd = function() require('telekasten').find_daily_notes() end,
    keys = { "n", "<leader>zd", noremap },
    category = "@Telekasten"
  },
  {
    desc = "Telekasten search notes",
    cmd = function() require('telekasten').search_notes() end,
    keys = { "n", "<leader>zs", noremap },
    category = "@Telekasten"
  }
})
