local globals = require("globals")

local M = {}
M.winid = nil             -- window id
M.bufid = nil             -- buffer id

function M.resize_or_closed()
  if globals.term.winid ~= nil then
    globals.perm_config.terminal.height = vim.api.nvim_win_get_height(globals.term.winid)
  end
  if M.winid ~= nil and vim.api.nvim_win_is_valid(M.winid) == false then  -- window has disappeared
    if M.bufid ~= nil then
      vim.api.nvim_buf_delete(M.bufid, { force = true })
      M.bufid = nil
    end
    M.winid = nil
  end
end

function M.close()
  if M.winid ~= nil then
    vim.api.nvim_win_close(M.winid, {force=true})
  end
end

--- this opens a split next to the terminal split and launches an instance of glances
--- system monitor in it. See: https://nicolargo.github.io/glances/
function M.open()
  local width = globals.perm_config.sysmon.width
  local wid = globals.findwinbyBufType("terminal")
  local curwin = vim.api.nvim_get_current_win()     -- remember active win for going back
  -- glances must be executable otherwise do nothing
  -- also, a terminal split must be present.
  if #wid > 0 and vim.fn.executable("glances") > 0 then
    vim.fn.win_gotoid(wid[1])
    vim.cmd("rightbelow " .. width .. " vsplit|terminal glances --disable-plugin all --disable-bg --enable-plugin " .. vim.g.config.sysmon.modules .. " --time 3")
    M.winid = vim.fn.win_getid()
    vim.schedule(function() vim.api.nvim_win_set_width(M.winid, globals.perm_config.sysmon.width - 2) end)
    vim.schedule(function() vim.api.nvim_win_set_width(M.winid, globals.perm_config.sysmon.width) end)
    M.bufid = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_option(M.winid, "list", false)
    vim.api.nvim_win_set_option(M.winid, "statusline", "System Monitor")
    vim.cmd("set winfixheight | set filetype=sysmon | set nonumber | set signcolumn=no | set winhl=SignColumn:NeoTreeNormalNC,Normal:NeoTreeNormalNC | set foldcolumn=0 | set statuscolumn= | setlocal nocursorline")
    vim.fn.win_gotoid(curwin)
  end
end

return M

