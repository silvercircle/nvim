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
              { nil,         "/**" },
              { nil,         " * <summary>",                           { no_results = true } },
              { nil,         " * $1",                                  { no_results = true } },
              { nil,         " * </summary>",                          { no_results = true } },
              { nil,         " * <summary>",                           {} },
              { nil,         " * $1",                                  {} },
              { nil,         " * </summary>",                          {} },
              { i.Parameter, ' * <param name="%s">$1</param>',         { type = { "func", "type" } } },
              { i.Tparam,    ' * <typeparam name="%s">$1</typeparam>', { type = { "func", "class" } } },
              { i.Return,    " * <returns>$1</returns>",               { type = { "func", "type" } } },
              { nil,         " */" }
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
      lsp = {
        auto_attach = true
      },
      icons = vim.g.lspkind_symbols,
      mappings = {
        ["<Left>"] = actions.parent(),   -- Move to left panel
        ["<Right>"] = actions.children()
      },
      window = {
        sections = {
          left = {
            size = "40%",
          },
          mid = {
            size = "30%",
          },
          right = {
            size = "30%",
            preview = "never"
          }
        }
      }
    })
  end,

  navic = function()
    require("nvim-navic").setup({
      lsp = {
        auto_attach = true
      },
      highlight = true,
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
      zindex = 100,       -- The Z-index of the context window
      on_attach = function()
        return true
      end
    }
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
    _Config_SetKey({ "n", "i" }, "<C-t>t", function() trouble.open() end, "Toggle Trouble window")
    _Config_SetKey({ "n", "i" }, "<C-t>q", function() trouble.close() end, "Toggle Trouble window")
    _Config_SetKey({ "n", "i" }, "<C-t><Down>", function() trouble.next({ skip_groups = true, jump = true }) end, "Trouble next item")
    _Config_SetKey({ "n", "i" }, "<C-t><Up>", function() trouble.previous({ skip_groups = true, jump = true }) end, "Trouble previous item")
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
  end
}

return M

