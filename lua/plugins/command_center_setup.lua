-- setup command center mappings. Outsourced from setup_telescope.lua
-- when this is in use, only vim_mappings_light is required for full keyboard configuration
-- most of these mappings are also in vim_mappings_full.lua so command_center is optional.
local command_center = require("command_center")
local noremap = { noremap = true }
local lsputil = require("lspconfig.util")
local lutils = require("local_utils")
local _t = require("telescope")
local _tb = require("telescope.builtin")
local Terminal  = require('toggleterm.terminal').Terminal

local fkeys = vim.g.fkeys

command_center.add({
  {
    desc = "Bookmark toggle",
    --cmd = function() bm.bookmark_toggle() end,
    cmd = "<CMD>silent BookmarkToggle<CR>",
    keys = { "n", "<leader>bt", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Bookmark annotate",
    --cmd = function() bm.bookmark_ann() end,
    cmd = "<CMD>silent BookmarkAnnotate<CR>",
    keys = { "n", "<leader>ba", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Bookmark delete",
    --cmd = function() bm.bookmark_clean() end,
    cmd = "<CMD>silent BookmarkClear<CR>",
    keys = { "n", "<leader>bd", noremap },
    category = "@Bookmarks"
  },
  {
    desc = "Show all bookmarks (Telescope)",
    cmd = function()
      --_t.extensions.bookmarks.list(__Telescope_vertical_dropdown_theme({
      local bookmark_actions = require("telescope").extensions.vim_bookmarks.actions
      _t.extensions.vim_bookmarks.all(__Telescope_vertical_dropdown_theme({
        shorten_path = true,
        width_text = 40,
        width_annotation = 50,
        path_display = false,
        attach_mappings = function(_, map)
          map("i", "<C-d>", bookmark_actions.delete_selected_or_at_cursor)
          return true
        end,
        prompt_title = "All Bookmarks",
        hide_filename = false,
        layout_config = Config.telescope_vertical_preview_layout
      }))
    end,
    keys = {
      { "n", "<A-b>", noremap },
      { "i", "<A-b>", noremap },
    },
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
    keys = { "n", fkeys.s_f12, },
    category = "@Bookmarks"
  },
  -- LSP
  {
    desc = "LSP server info",
    cmd = "<CMD>LspInfo<CR>",
    keys = { "n", "lsi", noremap },
    category = "@LSP"
  },
  {
    desc = "Peek definitions (Glance plugin)",
    cmd = function() require("glance").open("definitions") end,
    keys = { "n", fkeys.s_f4, noremap },
    category = "@LSP"
  },
  {
    desc = "Peek references (Glance plugin)",
    cmd = function() require("glance").open("references") end,
    keys = { "n", "<f4>", noremap },
    category = "@LSP"
  },
  {
    desc = "LSP diagnostics",
    cmd = function() vim.diagnostic.setloclist() end,
    keys = { "n", "le", noremap },
    category = "@LSP"
  },
  {
    desc = "LSP jump to type definition",
    cmd = function() vim.lsp.buf.type_definition() end,
    keys = {
      { "n", "<C-x>t", noremap },
      { "i", "<C-x>t", noremap }
    },
    category = "@LSP"
  },
  -- Telescope LSP code navigation and diagnostics
  {
    desc = "Jump to definition (Telescope)",
    cmd = function()
      _tb.lsp_definitions(__Telescope_vertical_dropdown_theme({
        prompt_prefix = lutils.getTelescopePromptPrefix(),
        symbol_highlights = Config.telescope_symbol_highlights,
        layout_config = Config.minipicker_layout
      }))
    end,
    keys = {
      { "n", "<C-x>d", noremap },
      { "i", "<C-x>d", noremap }
    },
    category = "@LSP Telescope"
  },
  {
    desc = "Mini document symbols",
    cmd = function()
      local ignore_symbols = {}
      if __Globals.ignore_symbols[vim.bo.filetype] ~= nil then
        ignore_symbols = __Globals.ignore_symbols[vim.bo.filetype]
      end
      _tb.lsp_document_symbols(__Telescope_vertical_dropdown_theme({
        prompt_prefix = lutils.getTelescopePromptPrefix(),
        symbol_highlights = Config.telescope_symbol_highlights,
        ignore_symbols = ignore_symbols,
        layout_config = Config.minipicker_layout
      }))
    end,
    keys = {
      { "n", "<A-o>", noremap },
      { "i", "<A-o>", noremap }
    },
    category = "@LSP Telescope"
  },
  {
    desc = "Aerial document symbols",
    cmd = function()
      _t.extensions.aerial.aerial(__Telescope_vertical_dropdown_theme({
        prompt_prefix = lutils.getTelescopePromptPrefix(),
        prompt_title = "Symbols (Aerial)",
        layout_config = Config.minipicker_layout
      }))
    end,
    keys = {
      { "n", "<A-a>", noremap },
      { "i", "<A-a>", noremap }
    },
    category = "@LSP Telescope Aerial"
  },
  {
    desc = "Mini document references",
    cmd = function()
      _tb.lsp_references(__Telescope_vertical_dropdown_theme({
        prompt_prefix = lutils.getTelescopePromptPrefix(),
        path_display = { truncate = 9 },
        show_line = false,
        layout_config = Config.minipicker_layout
      }))
    end,
    keys = {
      { "i", "<A-r>", noremap },
      { "n", "<A-r>", noremap }
    },
    category = "@LSP Telescope"
  },
  {
    desc = "Mini document treesitter view",
    cmd = function()
      _tb.treesitter(__Telescope_vertical_dropdown_theme({
        prompt_prefix = lutils.getTelescopePromptPrefix(),
        layout_config = Config.minipicker_layout
      }))
    end,
    keys = {
      { "i", "<A-t>", noremap },
      { "n", "<A-t>", noremap }
    },
    category = "@LSP Telescope"
  },
  {
    desc = "Dynamic workspace symbols (Telescope)",
    cmd = function() _tb.lsp_dynamic_workspace_symbols(__Telescope_vertical_dropdown_theme({})) end,
    keys = { "n", "tds", noremap },
    category = "@LSP Telescope"
  },
  {
    desc = "Workspace symbols (Telescope)",
    cmd = function() _tb.lsp_workspace_symbols(__Telescope_vertical_dropdown_theme({})) end,
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
    desc = "Run diagnostics (workspace)",
    cmd = function()
      _tb.diagnostics(__Telescope_vertical_dropdown_theme({
        prompt_prefix = lutils.getTelescopePromptPrefix(),
        root_dir = lutils.getroot_current()
      }))
    end,
    keys = {
      { "i", "<C-t>d", noremap },
      { "n", "<C-t>d", noremap }
    },
    category = "@LSP"
  },
  {
    desc = "Shutdown LSP server",
    cmd = function() lutils.StopLsp() end,
    keys = { "n", "lss", noremap },
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
    desc = "Code action",
    cmd = function() vim.lsp.buf.code_action() end,
    keys = { "n", "DA", },
    category = "@LSP Diagnostics"
  },
  {
    desc = "Reset diagnostics",
    cmd = function() vim.diagnostic.reset() end,
    keys = { "n", "DR", },
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
      local lazygit = Terminal:new({ cmd = "lazygit",
        direction = "float",
        dir = path,
        -- refresh neo-tree display to reflect changes in git status
        -- TODO: implement for nvim-tree?
        on_close = function()
          if vim.g.tweaks.tree.version == "Neo" then
            vim.schedule(function() require("neo-tree.command").execute({ action="show" }) end)
          end
        end,
        hidden = false })
      lazygit:toggle()
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
      local cmd = "imd '" .. path .. "'"
      local imd = Terminal:new({ cmd = cmd,
        direction = "float",
        float_opts = {
          width = 150
        },
        hidden = false })
      imd:toggle()
    end,
    keys = { -- Shift-F6
      { "n", fkeys.s_f6, noremap },
      { "i", fkeys.s_f6, noremap },
    },
    category = "@Markdown"
  },
  {
    -- open a markdown preview using lightmdview
    desc = "View Markdown in GUI viewer (" .. vim.g.tweaks.mdguiviewer .. ")",
    cmd = function()
      local path = vim.fn.expand("%:p")
      local cmd = "silent !" .. vim.g.tweaks.mdguiviewer ..  " '" .. path .. "' &"
      vim.cmd.stopinsert()
      vim.schedule(function() vim.cmd(cmd) end)
    end,
    keys = { -- Ctrl-F6
      { "n", fkeys.c_f6, noremap },
      { "i", fkeys.c_f6, noremap },
    },
    category = "@Markdown"
  },
  {
    -- open a document viewer zathura view and view the tex document as PDF
    desc = "View LaTeX result (" .. vim.g.tweaks.texviewer .. ")",
    cmd = lutils.view_latex(),
    keys = { -- shift-f9
      { "n", fkeys.s_f9, noremap },
      { "i", fkeys.s_f9, noremap },
    },
    category = "@LaTeX"
  },
  {
    -- recompile the .tex document using lualatex
    desc = "Recompile LaTeX document",
    cmd = lutils.compile_latex(),
    keys = {
      { "n", "<f9>", noremap },
      { "i", "<f9>", noremap },
    },
    category = "@LaTeX"
  },
  -- format with the LSP server
  -- note: ranges are not supported by all LSP
  {
    desc = "LSP Format document or range",
    cmd = function() vim.lsp.buf.format() end,
    keys = { -- shift-f7
      { "n", fkeys.s_f7, noremap },
      { "i", fkeys.s_f7, noremap },
      { "v", fkeys.s_f7, noremap },
    },
    category = "@Formatting"
  },
  -- Telescope pickers
  {
    desc = "Find files in current directory (Telescope)",
    cmd = function()
      _tb.find_files(__Telescope_vertical_dropdown_theme({
        hidden = false,
        prompt_title = "Find Files (current)",
        -- previewer = false,
        prompt_prefix = lutils.getTelescopePromptPrefix(),
        layout_config = { width = 80, preview_height = 15 },
        cwd = vim.fn.expand("%:p:h")
      }))
    end,
    keys = { -- shift-f8
      { "i", fkeys.s_f8, noremap },
      { "n", fkeys.s_f8, noremap }
    },
    category = "@Telescope"
  },
  {
    desc = "Find files from current project root",
    cmd = function()
      _tb.find_files(__Telescope_vertical_dropdown_theme({
        prompt_title = "Find Files (project root)",
        hidden = false,
        prompt_prefix = lutils.getTelescopePromptPrefix(),
        -- previewer = false;
        layout_config = { width = 80, preview_height = 15 },
        cwd = lutils.getroot_current()
      }))
    end,
    keys = {
      { "n", "<f8>", noremap },
      { "i", "<f8>", noremap }
    },
    category = "@Telescope"
  },
  {
    desc = "Jumplist (Telescope)",
    cmd = function()
      _tb.jumplist(__Telescope_vertical_dropdown_theme({
        show_line = false,
        prompt_prefix = lutils.getTelescopePromptPrefix(),
        layout_config = Config.telescope_vertical_preview_layout
      }))
    end,
    keys = {
      { "n", "<A-Backspace>", noremap },
      { "i", "<A-Backspace>", noremap }
    },
    category = "@Telescope"
  },
  {
    desc = "Command history (Telescope)",
    cmd = function() _tb.command_history(__Telescope_dropdown_theme { title = "Command history", width = 0.4, height = 0.7 }) end,
    keys = { "n", "<A-C>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Command list (Telescope)",
    cmd = function() _tb.commands(__Telescope_dropdown_theme { title = "Commands", width = 0.6, height = 0.7 }) end,
    keys = { "n", "<A-c>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Registers (Telescope)",
    cmd = function() _tb.registers(__Telescope_dropdown_theme { prompt_prefix = lutils.getTelescopePromptPrefix() }) end,
    keys = {
      { "i", "<C-x><C-r>", noremap },
      { "n", "<C-x><C-r>", noremap }
    },
    category = "@Telescope"
  },
  {
    desc = "Keymaps (Telescope",
    cmd = function() _tb.keymaps({ layout_config = { width = 0.8, height = 0.7 } }) end,
    keys = { "n", "<C-x><C-k>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Fuzzy search in current buffer",
    cmd = function()
      _tb.current_buffer_fuzzy_find(__Telescope_vertical_dropdown_theme({
        layout_config = Config.telescope_vertical_preview_layout,
        prompt_title = "Fuzzy Find in current buffer"
      }))
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
    desc = "Live grep (current directory)",
    cmd = function()
      _tb.live_grep(__Telescope_vertical_dropdown_theme({
        layout_config = { width = 130 },
        prompt_title = "Live grep folder (current directory)",
        search_dirs = { vim.fn.expand("%:p:h") }
      }))
    end,
    keys = { "n", "<C-x>g", noremap },
    category = "@Telescope"
  },
  {
    desc = "Live grep (project root)",
    cmd = function()
      _tb.live_grep(__Telescope_vertical_dropdown_theme({
        layout_config = { width = 130 },
        prompt_title = "Live grep folder (project root)",
        search_dirs = { lutils.getroot_current() }
      }))
    end,
    keys = { "n", "<C-x><C-g>", noremap },
    category = "@Telescope"
  },
  {
    desc = "Spell suggestions",
    cmd = function() _tb.spell_suggest(__Telescope_dropdown_theme { prompt_prefix = lutils.getTelescopePromptPrefix(), title = "Spell suggestions", height = 0.5, width = 0.2 }) end,
    keys = {
      { "n", "<A-s>", noremap },
      { "i", "<A-s>", noremap }
    },
    category = "@Telescope"
  },
  {
    desc = "Tags list (Telescope)",
    cmd = function() _tb.tags(__Telescope_vertical_dropdown_theme({ prompt_title = "Tags list", cwd = lutils.getroot_current() })) end,
    keys = { "n", "<leader>t", },
    category = "@Telescope"
  },
  {
    desc = "Todo list (project root)",
    cmd = function()
      require("telescope._extensions.todo-comments").exports.todo(__Telescope_vertical_dropdown_theme({
        layout_config = { width = 120 }, prompt_title = "Todo comments (project root)", cwd = lutils.getroot_current(), hidden = true }))
    end,
    keys = { "n", "tdp", noremap },
    category = "@Neovim"
  },
  {
    desc = "Todo list (current directory)",
    cmd = function()
      local dir = vim.fn.expand("%:p:h")
      require("telescope._extensions.todo-comments").exports.todo(__Telescope_vertical_dropdown_theme({
        layout_config = { width = 120 }, prompt_title = "Todo comments (current directory)", cwd = dir }))
    end,
    keys = { "n", "tdo", noremap },
    category = "@Neovim"
  },
  {
    desc = "List all highlight groups",
    cmd = function() _tb.highlights(__Telescope_vertical_dropdown_theme({
      layout_config = Config.telescope_vertical_preview_layout
    }) ) end,
    keys = { "n", "thl", noremap },
    category = "@Neovim"
  },
  {
    desc = "Inspect auto word list (wordlist plugin)",
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
      __Globals.toggle_debug()
    end,
    keys = { "n", "dbg", noremap },
    category = "@Neovim"
  },
  {
    desc = "Treesitter tree",
    cmd = function()
      vim.treesitter.inspect_tree({ command = "rightbelow 36vnew" })
      vim.o.statuscolumn = ""
    end,
    keys = { "n", "tsp", noremap },
    category = "@Neovim"
  },
  {
    desc = "Quickfix list (mini.picker)",
    cmd = function() require("mini.extra").pickers.list({ scope = "quickfix" }, { window = { config = __Globals.mini_pick_center(110, 25, 0.1) } }) end,
    keys = { "n", "qfl", noremap },
    category = "@Neovim"
  },
  {
    desc = "Location list (mini.picker)",
    cmd = function() require("mini.extra").pickers.list({ scope = "location" }, { window = { config = __Globals.mini_pick_center(110, 25, 0.1) } }) end,
    keys = { "n", "lll", noremap },
    category = "@Neovim"
  },
  {
    desc = "GitSigns next hunk",
    cmd = function() require("gitsigns").next_hunk() end,
    keys = {
      { "n", "<C-x><Down>", noremap },
      { "i", "<C-x><Down>", noremap }
    },
    category = "@GIT"
  },
  {
    desc = "GitSigns previous hunk",
    cmd = function() require("gitsigns").prev_hunk() end,
    keys = {
      { "n", "<C-x><Up>", noremap },
      { "i", "<C-x><Up>", noremap }
    },
    category = "@GIT"
  },
  {
    desc = "GitSigns preview hunk",
    cmd = function() require("gitsigns").preview_hunk() end,
    keys = {
      { "n", "<C-x>h", noremap },
      { "i", "<C-x>h", noremap }
    },
    category = "@GIT"
  },
  {
    desc = "GitSigns diff this",
    cmd = function() require("gitsigns").diffthis() end,
    keys = {
      { "n", "<C-x><C-d>", noremap },
      { "i", "<C-x><C-d>", noremap }
    },
    category = "@GIT"
  },
  {
    desc = "Telescope marks",
    cmd = function()
      _tb.marks(__Telescope_vertical_dropdown_theme({
        prompt_prefix = lutils.getTelescopePromptPrefix(),
        symbol_highlights = Config.telescope_symbol_highlights,
        layout_config = Config.minipicker_layout
      }))
    end,
    keys = {
      { "n", "<C-x>m", noremap },
      { "i", "<C-x>m", noremap }
    },
    category = "@Telescope"
  },
  {
    desc = "Configure CMP layout",
    cmd = function() require("plugins.cmp").select_layout() end,
    keys = {
      { "n", "<leader>cc", noremap },
    },
    category = "@Setup"
  },
  {
    desc = "ZK tags",
    cmd = function()
      require("telescope").extensions.zk.tags( __Telescope_vertical_dropdown_theme({ layout_config={preview_height=0.7, width=0.5, height=0.9}} ) )
    end,
    keys = {
      { "n", "zkt", noremap },
    },
    category = "@ZK"
  },
  {
    desc = "ZK notes",
    cmd = function()
      require("telescope").extensions.zk.notes( __Telescope_vertical_dropdown_theme({ layout_config={preview_height=15, width=0.5, height=0.9}} ) )
    end,
    keys = {
      { "n", "zkn", noremap },
    },
    category = "@ZK"
  },
  {
    desc = "ZK live grep",
    cmd = function()
      _tb.live_grep(__Telescope_vertical_dropdown_theme({
        layout_config = { width = 130 },
        prompt_title = "Live grep zettelkasten",
        search_dirs = { vim.fn.expand(vim.g.tweaks.zk.root_dir) }
      }))
    end,
    keys = { "n", "zkg", noremap },
    category = "@ZK"
  },
  -- unused stuff keep it here in case we need it at some point
  --  {
  --    desc = "Neotree buffer list",
  --    cmd = "<CMD>Neotree buffers dir=%:p:h position=float<CR>",
  --    keys = { "n", "<C-t>", noremap },
  --    category = "@Neovim"
  --  },
  --  {
  --    desc = "Neotree Git status",
  --    cmd = "<CMD>Neotree git_status dir=%:p:h position=float<CR>",
  --    keys = { "n", "<C-g>", noremap },
  --    category = "@Neovim"
  --  },
})

