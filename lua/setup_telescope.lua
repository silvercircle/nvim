-- setup telescope
local actions = require("telescope.actions")
local actions_fb = require("telescope").extensions.file_browser.actions
local command_center = require("command_center")
local noremap = {noremap = true}
local silent_noremap = {noremap = true, silent = true}

-- private modified version of the dropdown theme
-- with a square border
Telescope_dropdown_theme = function(opts)
  return require('telescope.themes').get_dropdown({
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
    sort_lastused = true
  })
end

Telescope_preview_dropdown_theme = function(opts)
  return require('telescope.themes').get_dropdown({
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

command_center.add({
  {
    desc = "Search inside current buffer",
    cmd = "<CMD>Telescope current_buffer_fuzzy_find<CR>",
    keys = { "n", "<leader>fl", noremap },
  },  {
    -- If no descirption is specified, cmd is used to replace descirption by default
    -- You can change this behavior in setup()
    cmd = "<CMD>Telescope find_files<CR>",
    keys = { "n", "<leader>ff", noremap },
  }, {
    -- If no keys are specified, no keymaps will be displayed nor set
    desc = "Find hidden files",
    cmd = "<CMD>Telescope find_files hidden=true<CR>",
  }, {
    -- You can specify multiple keys for the same cmd ...
    desc = "Show document symbols",
    cmd = "<CMD>Telescope lsp_document_symbols<CR>",
    keys = {
      {"n", "<leader>ss", noremap},
      {"n", "<leader>ssd", noremap},
    },
  }, {
    -- ... and for different modes
    desc = "Show function signaure (hover)",
    cmd = "<CMD>lua vim.lsp.buf.hover()<CR>",
    keys = {
      {"n", "K", silent_noremap },
      {"i", "<C-k>", silent_noremap },
    }
  }, {
    -- You can pass in a key sequences as if you would type them in nvim
    desc = "My favorite key sequence",
    cmd = "A  -- Add a comment at the end of a line",
    keys = {"n", "<leader>Ac", noremap}
  }, {
    -- You can also pass in a lua functions as cmd
    -- NOTE: binding lua funciton to a keymap requires nvim 0.7 and above
    desc = "Run lua function",
    cmd = function() print("ANONYMOUS LUA FUNCTION") end,
    keys = {"n", "<leader>alf", noremap},
  }
})

--the following two functions are helpers for Telescope to workaround a bug
--with creating/restoring views via autocmd when picking files via telescope.
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
    command_center = {
    -- Specify what components are shown in telescope prompt;
    -- Order matters, and components may repeat
      components = {
        command_center.component.DESC,
        command_center.component.KEYS,
        command_center.component.CMD,
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
      -- The description compoenent will be empty if it is not specified
      auto_replace_desc_with_cmd = true,
      -- Default title to Telescope prompt
      prompt_title = "Command Center",
        -- can be any builtin or custom telescope theme
      theme = require("telescope.themes").ivy,
    },
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
    media_files = {
      -- filetypes whitelist
      -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
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

-- To get telescope-file-browser loaded and working with telescope,
-- you need to call load_extension, somewhere after setup function:
require("telescope").load_extension("file_browser")
require("telescope").load_extension("vim_bookmarks")
require("telescope").load_extension("fzf")
-- require('telescope').load_extension('command_palette')
require("telescope").load_extension("command_center")

