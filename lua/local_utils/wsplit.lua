-- implements a split window showing weather data or buffer information
-- weather display depends on my ~/.weather/weather data file, created by fetchweather
-- this is useless without.
-- requires a NERDFont
local globals = require("globals")
local plenary = require("plenary.path")
local utils = require("local_utils")

local M = {}
M.winid = nil             -- window id
M.bufid = nil             -- buffer id
M.win_width = nil         -- horizontal requirement
M.win_height = nil
M.weatherfile = ""
M.content = 'info'        -- content type (info or weather as of now)
M.content_winid = nil     -- window of interest.
M.freeze = false          -- do not refresh when set
M.cookie = {}

local watch = nil             -- file watcher (for weather content)
local timer = nil             -- timer (for info content)
local cookie_timer = nil
local timer_interval = 60000  -- timer interval
local cookie_timer_interval = 300000

local autocmd_set = false     -- remember whether the OptionSet autocmd has been set

-- this translates condition codes (single letters) to actual readable conditions. This is API specific
-- and right now only implemented for the VC API (visual crossing)
-- this also requires a NERD font.
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

-- folding modes (translate foldmethod to readable terms)
local fdm = {
  expr    = "Expression",
  manual  = "Manual",
  syntax  = "Syntax",
  indent  = "Indent",
  marker  = "Marker",
  diff    = "Diff"
}

--- truncate the path and display the rightmost maxlen characters
--- @param path string: A filepath
--- @param maxlen number: the desired length
--- @return string: the truncated path
local function path_truncate(path, maxlen)
  local len = string.len(path)
  if len <= maxlen then
    return path
  end
  local effective_width = maxlen - 3    -- make space for leading ...
  return "..." .. string.sub(path, len - effective_width, len)
end

-- reconfigure the rendering
function M.on_content_change()
  globals.perm_config.weather.content = M.content
  M.content_winid = vim.fn.win_getid()
  if M.content ~= 'weather' then
    if timer ~= nil then
      timer:stop()
      timer:start(0, timer_interval, vim.schedule_wrap(M.refresh_on_timer))
    end
  else
    if timer ~= nil then
      timer:stop()
    end
  end
  M.refresh()
end

--- toggle window content
function M.toggle_content()
  if M.content == 'info' then
    M.content = 'weather'
  elseif M.content == 'weather' then
    M.content = 'info'
  end
  M.on_content_change()
end

--- set content type
--- @param _content string: content type. Allowed are 'info' or 'weather'
function M.set_content(_content)
  if _content ~= nil and (_content == 'info' or _content == 'weather') then
    M.content = _content
    M.on_content_change()
  end
end

--- filetypes we are not interested in
local info_exclude = { "terminal", "Outline", "aerial", "NvimTree", "sysmon", "weather" }

--- set the window id of the buffer of interest
--- @param _id number: the window id
function M.content_set_winid(_id)
  if M.content ~= 'info' then
    return
  end
  local bufid = vim.api.nvim_win_get_buf(_id)
  if bufid ~= nil and vim.api.nvim_buf_is_valid(bufid) then
    -- ignore floating windows
    if vim.api.nvim_win_get_config(_id).relative ~= "" then
      return
    end
    globals.debugmsg("Set winid to " .. _id .. " and buffer to " .. bufid .. " and buftype to " .. vim.api.nvim_buf_get_option(bufid, "buftype") .. " and filetype to " .. vim.api.nvim_buf_get_option(bufid, "filetype"))
    -- ignore buffers without a type
    if vim.api.nvim_buf_get_option(bufid, "buftype") == 'nofile' then
      return
    end
    -- ignore certain filetypes
    if vim.tbl_contains(info_exclude, vim.api.nvim_buf_get_option(bufid, "filetype")) == true then
      M.freeze = true
      return
    end
    globals.debugmsg("Set content window id to " .. _id)
    M.content_winid = _id
    M.freeze = false
  end
