local dm = require("debugmaster")
-- keymaps changing example
dm.keys.get("x").key = "y" -- remap x key in debug mode to y

-- changing some plugin options (see 1. note)
dm.plugins.cursor_hl.enabled = false
dm.plugins.ui_auto_toggle.enabled = false

-- Changing debug mode cursor hl
-- Debug mode cursor color controlled by "dCursor" highlight group
-- so to change it you can use the following code
vim.api.nvim_set_hl(0, "dCursor", {bg = "#FF2C2C"})
-- make sure to call this after you do vim.cmd("colorscheme x")
-- otherwise this highlight group could be cleaned by your colorscheme
vim.keymap.set({ "n", "v" }, "<leader>d", dm.mode.toggle, { nowait = true })
vim.keymap.set("t", "<C-/>", "<C-\\><C-n>", {desc = "Exit terminal mode"})
