-- implements a split window showing weather data or buffer information
-- weather display depends on my ~/.weather/weather data file, created by fetchweather
-- this is useless without.
-- requires a NERDFont

---@class subspace.Wsplit
---@field id_win integer
---@field id_buf integer
---@field id_tab integer
---@field id_ns  integer
---@field width  integer
---@field content string
---@field old_dimensions table
---@field provider? subspace.providers.Wx|subspace.providers.Info
---@field timer uv.uv_timer_t

local Wsplit = {}
Wsplit.__index = Wsplit

Wsplit.weatherfile = ""
Wsplit.nsid = nil
Wsplit.cookie_source = Tweaks.cookie_source

local cookie_timer_interval = 900000

---@type uv.uv_timer_t?
local wsplit_cookie_timer = nil

local autocmd_set = false -- remember whether the OptionSet autocmd has been set

---@return subspace.Wsplit
---@param  t integer - the tabpage
---@param  tim uv.uv_timer_t timer object
function Wsplit:new(t, tim)
  return setmetatable({
    id_win = 0,
    id_tab = t,
    id_buf = 0,
    id_ns  = Wsplit.nsid and Wsplit.nsid or vim.api.nvim_create_namespace("wsplit" .. tostring(t)),
    content = PCFG.weather.content,
    provider = nil,
    timer = tim,
    old_dimensions = {
      w = 0, h = 0
    }
  }, self)
end

function Wsplit:render()
end

function Wsplit:destroy()
end

-- split the file tree horizontally
--- @param _factor number:  if _factor is betweeen 0 and 1 it is interpreted as percentage
--  of the window to split. Otherwise as an absolute number. The default is set to 1/3 (0.33)
--- @return integer: the window id, 0 if the process failed
function Wsplit.splittree(_factor)
  local factor = math.abs((_factor ~= nil and _factor > 0) and _factor or 0.33)
  local winid = TABM.findWinByFiletype(Tweaks.tree.filetype, true)
  if #winid > 0 then
    local splitheight = (factor < 1) and (vim.fn.winheight(winid[1]) * factor) or factor
    vim.fn.win_gotoid(winid[1])
    vim.cmd("below " .. splitheight .. " sp wsplit_" .. winid[1])
    local wid = vim.fn.win_getid()
    vim.api.nvim_set_option_value("list", false, { win = wid })
    vim.cmd("set nonumber | set norelativenumber | set signcolumn=no | set winhl=Normal:TreeNormalNC | set foldcolumn=0")
    vim.fn.win_gotoid(TABM.get().id_main)
    return wid
  end
  return 0
end

-- set minimum height of the window. Depends on the content type.
function Wsplit.set_minheight()
  local wsplit = TABM.get().wsplit
  if wsplit.id_win ~= nil and vim.api.nvim_win_is_valid(wsplit.id_win) then
    if wsplit.provider then
      vim.api.nvim_win_set_height(wsplit.id_win, wsplit.provider.min_height)
    end
  end
end

-- reconfigure the rendering
function Wsplit.on_content_change()
  local wsplit = TABM.get().wsplit

  PCFG.weather.content = wsplit.content
  wsplit.content_id_win = vim.fn.win_getid()
  if wsplit.provider then wsplit.provider:destroy() wsplit.provider = nil end
  if wsplit.content == "weather" then
    vim.api.nvim_set_option_value("statusline", " 󰏈  Weather", { win = wsplit.id_win })
    wsplit.provider = require("subspace.content.providers.wx").new(wsplit)
  elseif wsplit.content == "info" then
    vim.api.nvim_set_option_value("statusline", " 󰋼  Information", { win = wsplit.id_win })
    wsplit.provider = require("subspace.content.providers.info").new(wsplit)
  end
  Wsplit.set_minheight()
  Wsplit.refresh("on_content_change()")
end

--- toggle window content
function Wsplit.toggle_content()
  local wsplit = TABM.get().wsplit
  if wsplit.content == "info" then
    wsplit.content = "weather"
  elseif wsplit.content == "weather" then
    wsplit.content = "info"
  end
  wsplit.freeze = false
  Wsplit.on_content_change()
end

