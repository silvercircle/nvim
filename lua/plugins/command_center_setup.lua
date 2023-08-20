-- setup command center mappings. Outsourced from setup_telescope.lua
-- when this is in use, only vim_mappings_light is required for full keyboard configuration
-- most of these mappings are also in vim_mappings_full.lua so command_center is optional.
local command_center = require("command_center")
local noremap = { noremap = true }
local lsputil = require('lspconfig.util')
local lutils = require("local_utils")
local _t = require("telescope")
local _tb = require("telescope.builtin")

-- this is a helper for mini pickers like references and symbols.
local fzf_vertical_winops = { width = 0.6, preview = { layout = 'vertical', vertical = "up:30%" } }

command_center.add({
  {
    desc = "Bookmark Toggle",
    cmd = "<Plug>BookmarkToggle",
    keys = { "n", "<leader>bt", noremap },
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
    desc = "Bookmark del,rete All",
    cmd = "<Plug>BookmarkClearAll",
    keys = { "n", "<leader>bx", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Bookmark move down",
    cmd = "<Plug>BookmarkMoveDown",
    keys = { "n", "<leader>bb", noremap },
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
    cmd = function()
      _t.extensions.vim_bookmarks.all(Telescope_vertical_dropdown_theme({
        prompt_title = "All Bookmarks",
        hide_filename = false,
        width_text = 120
      }))
    end,
    keys = { "n", "<A-b>", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Show bookmarks in current file (Telescope)",
    cmd = function()
      _t.extensions.vim_bookmarks.current_file(Telescope_vertical_dropdown_theme({
        prompt_title = "File Bookmarks" }))
    end,
    keys = { "n", "<A-B>", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Show favorite folders",
    cmd = function() require "quickfavs".Quickfavs(false) end,
    keys = { "n", "<f12>", },
    category = "@Bookmarks"
  },
  {
    desc = "Show favorite folders (rescan fav file)",
    cmd = function() require "quickfavs".Quickfavs(true) end,
    keys = { "n", "<f24>", },
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
    keys = { { "n", "<C-x>d", noremap },
      { 'i', "<C-x>d", noremap }
    },
    category = "@LSP"
  },
  {
    desc = "LSP References",
    cmd = function() vim.lsp.buf.references() end,
    keys = { { "n", "<C-x>r", noremap },
      { 'i', "<C-x>r", noremap }
    },
    category = "@LSP"
  },
  {
    desc = "LSP Diagnostics",
    cmd = function() vim.diagnostic.setloclist() end,
    keys = { "n", "le", noremap },
    category = "@LSP"
  },
  {
    desc = "LSP Jump to type definition",
    cmd = function() vim.lsp.buf.type_definition() end,
    keys = { { "n", "<C-x>t", noremap },
      { 'i', "<C-x>t", noremap }
    },
    category = "@LSP"
  },
  -- Telescope LSP code navigation and diagnostics
  {
    desc = "Jump to definition (Telescope)",
    cmd = function() _tb.lsp_definitions(Telescope_vertical_dropdown_theme({})) end,
    keys = { "n", "tde", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Show references (Telescope)",
    cmd = function()
      _tb.lsp_references(Telescope_vertical_dropdown_theme({
        fname_width = 120,
        layout_config = {
          width = 0.9 }
      }))
    end,
    keys = { "n", "tre", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Document symbols (Telescope)",
    cmd = function() _tb.lsp_document_symbols({ layout_config = { height = 0.6, width = 0.8, preview_width = 0.6 } }) end,
    keys = { "n", "ts", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Mini Document symbols",
    cmd = function()
      _tb.lsp_document_symbols(Telescope_vertical_dropdown_theme({
        layout_config = vim.g.config.minipicker_layout }))
    end,
    keys = { "n", "<A-o>", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Mini Document symbols (i)",
    cmd = function()
      _tb.lsp_document_symbols(Telescope_vertical_dropdown_theme({
        prompt_prefix = vim.g.config.minipicker_iprefix, layout_config = vim.g.config.minipicker_layout }))
    end,
    keys = { "i", "<A-o>", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Mini Document references",
    cmd = function()
      _tb.lsp_references(Telescope_vertical_dropdown_theme({
        path_display = { truncate = 9 },
        show_line = false,
        layout_config = vim.g.config.minipicker_layout
      }))
    end,
    keys = { "n", "<A-r>", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Mini Document references (i)",
    cmd = function()
      _tb.lsp_references(Telescope_vertical_dropdown_theme({
        path_display = { truncate = 9 },
        show_line = false,
        prompt_prefix = vim.g.config.minipicker_iprefix,
        layout_config = vim.g.config
            .minipicker_layout
      }))
    end,
    keys = { "i", "<A-r>", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Mini Document Treesitter",
    cmd = function() _tb.treesitter(Telescope_vertical_dropdown_theme({ layout_config = vim.g.config.minipicker_layout })) end,
    keys = { "n", "<A-t>", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Mini Document Treesitter (i)",
    cmd = function()
      _tb.treesitter(Telescope_vertical_dropdown_theme({
        prompt_prefix = vim.g.config.minipicker_iprefix,
        layout_config = vim.g.config.minipicker_layout
      }))
    end,
    keys = { "i", "<A-t>", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Dynamic workspace symbols (Telescope)",
    cmd = function() _tb.lsp_dynamic_workspace_symbols(Telescope_vertical_dropdown_theme({})) end,
    keys = { "n", "tds", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Workspace symbols (Telescope)",
    cmd = function() _tb.lsp_workspace_symbols(Telescope_vertical_dropdown_theme({})) end,
    keys = { "n", "tws", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Show implementations (Telescope)",
    cmd = function() _tb.lsp_implementations({ layout_config = { height = 0.6, width = 0.8, preview_width = 0.5 } }) end,
    keys = { "n", "ti", noremap },
    category = "@LSP (Telescope)"
  },
  {
    desc = "Run diagnostics",
    cmd = function() _tb.diagnostics({ bufnr = 0, layout_config = { height = 0.6, width = 0.8, preview_width = 0.5 } }) end,
    keys = { "n", "te", noremap },
    category = "@LSP"
  },
  {
    desc = "Shutdown LSP server",
    cmd = function() lutils.StopLsp() end,
    keys = { "n", "lss", noremap },
    category = "@LSP"
  },
  {
    desc = "toggle outline view",
    cmd = "<CMD>SymbolsOutline<CR>",
    keys = { "n", "<leader>.", noremap },
    category = "@LSP"
  },
  -- LSP Diagnostics
  {
    desc = "Show diagnostic popup",
    cmd = function() vim.diagnostic.open_float() end,
    keys = { "n", "DO", noremap },
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
    keys = { "n", "DA", },
    category = "@LSP Diagnostics"
  },
  -- GIT
  {
    desc = "GIT status (Telescope)",
    cmd = function()
      _tb.git_status({
        cwd = lsputil.root_pattern(".git")(vim.fn.expand("%:p")),
        layout_config = { height = 0.8, width = 0.8 }
      })
    end,
    keys = { "n", "tgs", noremap },
    category = "@GIT"
  },
  {
    desc = "GIT commits (Telescope)",
    cmd = function()
      _tb.git_commits({
        cwd = lsputil.root_pattern(".git")(vim.fn.expand("%:p")),
        layout_config = { height = 0.8, width = 0.8 }
      })
    end,
    keys = { "n", "tgc", noremap },
    category = "@GIT"
  },
  {
    -- open a float term with lazygit.
    -- use the path of the current buffer to find the .git root. The LSP utils are useful here
    desc = "FloatTerm lazygit",
    cmd = function()
      local path = lsputil.root_pattern(".git")(vim.fn.expand("%:p"))
      path = path or "."
      local cmd = "FloatermNew --name=GIT --width=0.9 --height=0.9 lazygit --path=" .. path
      vim.cmd.stopinsert()
      vim.schedule(function() vim.cmd(cmd) end)
    end,
    keys = {
      { "n", "<f6>", noremap },
      { "i", "<f6>", noremap },
    },
    category = "@GIT"
  },
  {
    -- open a markdown preview using IMD
    desc = "Floatterm IMD",
    cmd = function()
      local path = vim.fn.expand("%:p")
      local cmd = "FloatermNew --name=IMD --width=150 --height=0.95 imd '" .. path .. "'"
      vim.cmd.stopinsert()
      vim.schedule(function() vim.cmd(cmd) end)
    end,
    keys = {
      { "n", "<f18>", noremap },
      { "i", "<f18>", noremap },
    },
    category = "@Markdown"
  },
  {
    -- open a markdown preview using lightmdview
    desc = "View Markdown in lightmdview",
    cmd = function()
      local path = vim.fn.expand("%:p")
      local cmd = "!litemdview '" .. path .. "'"
      vim.cmd.stopinsert()
      vim.schedule(function() vim.cmd(cmd) end)
    end,
    keys = {
      { "n", "<f30>", noremap },
      { "i", "<f30>", noremap },
    },
    category = "@Markdown"
  },
  {
    -- open a zathura view and view the tex document as PDF
    desc = "View LaTeX result",
    cmd = function()
      local result, path = require("globals").getLatexPreviewPath(vim.fn.expand("%"), true)
      if result == true then
        local cmd = "silent !zathura  '" .. path .. "'"
        vim.cmd.stopinsert()
        vim.schedule(function() vim.cmd(cmd) end)
      else
        print("The PDF output does not exist. Please recompile.")
        return
      end
    end,
    keys = {
      { "n", "<f54>", noremap },
      { "i", "<f54>", noremap },
    },
    category = "@Markdown"
  },
  {
    -- recompile the .tex document using lualatex
    desc = "Recompile LaTeX document",
    cmd = function()
      -- must change cwd to current, otherwise latex may not found subdocuments using relative
      -- file names. 
      local cwd = "cd " .. vim.fn.expand("%:p:h")
      vim.cmd(cwd)
      local cmd = "!lualatex --output-directory=" .. vim.fn.expand(vim.g.config.texoutput) .. " '" .. vim.fn.expand("%:p") .. "'"
      require("globals").debugmsg(cmd)
      vim.cmd.stopinsert()
      vim.schedule(function() vim.cmd(cmd) end)
    end,
    keys = {
      { "n", "<f53>", noremap },
      { "i", "<f53>", noremap },
    },
    category = "@Markdown"
  },
  -- format with the LSP server
  -- note: ranges are not supported by all LSP
  {
    desc = "LSP Format document or range",
    cmd = function() vim.lsp.buf.format() end,
    keys = {
      { "n", "<f19>", noremap },
      { "i", "<f19>", noremap },
      { "v", "<f19>", noremap },
    },
    category = "@Formatting"
  },
  -- format with the configured utility
  {
    desc = "Format document using the configured utility",
    cmd = function() require("globals").format_source() end,
    keys = {
      { "n", "<f55>", noremap },
      { "i", "<f55>", noremap },
      { "v", "<f55>", noremap },
    },
    category = "@Formatting"
  },
  -- Telescope pickers
  {
    desc = "Find files in current directory (Telescope)",
    cmd = function()
      _tb.find_files(Telescope_vertical_dropdown_theme({
        hidden = true,
        prompt_title = "Find Files",
        cwd = vim.fn.expand('%:p:h')
      }))
    end,
    keys = { "n", "<f20>", noremap }, --shift-f8
    category = "@Telescope"
  },
  {
    desc = "Find files from current project root",
    cmd = function()
      _tb.find_files(Telescope_vertical_dropdown_theme({
        prompt_title = "Find Files",
        cwd = lutils.getroot_current()
      }))
    end,
    keys = { "n", "<f8>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Jumplist (Telescope)",
    cmd = function()
      _tb.jumplist(Telescope_vertical_dropdown_theme({
        show_line = false,
        layout_config = { width = 80, preview_height = 0.3 }
      }))
    end,
    keys = { "n", "<A-Backspace>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Jumplist (Telescope) (i)",
    cmd = function()
      _tb.jumplist(Telescope_vertical_dropdown_theme({
        prompt_prefix = vim.g.config.minipicker_iprefix,
        show_line = false,
        layout_config = { width = 80, preview_height = 0.3 }
      }))
    end,
    keys = { "i", "<A-Backspace>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Command history (Telescope)",
    cmd = function() _tb.command_history(Telescope_dropdown_theme { title = 'Command history', width = 0.4, height = 0.7 }) end,
    keys = { "n", "<A-C>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Command list (Telescope)",
    cmd = function() _tb.commands(Telescope_dropdown_theme { title = 'Commands', width = 0.6, height = 0.7 }) end,
    keys = { "n", "<A-c>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Registers (Fzf)",
    cmd = function() require("fzf-lua").registers({ winopts = fzf_vertical_winops }) end,
    keys = { "n", "<C-x><C-r>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Keymaps (Telescope",
    cmd = function() _tb.keymaps({ layout_config = { width = 0.8, height = 0.7 } }) end,
    keys = { "n", "<C-x><C-k>", noremap },
    category = "@Telescope"
  },
  {
    desc = "File Browser (Telescope)",
    cmd = function()
      _t.extensions.file_browser.file_browser(Telescope_vertical_dropdown_theme({
        hidden = true,
        prompt_title = "File Browser",
        path = vim.fn.expand('%:p:h')
      }))
    end,
    keys = { "n", "<A-f>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Fuzzy search in current buffer",
    cmd = function()
      _tb.current_buffer_fuzzy_find(Telescope_vertical_dropdown_theme({
        prompt_title = "Fuzzy Find in current buffer" }))
    end,
    keys = { "n", "<C-x><C-f>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Help tags (@Telescope)",
    cmd = function() _tb.help_tags({ layout_config = { width = 0.8, height = 0.8, preview_width = 0.7 } }) end,
    keys = { "n", "tht", noremap },
    category = "@Telescope"
  },
  {
    desc = "Live Grep (current directory)",
    cmd = function()
      _tb.live_grep(Telescope_vertical_dropdown_theme({
        prompt_title = "Live Grep Folder (current)",
        search_dirs = { vim.fn.expand("%:p:h") }
      }))
    end,
    keys = { "n", "<C-x>g", noremap },
    category = "@Telescope"
  },
  {
    desc = "Live Grep (project root)",
    cmd = function()
      _tb.live_grep(Telescope_vertical_dropdown_theme({
        prompt_title = "Live Grep Folder (project root)",
        search_dirs = { lutils.getroot_current() }
      }))
    end,
    keys = { "n", "<C-x><C-g>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Spell suggestions",
    cmd = function() _tb.spell_suggest(Telescope_dropdown_theme { title = 'Spell suggestions', height = 0.5, width = 0.2 }) end,
    keys = { "n", "<A-s>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Tags list (Telescope)",
    cmd = function() _tb.tags(Telescope_vertical_dropdown_theme({ prompt_title = "Tags", cwd = lutils.getroot_current() })) end,
    keys = { "n", "<leader>t", },
    category = "@Telescope"
  },
  {
    desc = "Todo List",
    cmd = function()
      require('telescope._extensions.todo-comments').exports.todo(Telescope_vertical_dropdown_theme({
        prompt_title = "Todo Comments", cwd = lutils.getroot_current(), hidden = true }))
    end,
    keys = { "n", "tdo", noremap },
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
    keys = {},
    category = "@Neovim"
  },
  {
    desc = "List all Highlight groups",
    cmd = function() _tb.highlights() end,
    keys = { "n", "thl", noremap },
    category = "@Neovim"
  },
  {
    desc = "Inspect Auto Word list",
    cmd = function() require("cmp_wordlist").autolist() end,
    keys = { "n", "<leader>zw", noremap },
    category = "@Neovim"
  },
  {
    desc = "Colorizer Toggle",
    cmd = function()
      local c = require("colorizer")
      if c.is_buffer_attached(0) then c.detach_from_buffer(0) else c.attach_to_buffer(0) end
    end,
    keys = { "n", "ct", noremap },
    category = "@Neovim"
  },
  {
    desc = "Debug toggle",
    cmd = function()
      require("globals").toggle_debug()
    end,
    keys = { "n", "dbg", noremap },
    category = "@Neovim"
  },
  {
    desc = "Treesitter tree",
    cmd = function()
      vim.treesitter.inspect_tree({ command = 'rightbelow 36vnew' })
      vim.o.statuscolumn = ""
    end,
    keys = { "n", "tsp", noremap },
    category = "@Neovim"
  },
  {
    desc = "Fzf Quickfix list",
    cmd = function() require("fzf-lua").quickfix({ winopts = fzf_vertical_winops }) end,
    keys = { "n", "qfl", noremap },
    category = "@Neovim"
  },
  {
    desc = "Fzf Location list",
    cmd = function() require("fzf-lua").loclist({ winopts = fzf_vertical_winops }) end,
    keys = { "n", "lll", noremap },
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
  },
  {
    desc = "FZF live grep current directory",
    cmd = function() require("fzf-lua").live_grep({ cwd = vim.fn.expand("%:p:h"), winopts = fzf_vertical_winops }) end,
    keys = { "n", "<f9>", noremap },
    category = "@FZF"
  },
  {
    desc = "FZF live grep project root",
    cmd = function()
      require("fzf-lua").live_grep({
        cwd = require("local_utils").getroot_current(),
        winopts = fzf_vertical_winops
      })
    end,
    keys = { "n", "<f21>", noremap },
    category = "@FZF"
  }
})
