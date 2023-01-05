-- setup telescope
local actions = require("telescope.actions")
local actions_fb = require("telescope").extensions.file_browser.actions

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
    command_palette = {
      -- TODO: this needs lots of customization (outsource to external file?)
      {"File",
        { "entire selection (C-a)", ':call feedkeys("GVgg")' },
        { "save current file (C-s)", ':w' },
        { "save all files (C-A-s)", ':wa' },
        { "quit (C-q)", ':qa' },
        { "file browser (C-i)", ":lua require'telescope'.extensions.file_browser.file_browser()", 1 },
        { "search word (A-w)", ":lua require('telescope.builtin').live_grep()", 1 },
        { "git files (A-f)", ":lua require('telescope.builtin').git_files()", 1 },
        { "files (C-f)",     ":lua require('telescope.builtin').find_files()", 1 },
      },
      {"Help",
        { "tips", ":help tips" },
        { "cheatsheet", ":help index" },
        { "tutorial", ":help tutor" },
        { "summary", ":help summary" },
        { "quick reference", ":help quickref" },
        { "search help(F1)", ":lua require('telescope.builtin').help_tags()", 1 },
      },
      {"Vim",
        { "reload vimrc", ":source $MYVIMRC" },
        { 'check health', ":checkhealth" },
        { "jumps (Alt-j)", ":lua require('telescope.builtin').jumplist()" },
        { "commands", ":lua require('telescope.builtin').commands()" },
        { "command history", ":lua require('telescope.builtin').command_history()" },
        { "registers (A-e)", ":lua require('telescope.builtin').registers()" },
        { "colorshceme", ":lua require('telescope.builtin').colorscheme()", 1 },
        { "vim options", ":lua require('telescope.builtin').vim_options()" },
        { "keymaps", ":lua require('telescope.builtin').keymaps()" },
        { "buffers", ":Telescope buffers" },
        { "search history (C-h)", ":lua require('telescope.builtin').search_history()" },
        { "paste mode", ':set paste!' },
        { 'cursor line', ':set cursorline!' },
        { 'cursor column', ':set cursorcolumn!' },
        { "spell checker", ':set spell!' },
        { "relative number", ':set relativenumber!' },
        { "search highlighting (F12)", ':set hlsearch!' },
      }
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
require('telescope').load_extension('command_palette')

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
