require("snacks").setup({
  notifier = {
    enabled = vim.g.tweaks.notifier == "snacks" and true or false,
  },
  explorer = {
    replace_netrw = false
  },
  picker = {
    layout = { preset = "vertical", preview = false, layout = {width=80, border = vim.g.tweaks.borderfactory("double")} },
    sources = {
      explorer = {
        auto_close = true,
        focus = "input",
        jump = {
          close = true
        }
      }
    },
    ui_select = false,
    win = {
      input = {
        keys = {
          ["<PageDown>"] = "list_scroll_down",
          ["<PageUp>"] = "list_scroll_up",
          ["<Home>"] = "list_top",
          ["<End>"] = "list_bottom",
        }
      },
      list = {
        keys = {
          ["<PageDown>"] = "list_scroll_down",
          ["<PageUp>"] = "list_scroll_up",
          ["<Home>"] = "list_top",
          ["<End>"] = "list_bottom",
        },
        wo = {
          concealcursor = "nvc"
        }
      }
    }
  },
  input = {
    enabled = true
  },
  indent = {
    indent = {
      priority = 1,
      enabled = true,             --vim.g.tweaks.indent.version == "snacks" and true or false,   -- enable indent guides
      char = "│",
      only_scope = false,         -- only show indent guides of the scope
      only_current = false,       -- only show indent guides in the current window
      --hl = "IndentBlankLineChar", ---@type string|string[] hl groups for indent guides
      hl = {
        "IndentBlanklineIndent1", "IndentBlanklineIndent2", "IndentBlanklineIndent3", "IndentBlanklineIndent4",
        "IndentBlanklineIndent5", "IndentBlanklineIndent6", "IndentBlanklineIndent1", "IndentBlanklineIndent2"
      },
    },
    animate = {
      enabled = false,
      style = "out",
      easing = "linear",
      duration = {
        step = 10,         -- ms per step
        total = 100,       -- maximum duration
      },
    },
    scope = {
      enabled = true,       -- enable highlighting the current scope
      priority = 200,
      char = "┃",
      underline = false,          -- underline the start of the scope
      only_current = false,       -- only show scope in the current window
      hl = "Brown", ---@type string|string[] hl group for scopes
    },
    chunk = {
      -- when enabled, scopes will be rendered as chunks, except for the
      -- top-level scope which will be rendered as a scope.
      enabled = false,
      -- only show chunk scopes in the current window
      only_current = false,
      priority = 200,
      hl = "SnacksIndentChunk", ---@type string|string[] hl group for chunk scopes
      char = {
        corner_top = "┌",
        corner_bottom = "└",
        -- corner_top = "╭",
        -- corner_bottom = "╰",
        horizontal = "─",
        vertical = "│",
        arrow = ">",
      }
    },
    blank = {
      char = " ",
      -- char = "·",
      hl = "SnacksIndentBlank", ---@type string|string[] hl group for blank spaces
    },
    -- filter for buffers to enable indent guides
    filter = function(buf)
      return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == ""
    end
  }
})
