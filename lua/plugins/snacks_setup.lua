local old_mode

require("snacks").setup({
  notifier = {
    enabled = Tweaks.notifier == "snacks" and true or false,
    style = "fancy",
    top_down = false,
    refresh = 1000,
    animate = false
  },
  scratch = {
    win = {
      border = Borderfactory("thicc")
    },
    icon = "󱪗 ",
  },
  words = {
    enabled = false,
  },
  explorer = {
    replace_netrw = false,
    layout = SPL({ input = "top", width = 80, psize = 12 })
  },
  projects = {
    dev = { "/data/mnt/shared/data/", "/Media/NVIM/", "~/Downloads/Projects/" },
    patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "package.json", "Makefile", "CMakeLists.txt", "Cargo.toml", "*.nimble", "pom.xml", "settings.gradle", "*.sln", "build.zig", "go.mod", "*.gpr" }
  },
  lazygit = {
    enabled = vim.tbl_contains(Tweaks.snacks.enabled_modules, "lazygit"),
    win = {
      border = Borderfactory("thicc"),
      backdrop = Tweaks.theme.picker_backdrop
    }
  },
  image = {
    formats = { "png", "bmp", "webp", "tiff" },
    enabled = vim.tbl_contains(Tweaks.snacks.enabled_modules, "image"),
    doc = {
      enabled = true,
      inline = false,
      float = true,
    }
  },
  picker = {
    on_show = function()
      old_mode = vim.api.nvim_get_mode().mode
    end,
    on_close = function()
      if old_mode == "i" then
        vim.schedule(function() vim.api.nvim_input("i") end)
      end
    end,
    projects = {
      dev = Tweaks.snacks.dev,
      patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "package.json", "Makefile", "CMakeLists.txt", "Cargo.toml" },
    },
    treesitter = {
      filter = {
        markdown = true,
        help = true
      }
    },
    formatters = {
      file = {
        filename_first = true,
        truncate = 80
      }
    },
    matcher = {
      ignorecase = true
    },
    layout = { preset = "vertical", layout = { backdrop = Tweaks.theme.picker_backdrop, width = 120, border = Borderfactory("thicc") } },
    icons = {
      kind = CFG.lspkind_symbols
    },
    sources = {
      explorer = {
        auto_close = true,
        focus = "input",
        jump = {
          close = true
        }
      },
      buffers = {
        win = {
          input = {
            keys = {
              ["<c-d>"] = { "bufdelete", mode = { "n", "i" } }
            }
          }
        }
      }
    },
    ui_select = true,
    win = {
      input = {
        keys = {
          ["<PageDown>"] = { "list_scroll_down", mode = { "i", "n" } },
          ["<PageUp>"] = { "list_scroll_up", mode = { "i", "n" } },
          ["<A-Up>"] = { "list_top", mode = { "i", "n" } },
          ["<S-Down>"] = { "list_bottom", mode = { "i", "n" } },
          ["<A-q>"] = { "qflist", mode = { "i", "n" } },
          ["<C-Up>"] = { "preview_scroll_up", mode = { "i", "n" } },
          ["<C-Down>"] = { "preview_scroll_down", mode = { "i", "n" } }
        }
      },
      list = {
        keys = {
          ["<PageDown>"] = "list_scroll_down",
          ["<PageUp>"] = "list_scroll_up",
          ["<A-Up>"] = "list_top",
          ["<A-Down>"] = "list_bottom",
          ["<A-q>"] = { "qflist", mode = { "i", "n" } },
          ["<C-Up>"] = { "preview_scroll_up", mode = { "i", "n" } },
          ["<C-Down>"] = { "preview_scroll_down", mode = { "i", "n" } }
        },
        wo = {
          concealcursor = "nvc", signcolumn = "no", foldcolumn = "0"
        }
      },
      preview = {
        wo = {
          signcolumn = "no", foldcolumn = "0"
        }
      }
    }
  },
  input = {
    enabled = true,
    win = {
      border = Borderfactory("thicc"),
      row = -10,
      wo = {
        winhighlight = "NormalFloat:NormalFloat,FloatBorder:SnacksInputBorder,FloatTitle:FloatTitle",
      }
    }
  },
  dashboard = {
    formats = {
      key = function(item)
        return { { "[", hl = "special" }, { item.key, hl = "key" }, { "]", hl = "special" } }
      end,
    },
    sections = {
      { title = "MRU",            padding = 1 },
      { section = "recent_files", limit = 8,                            padding = 1 },
      { title = "MRU ",           file = vim.fn.fnamemodify(".", ":~"), padding = 1 },
      { section = "recent_files", cwd = true,                           limit = 8,  padding = 1 },
    },
    enabled = false
  },
  styles = {
    notification = {
      border = Borderfactory("thicc"),
      zindex = 100,
      ft = "markdown",
      title = " Notification ",
      title_pos = "center",
      wo = {
        winblend = 0,
        wrap = false,
        conceallevel = 2,
        colorcolumn = "",
      },
      bo = { filetype = "snacks_notif" }
    }
  },
  indent = {
    enabled = vim.tbl_contains(Tweaks.snacks.enabled_modules, "indent"),
    indent = {
      priority = 100,
      enabled = Tweaks.indent.enabled,
      char = "│",
      only_scope = false,   -- only show indent guides of the scope
      only_current = false, -- only show indent guides in the current window
      --hl = "IndentBlankLineChar", ---@type string|string[] hl groups for indent guides
      hl = Tweaks.indent.rainbow_guides == true and {
        "IndentBlanklineIndent1", "IndentBlanklineIndent2", "IndentBlanklineIndent3", "IndentBlanklineIndent4",
        "IndentBlanklineIndent5", "IndentBlanklineIndent6", "IndentBlanklineIndent1", "IndentBlanklineIndent2"
      } or "IndentBlankLineChar",
    },
    animate = Tweaks.indent.animate,
    scope = Tweaks.indent.scope,
    chunk = Tweaks.indent.chunk,
    blank = Tweaks.indent.blank,
    -- filter for buffers to enable indent guides
    filter = function(buf)
      return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == ""
    end
  }
})
