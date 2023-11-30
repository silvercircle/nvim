-- setup telescope
local actions = require("telescope.actions")
local actionset = require("telescope.actions.set")
local actionstate = require("telescope.actions.state")
-- local actions_fb = require("telescope").extensions.file_browser.actions
-- local themes = require("telescope.themes")

-- add all the commands and mappings to the command_center plugin.
-- since this is a lot of code, it's outsourced but really belongs here.
local command_center = require('command_center')

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
    borderchars = __Globals.perm_config.telescope_borders == "squared" and { '─', '│', '─', '│', '┌', '┐', '┘', '└'} or { '─', '│', '─', '│', '╭', '╮', '╯', '╰'},
    color_devicons = true,
    disable_devicons = false,
    mappings = {
      i = {
        ["<CR>"] = stopinsert_ins(actions.select_default),
        ["<C-x>"] = stopinsert(actions.select_horizontal),
        ["<C-v>"] = stopinsert(actions.select_vertical),
        ["<C-t>"] = stopinsert(actions.select_tab),
        -- remap C-Up and C-Down to scroll the previewer by one line
        ["<C-Up>"] = function(prompt_bufnr) actionset.scroll_previewer(prompt_bufnr, -1) end,
        ["<C-Down>"] = function(prompt_bufnr) actionset.scroll_previewer(prompt_bufnr, 1) end,
        ['<C-c>'] = function(prompt_bufnr) close_insertmode(prompt_bufnr) end
      },
      n = {
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
--        command_center.component.CMD,
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
-- require("telescope").load_extension("file_browser")
require("telescope").load_extension("vim_bookmarks")
require("telescope").load_extension("fzf")

