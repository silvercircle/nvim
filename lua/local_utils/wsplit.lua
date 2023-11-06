-- implements a split window showing weather data.
-- depends on my ~/.weather/weather data file, created by fetchweather
-- this is useless without.
-- requires a NERDFont
local globals = require("globals")

local M = {}
M.winid = nil             -- window id
M.bufid = nil             -- buffer id
M.win_width = nil
M.win_height = nil
M.weatherfile = ""

local watch = nil

-- this translates condition codes (single letters) to actual readable conditions. This is API specific
-- and right now only implemented for the VC API (visual crossing)
local conditions = {
  VC = {
    c = "󰖕 Partly Cloudy",
    a = "󰖙 Clear",
    e = "󰖐 Cloudy",
    j = "󰖖 Rain",
    o = "󰼶 Snow",
    g = "󰖗 Showers",
    k = "󰖓 Thunderstorm"
  }
}

-- handles resize and close events. Called from auto.lua resize/close handler
-- it removes the buffer when the window has disappeared. Otherwise it refreshes
-- it.
function M.resize_or_closed()
  if M.winid ~= nil and vim.api.nvim_win_is_valid(M.winid) == false then  -- window has disappeared
    if M.bufid ~= nil then
      vim.api.nvim_buf_delete(M.bufid, { force = true })
      M.bufid = nil
    end
    M.winid = nil
  else
    vim.api.nvim_win_set_height(M.winid, vim.g.config.weather.required_height)
    M.refresh()
  end
end

--- handles file watcher events.
local function onChange(cust, _, _, status)
  if not status.change then
    --source.debugmsg("No status change, do nothing")
    return
  end
  if watch ~= nil then
    vim.loop.fs_event_stop(watch)
  end
  M.refresh()
  if watch ~= nil then
    vim.loop.fs_event_start(watch, M.weatherfile, {}, vim.schedule_wrap(function(...) onChange(cust, ...) end))
  end
end

--- install the file watcher local function with onChange(...) as event handler
--- when the file containing the weather dump changes, refresh the buffer
function M.installwatch()
  if watch == nil then
    watch = vim.loop.new_fs_event()
  end
  if watch ~= nil then
    if vim.fn.filereadable(M.weatherfile) then
      vim.loop.fs_event_start(watch, M.weatherfile, {}, vim.schedule_wrap(function(...) onChange(M.weatherfile, ...) end))
    end
  end
end

function M.open(_weatherfile)
  local wid = globals.findwinbyBufType("terminal")
  local curwin = vim.api.nvim_get_current_win()     -- remember active win for going back
  M.weatherfile = vim.fn.expand(_weatherfile)

  if vim.fn.filereadable(M.weatherfile) == 0 then
    return
  end
  -- glances must be executable otherwise do nothing
  -- also, a terminal split must be present.
  if #wid > 0 and vim.fn.filereadable(M.weatherfile) then
    vim.fn.win_gotoid(wid[1])
    vim.cmd((vim.g.config.weather.splitright == true and "setlocal splitright | " or "") .. globals.perm_config.weather.width .. " vsp new")
    M.winid = vim.fn.win_getid()
    M.bufid = vim.api.nvim_get_current_buf()
    vim.bo[M.bufid].buflisted = false
    vim.api.nvim_buf_set_option(M.bufid, "buftype", "nofile")
    vim.api.nvim_win_set_option(M.winid, "list", false)
    vim.api.nvim_win_set_option(M.winid, "statusline", "  Weather")
    vim.cmd("set winfixheight | set filetype=weather | set nonumber | set signcolumn=no | set winhl=Normal:NeoTreeNormalNC | set foldcolumn=0 | set statuscolumn=%#NeoTreeNormalNC#\\  | setlocal nocursorline")
    vim.fn.win_gotoid(curwin)
  end
  M.refresh()
  M.installwatch()
end

--- open the weather split in a split of the nvim-tree
function M.openleftsplit(_weatherfile)
  local curwin = vim.api.nvim_get_current_win()     -- remember active win for going back
  M.weatherfile = vim.fn.expand(_weatherfile)

  if vim.fn.filereadable(M.weatherfile) == 0 then
    return
  end
  M.winid = require("globals").splittree(vim.g.config.weather.required_height)
  if M.winid == 0 then
    print("Could not find split")
    M.close()
    return
  end
  if vim.fn.filereadable(M.weatherfile) == 1 then
    vim.fn.win_gotoid(M.winid)
    M.bufid = vim.api.nvim_create_buf(false, true)
    vim.bo[M.bufid].buflisted = false
    vim.api.nvim_win_set_buf(M.winid, M.bufid)
    vim.api.nvim_buf_set_option(M.bufid, "buftype", "nofile")
    vim.api.nvim_win_set_option(M.winid, "list", false)
    vim.api.nvim_win_set_option(M.winid, "statusline", "  Weather")
    vim.cmd("set winfixheight | set filetype=weather | set nonumber | set signcolumn=no | set winhl=Normal:NeoTreeNormalNC | set foldcolumn=0 | set statuscolumn=%#NeoTreeNormalNC#\\  | setlocal nocursorline")
    vim.fn.win_gotoid(curwin)
  end
  M.refresh()
  M.installwatch()
end
--- prepare a line with two elements
--- @param _left string: the left part of the line
--- @param _right string: The right part
--- @param correct number: a correction value to control the padding
--- @return string: the line to print
function M.prepare_line(_left, _right, correct)
  local format = "%-" .. math.floor(M.win_width / 2) .. "s"
  local left = string.format(format, _left)
  format = "%-15s"
  local right = string.format(format, _right)

  local pad = string.rep(" ", M.win_width - 2 - vim.fn.strwidth(right) - vim.fn.strwidth(left) + correct)
  return left .. pad .. right .. " "
