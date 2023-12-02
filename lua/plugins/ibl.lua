-- indent blankline setup
-- note: ibl requires version 3

require("ibl").setup({
  -- for example, context is off by default, use this to turn it on
  enabled = __Globals.perm_config.ibl_enabled,
  debounce = 300,
  indent = { highlight = __Globals.perm_config.ibl_rainbow == true and __Globals.ibl_rainbow_highlight or __Globals.ibl_highlight, char = "│", tab_char = "│" },
  whitespace = {
    remove_blankline_trail = true,
  },
  scope = {
    enabled = __Globals.perm_config.ibl_context,
    highlight = "IndentBlanklineContextChar",
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