end

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
  elseif M.winid ~= nil then
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
  if timer == nil then
    timer = vim.loop.new_timer()
  end
  if timer ~= nil then
    if M.content == 'info' then
      timer:start(0, timer_interval, vim.schedule_wrap(M.refresh_on_timer))
    end
  end
  if autocmd_set == false then
    autocmd_set = true
    vim.api.nvim_create_autocmd({ "OptionSet" }, {
      -- TODO: update this when adding new options of interest
      pattern = { "wrap", "formatoptions", "textwidth", "foldmethod", "filetype" },
      callback = function()
        -- weather content refreshes from a file watcher
        if M.content ~= 'weather' then
          M.refresh()
        end
      end,
    })
  end
  if cookie_timer == nil then
    cookie_timer = vim.loop.new_timer()
  end
  if cookie_timer ~= nil then
    cookie_timer:start(0, cookie_timer_interval, vim.schedule_wrap(M.refresh_cookie))
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
  globals.perm_config.weather.active = true
end

--- open the weather split in a split of the nvim-tree
function M.openleftsplit(_weatherfile)
  local curwin = vim.api.nvim_get_current_win()     -- remember active win for going back
  M.weatherfile = vim.fn.expand(_weatherfile)
  M.winid = require("globals").splittree(vim.g.config.weather.required_height)
  if M.winid == 0 then
    M.close()
    return
  end
  if vim.fn.filereadable(M.weatherfile) == 0 then
    M.content = 'info'
  end
  vim.fn.win_gotoid(M.winid)
  M.bufid = vim.api.nvim_create_buf(false, true)
  vim.bo[M.bufid].buflisted = false
  vim.api.nvim_win_set_buf(M.winid, M.bufid)
  vim.api.nvim_buf_set_option(M.bufid, "buftype", "nofile")
  vim.api.nvim_win_set_option(M.winid, "list", false)
  vim.cmd("set winfixheight | set filetype=weather | set nonumber | set signcolumn=no | set winhl=Normal:NeoTreeNormalNC | set foldcolumn=0 | set statuscolumn=%#NeoTreeNormalNC#\\  | setlocal nocursorline")
  vim.fn.win_gotoid(curwin)
  M.refresh()
  M.installwatch()
  globals.perm_config.weather.active = true
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
    M.winid = nil
  end
  if watch ~= nil then
    vim.loop.fs_event_stop(watch)
  end
  if timer ~= nil then
    timer:stop()
  end
  print("close wsplit")
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
  elseif t > 5 and t < 10 then
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

-- refresh the cookie 
function M.refresh_cookie()
  for i, _ in ipairs(M.cookie) do
    M.cookie[i] = nil
  end
  vim.fn.jobstart("curl -s -m 5 --connect-timeout 5 https://vtip.43z.one|fmt -" .. M.win_width - 2, {
    on_stdout = function(_, b, _) for _,v in ipairs(b) do table.insert(M.cookie, v) end end
  })
end
-- refresh on timer. But only for info content. Weather content ist handled by the
-- file watcher plugin
function M.refresh_on_timer()
  if M.content == 'weather' then
    return
  end
  M.refresh()
