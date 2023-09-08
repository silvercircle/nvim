local globals = require("globals")

local M = {}
M.winid = nil             -- window id
M.bufid = nil             -- buffer id

-- this is called from the winresized / winclosed handler in auto.lua
-- when the window has disappeared, the buffer is deleted.
function M.resize_or_closed()
  if M.winid ~= nil and vim.api.nvim_win_is_valid(M.winid) == false then  -- window has disappeared
    if  M.bufid ~= nil and vim.api.nvim_buf_is_valid(M.bufid) then
      vim.api.nvim_buf_delete(M.bufid, { force = true })
      M.bufid = nil
    end
    M.winid = nil
  else
    M.refresh()
  end
end

function M.close()
  if M.winid ~= nil then
    vim.api.nvim_win_close(M.winid, {force=true})
    -- resize_or_closed() will cleanup, triggered by auto command
  end
end

function M.refresh()
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
    vim.api.nvim_win_set_option(M.winid, "statusline", "  System Monitor")
    vim.cmd("set winfixheight | set filetype=sysmon | set nonumber | set signcolumn=no | set winhl=SignColumn:NeoTreeNormalNC,Normal:NeoTreeNormalNC | set foldcolumn=0 | set statuscolumn=%#NeoTreeNormalNC#\\  | setlocal nocursorline")
    vim.fn.win_gotoid(curwin)
  end
end

return M

