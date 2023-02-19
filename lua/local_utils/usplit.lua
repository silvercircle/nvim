local globals = require("globals")

local M = {}
M.winid = nil

function M.open(_width)
  local width = _width or vim.g.config.sysmon.width
  local wid = globals.findwinbyBufType("terminal")
  local curwin = vim.api.nvim_get_current_win()

  if #wid > 0 then
    vim.fn.win_gotoid(wid[1])
    vim.cmd("rightbelow " .. width .. " vsplit|terminal glances --disable-plugin all --enable-plugin cpu,mem,network,load,system,uptime --time 3")
    M.winid = vim.fn.win_getid()
    vim.api.nvim_win_set_option(M.winid, "list", false)
    vim.api.nvim_win_set_option(M.winid, "statusline", "System Monitor")
    vim.cmd("set filetype=sysmon | set nonumber | set signcolumn=no | set winhl=Normal:NeoTreeNormalNC | set foldcolumn=0")
    vim.fn.win_gotoid(curwin)
  end
end

return M

