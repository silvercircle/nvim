local globals = require("globals")

local M = {}
M.winid = nil             -- window id
M.bufid = nil             -- buffer id
M.autocmds_valid = nil    -- auto command was set

-- set auto command for the sysmon split. Watches WinClosed to react by removing the buffer when the
-- window has been closed.
function M.setup_auto()
  if M.autocmds_valid == true then
    return
  end
  M.autocmds_valid = true
  vim.api.nvim_create_augroup("SYSMONSplit", { clear = true })
  vim.api.nvim_create_autocmd({ "WinClosed" }, {
    group = "SYSMONSplit",
    callback = function()
      if M.winid ~= nil and vim.api.nvim_win_is_valid(M.winid) == false then  -- window has disappeared
        if M.bufid ~= nil then
          vim.api.nvim_buf_delete(M.bufid, { force = true })
          M.bufid = nil
        end
        M.winid = nil
      end
    end,
  })
end

function M.close()
  if M.winid ~= nil then
    vim.api.nvim_win_close(M.winid, {force=true})
  end
end

--- this opens a split next to the terminal split and launches an instance of glances
--- system monitor in it. See: https://nicolargo.github.io/glances/
--- @param _width number: the width of the split. Default is vim.g.config.sysmon.width
function M.open(_width)
  local width = _width or vim.g.config.sysmon.width
  local wid = globals.findwinbyBufType("terminal")
  local curwin = vim.api.nvim_get_current_win()     -- remember active win for going back

  -- glances must be executable otherwise do nothing
  -- also, a terminal split must be present.
  if #wid > 0 and vim.fn.executable("glances") > 0 then
    vim.fn.win_gotoid(wid[1])
    vim.cmd("rightbelow " .. width .. " vsplit|terminal glances --disable-plugin all --disable-bg --enable-plugin cpu,mem,network,load,system,uptime,quicklook --time 3")
    M.winid = vim.fn.win_getid()
    M.bufid = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_option(M.winid, "list", false)
    vim.api.nvim_win_set_option(M.winid, "statusline", "System Monitor")
    vim.cmd("set filetype=sysmon | set nonumber | set signcolumn=no | set winhl=Normal:NeoTreeNormalNC | set foldcolumn=0 | set statuscolumn= | setlocal nocursorline")
    vim.fn.win_gotoid(curwin)
  end
  M.setup_auto()
end

return M

