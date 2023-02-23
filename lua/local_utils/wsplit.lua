local globals = require("globals")

local M = {}
M.winid = nil             -- window id
M.bufid = nil             -- buffer id
M.win_width = nil
M.win_height = nil
M.autocmds_valid = nil

M.autocmds_valid = nil    -- auto command was set
M.weatherfile = "~/.weather/weather"

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

function M.open()
  local wid = globals.findwinbyBufType("terminal")
  local curwin = vim.api.nvim_get_current_win()     -- remember active win for going back

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
  vim.fn.timer_start(vim.g.config.weather.interval, function() M.refresh() end)
end

function M.prepare_line(_left, _right, correct)
  local format = "%-" .. M.win_width / 2 .. "s"
  local left = string.format(format, _left)
  format = "%-" .. M.win_width / 2 - 5 .. "s"
  local right = string.format(format, _right)
  local pad = string.rep(" ", M.win_width / 2 - #right - correct)
  return " " .. string.format(format, left) .. pad .. right .. " "
end

function M.close()
  if M.winid ~= nil then
    vim.api.nvim_win_close(M.winid, {force=true})
  end
end

function M.refresh()
  local name = vim.fn.expand(M.weatherfile)
  local results = {}

  if M.winid ~= nil and vim.api.nvim_win_is_valid(M.winid) then
    M.win_width = vim.api.nvim_win_get_width(M.winid)
    M.win_height = vim.api.nvim_win_get_height(M.winid)
  else
    return
  end

  vim.api.nvim_buf_clear_namespace(M.bufid, -1, 0, -1)
  if vim.fn.filereadable(name) then
    local lines = {}
    local file = io.open(name)
    local index = 1
    if file ~= nil then
      local l = file:lines()
      for line in l do
        results[tostring(index)] = line
        index = index + 1
      end
      io.close(file)
    end
    vim.api.nvim_buf_set_option(M.bufid, "modifiable", true)
    table.insert(lines, M.prepare_line(results['26'], results['28'], 1))
    table.insert(lines, M.prepare_line(results['27'], "API: " .. results['37'], 1))
    table.insert(lines, "  ")
    table.insert(lines, M.prepare_line("Temp: " .. results['3'],    "Feels: " .. results['16'], 0))
    table.insert(lines, M.prepare_line("Min:  " .. results['29'],   "Max:   " .. results['30'], 0))
    table.insert(lines, M.prepare_line("Dew:  " .. results['17'],   results['21'] .. "      ", 0))
    table.insert(lines, "  ")
    table.insert(lines, M.prepare_line("" .. results['25'] .. " at " .. results['20'], "Vis:   " .. results['22'], 1))
    table.insert(lines, M.prepare_line("Pressure: " .. results['19'], results['18'], 1))
    table.insert(lines, M.prepare_line("Sunrise: " .. results['23'], "Sunset: " .. results['24'], 1))
    table.insert(lines, "  ")
    table.insert(lines, M.prepare_line(results['31'], "", 1))

    vim.api.nvim_buf_set_lines(M.bufid, 0, -1, false, lines)

    vim.api.nvim_buf_add_highlight(M.bufid, -1, "Debug", 0, 0, -1)
    vim.api.nvim_buf_add_highlight(M.bufid, -1, "Keyword", 1, 0, -1)
    vim.api.nvim_buf_set_option(M.bufid, "modifiable", false)
  end

end

return M
