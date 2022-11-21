-- packer.nvim example
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'

-- vim.api.nvim_command 'packadd packer.nvim'

require('editorconfig').properties.foo = function(bufnr, val)
  vim.b[bufnr].foo = val
end

--[[
--count words in either the entire document or the current visual mode
--selection. This is for a custom lualine section (see below)
--]]
local function getWordsV2()
    local wc = vim.api.nvim_eval("wordcount()")
    if wc["visual_words"] then    -- text is selected in visual mode
        return wc["visual_words"] .. ' Words (Selection)'
    else                          -- all of the document
        return wc["words"] .. ' Words'
    end
end

local telescope_actions = require("telescope.actions.set")

--[[
--the following two functions are helpers for Telescope to workaround a bug
--with creating/restoring view via autocmd when picking files via telescope.
--]]
local function stopinsert(callback)
  return function(prompt_bufnr)
    vim.cmd.stopinsert()
    vim.schedule(function() callback(prompt_bufnr) end)
  end
end

local function stopinsert_fb(callback, callback_dir)
  return function(prompt_bufnr)
    local entry = require'telescope.actions.state'.get_selected_entry()
    if entry and not entry.Path:is_dir() then
      stopinsert(callback)(prompt_bufnr)
    elseif callback_dir then
      callback_dir(prompt_bufnr)
    end
  end
end

local actions = require'telescope.actions'
local actions_fb = require'telescope'.extensions.file_browser.actions

require'telescope'.setup {
  defaults = {
    layout_config = {
        width = 0.9,
        height = 0.6,
    },
    color_devicons = true,
    disable_devicons = false,
    mappings = {
      i = {
        ["<CR>"]  = stopinsert(actions.select_default),
        ["<C-x>"] = stopinsert(actions.select_horizontal),
        ["<C-v>"] = stopinsert(actions.select_vertical),
        ["<C-t>"] = stopinsert(actions.select_tab)
      }
    }
  },
  extensions = {
    file_browser = {
      mappings = {
        i = {
          ["<CR>"]  = stopinsert_fb(actions.select_default, actions.select_default),
          ["<C-x>"] = stopinsert_fb(actions.select_horizontal),
          ["<C-v>"] = stopinsert_fb(actions.select_vertical),
          ["<C-t>"] = stopinsert_fb(actions.select_tab, actions_fb.change_cwd)
        }
      }
    },
    coc = {
        layout_config = {
          width=0.5,
          height=0.5
        },
        theme = 'ivy',
        prefer_locations = true, -- always use Telescope locations to preview definitions/declarations/implementations etc
    }
  }
}

-- To get telescope-file-browser loaded and working with telescope,
-- you need to call load_extension, somewhere after setup function:
require("telescope").load_extension("file_browser")
require('telescope').load_extension('coc')
require('telescope').load_extension("vim_bookmarks")
require'telescope'.load_extension('project')

-- TabLine

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'my_powerline',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
      tabline = {'coctree', 'nerdtree'}
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 2000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode', 'o:formatoptions'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {{ getWordsV2 },'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
    lualine_a = { {'buffers', mode=2, filetype_names = {coctree='C'}}},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {'tabs'}
  },
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
require("nvim-autopairs").setup {}
require("scrollbar").setup()


require('gitsigns').setup {
  signs = {
    add          = { hl = 'GitSignsAdd'   , text = '│', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'    },
    change       = { hl = 'GitSignsChange', text = '│', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn' },
    delete       = { hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn' },
    topdelete    = { hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn' },
    changedelete = { hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn' },
    untracked    = { hl = 'GitSignsAdd'   , text = '┆', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'    },
  },
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    interval = 2000,
    follow_files = true
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
  yadm = {
    enable = false
  },
}

-- use("williamboman/nvim-lsp-installer")
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "bash",
    "c",
    "cpp",
    "css",
    "c_sharp",
    "cmake",
    "elixir",
    "fish",
    "graphql",
    "go",
    "html",
    "java",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "php",
    "python",
    "regex",
    "ruby",
    "rust",
    "scss",
    "sql",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "yaml",
  },
  playground = {
              enable = true,
              disable = {},
              updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
              persist_queries = false, -- Whether the query persists across vim sessions
              keybindings = {
              toggle_query_editor = 'o',
              toggle_hl_groups = 'i',
              toggle_injected_languages = 't',
              toggle_anonymous_nodes = 'a',
              toggle_language_display = 'I',
              focus_language = 'f',
              unfocus_language = 'F',
              update = 'R',
              goto_node = '<cr>',
              show_help = '?',
            },
  },
  rainbow = {
    enable = true,
--        colors = {
--            "#cc241d",
--            "#a89984",
--            "#b16286",
--            "#d79921",
--            "#689d6a",
--            "#d65d0e",
--            "#cc241d",
--        },
        colors = {
            "#cc241d",
            "#cc241d",
            "#cc241d",
            "#cc241d",
            "#cc241d",
            "#d65d0e",
            "#cc241d",
        },
--        termcolors = {
--            "Red",
--            "Green",
--            "Yellow",
--            "Blue",
--            "Magenta",
--            "Cyan",
--            "Red",
         termcolors = {
            "Red",
            "Red",
            "Red",
            "Red",
            "Magenta",
            "Red",
            "Red",
    },

    -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = 50000, -- Do not enable for files with more than n lines, int
    -- colors = {}, -- table of hex strings
    -- termcolors = {} -- table of colour name strings
  },
  highlight = { enable = true },
  indent = { enable = true },
  autotag = {
  enable = true,
  filetypes = {
    "html",
    "javascript",
    "javascriptreact",
    "svelte",
    "typescript",
    "typescriptreact",
    "vue",
    "xml",
  },
  },
})

-- devicons for lua plugins (e.g. Telescope needs them)
require'nvim-web-devicons'.setup {
 -- your personnal icons can go here (to override)
 -- you can specify color or cterm_color instead of specifying both of them
 -- DevIcon will be appended to `name`
 override = {
  zsh = {
    icon = "",
    color = "#428850",
    cterm_color = "65",
    name = "Zsh"
  }
 };
 -- globally enable different highlight colors per icon (default to true)
 -- if set to false all icons will have the default icon's color
 color_icons = true;
 -- globally enable default icons (default to false)
 -- will get overriden by `get_icons` option
 default = true;
}
require'colorizer'.setup()
require'alpha'.setup(require'alpha.themes.startify'.config)

