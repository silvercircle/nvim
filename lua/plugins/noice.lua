 require("noice").setup({
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
    },
    progress = { enabled = true },
    hover = { enabled = false },
    signature = { enabled = false },
  },
  cmdline = {
    enabled = true,
  },
  messages = {
    -- NOTE: If you enable messages, then the cmdline is enabled automatically.
    -- This is a current Neovim limitation.
    enabled = true, -- enables the Noice messages UI
    view = "cmdline", -- default view for messages
    view_error = "notify", -- view for errors
    view_warn = "notify", -- view for warnings
    view_history = "messages", -- view for :messages
    view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
  },
  routes = {
    {
      filter = {
        event = "msg_show",
        kind = "search_count",
      },
      opts = { skip = true },
    },
  },
  views = {
    notify = {
      opts = { merge = true, animate = false },
    },
    popup = {
      size = { height = "auto", width = "80%" },
    },
    messages = {
      position = "top",
      relative = "editor",
      size = { width = "auto", height = "auto" },
    },
    cmdline_popup = {
      position = {
        row = 20,
        col = "50%",
      },
      size = {
        width = "auto",
        height = "auto",
      },
    },
    popupmenu = {
      relative = "editor",
      position = {
        row = 23,
        col = "50%",
      },
      size = {
        width = 80,
        height = "auto",
      },
      border = {
        style = "rounded",
        padding = { 0, 1 },
      },
      win_options = {
        winhighlight = { Normal = "Normal", FloatBorder = "FloatBorder" },
      },
    },
    mini = {
      timeout = 4000,
    },
    cmdline = {
      timeout = 5000,
      close = {
        keys = { "q" },
      },
      backend = "popup",
      relative = "editor",
      position = {
        row = "100%",
        col = "50%",
      },
      size = {
        height = "auto",
        width = "100%",
      },
      border = {
        style = "none",
        padding = { 0, 1 },
      },
      win_options = {
        winhighlight = {
          Normal = "NormalFloat",
          FloatBorder = "NormalFloat",
          IncSearch = "",
          Search = "",
        },
      },
    },
  },
})
