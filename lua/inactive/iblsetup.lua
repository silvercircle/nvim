-- indent blankline setup
-- note: ibl requires version 3
local _char = Tweaks.indent.scope.char
-- use multiple colors for indentation guides ("rainbow colors")
-- theme is responsible for defining the colors
local ibl_rainbow_highlight = {
  "IndentBlanklineIndent1",
  "IndentBlanklineIndent2",
  "IndentBlanklineIndent3",
  "IndentBlanklineIndent4",
  "IndentBlanklineIndent5",
  "IndentBlanklineIndent6",
}
-- use single color for ibl highlight
local ibl_highlight = {
  "IndentBlanklineChar",
}

  vim.notify("indentblankline setup")
require("ibl").setup({
  -- for example, context is off by default, use this to turn it on
  enabled = CGLOBALS.perm_config.ibl_enabled,
  debounce = 300,
  indent = { highlight = CGLOBALS.perm_config.ibl_rainbow == true and ibl_rainbow_highlight or ibl_highlight, char = _char, tab_char = _char },
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

