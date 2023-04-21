--- global functions for my Neovim configuration
--- use with require("globals")
local M = {}

M.winid_bufferlist = 0
M.main_winid = 0

M.term = {
  bufid = nil,
  winid = nil,
  height = 12,
  visible = false,
}

-- these are the defaults for the permanent configuration structure. it will be saved to a JSON
-- file on exit and read on startup.
M.perm_config_default = {
  sysmon = {
    active = false,
    width = vim.g.config.sysmon.width
  },
  weather = {
    active = false,
    width = vim.g.config.weather.width
  },
  terminal = {
    active = true,
    height = 12
  },
  statuscol_current = 'normal',
  blist = true,
  blist_height = 0.33,
  tree = true,
  theme_variant = 'warm',
  theme_desaturate = true,
  theme_name = "my_sonokai"
}

M.perm_config = {}

local function get_permconfig_file()
  return vim.fn.stdpath("state") .. "/permconfig.json"
end

--- set the statuscol to either normal or relative line numbers
--- @param mode string: allowed values: 'normal' or 'rel'
function M.set_statuscol(mode)
  if mode ~= nil and mode ~= 'normal' and mode ~= 'rel' then
    return
  end
  M.perm_config.statuscol_current = mode
  vim.o.statuscolumn = vim.g.config["statuscol_" .. mode ]
  if mode == 'normal' then
    vim.o.relativenumber = false
    vim.o.numberwidth=5
    vim.o.number = true
  else
    vim.o.relativenumber = true
    vim.o.numberwidth=5
    vim.o.number = false
  end
end

-- toggle statuscolum between absolute and relative line numbers
-- by default, it is mapped to <C-l><C-l>
function M.toggle_statuscol()
  if M.perm_config.statuscol_current == 'normal' then
    M.set_statuscol('rel')
    return
  end
  if M.perm_config.statuscol_current == 'rel' then
    M.set_statuscol('normal')
    return
  end
end

-- toggle the right colorcolumn value (right margin).
-- this can be different, depending on filetype. The relevant table is in vim.g.config.colorcolumn.
-- by default, this is mapped to <C-l><C-k>
function M.toggle_colorcolumn()
  if vim.opt_local.colorcolumn._value ~= "" then
    vim.opt_local.colorcolumn = ""
  else
    local filetype = vim.bo.filetype
    for _,v in pairs(vim.g.config.colorcolumns) do
      if string.find(v.filetype, filetype) then
        vim.opt_local.colorcolumn = v.value
        return
      end
    end
    vim.opt_local.colorcolumn = vim.g.config.colorcolumns.all.value
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
--- @param max_length number: the maximum length
--- @return string:           the truncated text
function M.truncate(text, max_length)
  if #text > max_length then
    return string.sub(text, 1, max_length) .. "…"
  else
    return text
  end
end

--- global function to create a view
--- this creates a view using mkview unless the buffer has no file name or is not a file at all.
function M.mkview()
  if #vim.fn.expand("%") > 0 and vim.api.nvim_buf_get_option(0, "buftype") ~= 'nofile' then
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
  if vim.opt_local.wrap._value == true then
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
--- @return number: the window id
function M.splittree(_factor)
  local factor = (_factor ~= nil and _factor > 0) and _factor or 0.33
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
    vim.cmd("set nonumber | set norelativenumber | set signcolumn=no | set winhl=Normal:NeoTreeNormalNC | set foldcolumn=0")
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
    for i,_ in pairs(winid) do
      if winid[i] > 0 and vim.api.nvim_win_is_valid(winid[i]) then
        vim.api.nvim_win_close(winid[i], {})
        if M.term.winid ~= nil then
          vim.api.nvim_win_set_height(M.term.winid, M.perm_config.terminal.height)
        end
      end
    end
  end
end

--- opens a terminal split at the bottom. May also open the sysmon and weather
--- splits
--- @param _height number: height of the terminal split to open.
function M.termToggle(_height)
  local height = _height or M.term.height
  -- if it is visible, then close it an all sub frames
  -- but leave the buffer open
  if M.term.visible == true then
    require("local_utils.usplit").close()
    require("local_utils.wsplit").close()
    vim.api.nvim_win_hide(M.term.winid)
    M.term.visible = false
    M.term.winid = nil
    return
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
  vim.cmd("setlocal statuscolumn=%#NeoTreeNormalNC#\\  | set filetype=terminal | set nonumber | set norelativenumber | set foldcolumn=0 | set signcolumn=no | set winfixheight | set nocursorline | set winhl=SignColumn:NeoTreeNormalNC,Normal:NeoTreeNormalNC")
  M.term.winid = vim.fn.win_getid()
  vim.api.nvim_win_set_option(M.term.winid, "statusline", "  Terminal")
  M.term.bufid = vim.api.nvim_get_current_buf()
  M.term.visible = true

  -- finally, open the sub frames if they were previously open
  if M.perm_config.sysmon.active == true then
    require("local_utils.usplit").open()
  end
  if M.perm_config.weather.active == true then
    require("local_utils.wsplit").open(vim.g.config.weather.file)
  end
