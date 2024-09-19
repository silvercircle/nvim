-- various setup functions for smaller plugins
local M = {}

M.setup = {
  neogen = function()
    local i = require("neogen.types.template").item
    require("neogen").setup({
      enabled = true,
      snippet_engine = "snippy",
      languages = {
        cs = {
          template = {
            annotation_convention = "xmldoccustom",
            -- override the xmldoc configuration. I prefer the /** ... */ comment syntax over ///.
            -- Both is valid xmldoc
            xmldoccustom = {
              { nil,         "/**",                                    { no_results = true, type = { "func", "file", "class", "type" } } },
              { nil,         " * <summary>",                           { no_results = true, type = { "func", "file", "class", "type" } } },
              { nil,         " * $1",                                  { no_results = true, type = { "func", "file", "class", "type" } } },
              { nil,         " * </summary>",                          { no_results = true, type = { "func", "file", "class", "type" } } },
              { nil,         " */",                                    { no_results = true, type = { "func", "file", "class", "type" } } },

              { nil,         "/**",                                    { type = { "func", "class", "type" } } },
              { nil,         " * <summary>",                           {} },
              { nil,         " * $1",                                  {} },
              { nil,         " * </summary>",                          {} },
              { i.Parameter, ' * <param name="%s">$1</param>',         { type = { "func", "type" } } },
              { i.Tparam,    ' * <typeparam name="%s">$1</typeparam>', { type = { "func", "class" } } },
              { i.Return,    " * <returns>$1</returns>",               { type = { "func", "type" } } },
              { nil,         " */",                                    { type = { "func", "class", "type" }} }
            }
          }
        },
        lua = {
          template = {
            annotation_convention = "emmylua"
          }
        }
      }
    })
  end,

  navbuddy = function()
    local actions = require("nvim-navbuddy.actions")
    require("nvim-navbuddy").setup({
      icons = vim.g.lspkind_symbols,
      mappings = {
        ["<Left>"] = actions.parent(),   -- Move to left panel
        ["<Right>"] = actions.children()
      },
      window = {
        sections = {
          left = {
            size = "33%",
          },
          mid = {
            size = "33%",
          },
          right = {
            size = "33%",
            preview = "never"
          }
        }
      }
    })
  end,

  navic = function()
    require("nvim-navic").setup({
      highlight = true,
      lazy_update_context = true,
      icons = vim.g.lspkind_symbols,
    })
  end,

  treesitter_context = function()
    require("treesitter-context").setup {
      enable = true,                  -- Enable this plugin (Can be enabled/disabled later via commands)
      max_lines = 12,                 -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 0,          -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      line_numbers = true,
      multiline_threshold = 20,       -- Maximum number of lines to show for a single context
      trim_scope = "outer",           -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      mode = "cursor",                -- Line used to calculate context. Choices: 'cursor', 'topline'
      -- Separator between context and content. Should be a single character string, like '-'.
      -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      separator = "─",
      zindex = 10,       -- The Z-index of the context window
      on_attach = function()
        return true
      end
    }
  end,

  zk = function()
    require("zk").setup({
      -- can be "telescope", "fzf", "fzf_lua", "minipick", or "select" (`vim.ui.select`)
      -- it's recommended to use "telescope", "fzf", "fzf_lua", or "minipick"
      picker = "telescope",

      lsp = {
        -- `config` is passed to `vim.lsp.start_client(config)`
        config = {
          cmd = { "zk", "lsp" },
          name = "zk",
          -- on_attach = ...
          -- etc, see `:h vim.lsp.start_client()`
        },
        -- automatically attach buffers in a zk notebook that match the given filetypes
        auto_attach = {
          enabled = true,
          filetypes = { "markdown", "liquid" },
        },
      }
    })
  end,

  ufo = function()
    require("ufo").setup({
      open_fold_hl_timeout = 0,
      --provider_selector = function(bufnr, filetype, buftype)
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
      -- fold_virt_text_handler = __Globals.ufo_virtual_text_handler,
      preview = {
        mappings = {
          scrollU = "<Up>",
          scrollD = "<Down>",
          jumpTop = "<Home>",
          jumpBot = "<End>"
        },
        win_config = {
          max_height = 30,
          border = __Globals.perm_config.telescope_borders
        }
      }
    })
  end,

  trouble = function()
    local trouble = require("trouble")
    vim.g.setkey({ "n", "i" }, "<C-t>t", function() trouble.open() end, "Toggle Trouble window")
    vim.g.setkey({ "n", "i" }, "<C-t>q", function() trouble.close() end, "Toggle Trouble window")
    vim.g.setkey({ "n", "i" }, "<C-t><Down>", function() trouble.next({ skip_groups = true, jump = true }) end, "Trouble next item")
    vim.g.setkey({ "n", "i" }, "<C-t><Up>", function() trouble.previous({ skip_groups = true, jump = true }) end, "Trouble previous item")
    require("trouble").setup({
      position = "bottom",
      height = 15,
      width = 50,
      action_keys = {
        open_tab = {}
      }
    })
    vim.cmd("hi TroubleText guibg=NONE")
    vim.cmd("hi TroubleLocation guibg=NONE")
  end,

  gitsigns = function()
    require("gitsigns").setup({
      signs = {
        add          = { text = "┃" },
        change       = { text = "┃" },
        delete       = { text = "━" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
      },
      signs_staged = {
        add          = { text = "▌" },
        change       = { text = "▌" },
        delete       = { text = "━" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
      },
      _refresh_staged_on_update = false,
      signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
      numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir = {
        interval = 2000,
        follow_files = true,
      },
      attach_to_untracked = true,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      sign_priority = 0,
      update_debounce = 1000,
      status_formatter = nil, -- Use default
      max_file_length = 40000, -- Disable if file is longer than this (in lines)
      preview_config = {
        -- Options passed to nvim_open_win
        border = "single", -- __Globals.perm_config.telescope_borders,

        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1
      }
      --yadm = {
      --  enable = false,
      --},
    })
  end,

  toggleterm = function()
    require("toggleterm").setup({
      highlights = {
        NormalFloat = {
          link = "NeoTreeNormalNC"
        },
        FloatBorder = {
          link = "TelescopeBorder"
        }
      }
    })
  end,

  -- currently not in use
  conform = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        cs = { "astyle" },
        -- Conform will run multiple formatters sequentially
        python = { "isort", "black" },
        -- Use a sub-list to run only the first available formatter
        javascript = { { "prettierd", "prettier" } },
      },
      formatters = {
        astyle = {
          prepend_args = { "--project=.astylerc" }
        }
      }
    })
  end,

  orgmode = function()
    require('orgmode').setup_ts_grammar()
    require("orgmode").setup({
      org_agenda_files = '~/orgfiles/**/*',
      org_default_notes_file = '~/orgfiles/refile.org'
    })
  end,

  cabinet = function()
    require("cabinet"):setup()
  end,

  mini_extra = function()
    require("mini.extra").setup()
  end,

  mini_files = function()
    require("mini.files").setup({
      windows = {
        preview = true,
        width_preview = 50
      }
    })
  end,

  mini_pick = function()
    require("mini.pick").setup()
  end,

  fidget = function()
    __Globals.notifier = require("fidget").notify
    vim.notify = require("fidget").notify
    require("fidget").setup({
      progress = {
        poll_rate = 1,
        ignore_done_already = true,
        ignore_empty_message = true,
        display = {
          render_limit = 4,
          skip_history = false
        }
      },
      notification = {
        override_vim_notify = true,
        history_size = 50,
        filter = vim.log.levels.TRACE,
        configs = {
          --default = require("fidget.notification").default_config
        },
        window = {
          winblend = 0,
          normal_hl = "NormalFloat",
          border = "single"
        }
      }
    })
  end
}

return M