--- set content type
--- @param _content string: content type. Allowed are 'info' or 'weather'
function Wsplit.set_content(_content)
  if _content ~= nil and (_content == "info" or _content == "weather") then
    TABM.T[TABM.active].wsplit.content = _content
    Wsplit.on_content_change()
  end
end

-- handles resize and close events. Called from auto.lua resize/close handler
-- it removes the buffer when the window has disappeared. Otherwise it refreshes
-- it.
function Wsplit.resize_or_closed()
  local wsplit = TABM.get().wsplit
  if wsplit.id_win ~= nil and vim.api.nvim_win_is_valid(wsplit.id_win) == false then -- window has disappeared
    if wsplit.id_buf ~= nil then
      vim.api.nvim_buf_delete(wsplit.id_buf, { force = true })
      wsplit.id_buf = nil
    end
    wsplit.id_win = nil
  elseif wsplit.id_win ~= nil then
    Wsplit.set_minheight()
    Wsplit.refresh("resize_or_closed")
  end
end

--- handles file watcher events.
local function onChange(cust, _, _, status)
  if not status.change then
    --source.debugmsg("No status change, do nothing")
    return
  end
  local wsplit = TABM.get().wsplit
  if wsplit.watch ~= nil then
    vim.uv.fs_event_stop(wsplit.watch)
  end
  Wsplit.refresh("onChange()")
  if wsplit.watch ~= nil then
    vim.uv.fs_event_start(
      wsplit.watch,
      Wsplit.weatherfile,
      {},
      vim.schedule_wrap(function(...)
        onChange(cust, ...)
      end)
    )
  end
end

--- install the file watcher local function with onChange(...) as event handler
--- when the file containing the weather dump changes, refresh the buffer
function Wsplit.installwatch()
  local wsplit = TABM.get().wsplit
  if wsplit.watch == nil then
    wsplit.watch = vim.uv.new_fs_event()
  end
  if wsplit.watch ~= nil then
    if vim.fn.filereadable(Wsplit.weatherfile) then
      vim.uv.fs_event_start(
        wsplit.watch,
        Wsplit.weatherfile,
        {},
        vim.schedule_wrap(function(...)
          onChange(Wsplit.weatherfile, ...)
        end)
      )
    end
  end
  if autocmd_set == false then
    autocmd_set = true
    vim.api.nvim_create_autocmd({ "OptionSet" }, {
      -- TODO: update this when adding new options of interest
      pattern = { "wrap", "formatoptions", "textwidth", "foldmethod", "filetype" },
      callback = function()
        -- weather content refreshes from a file watcher
        if wsplit.content ~= "weather" then
          Wsplit.refresh("installwatch()")
        end
      end,
    })
  end
  if wsplit_cookie_timer == nil then
    wsplit_cookie_timer = vim.uv.new_timer()
    if wsplit_cookie_timer ~= nil then
      wsplit_cookie_timer:start(0, cookie_timer_interval, vim.schedule_wrap(Wsplit.refresh_cookie))
    end
  end
  Wsplit.set_minheight()
end

--- open the weather split in a split of the nvim-tree
function Wsplit.open(_weatherfile)
  local wsplit = TABM.get().wsplit
  local curwin = vim.api.nvim_get_current_win() -- remember active win for going back
  if Wsplit.nsid == nil then Wsplit.nsid = vim.api.nvim_create_namespace("wsplit") end
  Wsplit.weatherfile = vim.fn.expand(_weatherfile)
  wsplit.id_win = Wsplit.splittree(CFG.weather.required_height)
  if wsplit.id_win == 0 then
    Wsplit.close()
    return
  end
  wsplit.id_buf = vim.api.nvim_win_get_buf(wsplit.id_win)
  wsplit.id_tab = TABM.active
  if vim.fn.filereadable(Wsplit.weatherfile) == 0 then
    wsplit.content = "info"
  end
  vim.fn.win_gotoid(wsplit.id_win)
  vim.bo[wsplit.id_buf].buflisted = false
  --vim.api.nvim_win_set_buf(wsplit.id_win, wsplit.id_buf)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = wsplit.id_buf })
  vim.api.nvim_set_option_value("list", false, { win = wsplit.id_win })
  vim.cmd("set winfixheight | setlocal statuscolumn=| set filetype=weather | set nonumber |\
    set signcolumn=no | set winhl=Normal:TreeNormalNC | set foldcolumn=0 | setlocal nocursorline")
  vim.fn.win_gotoid(curwin)
  Wsplit.refresh("openleftsplit()")
  Wsplit.installwatch()
  PCFG.weather.active = true
  Wsplit.refresh_tab_cookie(TABM.active)
  Wsplit.on_content_change()
