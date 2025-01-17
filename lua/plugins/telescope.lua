-- setup telescope
local actions = require("telescope.actions")
local actionset = require("telescope.actions.set")
local actionstate = require("telescope.actions.state")
local trouble = require("trouble.sources.telescope")

-- local actions_fb = require("telescope").extensions.file_browser.actions
-- local themes = require("telescope.themes")

-- add all the commands and mappings to the command_center plugin.
-- since this is a lot of code, it's outsourced but really belongs here.
local command_center = require('command_center')

-- ensure a valid border style and set a default in case none is found
if vim.tbl_contains( { "single", "rounded", "none", "thicc" }, __Globals.perm_config.telescope_borders) ~= true then
  __Globals.perm_config.telescope_borders = "single"
end

-- the following two functions are helpers for Telescope to workaround a bug
-- with creating/restoring views via autocmd when picking files via telescope.
-- the problem affects file browser, buffer list and the „oldfiles“ picker. Maybe 
-- others too.
-- Reference: https://github.com/nvim-telescope/telescope.nvim/issues/559
local function stopinsert(callback)
  return function(prompt_bufnr)
    vim.cmd.stopinsert()
    vim.schedule(function()
      callback(prompt_bufnr)
    end)
  end
end

-- same as above, but for the file browser extension
--local function stopinsert_fb(callback, callback_dir)
--  return function(prompt_bufnr)
--    local entry = require("telescope.actions.state").get_selected_entry()
--    if entry and not entry.Path:is_dir() then
--      stopinsert(callback)(prompt_bufnr)
--    elseif callback_dir then
--      callback_dir(prompt_bufnr)
--    end
--  end
--end

--- very ugly hack. Basically the same as above: Allow restoring of views (loadview) when selecting
--- files from a telescope picker.
--- This however, keeps the editor in insert mode if the picker was launched from insert mode with
--- "#>" as prompt_prefix
--- TODO: find a better, less hack-ish way.
local function stopinsert_ins(callback)
  return function(prompt_bufnr)
    local current = actionstate.get_current_picker(prompt_bufnr)
    vim.cmd.stopinsert()
    vim.schedule(function()
      callback(prompt_bufnr)
    end)
    if current.prompt_prefix == Config.minipicker_iprefix then
      vim.schedule(function() vim.api.nvim_input("i") end)
    end
    vim.schedule(function() vim.api.nvim_input("<Left>") end)
  end
end

local function close_insertmode(prompt_bufnr)
  local current = actionstate.get_current_picker(prompt_bufnr)
  actions.close(prompt_bufnr)
  if current.prompt_prefix == Config.minipicker_iprefix then
    vim.api.nvim_input("i")
  end
end

local function select_insertmode(prompt_bufnr)
  local current = actionstate.get_current_picker(prompt_bufnr)
  if current.prompt_prefix == "@>" then
    vim.api.nvim_input("i")
  end
  stopinsert(actions.select_default(prompt_bufnr))
end

