-- setup command center mappings. Outsourced from setup_telescope.lua
-- this contains only basic mappings. Telescope mappings are outsourced to
-- setup_telescope and fzf-lua mappings to fzf-lua respectively.
local command_center = require("command_center")
local noremap = { noremap = true }
local lsputil = require("lsp.utils")
local Utils = require("subspace.lib")
local _tb = require("telescope.builtin")
local Terminal  = require('toggleterm.terminal').Terminal

local fkeys = vim.g.fkeys
--local bm = require("bookmarks")

command_center.add({
  {
    desc = "Show notification history",
    --cmd = function() bm.bookmark_clean() end,
    cmd = function() Utils.notification_history() end,
    keys = {
      { "n", Tweaks.keymap.utility_key .. "<C-n>", noremap },
      { "i", Tweaks.keymap.utility_key .. "<C-n>", noremap }
    },
    category = "@Notifications"
  },
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
      require("plugins.bookmarkspicker").open({layout = layout})
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
  {
    desc = "Mini document treesitter view",
    cmd = function()
      _tb.treesitter(__Telescope_vertical_dropdown_theme({
        prompt_prefix = Utils.getTelescopePromptPrefix(),
        layout_config = CFG.minipicker_layout
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
    cmd = function() Utils.StopLsp() end,
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
    cmd = function() vim.diagnostic.jump({ count = 1, float = true }) end,
    keys = { "n", "DN", noremap },
    category = "@LSP Diagnostics"
  },
  {
    desc = "Go to previous diagnostic",
    cmd = function() vim.diagnostic.jump({ count = -1, float = true }) end,
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
      local lazygit = Terminal:new({ cmd = "lazygit",
        direction = "float",
        dir = path,
        -- refresh neo-tree display to reflect changes in git status
        -- TODO: implement for nvim-tree?
        on_close = function()
          if Tweaks.tree.version == "Neo" then
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
    desc = "View Markdown in GUI viewer (" .. Tweaks.mdguiviewer .. ")",
    cmd = function()
      local path = vim.fn.expand("%:p")
      local cmd = "silent !" .. Tweaks.mdguiviewer ..  " '" .. path .. "' &"
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
    desc = "View LaTeX result (" .. Tweaks.texviewer .. ")",
    cmd = Utils.view_latex(),
    keys = { -- shift-f9
      { "n", fkeys.s_f9, noremap },
      { "i", fkeys.s_f9, noremap },
    },
    category = "@LaTeX"
  },
  {
    -- recompile the .tex document using lualatex
    desc = "Recompile LaTeX document",
    cmd = Utils.compile_latex(),
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
    cmd = function() _tb.tags(__Telescope_vertical_dropdown_theme({ prompt_title = "Tags list", cwd = Utils.getroot_current() })) end,
    keys = { "n", "<leader>t", },
    category = "@Telescope"
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
    cmd = function() CGLOBALS.toggle_autocomplete() end,
    keys = {
      { "n", "<leader>ca", noremap },
    },
    category = "@Setup"
  },
  {
    desc = "Command history (FZF)",
    cmd = function() require("snacks").picker.command_history( { layout = SPL( {input="top", width=140, height = 0.7, row = 7, preview = false } ) } ) end,
    keys = { "n", "<A-C>", noremap },
    category = "@FZF"
  },
  {
    desc = "Command list (FZF)",
    cmd = function() require("snacks").picker.commands( { layout = SPL( {input="top", width=80, height = 0.8, row = 7, preview = false } ) } ) end,
    keys = { "n", "<A-c>", noremap },
    category = "@FZF"
  }
})

