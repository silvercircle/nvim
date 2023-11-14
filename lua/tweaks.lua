-- user tweakable stuff
-- most of this is for cosmetical or performance purpose. Other tweaks are still
-- in config.lua and options.lua, but the goal is to have all user-tweakable options
-- here. This is WIP.
local M = {}

-- telescope field widths. These depend on the characters per line in the terminal
-- setup. So it needs to be tweakable
M.telescope_symbol_width = 60
M.telescope_fname_width = 120
-- the width for the vertical layout with preview on top
M.telescope_vertical_preview_layout = {
  width = 120,
  preview_height = 15
}

-- the overall width for the "mini" telescope picker. These are used for LSP symbols
-- and references.
M.telescope_mini_picker_width = 76

-- length of the filename in the cokeline winbar
M.cokeline_filename_width = 25

M.cmp = {
  -- max buffer size to enable the buffer words autocompletion source in cmp
  -- this is a performance tweak. Value is in bytes and 300kB is a reasonable default, even for
  -- slower machines. On fast hardware you can increase this to much higher values
  buffer_maxsize = 300 * 1024,
  -- I prefer to have only manual cmp complation (hit Ctrl-Space)
  -- set this to true to always have auto-completion when typing
  autocomplete = false,
  -- minimum keyword length for auto-complete to kick in
  keywordlen = 1,
  --enable experimental ghost text feature. Set to false (disable) or a table
  --containing the highlight group to use for ghost text.
  --M.cmp_ghost = { hl_group = 'CmpGhostText' }
  ghost = false
}

-- set this to "Outline" to use the symbols-outline plugin.
-- set it to "aerial" to use the Aerial plugin.
M.outline_plugin = "Outline"

-- list of filetypes for which no views are created when saving or leaving the buffer
-- by default, help files and terminals don't need views
M.mkview_exclude = { "help", "terminal", "floaterm" }
M.cmdheight = 0

-- width of line number (absolute numbers)
M.numberwidth = 6
-- for relative numbers, 2 should normally be sufficient, but then 
M.numberwidth_rel = 2
M.signcolumn = "yes:4"

-- valid are 'dropbar' and 'navic'. Defaults to 'navic' when unrecognized
-- note that dropbar requires neovim 0.10 which is currently in development
-- and only available as nightly build.
M.breadcrumb = 'dropbar'
M.cookie_source = 'curl -s -m 5 --connect-timeout 10 https://vtip.43z.one'

-- settings for the fortune cookie split
M.fortune = {
  refresh = 10, -- in minutes - the minimum is one minute, lower values are corrected.
  -- fetch 2 cookies and merge them.
  numcookies = 2,
  -- see man fortune (-s = short cookies, max. 300 characters long)
  command = "fortune -s -n300"
}

-- nvim-cmp tweak: enable ghost text with this highlight group. Set to false to
-- disable the feature.
M.use_foldlevel_patch = (os.getenv('NVIM_USE_PRIVATE_FORKS') ~= nil) and true or false

-- the key prefix used for various utility functions. See keymap.lua
M.utility_key = "<C-l>"
return M
