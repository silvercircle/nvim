local globals = require("globals")

local M = {}
M.winid = nil             -- window id
M.bufid = nil             -- buffer id
M.win_width = nil
M.win_height = nil
M.autocmds_valid = nil
M.watch = nil

M.autocmds_valid = nil    -- auto command was set
M.weatherfile = "~/.weather/weather"

M.conditions = {
  VC = {
    c = "Partly Cloudy",
    a = "Clear",
    e = "Cloudy",
    j = "Rain",
    o = "Snow",
    g = "Showers",
    k = "Thunderstorm"
  }
}

function M.setup_auto()
  if M.autocmds_valid == true then
    return
  end
  M.autocmds_valid = true
  vim.api.nvim_create_augroup("WeatherSplit", { clear = true })
  vim.api.nvim_create_autocmd({ "WinClosed", "WinResized" }, {
    group = "WeatherSplit",
    callback = function()
      if M.winid ~= nil and vim.api.nvim_win_is_valid(M.winid) == false then  -- window has disappeared
        if M.bufid ~= nil then
          vim.api.nvim_buf_delete(M.bufid, { force = true })
          M.bufid = nil
        end
        M.winid = nil
      else
        M.refresh()
      end
    end,
  })
end

local function onChange(cust, _, _, status)
  if not status.change then
    --source.debugmsg("No status change, do nothing")
    return
  end
  if M.watch ~= nil then
    vim.loop.fs_event_stop(M.watch)
  end
  M.refresh()
  if M.watch ~= nil then
    vim.loop.fs_event_start(M.watch, M.weatherfile, {}, vim.schedule_wrap(function(...) onChange(cust, ...) end))
  end
end

function M.open()
  local wid = globals.findwinbyBufType("terminal")
  local curwin = vim.api.nvim_get_current_win()     -- remember active win for going back
  M.weatherfile = vim.fn.expand(M.weatherfile)

  -- glances must be executable otherwise do nothing
  -- also, a terminal split must be present.
  if #wid > 0 and vim.fn.filereadable(M.weatherfile) then
    vim.fn.win_gotoid(wid[1])
    vim.cmd("setlocal splitright | " .. vim.g.config.weather.width .. " vsp new")
    M.winid = vim.fn.win_getid()
    M.bufid = vim.api.nvim_get_current_buf()
    vim.bo[M.bufid].buflisted = false
    vim.api.nvim_buf_set_option(M.bufid, "buftype", "nofile")
    vim.api.nvim_win_set_option(M.winid, "list", false)
    vim.api.nvim_win_set_option(M.winid, "statusline", "Weather")
    vim.cmd("set filetype=weather | set nonumber | set signcolumn=no | set winhl=Normal:NeoTreeNormalNC | set foldcolumn=0 | set statuscolumn= | setlocal nocursorline")
    vim.fn.win_gotoid(curwin)
  end
  M.setup_auto()
  M.refresh()
  if M.watch == nil then
    M.watch = vim.loop.new_fs_event()
  end
  if M.watch ~= nil then
    if vim.fn.filereadable(M.weatherfile) then
      vim.loop.fs_event_start(M.watch, M.weatherfile, {}, vim.schedule_wrap(function(...) onChange(M.weatherfile, ...) end))
    end
  end
  -- vim.fn.timer_start(vim.g.config.weather.interval, function() M.refresh() end)
end

function M.prepare_line(_left, _right, correct)
  local format = "%-" .. math.floor(M.win_width / 2) .. "s"
  local left = string.format(format, _left)
  format = "%-15s"
  local right = string.format(format, _right)
  local pad = string.rep(" ", M.win_width - 2 - #right - #left + correct)
  return " " .. left .. pad .. right .. " "
end

function M.close()
  if M.winid ~= nil then
    vim.api.nvim_win_close(M.winid, {force=true})
  end
  if M.watch ~= nil then
    vim.loop.fs_event_stop(M.watch)
  end
end

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
      table.insert(lines, M.prepare_line(results['26'], results['28'], 1))
      table.insert(lines, M.prepare_line(results['27'], "API: " .. results['37'], 1))
      table.insert(lines, "  ")
      table.insert(lines, M.prepare_line("Temp: " .. results['3'],    "Feels: " .. results['16'], 2))
      table.insert(lines, M.prepare_line("Min:  " .. results['29'],   "Max:   " .. results['30'], 2))
      table.insert(lines, M.prepare_line("Dew:  " .. results['17'],   results['21'] .. "      ", 2))
      table.insert(lines, M.prepare_line("", results['31'], 1))
      table.insert(lines, M.prepare_line(" " .. results['25'] .. " at " .. results['20'] .. "  ", " Vis: " .. results['22'], 2))
      table.insert(lines, M.prepare_line("Pressure: " .. results['19'], results['18'], 1))
      table.insert(lines, M.prepare_line("Sunrise: " .. results['23'], "Sunset: " .. results['24'], 1))
      local cond = M.conditions[results['37']][results['4']]
      if cond == nil then
        cond = "N/A"
      end
      table.insert(lines, "  ")
      table.insert(lines, M.prepare_line("Tomorrow: " .. cond, "    " .. results['5'] .. "°C "  .. results['6'] .. "°C", 2))

      vim.api.nvim_buf_set_lines(M.bufid, 0, -1, false, lines)

      vim.api.nvim_buf_add_highlight(M.bufid, -1, "Debug", 0, 0, -1)
      vim.api.nvim_buf_add_highlight(M.bufid, -1, "Keyword", 1, 0, -1)
      -- temp
      hl = temp_to_hl(results['3'])
      vim.api.nvim_buf_add_highlight(M.bufid, -1, hl, 3, 0, 20)
      hl = temp_to_hl(results['16'])
      vim.api.nvim_buf_add_highlight(M.bufid, -1, hl, 3, 20, -1)

      hl = temp_to_hl(results['29'])
      vim.api.nvim_buf_add_highlight(M.bufid, -1, hl, 4, 0, 20)
      hl = temp_to_hl(results['30'])
      vim.api.nvim_buf_add_highlight(M.bufid, -1, hl, 4, 20, -1)
      hl = temp_to_hl(results['17'])
      vim.api.nvim_buf_add_highlight(M.bufid, -1, hl, 5, 0, 20)

      hl = wind_to_hl(results['20'])
      vim.api.nvim_buf_add_highlight(M.bufid, -1, hl, 7, 0, 25)
      vim.api.nvim_buf_set_option(M.bufid, "modifiable", false)
    end
  end

end

return M
