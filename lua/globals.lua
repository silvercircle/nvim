--- global functions for my Neovim configuration
local colors = Config.theme

local M = {}

M.winid_bufferlist = 0
M.main_winid = 0
M.cur_bufsize = 0
M.outline_is_open = false

M.term = {
  bufid = nil,
  winid = nil,
  height = 12,
  visible = false,
}
-- use multiple colors for indentation guides ("rainbow colors")
-- theme is responsible for defining the colors
M.ibl_rainbow_highlight = {
  "IndentBlanklineIndent1",
  "IndentBlanklineIndent2",
  "IndentBlanklineIndent3",
  "IndentBlanklineIndent4",
  "IndentBlanklineIndent5",
  "IndentBlanklineIndent6",
}
-- use single color for ibl highlight
M.ibl_highlight = {
  "IndentBlanklineChar",
}

-- these are the defaults for the permanent configuration structure. it will be saved to a JSON
-- file on exit and read on startup.
M.perm_config_default = {
  sysmon = {
    active = false,
    width = Config.sysmon.width,
    content = "sysmon",
  },
  weather = {
    active = false,
    width = Config.weather.width,
    content = "info",
  },
  terminal = {
    active = true,
    height = 12,
  },
  tree = {
    width = Config.filetree_width,
    active = true,
  },
  outline = {
    width = Config.outline_width,
  },
  statuscol_current = "normal",
  blist = true,
  blist_height = 0.33,
  theme_variant = "warm",
  transbg = false,
  theme_desaturate = true,
  theme_dlevel = 1,
  theme_strings = "yellow",
  debug = false,
  ibl_rainbow = false,
  ibl_enabled = true,
  ibl_context = true,
  scrollbar = true,
  statusline_declutter = 0,
  outline_filetype = "Outline",
  treesitter_context = true,
  show_indicators = true,
  telescope_borders = "rounded"
}

M.perm_config = {}

M.sessions = {}

-- ignore symbol types for the fast symbol browser (telescope)
M.ignore_symbols = {
  lua = { "string", "object", "boolean", "number", "array", "variable" },
}

local function get_permconfig_filename()
  return vim.fn.stdpath("state") .. "/permconfig.json"
end

--- open the outline window
function M.open_outline()
  if M.perm_config.outline_filetype == "Outline" then
    vim.cmd("OutlineOpen")
  elseif M.perm_config.outline_filetype == "aerial" then
    require("aerial").open()
  end
end

--- close the outline window
function M.close_outline()
  if M.perm_config.outline_filetype == "Outline" then
    vim.cmd("OutlineClose")
  elseif M.perm_config.outline_filetype == "aerial" then
    require("aerial").close()
  end
end

function M.is_outline_open()
  local status = {
    outline = 0,
    aerial = 0,
  }
  local _o = M.findwinbyBufType("Outline")
  if #_o > 0 and _o[1] ~= nil then
    status.outline = _o[1]
  end
  local _a = M.findwinbyBufType("aerial")
  if #_a > 0 and _a[1] ~= nil then
    status.aerial = _a[1]
  end
  return status
end

-- toggle the type of outline window to use between outline.nvim and aerial.
function M.toggle_outline_type()
  M.close_outline()
  if M.perm_config.outline_filetype == "aerial" then
    M.perm_config.outline_filetype = "Outline"
  elseif M.perm_config.outline_filetype == "Outline" then
    M.perm_config.outline_filetype = "aerial"
  end
  M.notify("Now using " .. M.perm_config.outline_filetype, vim.log.levels.INFO)
end

--- set the statuscol to either normal or relative line numbers
--- @param mode string: allowed values: 'normal' or 'rel'
function M.set_statuscol(mode)
  if mode ~= nil and mode ~= "normal" and mode ~= "rel" then
    return
  end
  M.perm_config.statuscol_current = mode
  vim.o.statuscolumn = Config["statuscol_" .. mode]
  if mode == "normal" then
    vim.o.relativenumber = false
    vim.o.numberwidth = vim.g.tweaks.numberwidth
    vim.o.number = true
  else
    vim.o.relativenumber = true
    vim.o.numberwidth = vim.g.tweaks.numberwidth_rel
    vim.o.number = false
  end
  M.notify("Line numbers set to: " .. mode, vim.log.levels.INFO)
end

-- toggle statuscolum between absolute and relative line numbers
-- by default, it is mapped to <C-l><C-l>
function M.toggle_statuscol()
  if M.perm_config.statuscol_current == "normal" then
    M.set_statuscol("rel")
    return
  end
  if M.perm_config.statuscol_current == "rel" then
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
    for _, v in pairs(Config.colorcolumns) do
      if string.find(v.filetype, filetype) then
        vim.opt_local.colorcolumn = v.value
        return
      end
    end
    vim.opt_local.colorcolumn = Config.colorcolumns.all.value
  end
