local globals = require("globals")

local M = {}
M.winid = nil             -- window id
M.bufid = nil             -- buffer id
M.win_width = nil
M.win_height = nil

M.autocmds_valid = nil    -- auto command was set
M.weatherfile = "~/.weather/weather"

function M.open(_width)
  local width = _width or vim.g.config.weather.width
  local wid = globals.findwinbyBufType("terminal")
  local curwin = vim.api.nvim_get_current_win()     -- remember active win for going back

  -- glances must be executable otherwise do nothing
  -- also, a terminal split must be present.
  if #wid > 0 and vim.fn.filereadable(M.weatherfile) then
    vim.fn.win_gotoid(wid[1])
    vim.cmd("setlocal splitright | " .. vim.g.config.weather.width .. " vsp new")
    M.winid = vim.fn.win_getid()
    M.bufid = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_option(M.bufid, "buftype", "nofile")
    vim.api.nvim_win_set_option(M.winid, "list", false)
    vim.api.nvim_win_set_option(M.winid, "statusline", "Weather")
    vim.cmd("set filetype=weather | set nonumber | set signcolumn=no | set winhl=Normal:NeoTreeNormalNC | set foldcolumn=0 | set statuscolumn=")
    vim.fn.win_gotoid(curwin)
  end
  -- M.setup_auto()
  -- vim.fn.timer_start(vim.g.config.weather.interval, function() M.refresh() end)
  M.refresh()
end

function M.prepare_line_with_prefix(p1, p2, val1, val2)
  local left = string.format("%-6s: %6s", p1, val1)
  local right = string.format("%-6s: %6s", p2, val2)
  local pad = string.rep(" ", M.win_width - #left - #right)
  return left .. pad .. right
end

function M.prepare_line(left, right)
  local pad = string.rep(" ", M.win_width - #left - #right)
  return left .. pad .. right
end

function M.refresh()
  local name = vim.fn.expand(M.weatherfile)
  local results = {}

  if vim.api.nvim_win_is_valid(M.winid) then
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
    table.insert(lines, M.prepare_line(results['27'], results['28']))
    table.insert(lines, "  ")
    table.insert(lines, M.prepare_line_with_prefix("Temp", "Feels", results['3'], results['16']))
    table.insert(lines, M.prepare_line_with_prefix("Min", "Max", results['29'], results['30']))

    vim.api.nvim_buf_set_lines(M.bufid, 0, -1, false, lines)

    vim.api.nvim_buf_add_highlight(M.bufid, -1, "Accent", 0, 0, -1)
    vim.api.nvim_buf_set_option(M.bufid, "modifiable", false)
  end

end

return M
