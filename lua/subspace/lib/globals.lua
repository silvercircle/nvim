--- global functions for my Neovim configuration
local M = {}

M.main_winid = 0
M.cur_bufsize = 0
M.outline_is_open = false
M.notifier = nil
M.cmp_setup_done = false
M.blink_setup_done = false

M.term = {
  bufid = nil,
  winid = nil,
  height = 12,
  visible = false,
}
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

--- open the outline window
function M.open_outline()
  local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
  if buftype ~= "" then  --current buffer is no ordinary file. Ignore it.
    return
  end
  vim.cmd("Symbols!")
  local id_win = CGLOBALS.is_outline_open()
  if id_win and vim.api.nvim_win_is_valid(id_win) then
    vim.api.nvim_set_option_value("winhl", "Normal:TreeNormalNC,CursorLine:TreeCursorLine", { win = id_win })
    vim.api.nvim_win_set_width(id_win, PCFG.outline.width)
  end
end

--- close the outline window
function M.close_outline()
  vim.cmd("SymbolsClose")
end

function M.is_outline_open()
  local _o = M.findWinByFiletype(PCFG.outline_filetype)
  if #_o > 0 and _o[1] ~= nil then
    return _o[1]
  end
  return false
end

--- open the tree (file manager tree on the left). It can be either NvimTree
--- or NeoTree
function M.open_tree()
  if Tweaks.tree.version == "Nvim" then
    require('nvim-tree.api').tree.toggle({ focus = false })
  elseif Tweaks.tree.version == "Neo" then
    require("neo-tree.command").execute({
      action = "show",
      source = "filesystem",
      position = "left"
    })
  -- TODO: make it work with snacks explorer
  elseif Tweaks.tree.version == "Explorer" then
    require("snacks").picker.explorer( { jump = {close=false},
      auto_close = false, layout={position="left", layout={ border="none", width=40, min_width=40}} } )
  end
end

-- reveal the current file in the tree. Change directory accordingly
-- works with NeoTree and NvimTree
-- This tries to find the root folder of the current project.
function M.sync_tree()
  local root = require("subspace.lib").getroot_current()
  if Tweaks.tree.version == "Neo" then
    local nc = require("neo-tree.command")
    nc.execute( {action="show", dir=root, source="filesystem" } )
    nc.execute( {action="show", reveal=true, reveal_force_cwd=true, source="filesystem" } )
  elseif Tweaks.tree.version == "Nvim" then
    require('nvim-tree.api').tree.change_root(root)
    vim.cmd("NvimTreeFindFile")
  -- TODO: Make this work with a docked "snacks explorer" as filetree
  elseif Tweaks.tree.version == "Explorer" then
  end
end
--- called by the event handler in NvimTree or NeoTree to inidicate that
--- the file tree has been opened.
function M.tree_open_handler()
  local wsplit = require("subspace.content.wsplit")
  vim.opt.statuscolumn = ''
  local w = vim.fn.win_getid()
  vim.api.nvim_set_option_value('statusline', '   ' .. (Tweaks.tree.version == "Neo" and "NeoTree" or "NvimTree"), { win = w })
  vim.cmd('setlocal winhl=Normal:TreeNormalNC,CursorLine:Visual | setlocal statuscolumn= | setlocal signcolumn=no | setlocal nonumber')
  vim.api.nvim_win_set_width(w, PCFG.tree.width)
  CGLOBALS.adjust_layout()
  if PCFG.weather.active == true then
    wsplit.content = PCFG.weather.content
    if wsplit.winid == nil then
      wsplit.openleftsplit(CFG.weather.file)
    end
  end
end

--- called by the event handler in NvimTree or NeoTree to inidicate that
--- the file tree was opened.
function M.tree_close_handler()
  local wsplit = require("subspace.content.wsplit")
  wsplit.close()
  wsplit.winid = nil
  CGLOBALS.adjust_layout()
  if CGLOBALS.term.winid ~= nil then
    vim.api.nvim_win_set_height(CGLOBALS.term.winid, CGLOBALS.term.height)
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

--- find the first window for a given filetype.
--- @param filetypes string|table: the filetype(s)
--- @return table: a list of windows displaying the buffer or an empty list if none has been found
function M.findWinByFiletype(filetypes)

  local function finder(ft, where)
    if type(where) == "string" then
      return ft == where
    else
      return vim.tbl_contains(where, ft)
    end
  end

  local ls = vim.api.nvim_list_bufs()
  local win_ids = {}
  for i = 1, #ls, 1 do
    if vim.api.nvim_buf_is_valid(ls[i]) then
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = ls[i] })
      if finder(filetype, filetypes) then
        local wins = vim.fn.win_findbuf(ls[i])
        if wins == 1 then
          table.insert(win_ids, wins[1])
        else
          for j = 1, #wins, 1 do
            table.insert(win_ids, wins[j])
          end
        end
      end
    end
  end
  return win_ids
