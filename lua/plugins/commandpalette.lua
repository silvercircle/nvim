local fkeys      = vim.g.fkeys
local fzf_tweaks = Tweaks.fzf
local fzf        = require("fzf-lua")
local Snacks     = require("snacks")
local lutils     = require("subspace.lib")
local lsputil    = require("lsp.utils")
local noremap    = true

require("commandpicker").add({
  {
    desc = "Show all bookmarks (Snacks picker)",
    cmd = function()
      local layout = SPL({
        preset = "select",
        preview = true,
        width = 120,
        height = 0.7,
        psize = 12,
        input = "bottom",
        title = "Select Bookmark"
      })
      require("subspace.content.bookmarkspicker").open({ layout = layout })
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
    desc = "LSP server info",
    cmd = "<cmd>LspInfo<cr>",
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
  {
    -- open a float term with lazygit.
    -- use the path of the current buffer to find the .git root. The LSP utils are useful here
    desc = "Snacks LazyGit",
    cmd = function()
      require("snacks").lazygit({ cwd=lutils.getroot_current() })
    end,
    keys = {
      { "n", "<f6>", noremap },
      { "i", "<f6>", noremap },
    },
    category = "@GIT"
  },
  {
    desc = "View Markdown in GUI viewer (" .. Tweaks.mdguiviewer .. ")",
    cmd = function()
      local path = vim.fn.expand("%:p")
      local cmd = "silent !" .. Tweaks.mdguiviewer .. " '" .. path .. "' &"
      vim.cmd.stopinsert()
      vim.schedule(function() vim.cmd(cmd) end)
    end,
    keys = {   -- Ctrl-F6
      { "n", fkeys.c_f6, noremap },
      { "i", fkeys.c_f6, noremap },
    },
    category = "@Markdown"
  },
  {
    -- open a document viewer zathura view and view the tex document as PDF
    desc = "View LaTeX result (" .. Tweaks.texviewer .. ")",
    cmd = lutils.view_latex(),
    keys = {   -- shift-f9
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
    keys = {   -- shift-f7
      { "n", fkeys.s_f7, noremap },
      { "i", fkeys.s_f7, noremap },
      { "v", fkeys.s_f7, noremap },
    },
    category = "@Formatting"
  },
  {
    desc = "Inspect auto word list (wordlist plugin)",
    cmd = function() require(Tweaks.completion.version == "nvim-cmp" and "cmp_wordlist" or "blink-cmp-wordlist").autolist() end,
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
      CGLOBALS.toggle_debug()
    end,
    keys = { "n", "dbg", noremap },
    category = "@Neovim"
  },
  {
    desc = "Treesitter tree",
    cmd = function()
      vim.treesitter.inspect_tree({ command = "rightbelow 50vnew" })
      vim.o.statuscolumn = ""
      vim.cmd("set ft=query_rt | silent! setlocal signcolumn=no | silent! setlocal foldcolumn=0 | silent! setlocal norelativenumber | silent! setlocal nonumber | setlocal statusline=Treesitter | setlocal winhl=Normal:TreeNormalNC")
    end,
    keys = { "n", "tsp", noremap },
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
    -- only use this for nvim-cmp, not yet supported for blink
    desc = "Configure CMP layout",
    cmd = function()
      if Tweaks.completion.version == "nvim-cmp" then
        require("plugins.cmp_setup").select_layout()
      end
    end,
    keys = {
      { "n", "<leader>cc", noremap },
    },
    category = "@Setup"
  },
  {
    desc = "Command history (FZF)",
    cmd = function() require("snacks").picker.command_history({
      layout = SPL({ input = "top", width = 140, height = 0.7, row = 7, preview = false }) })
    end,
    keys = { "n", "<A-C>", noremap },
    category = "@FZF"
  },
  {
    desc = "Command list (FZF)",
    cmd = function() require("snacks").picker.commands({
      layout = SPL({ input = "top", width = 80, height = 0.8, row = 7, preview = false }) })
    end,
    keys = { "n", "<A-c>", noremap },
    category = "@FZF"
  },
  {
    desc = "Show notification history",
    cmd = function() lutils.notification_history() end,
    keys = {
      { "n", Tweaks.keymap.utility_key .. "n" },
      { "i", Tweaks.keymap.utility_key .. "n" }
    },
    category = "@Notifications"
  },
  {
    desc = "FZF Jumplist",
    -- cmd = function() fzf.jumps({ winopts = fzf_tweaks.winopts.std_preview_top }) end,
    cmd = function() Snacks.picker.jumps({ layout = SPL({width=120, preview=true, psize=12, input="top"}) }) end,
    keys = {
      { "n", "<A-Backspace>", noremap },
      { "i", "<A-Backspace>", noremap },
    },
    category = "@FZF"
  },
})

require("commandpicker").add({
  {
    desc = "FZF-LUA resume",
    cmd = function()
      fzf.resume({ winopts = fzf_tweaks.winopts.std_preview_top })
    end,
    keys = {
      { "i", Tweaks.keymap.fzf_prefix .. "r", noremap },
      { "n", Tweaks.keymap.fzf_prefix .. "r", noremap }
    },
    category = "@FZF"
  },
  {
    desc = "FZF-LUA quickfix list",
    cmd = function()
      fzf.quickfix({ winopts = fzf_tweaks.winopts.std_preview_top })
    end,
    keys = {
      { "i", Tweaks.keymap.fzf_prefix .. "q", noremap },
      { "n", Tweaks.keymap.fzf_prefix .. "q", noremap }
    },
    category = "@FZF"
  },
  {
    desc = "FZF-LUA commands",
    cmd = function()
      fzf.builtin({ prompt = "Commands: ", winopts = fzf_tweaks.winopts.mini_list })
    end,
    keys = {
      { "i", Tweaks.keymap.fzf_prefix .. "<space>", noremap },
      { "n", Tweaks.keymap.fzf_prefix .. "<space>", noremap }
    },
    category = "@FZF"
  },
  {
    desc = "Zettelkasten files",
    cmd = function()
      fzf.files({
        prompt = "Zettelkasten files: ",
        cwd = vim.fn.expand(Tweaks.zk.root_dir),
        fd_opts =
        "--type f --hidden --follow --exclude .obsidian --exclude .git --exclude .zk",
        winopts = fzf_tweaks.winopts.std_preview_top
      })
    end,
    keys = {
      { "i", Tweaks.keymap.fzf_prefix .. "<C-z>", noremap },
      { "n", Tweaks.keymap.fzf_prefix .. "<C-z>", noremap }
    },
    category = "@ZK"
  },
  {
    desc = "Zettelkasten live grep",
    cmd = function()
      local wo = fzf_tweaks.winopts.std_preview_top
      fzf.live_grep({ prompt = "Zettelkasten live grep: ", cwd = vim.fn.expand(Tweaks.zk.root_dir), winopts = wo })
    end,
    keys = {
      { "i", Tweaks.keymap.fzf_prefix .. "z", noremap },
      { "n", Tweaks.keymap.fzf_prefix .. "z", noremap }
    },
    category = "@ZK"
  },
  {
    desc = "Spell suggestions",
    cmd = function() fzf.spell_suggest({ winopts = { height = 0.5, width = 60, preview = { hidden = "hidden" } } }) end,
    keys = {
      { "n", "<A-s>", noremap },
      { "i", "<A-s>", noremap }
    },
    category = "@FZF"
  },
  {
    desc = "Registers (FZF)",
    cmd = function() fzf.registers({ winopts = fzf_tweaks.winopts.std_preview_none }) end,
    keys = {
      { "i", "<C-x><C-r>", noremap },
      { "n", "<C-x><C-r>", noremap }
    },
    category = "@FZF"
  },
  {
    desc = "Fuzzy search in current buffer",
    cmd = function()
      fzf.blines({ query = lutils.get_selection(), winopts = FWO("std_preview_top", "Fuzzy search in current buffer") })
    end,
    key = { { "n", "i", "v" }, "<C-x><C-f>", noremap },
    category = "@FZF"
  },
  {
    desc = "Fuzzy search in all open buffers",
    cmd = function()
      fzf.lines({ query = lutils.get_selection(), winopts = FWO("std_preview_top", "Fuzzy search in all open buffers") })
    end,
    key = { { "n", "i", "v" }, "<C-x>f", noremap },
    category = "@FZF"
  },
  {
    desc = "Todo list (current file)",
    cmd = function()
      local dir = vim.fn.expand("%:p:h")
      require("todo-comments.fzf").todo({
        cwd = dir, query = vim.fn.expand("%:t"), winopts = fzf_tweaks.winopts.std_preview_top })
    end,
    keys = {
      { "n", "tdf", noremap },
      { "i", Tweaks.keymap.fzf_prefix .. "f", noremap }
    },
    category = "@Neovim"
  },
  {
    desc = "Todo list (current directory)",
    cmd = function()
      local dir = vim.fn.expand("%:p:h")
      require("todo-comments.fzf").todo({
        cwd = dir, winopts = FWO("std_preview_top", "TODO list (current directory)") })
    end,
    keys = {
      { "n", "tdo", noremap },
      { "i", Tweaks.keymap.fzf_prefix .. "t", noremap }
    },
    category = "@Neovim"
  },
  {
    desc = "Todo list (project root)",
    cmd = function()
      require("todo-comments.fzf").todo({
        cwd = lutils.getroot_current(), winopts = FWO("std_preview_top", "TODO list (project root)") })
    end,
    keys = {
      { "n", "tdp", noremap },
      { "i", Tweaks.keymap.fzf_prefix .. "<C-t>", noremap }
    },
    category = "@Neovim"
  },
  {
    desc = "List all highlight groups (FZF)",
    cmd = function()
      fzf.highlights({
        winopts = FWO("narrow_small_preview", "Highlight Groups")
      })
    end,
    keys = { "n", "thl", noremap },
    category = "@Neovim"
  },
  {
    desc = "FZF live grep (current directory)",
    cmd = function()
      fzf.live_grep({ query = lutils.get_selection(), cwd = vim.fn.expand("%:p:h"),
        winopts = FWO("std_preview_top", "Live Grep (current directory)") })
    end,
    keys = {
      { "n", "<C-x>g", noremap },
      { "i", "<C-x>g", noremap },
      { "v", "<C-x>g", noremap }
    },
    category = "@FZF"
  },
  {
    desc = "FZF live grep (project root)",
    cmd = function()
      fzf.live_grep({ query = lutils.get_selection(), cwd = lutils.getroot_current(),
        winopts = FWO("std_preview_top", "Live Grep (project root)") })
    end,
    keys = {
      { "n", "<C-x><C-g>", noremap },
      { "i", "<C-x><C-g>", noremap },
      { "v", "<C-x><C-g>", noremap }
    },
    category = "@FZF"
  },
  {
    desc = "FZF live grep resume",
    cmd = function() fzf.live_grep_resume({ winopts = fzf_tweaks.winopts.std_preview_top }) end,
    keys = {
      { "n", "<C-x>G", noremap },
      { "i", "<C-x>G", noremap }
    },
    category = "@FZF"
  },
  {
    desc = "FZF smart find files (project root)",
    cmd = function()
      require("subspace.lib.smartpickers").smartfiles_or_grep({useroot = true, op="files"})
    end,
    keys = {
      { "i", fkeys.s_f8, noremap },
      { "n", fkeys.s_f8, noremap }
    },
    category = "@FZF"
  },
  {
    desc = "FZF smart live grep (project root)",
    cmd = function()
      require("subspace.lib.smartpickers").smartfiles_or_grep({useroot = true, op="grep"})
    end,
    keys = {
      { "n", "<f8>", noremap },
      { "i", "<f8>", noremap }
    },
    category = "@FZF"
  },
  {
    desc = "FZF marks",
    cmd = function()
      fzf.marks({
        winopts = fzf_tweaks.winopts.mini_with_preview,
      })
    end,
    keys = {
      { "n", "<C-x>m", noremap },
      { "i", "<C-x>m", noremap }
    },
    category = "@FZF"
  },
  {
    desc = "FZF Helptags",
    cmd = function()
      fzf.helptags({
        winopts = fzf_tweaks.winopts.big_preview_topbig,
      })
    end,
    keys = {
      { "n", "<C-x><C-h>", noremap },
      { "i", "<C-x><C-h>", noremap }
    },
    category = "@FZF"
  },
  {
    desc = "GIT status (FZF)",
    cmd = function()
      fzf.git_status({
        cwd = lsputil.root_pattern(".git")(vim.fn.expand("%:p")),
        winopts = fzf_tweaks.winopts.big_preview_topbig
      })
    end,
    keys = { "n", "tgs", noremap },
    category = "@GIT"
  },
  {
    desc = "GIT commits (project) (FZF)",
    cmd = function()
      fzf.git_commits({
        cwd = lsputil.root_pattern(".git")(vim.fn.expand("%:p")),
        winopts = fzf_tweaks.winopts.big_preview_topbig
      })
    end,
    keys = { "n", "tgc", noremap },
    category = "@GIT"
  },
  {
    desc = "GIT commits (buffer) (FZF)",
    cmd = function()
      fzf.git_bcommits({ winopts = fzf_tweaks.winopts.big_preview_topbig })
    end,
    keys = { "n", "tgb", noremap },
    category = "@GIT"
  },
  {
    desc = "GIT files (FZF)",
    cmd = function()
      fzf.git_files({
        cwd = lsputil.root_pattern(".git")(vim.fn.expand("%:p")),
        winopts = fzf_tweaks.winopts.big_preview_topbig
      })
    end,
    keys = { "n", "tgf", noremap },
    category = "@GIT"
  },
  {
    desc = "GIT branches (FZF)",
    cmd = function()
      fzf.git_branches({
        cwd = lsputil.root_pattern(".git")(vim.fn.expand("%:p")),
        winopts = fzf_tweaks.winopts.big_preview_topbig
      })
    end,
    keys = { "n", "tgb", noremap },
    category = "@GIT"
  },
  {
    desc = "GIT tags (FZF)",
    cmd = function()
      fzf.git_tags({
        cwd = lsputil.root_pattern(".git")(vim.fn.expand("%:p")),
        winopts = fzf_tweaks.winopts.big_preview_topbig
      })
    end,
    keys = { "n", "tgt", noremap },
    category = "@GIT"
  },
  {
    desc = "Jump to definition (FZF)",
    cmd = function() fzf.lsp_definitions({ winopts = fzf_tweaks.winopts.std_preview_top }) end,
    key = { { "n", "i"}, "<C-x>D", noremap },
    category = "@LSP FZF"
  },
  {
    desc = "Run diagnostics (workspace)",
    cmd = function()
      fzf.diagnostics_workspace({ cwd = lutils.getroot_current(), winopts = fzf_tweaks.winopts.big_preview_top })
    end,
    keys = {
      { "i", Tweaks.keymap.fzf_prefix .. "<C-d>", noremap },
      { "n", Tweaks.keymap.fzf_prefix .. "<C-d>", noremap }
    },
    category = "@LSP FZF"
  },
  {
    desc = "Run diagnostics (document)",
    cmd = function()
      fzf.diagnostics_document({ winopts = fzf_tweaks.winopts.big_preview_top })
    end,
    keys = {
      { "i", Tweaks.keymap.fzf_prefix .. "d", noremap },
      { "n", Tweaks.keymap.fzf_prefix .. "d", noremap }
    },
    category = "@LSP FZF"
  },
  {
    desc = "Dynamic workspace symbols (FZF)",
    cmd = function() fzf.lsp_live_workspace_symbols({ winopts = fzf_tweaks.winopts.big_preview_top }) end,
    keys = { "n", "tds", noremap },
    category = "@LSP FZF"
  },
  {
    desc = "Workspace symbols (FZF)",
    cmd = function() fzf.lsp_workspace_symbols({ winopts = fzf_tweaks.winopts.big_preview_top }) end,
    keys = { "n", "tws", noremap },
    category = "@LSP FZF"
  },
  {
    desc = "Incoming calls (FZF)",
    cmd = function() fzf.lsp_incoming_calls({ winopts = fzf_tweaks.winopts.std_preview_top }) end,
    keys = {
      { "n", "<C-x>i", noremap },
      { "i", "<C-x>i", noremap },
    },
    category = "@LSP FZF"
  },
  {
    desc = "Outgoing calls (FZF)",
    cmd = function() fzf.lsp_outgoing_calls({ winopts = fzf_tweaks.winopts.std_preview_top }) end,
    keys = {
      { "n", "<C-x>o", noremap },
      { "i", "<C-x>o", noremap },
    },
    category = "@LSP FZF"
  },
  {
    desc = "Document symbols (FZF)",
    cmd = function() require("snacks").picker.lsp_symbols({ layout = SPL( {width = 80, input="bottom", height=.8, preview=true, psize=0.3 } ) }) end,
    keys = {
      { "n", "<A-a>", noremap },
      { "i", "<A-a>", noremap }
    },
    category = "@LSP FZF"
  },
  {
    desc = "Mini document references (FZF)",
    cmd = function()
      fzf.lsp_references({ winopts = fzf_tweaks.winopts.std_preview_top })
    end,
    keys = {
      { "i", "<A-r>", noremap },
      { "n", "<A-r>", noremap }
    },
    category = "@LSP FZF"
  },
  {
    desc = "Mini document symbols (FZF)",
    cmd = function()
      fzf.lsp_document_symbols({ winopts = fzf_tweaks.winopts.mini_with_preview })
    end,
    keys = {
      { "n", "<A-o>", noremap },
      { "i", "<A-o>", noremap }
    },
    category = "@LSP FZF"
  },
  {
    desc = "Treesitter symbols (FZF)",
    cmd = function()
      fzf.treesitter({ winopts = fzf_tweaks.winopts.mini_with_preview })
    end,
    keys = {
      { "n", "<A-t>", noremap },
      { "i", "<A-t>", noremap }
    },
    category = "@FZF"
  },
  {
    desc = "LSP finder (FZF)",
    cmd = function()
      fzf.lsp_finder({ winopts = fzf_tweaks.winopts.std_preview_top })
    end,
    keys = {
      { "n", "<A-f>", noremap },
      { "i", "<A-f>", noremap }
    },
    category = "@LSP FZF"
  },
  {
    desc = "Zoxide history (FZF)",
    cmd = function()
      fzf.zoxide({ actions = require("subspace.lib.actions").fzf_dir_actions(), winopts = FWO("mini_with_preview", "Zoxide History, <CR>:browse, <C-g>:Grep, <C-d>:Set CWD, <C-o>:Oil" ) })
    end,
    key = { {"n","i"}, "<C-x>z", noremap },
    category = "@FZF"
  }
})