end

--- find the first window for a given filetype.
--- @param type string: the filetype
--- @return table: a list of windows displaying the buffer or an empty list if none has been found
function M.findwinbyBufType(type)
  local ls = vim.api.nvim_list_bufs()
  local win_ids = {}
  for i = 1, #ls, 1 do
    if vim.api.nvim_buf_is_valid(ls[i]) then
      local filetype = vim.api.nvim_buf_get_option(ls[i], "filetype")
      if filetype == type then
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
--- @param type string: buffer type (e.g. "NvimTree"
--- @return boolean: true if a window was found, false otherwise
function M.findbufbyType(type)
  local winid = M.findwinbyBufType(type)
  if #winid > 0 then
    vim.fn.win_gotoid(winid[1])
    return true
  end
  return false
end

--- truncate a string to a maximum length, appending ellipses when necessary
--- @param text string:       the string to truncate
--- @param max_length integer: the maximum length
--- @return string:           the truncated text
function M.truncate(text, max_length)
  if #text > max_length then
    return string.sub(text, 1, max_length) .. "…"
  else
    return text
  end
end

-- list of filetypes we never want to create views for.'
local _mkview_exclude = vim.g.tweaks.mkview_exclude

--- global function to create a view
--- this creates a view using mkview unless the buffer has no file name or is not a file at all.
--- it also respects the filetype exclusion list to avoid unwanted clutter in the views folder
function M.mkview()
  -- require valid filename and ignore all buffers with special buftype
  if #vim.fn.expand("%") > 0 and vim.api.nvim_buf_get_option(0, "buftype") == "" then
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
end

--- clear a format option
--- @param fo string a valid format option see :help fo-table
function M.clear_fo(fo)
  vim.opt_local.formatoptions:remove(fo)
end

--- toggle a format option(s)
--- this can only toggle A SINGLE format option
--- e.g. toggle_fo('t')
--- @param fo string ONE formatoption to toggle
function M.toggle_fo(fo)
  if vim.opt_local.formatoptions:get()[fo] == true then
    M.clear_fo(fo)
  else
    M.set_fo(fo)
  end
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
end

-- split the file tree horizontally
--- @param _factor number:  if _factor is betweeen 0 and 1 it is interpreted as percentage
--  of the window to split. Otherwise as an absolute number. The default is set to 1/3 (0.33)
--- @return number: the window id, 0 if the process failed
function M.splittree(_factor)
  local factor = math.abs((_factor ~= nil and _factor > 0) and _factor or 0.33)
  local winid = M.findwinbyBufType("NvimTree")
  if #winid > 0 then
    local splitheight
    if factor < 1 then
      splitheight = vim.fn.winheight(winid[1]) * factor
    else
      splitheight = factor
    end
    vim.fn.win_gotoid(winid[1])
    vim.cmd("below " .. splitheight .. " sp")
    M.winid_bufferlist = vim.fn.win_getid()
    vim.api.nvim_win_set_option(M.winid_bufferlist, "list", false)
    vim.api.nvim_win_set_option(M.winid_bufferlist, "statusline", "Buffer List")
    vim.cmd(
      "set nonumber | set norelativenumber | set signcolumn=no | set winhl=Normal:NeoTreeNormalNC | set foldcolumn=0"
    )
    vim.fn.win_gotoid(M.main_winid)
    return M.winid_bufferlist
  end
  return 0
end

--- close all quickfix windows
function M.close_qf_or_loc()
  local winid = M.findwinbyBufType("qf")
  if #winid == 0 then
    winid = M.findwinbyBufType("replacer")
  end
  if #winid > 0 then
    for i, _ in pairs(winid) do
      if winid[i] > 0 and vim.api.nvim_win_is_valid(winid[i]) then
        vim.api.nvim_win_close(winid[i], {})
        if M.term.winid ~= nil then
          vim.api.nvim_win_set_height(M.term.winid, M.perm_config.terminal.height)
        end
      end
    end
  end
end

--- opens a terminal split at the bottom. May also open the sysmon/fortune split
--- @param _height number: height of the terminal split to open.
function M.termToggle(_height)
  local height = _height or M.term.height
  local reopen_outline = false
  -- if it is visible, then close it an all sub frames
  -- but leave the buffer open
  if M.term.visible == true then
    require("local_utils.usplit").close()
    -- require("local_utils.wsplit").close()
    vim.api.nvim_win_hide(M.term.winid)
    M.term.visible = false
    M.term.winid = nil
    return
  end
  local outline_win = M.findwinbyBufType(M.perm_config.outline_filetype)

  if outline_win[1] ~= nil and vim.api.nvim_win_is_valid(outline_win[1]) then
    M.close_outline()
    reopen_outline = true
  end

  vim.fn.win_gotoid(M.main_winid)
  -- now, if we have no terminal buffer (yet), create one. Otherwise just select
  -- the existing one.
  if M.term.bufid == nil then
    vim.cmd("belowright " .. height .. " sp|terminal export NOCOW=1 && $SHELL")
  else
    vim.cmd("belowright " .. height .. " sp")
    vim.api.nvim_win_set_buf(0, M.term.bufid)
  end
  -- configure the terminal window
  vim.cmd(
    "setlocal statuscolumn=%#NeoTreeNormalNC#\\  | set filetype=terminal | set nonumber | set norelativenumber | set foldcolumn=0 | set signcolumn=no | set winfixheight | set nocursorline | set winhl=SignColumn:NeoTreeNormalNC,Normal:NeoTreeNormalNC"
  )
  M.term.winid = vim.fn.win_getid()
  vim.api.nvim_win_set_option(M.term.winid, "statusline", "  Terminal")
  M.term.bufid = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_option(M.term.bufid, "buflisted", false)
  M.term.visible = true

  -- finally, open the sub frames if they were previously open
  if M.perm_config.sysmon.active == true then
    require("local_utils.usplit").content = M.perm_config.sysmon.content
    require("local_utils.usplit").open()
  end

  if reopen_outline == true then
    vim.fn.win_gotoid(M.main_winid)
    M.open_outline()
    vim.schedule(function()
      vim.fn.win_gotoid(M.main_winid)
    end)
  end
end

--- write the configuration to the json file
--- do not write it when running in plain mode (without additional frames and content)
function M.write_config()
  if Config.plain == true then
    return
  end
  local file = get_permconfig_filename()
  local f = io.open(file, "w+")
  if f ~= nil then
    local wsplit_id = require("local_utils.wsplit").winid
    local usplit_id = require("local_utils.usplit").winid
    local blist_id = require("local_utils.blist").main_win
    local theme_conf = Config.theme.get_conf()
    local state = {
      terminal = {
        active = M.term.winid ~= nil and true or false,
      },
      weather = {
        active = wsplit_id ~= nil and true or false,
      },
      sysmon = {
        active = usplit_id ~= nil and true or false,
      },
      blist = blist_id ~= nil and true or false,
      tree = {
        active = #M.findwinbyBufType("NvimTree") > 0 and true or false,
      },
      theme_variant = theme_conf.variant,
      theme_desaturate = theme_conf.desaturate,
      theme_dlevel = theme_conf.dlevel,
      transbg = theme_conf.is_trans,
      theme_strings = theme_conf.theme_strings
    }
    if wsplit_id ~= nil then
      state.weather.width = vim.api.nvim_win_get_width(wsplit_id)
    end
    if usplit_id ~= nil then
      state.sysmon.width = vim.api.nvim_win_get_width(usplit_id)
    end
    if blist_id ~= nil then
      state.blist_height = vim.api.nvim_win_get_height(blist_id)
    end
    local string = vim.fn.json_encode(vim.tbl_deep_extend("force", M.perm_config, state))
    f:write(string)
    io.close(f)
  end
end

--- read the permanent config from the JSON dump.
--- if anything goes wrong, then restore the defaults.
function M.restore_config()
  local file = get_permconfig_filename()
  local f = io.open(file, "r")
  -- do some checks to avoid invalid data
  if f ~= nil then
    local string = f:read()
    if #string <= 1 then
      M.perm_config = M.perm_config_default
    else
      local tmp = vim.fn.json_decode(string)
      if #tmp ~= nil then
        M.perm_config = vim.tbl_deep_extend("force", M.perm_config_default, tmp)
      else
        M.perm_config = M.perm_config_default
      end
    end
  else
    M.perm_config = M.perm_config_default
  end
  -- configure the theme
  colors.setup({ variant = M.perm_config.theme_variant,
                 desaturate = M.perm_config.theme_desaturate, dlevel = M.perm_config.theme_dlevel,
                 theme_strings = M.perm_config.theme_strings, is_trans = M.perm_config.transbg,
                 sync_kittybg = vim.g.tweaks.theme.sync_kittybg,
                 kittysocket = vim.g.tweaks.theme.kittysocket,
                 kittenexec = vim.g.tweaks.theme.kittenexec,
                 callback = M.theme_callback })
end

--- the callback is called from internal theme functions that change its
--- configuration.
--- @param what string: description what has changed
function M.theme_callback(what)
  local conf = colors.get_conf()
  if what == 'variant' then
    M.perm_config.theme_variant = conf.variant
    M.notify("Theme variant is now: " .. conf.variant, vim.log.levels.INFO, "Theme")
  elseif what == 'desaturate' then
    M.perm_config.theme_desaturate = conf.desaturate
    M.perm_config.theme_dlevel = conf.dlevel
    if conf.desaturate == false then
      M.notify("Selected vivid color scheme", vim.log.levels.INFO, "Theme")
    else
      M.notify("Selected desaturated (Level " .. conf.dlevel .. ") color scheme", vim.log.levels.INFO, "Theme")
    end
  elseif what == 'strings' then
    M.notify("Theme strings set to: " .. conf.theme_strings, vim.log.levels.INFO, "Theme")
    M.perm_config.theme_strings = conf.theme_strings
  elseif what == "trans" then
    M.perm_config.transbg = conf.is_trans
    M.notify("Theme transparency is now " .. (conf.is_trans == true and "On" or "Off"), vim.log.levels.INFO, "Theme")
  end
end

--- adjust the optional frames so they will keep their width when the side tree opens or closes
function M.adjust_layout()
  local usplit = require("local_utils.usplit").winid
  --local wsplit = require("local_utils.wsplit").winid
  vim.o.cmdheight = vim.g.tweaks.cmdheight
  if usplit ~= nil then
    vim.api.nvim_win_set_width(usplit, M.perm_config.sysmon.width)
  end
  vim.api.nvim_win_set_height(M.main_winid, 200)
  if M.term.winid ~= nil then
    local width = vim.api.nvim_win_get_width(M.term.winid)
    vim.api.nvim_win_set_height(M.term.winid, M.term.height)
    vim.api.nvim_win_set_width(M.term.winid, width - 1)
    vim.api.nvim_win_set_width(M.term.winid, width)
  end
  local outline = M.findwinbyBufType("Outline")
  if #outline > 0 then
    vim.api.nvim_win_set_width(outline[1], M.perm_config.outline.width)
  end
end

--- try to format a souce file by using one of the defined formatter programs
function M.format_source()
  local ft = vim.api.nvim_buf_get_option(0, "filetype")
  local done = false
  if vim.g.formatters[ft] ~= nil then
    local cmd = "!" .. vim.g.formatters[ft].cmd .. " " .. vim.fn.expand("%:p")
    vim.cmd(cmd)
    done = true
  end
  if not done then
    M.notify("No formatter found for filetype " .. ft, vim.log.levels.INFO)
  end
end

function M.set_session(session)
  M.sessions[session] = session
  vim.print(M.sessions)
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
  if M.perm_config.debug == true then
    M.notify(msg, vim.log.levels.DEBUG, "Debug")
  end
end

local notify_classes = {
  { icon = " ", title = "Trace" },
  { icon = " ", title = "Debug" },
  { icon = "󰋼 ", title = "Information" },
  { icon = " ", title = "Warning" },
  { icon = " ", title = "Error" },
}

--- use the notifier to display a message
--- @param msg string: The message to display
--- @param level number: Warning level
--- @optionally a title can be specified
function M.notify(msg, level, ...)
  local arg = { ... }
  local params = {}
  if vim.g.notifier == nil then
    return
  end
  if level >= 0 and level <= 4 then
    params.icon = notify_classes[level + 1].icon
    params.title = (arg[1] == nil) and notify_classes[level + 1].title or arg[1]
    vim.g.notifier.notify(msg, level, params)
  end
end

--- toggle the debug mode and display the new status.
--- when enabled, additional debug messages will be shown using
--- the notifier
function M.toggle_debug()
  M.perm_config.debug = not M.perm_config.debug
  if M.perm_config.debug == true then
    M.notify("Debug messages are now ENABLED.", 2)
  else
    M.notify("Debug messages are now DISABLED.", 2)
  end
end

-- enable/disable ibl rainbow guides
function M.toggle_ibl_rainbow()
  M.perm_config.ibl_rainbow = not M.perm_config.ibl_rainbow
  require("ibl").update({
    indent = { highlight = M.perm_config.ibl_rainbow == true and M.ibl_rainbow_highlight or M.ibl_highlight },
  })
end

-- enable/disable ibl
function M.toggle_ibl()
  M.perm_config.ibl_enabled = not M.perm_config.ibl_enabled
  require("ibl").update({ enabled = M.perm_config.ibl_enabled })
end

-- enable/disable ibl context display
function M.toggle_ibl_context()
  M.perm_config.ibl_context = not M.perm_config.ibl_context
  require("ibl").update({ scope = { enabled = M.perm_config.ibl_context } })
end

--- toggle scrollbar visibility
--- this works with both the satellite and nvim-scrollbar plugins whatever one
--- is active. The current status is saved to the permanent configuration.
function M.set_scrollbar()
  local status, _ = pcall(require, "satellite")

  if M.perm_config.scrollbar == true then
    if status then
      vim.cmd("SatelliteEnable")
    else
      vim.cmd("ScrollbarShow")
    end
  else
    if status then
      vim.cmd("SatelliteDisable")
    else
      vim.cmd("ScrollbarHide")
    end
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

--- supporting function for mini.pick
--- returns a window config table to center a mini.picker with desired width and height
--- on screen
--- @param width integer      desired width of the picker window
--- @param height integer     desired height of the picker window
--- @param col_anchor number  vertical anchor in percentage. 0.5 centers
---                           lower values shift upwards, higher downwards
--- @ return table            a valid window config that can be passed to the picker
function M.mini_pick_center(width, height, col_anchor)
  local _ca = col_anchor or 0.5
  if width > 0 and width < 1 then
    width = math.floor(width * vim.o.columns)
  end
  if height > 0 and height < 1 then
    height = math.floor(height * vim.o.lines)
  end
  return {
    anchor = "NW",
    height = height,
    width = width,
    row = math.floor(_ca * (vim.o.lines - height)),
    col = math.floor(0.5 * (vim.o.columns - width)),
  }
end

-- configure the treesitter core component. This is called once before
-- treesitter is first started (in auto.lua)
function M.configure_treesitter()
  vim.treesitter.language.register("objc", "objcpp")
  vim.treesitter.language.register("markdown", "telekasten")
  -- disable injections for these languages, because they can be slow
  -- can be tweaked
  if vim.g.tweaks.treesitter.perf_tweaks == true then
    vim.treesitter.query.set("javascript", "injections", "")
    vim.treesitter.query.set("typescript", "injections", "")
  end
  -- enable/disable treesitter-context plugin
  _Config_SetKey({ 'n', 'i', 'v' }, "<C-x><C-c>", function() M.toggle_treesitter_context() end, "Toggle Treesitter Context")
  -- jump to current context start
  _Config_SetKey({ 'n', 'i', 'v' }, "<C-x>c", function() require("treesitter-context").go_to_context() end, "Go to Context Start")

  _Config_SetKey({ 'n', 'i', 'v' }, "<C-x>te",
    function()
      vim.treesitter.start()
      M.notify("Highlights enabled", vim.log.levels.INFO, "Treesitter")
    end, "Enable Treesitter for Buffer")
  _Config_SetKey({ 'n', 'i', 'v' }, "<C-x>td",
    function()
      vim.treesitter.stop()
      M.notify("Highlight disabled", vim.log.levels.INFO, "Treesitter")
    end, "Disable Treesitter for Buffer")
end

--- enable or disable the treesitter-context plugin
--- @param silent boolean: supress notification about the status change
function M.setup_treesitter_context(silent)
  local tsc = require("treesitter-context")
  if M.perm_config.treesitter_context == true then
    tsc.enable()
  else
    tsc.disable()
  end
  if not silent then
    M.notify("Treesitter-Context is now " .. (M.perm_config.treesitter_context == true and "enabled" or "disabled"), vim.log.levels.INFO)
  end
end

function M.toggle_treesitter_context()
  local wsplit = require("local_utils.wsplit")
  vim.api.nvim_buf_set_var(0, "tsc", not vim.api.nvim_buf_get_var(0, "tsc"))
  M.perm_config.treesitter_context = M.get_buffer_var(0, "tsc")
  M.setup_treesitter_context(false)
  wsplit.freeze = false
  vim.schedule(function() wsplit.refresh() end)
end

--- get a custom buffer variable
--- @param bufnr number: The buffer id
--- @param varname string: The variable's name
function M.get_buffer_var(bufnr, varname)
  local status, value = pcall(vim.api.nvim_buf_get_var, bufnr, varname)
  return (status == false) and nil or value
end

M.ufo_virtual_text_handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = (' 󰁂 %d '):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
        else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, {chunkText, hlGroup})
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
        end
        curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, {suffix, 'MoreMsg'})
    return newVirtText
end

return M
