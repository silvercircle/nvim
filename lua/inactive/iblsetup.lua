-- indent blankline setup
-- note: ibl requires version 3
local _char = Tweaks.indent.scope.char

  vim.notify("indentblankline setup")
require("ibl").setup({
  -- for example, context is off by default, use this to turn it on
  enabled = CGLOBALS.perm_config.ibl_enabled,
  debounce = 300,
  indent = { highlight = CGLOBALS.perm_config.ibl_rainbow == true and CGLOBALS.ibl_rainbow_highlight or CGLOBALS.ibl_highlight, char = _char, tab_char = _char },
  whitespace = {
    remove_blankline_trail = true,
  },
  scope = {
    enabled = CGLOBALS.perm_config.ibl_context,
    highlight = "IndentBlanklineContextChar",
    char = "│",
    show_start = false,
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

