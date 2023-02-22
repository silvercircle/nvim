local globals = require("globals")

local M = {}
M.winid = nil

-- this opens a split next to the terminal split and launches an instance of glances
-- system monitor in it. See: https://nicolargo.github.io/glances/

function M.open(_width)
  local width = _width or vim.g.config.sysmon.width
  local wid = globals.findwinbyBufType("terminal")
  local curwin = vim.api.nvim_get_current_win()     -- remember active win for going back

  -- glances must be executable otherwise do nothing
  if #wid > 0 and vim.fn.executable("glances") > 0 then
    vim.fn.win_gotoid(wid[1])
    vim.cmd("rightbelow " .. width .. " vsplit|terminal glances --disable-plugin all --disable-bg --enable-plugin cpu,mem,network,load,system,uptime --time 3")
    M.winid = vim.fn.win_getid()
    vim.api.nvim_win_set_option(M.winid, "list", false)
    vim.api.nvim_win_set_option(M.winid, "statusline", "System Monitor")
    vim.cmd("set filetype=sysmon | set nonumber | set signcolumn=no | set winhl=Normal:NeoTreeNormalNC | set foldcolumn=0 | set statuscolumn=")
    vim.fn.win_gotoid(curwin)
  end
end

return M