end

--- write the configuration to the json file
--- do not write it when running in plain mode (without additional frames and content)
function M.write_config()
  if vim.g.config.plain == true then
    return
  end
  local file = get_permconfig_file()
  local f = io.open(file, "w+")
  if f ~= nil then
    local wsplit_id = require("local_utils.wsplit").winid
    local usplit_id = require("local_utils.usplit").winid
    local blist_id = require("local_utils.blist").main_win

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
      blist = blist_id ~=nil and true or false,
      tree = #M.findwinbyBufType("NvimTree") > 0 and true or false,
      theme_variant = vim.g.theme_variant,
      theme_desaturate = vim.g.theme_desaturate
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
function M.restore_config()
  local file = get_permconfig_file()
  local f = io.open(file, "r")
  if f ~= nil then
    local string = f:read()
    local tmp = vim.fn.json_decode(string)
    M.perm_config = vim.tbl_deep_extend("force", M.perm_config_default, tmp)
  else
    M.perm_config = M.perm_config_default
  end
  vim.g.theme_variant = M.perm_config.theme_variant
  vim.g.theme_desaturate = M.perm_config.theme_desaturate
end

--- adjust the optional frames so they will keep their width when the side tree opens or closes
function M.adjust_layout()
  local globals = require("globals")
  local usplit = require("local_utils.usplit").winid
  local wsplit = require("local_utils.wsplit").winid
  if usplit ~= nil then
    vim.api.nvim_win_set_width(usplit, globals.perm_config.sysmon.width)
  end
  if wsplit ~= nil then
    vim.api.nvim_win_set_width(wsplit, globals.perm_config.weather.width)
  end
end

--- bound to a hotkey ("C-l C-t" by default)
--- toggle between warm and cold theme variants
function M.toggle_theme_variant()
  if vim.g.theme_variant == 'warm' then
    vim.g.theme_variant = 'cold'
  else
    vim.g.theme_variant = 'warm'
  end
  vim.cmd("colorscheme " .. M.perm_config.theme_name)
end

--- toggle theme saturate state. By default bound to C-l C-d
--- desaturated means a more pastel and less vivid color contrast
function M.toggle_theme_desaturate()
  vim.g.theme_desaturate = not vim.g.theme_desaturate
  vim.cmd("colorscheme " .. M.perm_config.theme_name)
end

--- function called when the automaton workspace changes
--- @param ws table: the new workspace
--- currently not in use
function M.workspace_changed(ws)
  print(ws)
end

--- try to format a souce file by using one of the defined formatter programs
function M.format_source()
  local ft = vim.api.nvim_buf_get_option(0, "filetype")
  if vim.g.formatters[ft] ~= nil then
    local cmd = "!" .. vim.g.formatters[ft].cmd .. " " .. vim.fn.expand("%:p")
    vim.cmd(cmd)
  end
end

--- this function determines the path where a latex-generated PDF may reside. It depends on the 
--- setting of config.texoutput. If this is set and _useglobal is true, then the global output
--- path will be used. Otherwise, the .pdf is expected in the same directory as the .tex file
--- @param _filename string: the filename to analyze
--- @param _useglobal boolean: use the global texoutput directory
function M.getLatexPreviewPath(_filename, _useglobal)
  local useglobal = _useglobal or false
  local path = vim.fn.expand(vim.g.config.texoutput)
  local finalpath

  if useglobal == true and #path > 0 and vim.fn.isdirectory(path) == 0 then
    finalpath = path .. vim.fn.expand(vim.fn.fnamemodify(_filename, ":t:r")) .. ".pdf"
  else
    finalpath = vim.fn.expand(vim.fn.fnamemodify(_filename, ":r")) .. ".pdf"
  end
  if vim.fn.filereadable(finalpath) == 1 then
    return true, finalpath
  else
    return false, ""
  end
end

return M
