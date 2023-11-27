-- indent blankline setup
-- note: ibl requires version 3
local globals = require("globals")

require("ibl").setup({
  -- for example, context is off by default, use this to turn it on
  enabled = globals.perm_config.ibl_enabled,
  debounce = 300,
  indent = { highlight = globals.perm_config.ibl_rainbow == true and globals.ibl_rainbow_highlight or globals.ibl_highlight, char = "│", tab_char = "│" },
  whitespace = {
    remove_blankline_trail = true,
  },
  scope = {
    enabled = globals.perm_config.ibl_context,
    highlight = "Normal",
    exclude = {  language = {"vim"} }
  },
  viewport_buffer = {
    min = 30,
    max = 100
  },
  exclude = {
    filetypes = {
      "alpha",
      "help",
      "sysmon"
    }
  }
})