end

--- prepare a line with two elements
--- @param _left string: the left part of the line
--- @param _right string: The right part
--- @param correct number: a correction value to control the padding
--- @return string: the line to print
function Wsplit.prepare_line(_left, _right, correct)
  local format = "%-" .. math.floor(TABM.T[TABM.active].wsplit.width / 2) .. "s"
  local left = string.format(format, _left)
  format = "%-16s"
  local right = string.format(format, _right)

  local pad = string.rep(" ", TABM.T[TABM.active].wsplit.width - 2 - vim.fn.strwidth(right) - vim.fn.strwidth(left) + correct)
  return left .. pad .. right .. " "
end

--- close the buffer, temporarily stop the file watcher
function Wsplit.close()
  local wsplit = TABM.get().wsplit
  if wsplit.id_win ~= nil then
    vim.api.nvim_win_close(wsplit.id_win, { force = true })
    wsplit.id_win = nil
  end
  if wsplit.watch ~= nil then
    vim.uv.fs_event_stop(wsplit.watch)
  end
  if wsplit.timer ~= nil then
    wsplit.timer:stop()
  end
  if Wsplit.nsid ~= nil then
    vim.api.nvim_buf_clear_namespace(wsplit.id_buf, Wsplit.nsid, 0, -1)
  end
  if wsplit.provider then
    wsplit.provider:destroy()
    wsplit.provider = nil
  end
  wsplit.cookie = {}
end

-- refresh the cookie
-- this can be any shell command that returns a string with multiple lines
-- it could be a fortune cookie or anything for example. It should not be longe
-- than 4 lines at most otherwise it will be clipped at the bottom of the frame.
---@param id_tab? integer tab page id
function Wsplit.refresh_tab_cookie(id_tab)
  id_tab = id_tab or TABM.active
  local wsplit = TABM.T[id_tab].wsplit
  for i, _ in ipairs(wsplit.cookie) do
    wsplit.cookie[i] = nil
  end
  vim.fn.jobstart(Wsplit.cookie_source .. "|fmt -" .. wsplit.width - 2, {
    on_stdout = function(_, b, _)
      for _, v in ipairs(b) do
        table.insert(wsplit.cookie, v)
      end
    end,
    on_exit = function()
      Wsplit.refresh("refresh_cookie()")
    end,
  })
end

function Wsplit.refresh_cookie()
  for _,v in ipairs(TABM.T) do
    if v.wsplit.id_win and vim.api.nvim_win_is_valid(v.wsplit.id_win) then
      Wsplit.refresh_tab_cookie(v.id_page)
    end
  end
end

--- refresh the buffer. Called when the window is resized or the file watcher detects a change
--- in the weather file. For info content, this is called when:
---   a) one option of interest changes
---   b) The current window or buffer changes (WinEnter, BufWinEnter events)
function Wsplit.refresh(reason)
  -- assume resize when no reason is given
  reason = reason or "resize"
  local wsplit = TABM.get().wsplit

  if wsplit.id_buf == nil or wsplit.id_win == nil then
    return
  end

  if wsplit.id_win ~= nil and vim.api.nvim_win_is_valid(wsplit.id_win) then
    wsplit.width = vim.api.nvim_win_get_width(wsplit.id_win)
    wsplit.height = vim.api.nvim_win_get_height(wsplit.id_win)
    if reason == "resize" and wsplit.width == wsplit.old_dimensions.w and wsplit.height == wsplit.old_dimensions.h then
      return
    else
      wsplit.old_dimensions.w = wsplit.width
      wsplit.old_dimensions.h = wsplit.height
    end
  else
    return
  end

  vim.api.nvim_set_option_value("modifiable", true, { buf = wsplit.id_buf })
  _ = wsplit.provider and wsplit.provider:render() or nil
  vim.api.nvim_set_option_value("modifiable", false, { buf = wsplit.id_buf })
end

return Wsplit
