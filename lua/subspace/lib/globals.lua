--- global functions for my Neovim configuration
local M = {}

M.cur_bufsize = 0
M.cmp_setup_done = false
M.blink_setup_done = false

-- ignore symbol types for the fast symbol browser (telescope)
M.ignore_symbols = {
  lua = { "string", "object", "boolean", "number", "array", "variable" },
}

function M.open_with_fzf(cwd)
  if vim.fn.isdirectory(cwd) then
    vim.schedule(function() require("fzf-lua").files({ formatter = "path.filename_first", cwd = cwd,
      winopts = Tweaks.fzf.winopts.very_narrow_no_preview })
     end)
  end
end

-- reveal the current file in the tree. Change directory accordingly
-- works with NeoTree and NvimTree
-- This tries to find the root folder of the current project.
function M.sync_tree()
  local root = require("subspace.lib").getroot_current()
  if Tweaks.tree.version == "Neo" then
    local nc = require("neo-tree.command")
    nc.execute({ action = "show", dir = root, source = "filesystem" })
    nc.execute({ action = "show", reveal = true, reveal_force_cwd = true, source = "filesystem" })
  elseif Tweaks.tree.version == "Nvim" then
    require("nvim-tree.api").tree.change_root(root)
    vim.cmd("NvimTreeFindFile")
    -- TODO: Make this work with a docked "snacks explorer" as filetree
  elseif Tweaks.tree.version == "Explorer" then
  end
end

--- set the statuscol to either normal or relative line numbers
--- @param mode string: allowed values: 'normal' or 'rel'
function M.set_statuscol(mode)
  if mode ~= nil and mode ~= "normal" and mode ~= "rel" then
    return
  end
  PCFG.statuscol_current = mode
  if Tweaks.use_foldlevel_patch == true then
    vim.o.statuscolumn = CFG["statuscol_" .. mode]
  end
  if mode == "normal" then
    vim.o.relativenumber = false
    vim.o.numberwidth = Tweaks.numberwidth
    vim.o.number = true
  else
    vim.o.relativenumber = true
    vim.o.numberwidth = Tweaks.numberwidth_rel
    vim.o.number = true
  end
end

-- toggle statuscolum between absolute and relative line numbers
-- by default, it is mapped to <C-l><C-l>
function M.toggle_statuscol()
  if PCFG.statuscol_current == "normal" then
    M.set_statuscol("rel")
    return
  end
  if PCFG.statuscol_current == "rel" then
    M.set_statuscol("normal")
    return
  end
end

-- toggle the right colorcolumn value (right margin).
-- this can be different, depending on filetype. The relevant table is in Config.colorcolumn.
-- by default, this is mapped to <C-l><C-k>
function M.toggle_colorcolumn()
  if #vim.opt_local.colorcolumn:get() ~= 0 then
    vim.opt_local.colorcolumn = ""
  else
    local filetype = vim.bo.filetype
    for _, v in pairs(CFG.colorcolumns) do
      if string.find(v.filetype, filetype) then
        vim.opt_local.colorcolumn = v.value
        return
      end
    end
    vim.opt_local.colorcolumn = CFG.colorcolumns.all.value
  end
end

-- list of filetypes we never want to create views for.'
local _mkview_exclude = Tweaks.mkview_exclude

--- this creates a view using mkview unless the buffer has no file name or is not a file at all.
--- it also respects the filetype exclusion list to avoid unwanted clutter in the views folder
function M.mkview()
  -- require valid filename and ignore all buffers with special buftype
  if #vim.fn.expand("%") > 0 and vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "" then
    -- respect exclusion list
    if vim.tbl_contains(_mkview_exclude, vim.bo.filetype) == true then
      return
    end
    vim.cmd("silent! mkview!")
  end
end

--- set one formatoptions
--- @param fo string a valid format option see :help fo-table
function M.set_fo(fo)
  vim.opt_local.formatoptions:append(fo)
  require("lualine").refresh()
end

--- clear a format option
--- @param fo string a valid format option see :help fo-table
function M.clear_fo(fo)
  for i = 1, #fo do
    vim.opt_local.formatoptions:remove(string.sub(fo, i, i))
  end
  require("lualine").refresh()
end

--- toggle a format option(s)
--- this can only toggle A SINGLE format option
--- e.g. toggle_fo('t')
--- @param fo string ONE formatoption to toggle
function M.toggle_fo(fo)
  for i = 1, #fo do
    if vim.opt_local.formatoptions:get()[string.sub(fo, i, i)] == true then
      M.clear_fo(string.sub(fo, i, i))
    else
      M.set_fo(string.sub(fo, i, i))
    end
  end
  require("lualine").refresh()
end

--- toggle the status of wrap between wrap and nowrap
function M.toggle_wrap()
  if vim.opt_local.wrap:get() == true then
    vim.opt_local.wrap = false
    vim.opt_local.linebreak = false
  else
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end
  require("lualine").refresh()
end

--- close all quickfix windows
function M.close_qf_or_loc()
  local winid = TABM.findWinByFiletype("qf", true)
  if #winid > 0 then
    for i, _ in pairs(winid) do
      if winid[i] > 0 and vim.api.nvim_win_is_valid(winid[i]) then
        vim.api.nvim_win_close(winid[i], {})
        if TABM.T[TABM.active].term.id_win ~= nil then
          vim.api.nvim_win_set_height(TABM.T[TABM.active].term.id_win, PCFG.terminal.height)
        end
      end
    end
  end
