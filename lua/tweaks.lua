--- user tweakable stuff
local M = {}

-- telescope field widths. These depend on the characters per line in the terminal
-- setup. So it needs to be tweakable
M.telescope_symbol_width = 60
M.telescope_fname_width = 120
M.telescope_vertical_layout_width = 120
M.telescope_vertical_preview_layout = {
  width = 120,
  preview_height = 15
}

-- the overall width for the "mini" telescope picker. These are used for LSP symbols
-- and references.
M.telescope_mini_picker_width = 76

-- length of the filename in the cokeline winbar
M.cokeline_filename_width = 25

-- max buffer size to enable the buffer words autocompletion source in cmp
-- this is a performance tweak. Value is in bytes and 300kB is a reasonable default, even for
-- slower machines. On fast hardware you can increase this to much higher values
M.cmp_buffer_maxsize = 300 * 1024
-- I prefer to have only manual cmp complation (hit Ctrl-Space)
-- set this to true to always have auto-completion when typing
M.cmp_autocomplete = false
-- minimum keyword length for auto-complete to kick in
M.cmp_keywordlen = 1

-- set this to "Outline" to use the symbols-outline plugin.
-- set it to "aerial" to use the Arial plugin.
M.outline_plugin = "Outline"

-- list of filetypes for which no views are created when saving or leaving the buffer
-- by default, help files and terminals don't need views
M.mkview_exclude = { "help", "terminal", "floaterm" }
M.cmdheight = 0
return M