end

--- close the buffer, temporarily stop the file watcher
function M.close()
  if M.winid ~= nil then
    vim.api.nvim_win_close(M.winid, {force=true})
  end
  if watch ~= nil then
    vim.loop.fs_event_stop(watch)
  end
end

--- set a highlight group for the given temperature
--- @param temp string: the temperature
--- @return string: the hl group
--- TODO: make this customizable via a setup() method
local function temp_to_hl(temp)
  local t = tonumber(string.gsub(temp, "°C", ""), 10)
  if t <= 0 then
    return "Purple"
  elseif t <= 5 then
    return "Blue"
  elseif t > 0 and t < 10 then
    return "Green"
  elseif t >= 10 and t <= 20 then
    return "Yellow"
  elseif t > 20 and t <= 27 then
    return "Orange"
  elseif t > 27 and t < 35 then
    return "PaleRed"
  else
    return "Red"
  end
end

--- set a highlight group for the wind speed
--- @param wind string: wind speed (assumed in km/h)
--- @return string: A hl group
--- TODO: make this customizable via a setup() method
local function wind_to_hl(wind)
  local w = tonumber(string.gsub(wind, "km/h", ""), 10)
  if w < 5 then
    return "Green"
  elseif w < 10 then
    return "Yellow"
  elseif w < 25 then
    return "Orange"
  elseif w < 50 then
    return "PaleRed"
  elseif w < 70 then
    return "Red"
  else
    return "Purple"
  end
end

--- refresh the buffer. Called when the window is resized or the file watcher detects a change
--- in the weather file
function M.refresh()
  local results = {}

  if M.bufid == nil or M.winid == nil then
    return
  end

  if M.winid ~= nil and vim.api.nvim_win_is_valid(M.winid) then
    M.win_width = vim.api.nvim_win_get_width(M.winid)
    M.win_height = vim.api.nvim_win_get_height(M.winid)
  else
    return
  end
  vim.api.nvim_buf_clear_namespace(M.bufid, -1, 0, -1)

  if vim.fn.filereadable(M.weatherfile) then
    local lines = {}
    local file = io.open(M.weatherfile)
    local index = 1
    local hl
    if file ~= nil then
      local l = file:lines()
      for line in l do
        results[tostring(index)] = line
        index = index + 1
      end
      io.close(file)
      vim.api.nvim_buf_set_option(M.bufid, "modifiable", true)
      local lcond = conditions[results['37']][string.lower(results['2'])]
      table.insert(lines, " ")
      table.insert(lines, M.prepare_line(results['26'], " " .. results['28'], 0))
      table.insert(lines, M.prepare_line(lcond, results['33'], 1))
      table.insert(lines, "  ")
      table.insert(lines, M.prepare_line("Temp: " .. results['3'],    "Feels: " .. results['16'], 0))
      table.insert(lines, M.prepare_line("Min:  " .. results['29'],   "Max:   " .. results['30'], 0))
      table.insert(lines, M.prepare_line("Dew:  " .. results['17'],   " " .. results['21'], 0))
      table.insert(lines, M.prepare_line("API:  " .. results['37'],   " " .. results['31'], 0))
      table.insert(lines, M.prepare_line("  " .. results['25'] .. " at " .. results['20'] .. "  ", " Vis: " .. results['22'], 0))
      table.insert(lines, M.prepare_line("Pressure: " .. results['19'], " " .. results['18'], 0))
      table.insert(lines, M.prepare_line("  " .. results['23'], "滋" .. results['24'], -2))
      local cond = conditions[results['37']][results['4']]
      if cond == nil then
        cond = "N/A"
      end
      table.insert(lines, "  ")
      table.insert(lines, M.prepare_line(results['7'] .. ": " .. cond, "  " .. results['5'] .. "°C "  .. results['6'] .. "°C", -1))
      -- set highlights. Use the max expected temp to highlight general conditions or specific
      -- temps (like the Dew Point)
      hl = temp_to_hl(results['6'])
      vim.api.nvim_buf_set_lines(M.bufid, 0, -1, false, lines)
      vim.api.nvim_buf_add_highlight(M.bufid, -1, hl, 11, 0, -1)

      vim.api.nvim_buf_add_highlight(M.bufid, -1, "Debug", 1, 0, -1)
      -- temp
      hl = temp_to_hl(results['3'])       -- the current temperature, also colorize the condition string
      vim.api.nvim_buf_add_highlight(M.bufid, -1, hl, 2, 0, -1)
      vim.api.nvim_buf_add_highlight(M.bufid, -1, hl, 4, 0, 20)
      hl = temp_to_hl(results['16'])
      vim.api.nvim_buf_add_highlight(M.bufid, -1, hl, 4, 20, -1)

      hl = temp_to_hl(results['29'])
      vim.api.nvim_buf_add_highlight(M.bufid, -1, hl, 5, 0, 20)
      hl = temp_to_hl(results['30'])
      vim.api.nvim_buf_add_highlight(M.bufid, -1, hl, 5, 20, -1)
      hl = temp_to_hl(results['17'])
      vim.api.nvim_buf_add_highlight(M.bufid, -1, hl, 6, 0, 20)

      hl = wind_to_hl(results['20'])
      vim.api.nvim_buf_add_highlight(M.bufid, -1, hl, 8, 0, 25)
      vim.api.nvim_buf_set_option(M.bufid, "modifiable", false)
    end
  end

end

return M