end

--- get the size (in bytes) of the current buffer.
--- needed for some performance tweaks to disable features for large buffers
function M.get_bufsize()
  local buf = vim.api.nvim_get_current_buf()
  local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
  M.cur_bufsize = byte_size
  return byte_size
end

--- output a debug message als notification. Does nothing when debug mode is disabled.
--- @param msg string: The message to show
--- it uses a log level of DEBUG by default.
function M.debugmsg(msg)
  if PCFG.debug == true then
    vim.notify(msg, vim.log.levels.DEBUG, { title = "Debug" })
  end
end

--- toggle the debug mode and display the new status.
--- when enabled, additional debug messages will be shown using
--- the notifier
function M.toggle_debug()
  PCFG.debug = not PCFG.debug
  if PCFG.debug == true then
    vim.notify("Debug messages are now ENABLED.", 2)
  else
    vim.notify("Debug messages are now DISABLED.", 2)
  end
  PCFG.is_dev = PCFG.debug
end

-- enable/disable ibl
function M.toggle_ibl()
  PCFG.indent_guides = not PCFG.indent_guides
  vim.g.snacks_indent = PCFG.indent_guides
  vim.schedule(function() vim.cmd.redraw() end)
end

--- toggle scrollbar visibility
--- this works with both the satellite and nvim-scrollbar plugins whatever one
--- is active. The current status is saved to the permanent configuration.
function M.set_scrollbar()
  if PCFG.scrollbar == true then
    vim.cmd("ScrollbarShow")
  else
    vim.cmd("ScrollbarHide")
  end
end

--- detach all TUI sessions from the headless master. The server will continue running
--- in the background accepting new TUI sessions.
function M.detach_all_tui()
  for _, ui in pairs(vim.api.nvim_list_uis()) do
    if ui.chan and not ui.stdout_tty then
      vim.fn.chanclose(ui.chan)
    end
  end
end

-- configure the treesitter core component. This is called once before
-- treesitter is first started (in auto.lua)
function M.configure_treesitter()
  vim.treesitter.language.register("objc", "objcpp")
  vim.treesitter.language.register("markdown", { "telekasten", "liquid" } )
  vim.treesitter.language.register("css", "scss")
  vim.treesitter.language.register("html", "jsp")
  vim.treesitter.language.register("ini", "editorconfig")
  -- disable injections for these languages, because they can be slow
  -- can be tweaked
  --if Tweaks.treesitter.perf_tweaks == true then
  --  vim.treesitter.query.set("javascript", "injections", "")
  --  vim.treesitter.query.set("typescript", "injections", "")
  --  vim.treesitter.query.set("vimdoc", "injections", "")
  --end
  -- enable/disable treesitter-context plugin
  vim.g.setkey({ 'n', 'i', 'v' }, "<C-x><C-c>", function() M.toggle_treesitter_context() end, "Toggle Treesitter Context")
  -- jump to current context start
  vim.g.setkey({ 'n', 'i', 'v' }, "<C-x>c", function() require("treesitter-context").go_to_context() end, "Go to Context Start")

  vim.g.setkey({ 'n', 'i', 'v' }, "<C-x>te",
    function()
      vim.treesitter.start()
      vim.notify("Highlights enabled", vim.log.levels.INFO)
    end, "Enable Treesitter for Buffer")
  vim.g.setkey({ 'n', 'i', 'v' }, "<C-x>td",
    function()
      vim.treesitter.stop()
      vim.notify("Highlight disabled", vim.log.levels.INFO)
    end, "Disable Treesitter for Buffer")
end

--- enable or disable the treesitter-context plugin
--- @param silent boolean: supress notification about the status change
function M.setup_treesitter_context(silent)
  local tsc = require("treesitter-context")
  if PCFG.treesitter_context == true then
    tsc.enable()
  else
    tsc.disable()
  end
  if not silent then
    vim.notify("Treesitter-Context is now " .. (PCFG.treesitter_context == true and "enabled" or "disabled"), vim.log.levels.INFO)
  end
end

function M.toggle_treesitter_context()
  local wsplit = require("subspace.content.wsplit")
  vim.api.nvim_buf_set_var(0, "tsc", not vim.api.nvim_buf_get_var(0, "tsc"))
  PCFG.treesitter_context = M.get_buffer_var(0, "tsc")
  M.setup_treesitter_context(false)
  TABM.T[TABM.active].wsplit.freeze = false
  vim.schedule(function() wsplit.refresh("toggle_treesitter_context()") end)
end

function M.toggle_inlayhints()
  local status = M.get_buffer_var(0, "inlayhints")
  vim.api.nvim_buf_set_var(0, "inlayhints", not status)
  vim.lsp.inlay_hint.enable(not status, { bufnr = 0 })
  PCFG.lsp.inlay_hints = not status
end

--- get a custom buffer variable.
-- @param bufnr number: The buffer id
-- @param varname string: The variable's name
function M.get_buffer_var(bufnr, varname)
  local status, value = pcall(vim.api.nvim_buf_get_var, bufnr, varname)
  return (status == false) and nil or value
end

return M
