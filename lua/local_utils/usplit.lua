local globals = require("globals")
local tweaks = require("tweaks")

local M = {}
M.winid = nil             -- window id
M.bufid = nil             -- buffer id
M.content = 'fortune'
M.cookie = {}

local timer = nil
local num_cookies = tweaks.fortune.numcookies or 1
local cookie_command = tweaks.fortune.command

-- timer interval is in minutes. We accept nothing lower than one minute
local timer_interval = tweaks.fortune.refresh * 60 * 1000
if timer_interval < 60000 then
  timer_interval = 60000
end

-- this is called from the winresized / winclosed handler in auto.lua
-- when the window has disappeared, the buffer is deleted.
function M.resize_or_closed()
  if M.winid ~= nil and vim.api.nvim_win_is_valid(M.winid) == false then  -- window has disappeared
    if  M.bufid ~= nil and vim.api.nvim_buf_is_valid(M.bufid) then
      vim.api.nvim_buf_delete(M.bufid, { force = true })
      M.bufid = nil
    end
    M.winid = nil
  elseif M.winid ~= nil then
    M.refresh()
    globals.perm_config.sysmon.width = vim.api.nvim_win_get_width(M.winid)
  end
end

-- toggle content. close() will stop and open() restart the timer
function M.toggle_content()
  if M.content == 'sysmon' then
    M.content = 'fortune'
  elseif M.content == 'fortune' then
    M.content = 'sysmon'
  end
  globals.perm_config.sysmon.content = M.content
  M.close()
  M.open()
end

-- force refreshing the cookie. just restart the timer should be enough
function M.refresh_cookie()
  if M.content ~= 'fortune' then
    return
  end
  if timer ~= nil then
    timer:stop()
  end
  if timer ~= nil then
    timer:start(0, timer_interval, vim.schedule_wrap(M.refresh_on_timer))
  end
end

function M.close()
  if M.winid ~= nil then
    vim.api.nvim_win_close(M.winid, {force=true})
    -- resize_or_closed() will cleanup, triggered by auto command
  end
  if timer ~= nil then
    timer:stop()
  end
end

function M.refresh()
  if M.content == 'sysmon' then
    return
  end
  local lines = {}
  vim.api.nvim_buf_set_option(M.bufid, "modifiable", true)
  -- prevent the winbar from appearing
  vim.api.nvim_buf_set_option(M.bufid, "winbar", "")
  vim.api.nvim_buf_clear_namespace(M.bufid, -1, 0, -1)
  table.insert(lines, " ")
  table.insert(lines, "    *** Quote of the moment ***")
  table.insert(lines, " ")
  for _, v in ipairs(M.cookie) do
    table.insert(lines, " " .. v)
  end
  vim.api.nvim_buf_set_lines(M.bufid, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(M.bufid, "modifiable", false)
  vim.api.nvim_buf_set_option(M.bufid, "modified", false)
  vim.api.nvim_buf_add_highlight(M.bufid, -1, "Debug", 1, 0, -1)
end

function M.refresh_on_timer()
  for i, _ in ipairs(M.cookie) do
    M.cookie[i] = nil
  end
  local width = vim.api.nvim_win_get_width(M.winid)
  for _ = 1, num_cookies, 1 do
    vim.fn.jobstart(cookie_command .. "|fmt -" .. width - 2, {
      on_stdout = function(_, b, _)
        for _,v in ipairs(b) do
          if #v > 1 then
            table.insert(M.cookie, v)
          end
        end
      end,
      on_exit = function() table.insert(M.cookie, " ") M.refresh() end
    })
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
  if not vim.fn.executable("glances") then
    M.content = 'fortune'
  end
  if #wid > 0 then
    vim.fn.win_gotoid(wid[1])
    if M.content == 'sysmon' then
      vim.cmd("rightbelow " .. width .. " vsplit|terminal glances --disable-plugin all --disable-bg --enable-plugin " .. vim.g.config.sysmon.modules .. " --time 3")
      M.winid = vim.fn.win_getid()
      vim.api.nvim_win_set_option(M.winid, "statusline", "  System Monitor")
    elseif M.content == 'fortune' then
      vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(wid[1]), "modifiable", true)
      vim.cmd("rightbelow " .. width .. " vsplit new")
      M.winid = vim.fn.win_getid()
      vim.api.nvim_win_set_option(M.winid, "statusline", "🗎  Fortune cookie")
      vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(wid[1]), "modifiable", false)
    end
    vim.schedule(function() vim.api.nvim_win_set_width(M.winid, globals.perm_config.sysmon.width - 2) end)
    vim.schedule(function() vim.api.nvim_win_set_width(M.winid, globals.perm_config.sysmon.width) end)
    M.bufid = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_option(M.bufid, "buflisted", false)
    vim.api.nvim_win_set_option(M.winid, "list", false)
    vim.cmd("setlocal statuscolumn=%#NeoTreeNormalNC#\\ |set winfixheight | setlocal winbar= |set filetype=sysmon | set nonumber | set signcolumn=no | set winhl=SignColumn:NeoTreeNormalNC,Normal:NeoTreeNormalNC | set foldcolumn=0 | setlocal nocursorline")
    vim.fn.win_gotoid(curwin)
  end
  if timer ~= nil then
    timer:stop()
  else
    timer = vim.loop.new_timer()
  end
  if timer ~= nil and M.content == 'fortune' then
    timer:start(0, timer_interval, vim.schedule_wrap(M.refresh_on_timer))
  end
end

return M

