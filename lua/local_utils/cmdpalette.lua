
local noremap = true
local M = {}
local fkeys = vim.g.fkeys
local fzf_tweaks = vim.g.tweaks.fzf
local fzf = require("fzf-lua")
local lutils = require("local_utils")
local lsputil = require("lspconfig.util")
local Terminal  = require('toggleterm.terminal').Terminal

local conf = {
  columns = {
    desc = {width = 43, hl = "String"},
    cat  = {width = 18, hl = "Class", align = "right"},
    cmd  = {width = 14, hl = "DefaultLib", "right"},
    keys = {width = 43, hl = "Operator"}
  }
}
M.lists = {
  default = {
    {
      desc = "Show notification history",
      cmd = function() require("local_utils").notification_history() end,
      keys = {
        { "n", vim.g.tweaks.keymap.utility_key .. "<C-n>", noremap },
        { "i", vim.g.tweaks.keymap.utility_key .. "<C-n>", noremap }
      },
      category = "@Notifications"
    },
    {
      desc = "Show all bookmarks (Snacks picker)",
      cmd = function()
        local layout = __Globals.gen_snacks_picker_layout({
          preset = "select",
          preview = true,
          width = 120,
          height = 0.7,
          psize = 12,
          input = "bottom",
          title = "Select Bookmark"
        })
        require("plugins.bookmarkspicker").open({ layout = layout })
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
    {
      desc = "LSP server info",
      cmd = "LspInfo",
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
      desc = "Show implementations (Telescope)",
      cmd = function() _tb.lsp_implementations({ layout_config = { height = 0.6, width = 0.8, preview_width = 0.5 } }) end,
      keys = { "n", "ti", noremap },
      category = "@LSP (Telescope)"
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
      desc = "FloatTerm lazygit",
      cmd = function()
        local path = lsputil.root_pattern(".git")(vim.fn.expand("%:p"))
        path = path or "."
        local lazygit = Terminal:new({
          cmd = "lazygit",
          direction = "float",
          dir = path,
          -- refresh neo-tree display to reflect changes in git status
          -- TODO: implement for nvim-tree?
          on_close = function()
            if vim.g.tweaks.tree.version == "Neo" then
              vim.schedule(function() require("neo-tree.command").execute({ action = "show" }) end)
            end
          end,
          hidden = false
        })
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
        local imd = Terminal:new({
          cmd = cmd,
          direction = "float",
          float_opts = {
            width = 150
          },
          hidden = false
        })
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
        local cmd = "silent !" .. vim.g.tweaks.mdguiviewer .. " '" .. path .. "' &"
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
    {
      desc = "Keymaps (Telescope",
      cmd = function() _tb.keymaps({ layout_config = { width = 0.8, height = 0.7 } }) end,
      keys = { "n", "<C-x><C-k>", noremap },
      category = "@Telescope"
    },
    {
      desc = "Help tags (@Telescope)",
      cmd = function() _tb.help_tags({ layout_config = { width = 0.8, height = 0.8, preview_width = 0.7 } }) end,
      keys = { "n", "tht", noremap },
      category = "@Telescope"
    },
    {
      desc = "Tags list (Telescope)",
      cmd = function() _tb.tags(__Telescope_vertical_dropdown_theme({ prompt_title = "Tags list", cwd = lutils.getroot_current() })) end,
      keys = { "n", "<leader>t", },
      category = "@Telescope"
    },
    {
      desc = "Inspect auto word list (wordlist plugin)",
      cmd = function() require(vim.g.tweaks.completion.version == "nvim-cmp" and "cmp_wordlist" or "blink-cmp-wordlist").autolist() end,
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
      desc = "Configure CMP layout",
      cmd = function() require("plugins.cmp_setup").select_layout() end,
      keys = {
        { "n", "<leader>cc", noremap },
      },
      category = "@Setup"
    },
    {
      desc = "Toggle CMP autocomplete",
      cmd = function() __Globals.toggle_autocomplete() end,
      keys = {
        { "n", "<leader>ca", noremap },
      },
      category = "@Setup"
    },
    {
      desc = "ZK tags",
      cmd = function()
        require("telescope").extensions.zk.tags(__Telescope_vertical_dropdown_theme({ layout_config = { preview_height = 0.7, width = 0.5, height = 0.9 } }))
      end,
      keys = {
        { "n", "zkt", noremap },
      },
      category = "@ZK"
    },
    {
      desc = "ZK notes",
      cmd = function()
        require("telescope").extensions.zk.notes(__Telescope_vertical_dropdown_theme({ layout_config = { preview_height = 15, width = 0.5, height = 0.9 } }))
      end,
      keys = {
        { "n", "zkn", noremap },
      },
      category = "@ZK"
    },
    {
      desc = "Command history (FZF)",
      cmd = function() require("snacks").picker.command_history({ layout = __Globals.gen_snacks_picker_layout({ input = "top", width = 140, height = 0.7, row = 7, preview = false }) }) end,
      keys = { "n", "<A-C>", noremap },
      category = "@FZF"
    },
    {
      desc = "Command list (FZF)",
      cmd = function() require("snacks").picker.commands({ layout = __Globals.gen_snacks_picker_layout({ input = "top", width = 80, height = 0.8, row = 7, preview = false }) }) end,
      keys = { "n", "<A-c>", noremap },
      category = "@FZF"
    },
  },
  fzf = {
    {
      desc = "FZF-LUA resume",
      cmd = function()
        fzf.resume({ winopts = fzf_tweaks.winopts.std_preview_top })
      end,
      keys = {
        { "i", vim.g.tweaks.keymap.fzf_prefix .. "r",  noremap },
        { "n", vim.g.tweaks.keymap.fzf_prefix .. "r",  noremap }
      },
      category = "@FZF"
    },
    {
      desc = "FZF-LUA quickfix list",
      cmd = function()
        fzf.quickfix({ winopts = fzf_tweaks.winopts.std_preview_top })
      end,
      keys = {
        { "i", vim.g.tweaks.keymap.fzf_prefix .. "q",  noremap },
        { "n", vim.g.tweaks.keymap.fzf_prefix .. "q",  noremap }
      },
      category = "@FZF"
    },
    {
      desc = "FZF-LUA commands",
      cmd = function()
        fzf.builtin({ prompt = "Commands: ", winopts = fzf_tweaks.winopts.mini_list })
      end,
      keys = {
        { "i", vim.g.tweaks.keymap.fzf_prefix .. "<space>",  noremap },
        { "n", vim.g.tweaks.keymap.fzf_prefix .. "<space>",  noremap }
      },
      category = "@FZF"
    },
    {
      desc = "Zettelkasten files",
      cmd = function()
        fzf.files({ prompt = "Zettelkasten files: ", cwd = vim.fn.expand(vim.g.tweaks.zk.root_dir), fd_opts =
        "--type f --hidden --follow --exclude .obsidian --exclude .git --exclude .zk", winopts = fzf_tweaks.winopts.std_preview_top })
      end,
      keys = {
        { "i", vim.g.tweaks.keymap.fzf_prefix .. "<C-z>",  noremap },
        { "n", vim.g.tweaks.keymap.fzf_prefix .. "<C-z>",  noremap }
      },
      category = "@ZK"
    },
    {
      desc = "Zettelkasten live grep",
      cmd = function()
        local wo = fzf_tweaks.winopts.std_preview_top
        fzf.live_grep({ prompt = "Zettelkasten live grep: ", cwd = vim.fn.expand(vim.g.tweaks.zk.root_dir), winopts = wo })
      end,
      keys = {
        { "i", vim.g.tweaks.keymap.fzf_prefix .. "z",  noremap },
        { "n", vim.g.tweaks.keymap.fzf_prefix .. "z",  noremap }
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
      desc = "FZF Jumplist",
      cmd = function() fzf.jumps({ winopts = fzf_tweaks.winopts.std_preview_top }) end,
      keys = {
        { "n", "<A-Backspace>", noremap },
        { "i", "<A-Backspace>", noremap },
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
        fzf.blines({ winopts = fzf_tweaks.winopts.std_preview_top })
      end,
      keys = {
        { "n", "<C-x><C-f>", noremap },
        { "i", "<C-x><C-f>", noremap }
      },
      category = "@FZF"
    },
    {
      desc = "Fuzzy search in all open buffers",
      cmd = function()
        fzf.lines({ winopts = fzf_tweaks.winopts.std_preview_top })
      end,
      keys = {
        { "n", "<C-x>f", noremap },
        { "i", "<C-x>f", noremap }
      },
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
        { "n", "tdf",                                 noremap },
        { "i", vim.g.tweaks.keymap.fzf_prefix .. "f", noremap }
      },
      category = "@Neovim"
    },
    {
      desc = "Todo list (current directory)",
      cmd = function()
        local dir = vim.fn.expand("%:p:h")
        require("todo-comments.fzf").todo({
          cwd = dir, winopts = fzf_tweaks.winopts.std_preview_top })
      end,
      keys = {
        { "n", "tdo",                                 noremap },
        { "i", vim.g.tweaks.keymap.fzf_prefix .. "t", noremap }
      },
      category = "@Neovim"
    },
    {
      desc = "Todo list (project root)",
      cmd = function()
        require("todo-comments.fzf").todo({
          cwd = lutils.getroot_current(), winopts = fzf_tweaks.winopts.std_preview_top })
      end,
      keys = {
        { "n", "tdp",                                      noremap },
        { "i", vim.g.tweaks.keymap.fzf_prefix .. "<C-t>",  noremap }
      },
      category = "@Neovim"
    },
    {
      desc = "List all highlight groups (FZF)",
      cmd = function()
        fzf.highlights({
          winopts = fzf_tweaks.winopts.narrow_small_preview
        })
      end,
      keys = { "n", "thl", noremap },
      category = "@Neovim"
    },
    {
      desc = "FZF grep cword (current directory)",
      cmd = function() fzf.grep_cword({ cwd = vim.fn.expand("%:p:h"), winopts = fzf_tweaks.winopts.std_preview_top }) end,
      keys = {
        { "n", "<C-x><CR>", noremap },
        { "i", "<C-x><CR>", noremap }
      },
      category = "@FZF"
    },
    {
      desc = "FZF grep cword (project root)",
      cmd = function()
        fzf.grep_cword({ cwd = lutils.getroot_current(), winopts = fzf_tweaks.winopts.std_preview_top })
      end,
      keys = {
        { "n", "<C-x><Backspace>", noremap },
        { "i", "<C-x><Backspace>", noremap }
      },
      category = "@FZF"
    },
    {
      desc = "FZF live grep (current directory)",
      cmd = function()
        fzf.live_grep({ query = lutils.get_selection(), cwd = vim.fn.expand("%:p:h"), winopts = fzf_tweaks.winopts.std_preview_top })
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
        fzf.live_grep({ query = lutils.get_selection(), cwd = lutils.getroot_current(), winopts = fzf_tweaks.winopts.std_preview_top })
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
      desc = "FZF find files (current directory)",
      cmd = function() fzf.files({ cwd = vim.fn.expand("%:p:h"), winopts = fzf_tweaks.winopts.big_preview_top }) end,
      keys = {
        { "i", fkeys.s_f8, noremap },
        { "n", fkeys.s_f8, noremap }
      },
      category = "@FZF"
    },
    {
      desc = "FZF files (project root)",
      cmd = function()
        fzf.files({
          cwd = lutils.getroot_current(),
          winopts = fzf_tweaks.winopts.big_preview_top
        })
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
      keys = {
        { "n", "<C-x>d", noremap },
        { "i", "<C-x>d", noremap }
      },
      category = "@LSP FZF"
    },
    {
      desc = "Run diagnostics (workspace)",
      cmd = function()
        fzf.diagnostics_workspace({ cwd = lutils.getroot_current(), winopts = fzf_tweaks.winopts.big_preview_top })
      end,
      keys = {
        { "i", vim.g.tweaks.keymap.fzf_prefix .. "<C-d>", noremap },
        { "n", vim.g.tweaks.keymap.fzf_prefix .. "<C-d>", noremap }
      },
      category = "@LSP FZF"
    },
    {
      desc = "Run diagnostics (document)",
      cmd = function()
        fzf.diagnostics_document({ winopts = fzf_tweaks.winopts.big_preview_top })
      end,
      keys = {
        { "i", vim.g.tweaks.keymap.fzf_prefix .. "d", noremap },
        { "n", vim.g.tweaks.keymap.fzf_prefix .. "d", noremap }
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
      cmd = function() fzf.lsp_document_symbols({ winopts = fzf_tweaks.winopts.std_preview_top }) end,
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
      desc = "LSP finder (FZF)",
      cmd = function()
        fzf.lsp_finder({ winopts = fzf_tweaks.winopts.std_preview_top })
      end,
      keys = {
        { "n", "<A-f>", noremap },
        { "i", "<A-f>", noremap }
      },
      category = "@LSP FZF"
    }
  }
}

M.pickeritems = {}

function M.init()
  for _,v in pairs(M.lists) do
    vim.iter(v):map(function(l)
      local pos = #M.pickeritems
      M.pickeritems[pos + 1] = {
        cat = l.category,
        cmd = l.cmd,
        desc = l.desc,
        text = l.category .. " " .. l.desc .. (type(l.cmd) == "string" and l.cmd or ""),
        keys = l.keys
      }
      -- print(l.desc .. " has " .. #l.keys .. " bindings. The type is: " .. type(l.keys))
      if type(l.keys[1]) == "string" then
        vim.g.setkey(l.keys[1], l.keys[2], l.cmd, l.desc )
      elseif type(l.keys[1]) == "table" then
        vim.iter(l.keys):map(function(w)
          -- print(vim.inspect(w))
          vim.g.setkey(w[1], w[2], l.cmd, l.desc )
        end)
      end
    end)
  end
end

function M.open()
  if #M.pickeritems == 0 then
    M.init()
  end

  local Snacks = require("snacks")
  local Align = Snacks.picker.util.align

  local oldmode = vim.fn.mode()
  return Snacks.picker({
    finder = function()
      return M.pickeritems
    end,
    focus = "input",
    -- TODO: move to setup
    layout = __Globals.gen_snacks_picker_layout( { width=120, height=25, row=5, input="bottom", prompt="Command Palette", preview=false } ),
    sort = {
      fields = {
        'cat',
        'desc'
      }
    },
    matcher = {
      match_empty = true
    },
    format = function(item)
      local e = {}
      local c = conf.columns
      local keys = ""
      if type(item.keys[1]) == "string" then
        keys = item.keys[1] .. '|' .. item.keys[2]
      elseif type(item.keys[1]) == "table" then
        vim.iter(item.keys):map(function(k)
          keys = keys .. (k[1] .. '|' .. k[2] .. ' ')
        end)
      else
        keys = "Unknown"
      end
      e[#e + 1] = { Align(lutils.truncate(item.desc, c.desc.width), c.desc.width, {align = c.desc.align or "left"}), c.desc.hl }
      e[#e + 1] = { Align(lutils.truncate(keys, c.keys.width), c.keys.width, {align = c.keys.align or "left"}), c.keys.hl }
      e[#e + 1] = { Align(type(item.cmd) == "function" and "Function" or item.cmd, c.cmd.width, {align = c.cmd.align or "left"}), c.cmd.hl }
      e[#e + 1] = { Align(item.cat, c.cat.width, {align=c.cat.align or "left"}), c.cat.hl }
      return e
    end,
    confirm = function(picker, item)
      picker:close()
      if type(item.cmd) == "function" then
        vim.schedule(function() item.cmd() end)
      elseif type(item.cmd) == "string" then
        vim.schedule(function() vim.cmd(item.cmd) end)
      end
      if oldmode == 'i' then vim.schedule(function() vim.cmd.startinsert() end) end
    end
  })
end
return M
