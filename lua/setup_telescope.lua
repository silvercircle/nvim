-- setup telescope
local actions = require("telescope.actions")
local actions_fb = require("telescope").extensions.file_browser.actions
local themes = require("telescope.themes")

-- add all the commands and mappings to the command_center plugin.
require('setup_command_center')

-- private modified version of the dropdown theme with a square border
Telescope_dropdown_theme = function(opts)
  return themes.get_dropdown({
    borderchars = {
      prompt = {"─", "│", " ", "│", '┌', '┐', "│", "│"},
      results = {"─", "│", "─", "│", "├", "┤", "┘", "└"},
      preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
    },
    layout_config = {
      width = opts.width,
      height = opts.height
    },
    winblend = vim.g.float_winblend,
    prompt_title = opts.title ~= nil and opts.title or 'Prompt',
    previewer = false,
    sort_lastused = opts.sort_lastused,
    sort_mru = opts.sort_mru,
    ignore_current_buffer=opts.ignore_current_buffer,
    show_all_buffers=opts.show_all_buffers
  })
end

-- and one with a preview (currently unused)
Telescope_preview_dropdown_theme = function(opts)
  return themes.get_dropdown({
    borderchars = {
      prompt = {"─", "│", " ", "│", '┌', '┐', "│", "│"},
      results = {"─", "│", "─", "│", "├", "┤", "┘", "└"},
      preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
    },
    layout_config = {
      width = opts.width,
      height = opts.height,
      preview_height=0.5
    },
    winblend = vim.g.float_winblend,
    prompt_title = opts.title ~= nil and opts.title or 'Prompt',
    sort_lastused = true
  })
end

-- custom theme for the command_center Telescope plugin
-- reason: I have square borders everywhere
local function command_center_theme(opts)
  opts = opts or {}
  local theme_opts = {
    theme = "command_center",
    results_title = false,
    sorting_strategy = "ascending",
    layout_strategy = "center",
    layout_config = {
      preview_cutoff = 0,
      anchor = "N",
      prompt_position = "top",
      width = function(_, max_columns, _)
        return math.min(max_columns, opts.max_width)
      end,
      height = function(_, _, max_lines)
        -- Max 20 lines, smaller if have less than 20 entries in total
        return math.min(max_lines, opts.num_items + 4, 20)
      end,
    },
    border = true,
    borderchars = {
      prompt = {"─", "│", " ", "│", '┌', '┐', "│", "│"},
      results = {"─", "│", "─", "│", "├", "┤", "┘", "└"},
      preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
    },
  }
  return vim.tbl_deep_extend("force", theme_opts, opts)
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

local function stopinsert_fb(callback, callback_dir)
  return function(prompt_bufnr)
    local entry = require("telescope.actions.state").get_selected_entry()
    if entry and not entry.Path:is_dir() then
      stopinsert(callback)(prompt_bufnr)
    elseif callback_dir then
      callback_dir(prompt_bufnr)
    end
  end
end

require("telescope").setup({
  defaults = {
    layout_config = {
      width = 0.9,
      height = 0.6
    },
    winblend = vim.g.float_winblend,
    -- square borders (just to be consistend with other UI elements like CMP)
    borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
    color_devicons = true,
    disable_devicons = false,
    mappings = {
      i = {
        ["<CR>"] = stopinsert(actions.select_default),
        ["<C-x>"] = stopinsert(actions.select_horizontal),
        ["<C-v>"] = stopinsert(actions.select_vertical),
        ["<C-t>"] = stopinsert(actions.select_tab),
      },
    },
  },
  pickers = {
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
    }
  },
  extensions = {
    -- command center is a command palette plugin. Pretty much like Ctrl-P in sublime text
    -- the actual commands are setup in setup_command_center.lua
    command_center = {
    -- Specify what components are shown in telescope prompt;
    -- Order matters, and components may repeat
      components = {
        Command_center.component.DESC,
        Command_center.component.KEYS,
        Command_center.component.CMD,
        Command_center.component.CATEGORY,
      },
      -- Spcify by what components the commands is sorted
      -- Order does not matter
      sort_by = {
        Command_center.component.DESC,
        Command_center.component.KEYS,
        Command_center.component.CMD,
        Command_center.component.CATEGORY,
      },
      -- Change the separator used to separate each component
      separator = " ",
      -- When set to false,
      -- The description component will be empty if it is not specified
      auto_replace_desc_with_cmd = true,
      -- Default title to Telescope prompt
      prompt_title = "Command Palette",
        -- can be any builtin or custom telescope theme
      theme = command_center_theme
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
    file_browser = {
      mappings = {
        i = {
          ["<CR>"] = stopinsert_fb(actions.select_default, actions.select_default),
          ["<C-x>"] = stopinsert_fb(actions.select_horizontal),
          ["<C-v>"] = stopinsert_fb(actions.select_vertical),
          ["<C-t>"] = stopinsert_fb(actions.select_tab, actions_fb.change_cwd),
        },
      },
    },
  },
})
-- finally, load the extensions
require("telescope").load_extension("file_browser")
require("telescope").load_extension("vim_bookmarks")
require("telescope").load_extension("fzf")
require("telescope").load_extension("command_center")