end
--- refresh the buffer. Called when the window is resized or the file watcher detects a change
--- in the weather file. For info content, this is called when:
---   a) one option of interest changes
---   b) The current window or buffer changes (WinEnter, BufWinEnter events)
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

  if M.content == 'info' then
    if M.freeze == true then
      return
    end
    vim.api.nvim_win_set_option(M.winid, "statusline", "ⓘ Information")

    vim.api.nvim_buf_clear_namespace(M.bufid, -1, 0, -1)
    if M.content_winid ~= nil and vim.api.nvim_win_is_valid(M.content_winid) then
      local curbuf = vim.api.nvim_win_get_buf(M.content_winid)

      vim.api.nvim_buf_set_option(M.bufid, "modifiable", true)
      local lines = {}
      local name = path_truncate(plenary:new(vim.api.nvim_buf_get_name(curbuf)):make_relative(), M.win_width - 3)

      local fn_symbol, fn_symbol_hl = utils.getFileSymbol(vim.api.nvim_buf_get_name(curbuf))
      table.insert(lines, utils.pad("Buffer Info", M.win_width, ' '))
      table.insert(lines, utils.pad(name, M.win_width, ' '))
      table.insert(lines, " ")
      -- size of buffer. Bytes, KB or MB
      if globals.cur_bufsize > 1 then
        local size = globals.cur_bufsize
        if size < 1024 then
          table.insert(lines, M.prepare_line("Size: " .. size .. " Bytes", "Lines: " .. vim.api.nvim_buf_line_count(curbuf), 2))
        elseif size < 1024 * 1024 then
          table.insert(lines, M.prepare_line("Size: " .. string.format("%.2f", size / 1024) .. " KB", "Lines: " .. vim.api.nvim_buf_line_count(curbuf), 2))
        else
          table.insert(lines, M.prepare_line("Size: " .. string.format("%.2f", size / 1024 / 1024) .. " MB", "Lines: " .. vim.api.nvim_buf_line_count(curbuf), 2))
        end
        table.insert(lines, M.prepare_line("Type: " .. vim.api.nvim_get_option_value("filetype", { buf = curbuf }) .. " " .. fn_symbol, "Enc: " .. vim.opt.fileencoding:get(), 2))
        table.insert(lines, " ")
        table.insert(lines, M.prepare_line("Textwidth: " .. vim.api.nvim_get_option_value("textwidth", { buf = curbuf }) ..
                     " / " .. (vim.api.nvim_get_option_value("wrap", { win = M.content_winid }) == false and "No Wrap" or "Wrap"),
                     "Fmt: " .. (vim.api.nvim_get_option_value("fo", { buf = curbuf })), 2))
        table.insert(lines, M.prepare_line("Folding method:", fdm[vim.api.nvim_get_option_value("foldmethod", { win = M.content_winid })], 2))
        if vim.api.nvim_get_option_value("foldmethod", { win = M.content_winid }) == 'expr' then
          table.insert(lines, "Expr: " .. vim.api.nvim_get_option_value("foldexpr", { win = M.content_winid }))
        else
          table.insert(lines, " ")
        end
        table.insert(lines, " ")
        -- add the cookie
        if M.cookie ~= nil and #M.cookie >= 1 then
          for _,v in ipairs(M.cookie) do
            table.insert(lines, v)
          end
        end
        vim.api.nvim_buf_set_lines(M.bufid, 0, -1, false, lines)
      end
      -- set highlights
      vim.api.nvim_buf_add_highlight(M.bufid, -1, "Visual", 0, 0, M.win_width - 2)
      if string.len(name) > 0 then
        vim.api.nvim_buf_add_highlight(M.bufid, -1, "CursorLine", 1, 0, M.win_width - 2)
      end
      if fn_symbol_hl ~= nil then
        vim.api.nvim_buf_add_highlight(M.bufid, -1, fn_symbol_hl, 4, 0, M.win_width - 2)
      end
      vim.api.nvim_buf_add_highlight(M.bufid, -1, "Debug", 6, 0, M.win_width - 2)
      vim.api.nvim_buf_add_highlight(M.bufid, -1, "Keyword", 7, 0, M.win_width - 2)
      vim.api.nvim_buf_add_highlight(M.bufid, -1, "Keyword", 8, 0, M.win_width - 2)
      vim.api.nvim_buf_set_option(M.bufid, "modifiable", false)
    end
  elseif M.content == 'weather' then
    vim.api.nvim_buf_clear_namespace(M.bufid, -1, 0, -1)
    vim.api.nvim_win_set_option(M.winid, "statusline", "  Weather")
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
end

return M