end

--- find a buffer with type and focus its primary window split
--- @param type string: filetype (e.g. "NvimTree"
--- @return boolean: true if a window was found, false otherwise
function M.findbufbyType(type)
  local winid = M.findWinByFiletype(type)
  if #winid > 0 then
    vim.fn.win_gotoid(winid[1])
    return true
  end
  return false
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
  local winid = M.findWinByFiletype("qf")
  if #winid > 0 then
    for i, _ in pairs(winid) do
      if winid[i] > 0 and vim.api.nvim_win_is_valid(winid[i]) then
        vim.api.nvim_win_close(winid[i], {})
        if M.term.winid ~= nil then
          vim.api.nvim_win_set_height(M.term.winid, PCFG.terminal.height)
        end
      end
    end
  end
end

--- opens a terminal split at the bottom. May also open the sysmon/fortune split
--- @param _height number: height of the terminal split to open.
function M.termToggle(_height)
  local height = _height or M.term.height
  height = height <= vim.o.lines/2 and height or vim.o.lines/2
  local reopen_outline = false
  -- if it is visible, then close it an all sub frames
  -- but leave the buffer open
  if M.term.visible == true then
    require("subspace.content.usplit").close()
    vim.api.nvim_win_hide(M.term.winid)
    M.term.visible = false
    M.term.winid = nil
    return
  end
  local outline_win = M.findWinByFiletype(PCFG.outline_filetype)

  if outline_win[1] ~= nil and vim.api.nvim_win_is_valid(outline_win[1]) then
    M.close_outline()
    reopen_outline = true
  end

  vim.fn.win_gotoid(M.main_winid)
  -- now, if we have no terminal buffer (yet), create one. Otherwise just select
  -- the existing one.
  if M.term.bufid == nil then
    local shell = Tweaks.shell or "$SHELL"
    vim.cmd("belowright " .. height .. " sp|terminal export NOCOW=1 && " .. shell )
  else
    vim.cmd("belowright " .. height .. " sp")
    vim.api.nvim_win_set_buf(0, M.term.bufid)
  end
  -- configure the terminal window
  vim.cmd(
    "setlocal statuscolumn=%#TreeNormalNC#\\  | set filetype=terminal | set nonumber | set norelativenumber | set foldcolumn=0 | set signcolumn=no | set winfixheight | set nocursorline | set winhl=SignColumn:TreeNormalNC,Normal:TreeNormalNC"
  )
  M.term.winid = vim.fn.win_getid()
  vim.api.nvim_set_option_value("statusline", "  Terminal", { win = M.term.winid })
  M.term.bufid = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_option_value("buflisted", false, { buf = M.term.bufid })
  M.term.visible = true

  -- finally, open the sub frames if they were previously open
  if PCFG.sysmon.active == true then
    require("subspace.content.usplit").content = PCFG.sysmon.content
    require("subspace.content.usplit").open()
  end

  if reopen_outline == true then
    vim.fn.win_gotoid(M.main_winid)
    M.open_outline()
    vim.schedule(function()
      vim.fn.win_gotoid(M.main_winid)
    end)
  end
end


--- adjust the optional frames so they will keep their width when the side tree opens or closes
function M.adjust_layout()
  local usplit = require("subspace.content.usplit").winid
  vim.o.cmdheight = Tweaks.cmdheight
  if usplit ~= nil then
    vim.api.nvim_win_set_width(usplit, PCFG.sysmon.width)
  end
  vim.api.nvim_win_set_height(M.main_winid, 200)
  if M.term.winid ~= nil then
    local width = vim.api.nvim_win_get_width(M.term.winid)
    vim.api.nvim_win_set_height(M.term.winid, M.term.height)
    vim.api.nvim_win_set_width(M.term.winid, width - 1)
    vim.api.nvim_win_set_width(M.term.winid, width)
  end
  local outline = M.findWinByFiletype(PCFG.outline_filetype)
  if #outline > 0 then
    vim.api.nvim_win_set_width(outline[1], PCFG.outline.width)
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
  wsplit.freeze = false
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
