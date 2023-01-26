require("sidebar-nvim").setup({
    disable_default_keybindings = 0,
    bindings = nil,
    open = true,
    side = "left",
    initial_width = vim.g.filetree_width,
    hide_statusline = false,
    update_interval = 2000,
    sections = { "datetime", "buffers", "diagnostics" },
    section_separator = {"", "-----------------------------", ""},
    section_title_separator = {""},
    containers = {
        attach_shell = "/bin/sh", show_all = true, interval = 5000,
    },
    buffers = {
      ignore_not_loaded = true,
    },
    datetime = { format = "%a %b %d, %H:%M", clocks = { { name = "local" } } },
    todos = { ignored_paths = { "~" } },
    winhl = "NeoTreeNormalNC",
    statusline = "  Sidebar / Neotree"
})