local _borderchars = {
  single =  { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
  rounded = { '─', '│', '─', '│', '╭', '╮', '╯', '╰'},
  none    = { " ", " ", " ", " ", " ", " ", " ", " "},
  thicc   = { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗"}
}

require("telescope").setup({
  defaults = {
    layout_config = {
      width = 0.9,
      height = 0.6,
      scroll_speed = 4
    },
    scroll_strategy = 'limit',
    winblend = vim.g.float_winblend,
    -- square borders (just to be consistend with other UI elements like CMP)
    borderchars = _borderchars[__Globals.perm_config.telescope_borders],
    color_devicons = true,
    disable_devicons = false,
    mappings = {
      i = {
        ["<C-t>"] = trouble.open,
        ["<CR>"] = stopinsert_ins(actions.select_default),
        ["<C-x>"] = stopinsert(actions.select_horizontal),
        ["<C-v>"] = stopinsert(actions.select_vertical),
        ["<A-t>"] = stopinsert(actions.select_tab),
        ["<A-Up>"] = actions.cycle_history_prev,
        ["<A-Down>"] = actions.cycle_history_next,

        -- remap C-Up and C-Down to scroll the previewer by one line
        ["<C-Up>"] = function(prompt_bufnr) actionset.scroll_previewer(prompt_bufnr, -1) end,
        ["<C-Down>"] = function(prompt_bufnr) actionset.scroll_previewer(prompt_bufnr, 1) end,
        ['<C-c>'] = function(prompt_bufnr) close_insertmode(prompt_bufnr) end
      },
      n = {
        ["<c-t>"] = trouble.open,
        ['<esc>'] = function(prompt_bufnr) close_insertmode(prompt_bufnr) end
      }
    }
  },
  pickers = {
    find_files = {
      find_command = { "rg", "--ignore", "-L", "--hidden", "--files", "-g", "!.git/objects/" }
    },
    buffers = {
      -- implement Ctrl-d to close a buffer directly from the buffer list without closing the list itself.
      -- works in both normal and insert modes.
      mappings = {
        n = {
          ['<c-d>'] = actions.delete_buffer
        },
        i = {
          ['<c-d>'] = actions.delete_buffer
        },
      }
    },
    command_center = {
      mappings = {
        i = {
          ["<CR>"] = function(prompt_bufnr) select_insertmode(prompt_bufnr) end
        }
      }
    }
  },
  extensions = {
    aerial = {
      -- Display symbols as <root>.<parent>.<symbol>
      show_nesting = {
        ["_"] = false, -- This key will be the default
        json = true, -- You can set the option for specific filetypes
        yaml = true,
        scala = true
      },
    },
    -- command center is a command palette plugin. Pretty much like Ctrl-P in sublime text
    -- the actual commands are setup in setup_command_center.lua
    command_center = {
    -- Specify what components are shown in telescope prompt;
    -- Order matters, and components may repeat
      components = {
        command_center.component.DESC,
        command_center.component.KEYS,
        -- command_center.component.CMD,
        command_center.component.CATEGORY,
      },
      -- Spcify by what components the commands is sorted
      -- Order does not matter
      sort_by = {
        command_center.component.DESC,
        command_center.component.KEYS,
        command_center.component.CMD,
        command_center.component.CATEGORY,
      },
      -- Change the separator used to separate each component
      separator = " ",
      -- When set to false,
      -- The description component will be empty if it is not specified
      auto_replace_desc_with_cmd = true,
      -- Default title to Telescope prompt
      prompt_title = "Command Palette",
        -- can be any builtin or custom telescope theme
      theme = require("local_utils").command_center_theme
    },
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
    media_files = {
      filetypes = { "png", "webp", "jpg", "jpeg" },
      find_cmd = "rg", -- find command (defaults to `fd`)
    },
--    file_browser = {
--      mappings = {
--        i = {
--          ["<CR>"] = stopinsert_fb(actions.select_default, actions.select_default),
--          ["<C-x>"] = stopinsert_fb(actions.select_horizontal),
--          ["<C-v>"] = stopinsert_fb(actions.select_vertical),
--          ["<C-t>"] = stopinsert_fb(actions.select_tab, actions_fb.change_cwd),
--        },
--      },
--    },
  },
})
-- finally, load the extensions
require("telescope").load_extension("bookmarks")
require("telescope").load_extension("fzf")
--require("telescope").load_extension("ascii")
--require("telescope").load_extension("noice")

local noremap  = { noremap = true }
local lsputil  = require("lspconfig.util")
local lutils   = require("local_utils")
local _t       = require("telescope")
local _tb      = require("telescope.builtin")
local fkeys    = vim.g.fkeys

if vim.g.tweaks.fzf.enable_keys == false then
  -- Telescope pickers
  command_center.add({
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
    desc = "Spell suggestions",
    cmd = function() _tb.spell_suggest(__Telescope_dropdown_theme { prompt_prefix = lutils.getTelescopePromptPrefix(), title = "Spell suggestions", height = 0.5, width = 0.2 }) end,
    keys = {
      { "n", "<A-s>", noremap },
      { "i", "<A-s>", noremap }
    },
    category = "@Telescope"
  },
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
    desc = "Todo list (project root)",
    cmd = function()
      require("telescope._extensions.todo-comments").exports.todo(__Telescope_vertical_dropdown_theme({
        layout_config = { width = 120 }, prompt_title = "Todo comments (project root)", cwd = lutils.getroot_current(), hidden = true }))
    end,
    keys = { "n", "tdp", noremap },
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
    desc = "Registers (Telescope)",
    cmd = function() _tb.registers(__Telescope_dropdown_theme { prompt_prefix = lutils.getTelescopePromptPrefix() }) end,
    keys = {
      { "i", "<C-x><C-r>", noremap },
      { "n", "<C-x><C-r>", noremap }
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
  }})
end
-- GIT
if vim.g.tweaks.fzf.prefer_for.git == false then
  command_center.add({
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
    }
  })
end
if vim.g.tweaks.fzf.prefer_for.lsp == false then
  command_center.add({
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
    }
  })
end
if vim.g.tweaks.notifier == 'fidget' then
  require("plugins.fidgethistory").setup({
    telescope = {
      theme = __Telescope_vertical_dropdown_theme,
      layout_config = Config.telescope_vertical_preview_layout
    },
    hl = {
      preview_header = "Brown",
      timestamp      = "Orange",
      title          = "Teal"
    }
  })
end
