local Usplit = {}
Usplit.winid = nil -- window id
Usplit.bufid = nil -- buffer id
Usplit.content = "fortune"
Usplit.cookie = {}

local timer = nil
local num_cookies = vim.g.tweaks.fortune.numcookies or 1
local cookie_command = vim.g.tweaks.fortune.command

-- timer interval is in minutes. We accept nothing lower than one minute
local timer_interval = vim.g.tweaks.fortune.refresh * 60 * 1000
if timer_interval < 60000 then
  timer_interval = 60000
end

-- this is called from the winresized / winclosed handler in auto.lua
-- when the window has disappeared, the buffer is deleted.
function Usplit.resize_or_closed()
  if Usplit.winid ~= nil and vim.api.nvim_win_is_valid(Usplit.winid) == false then -- window has disappeared
    if Usplit.bufid ~= nil and vim.api.nvim_buf_is_valid(Usplit.bufid) then
      vim.api.nvim_buf_delete(Usplit.bufid, { force = true })
      Usplit.bufid = nil
    end
    Usplit.winid = nil
  elseif Usplit.winid ~= nil then
    Usplit.refresh()
    __Globals.perm_config.sysmon.width = vim.api.nvim_win_get_width(Usplit.winid)
  end
end

-- toggle content. close() will stop and open() will restart the timer
function Usplit.toggle_content()
  if Usplit.content == "sysmon" then
    Usplit.content = "fortune"
  elseif Usplit.content == "fortune" then
    Usplit.content = "sysmon"
  end
  __Globals.perm_config.sysmon.content = Usplit.content
  Usplit.close()
  Usplit.open()
end

-- force refreshing the cookie. just restart the timer should be enough
function Usplit.refresh_cookie()
  if Usplit.content ~= "fortune" then
    return
  end
  if timer ~= nil then
    timer:stop()
    timer:start(0, timer_interval, vim.schedule_wrap(Usplit.refresh_on_timer))
  end
end

function Usplit.close()
  if Usplit.winid ~= nil then
    vim.api.nvim_win_close(Usplit.winid, { force = true })
    -- resize_or_closed() will cleanup, triggered by auto command
  end
  if timer ~= nil then
    timer:stop()
  end
end

--- this renders the fortune cookie content. In sysmon mode, it
--- does nothing.
function Usplit.refresh()
  if Usplit.content == "sysmon" then
    return
  end
  local lines = {}
  vim.api.nvim_buf_set_option(Usplit.bufid, "modifiable", true)
  -- prevent the winbar from appearing (nvim 0.10 or higher)
  if Config.nightly > 0 then
    vim.api.nvim_buf_set_option(Usplit.bufid, "winbar", "")
  end
  vim.api.nvim_buf_clear_namespace(Usplit.bufid, -1, 0, -1)
  table.insert(lines, " ")
  table.insert(lines, "    *** Quote of the moment ***")
  table.insert(lines, " ")
  for _, v in ipairs(Usplit.cookie) do
    table.insert(lines, " " .. v)
  end
  vim.api.nvim_buf_set_lines(Usplit.bufid, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(Usplit.bufid, "modifiable", false)
  vim.api.nvim_buf_set_option(Usplit.bufid, "modified", false)
  vim.api.nvim_buf_add_highlight(Usplit.bufid, -1, "Debug", 1, 0, -1)
end

--- timer event. fetch a new fortune cookie and store it. On completion
--- it calls refresh() to render
function Usplit.refresh_on_timer()
  for i, _ in ipairs(Usplit.cookie) do
    Usplit.cookie[i] = nil
  end
  local width = vim.api.nvim_win_get_width(Usplit.winid)
  for _ = 1, num_cookies, 1 do
    vim.fn.jobstart(cookie_command .. "|fmt -" .. width - 2, {
      on_stdout = function(_, b, _)
        for _, v in ipairs(b) do
          if #v > 1 then
            table.insert(Usplit.cookie, v)
          end
        end
      end,
      on_exit = function()
        table.insert(Usplit.cookie, " ")
        Usplit.refresh()
      end,
    })
  end
end

--- this opens a split next to the terminal split and launches an instance of glances
--- system monitor in it. See: https://nicolargo.github.io/glances/
function Usplit.open()
  local width = __Globals.perm_config.sysmon.width
  local wid = __Globals.findwinbyBufType("terminal")
  local curwin = vim.api.nvim_get_current_win() -- remember active win for going back
  local ver = vim.version()
  local verstr = "  nvim: " .. ver.major .. "." .. ver.minor .. "." .. ver.patch
  -- glances must be executable otherwise do nothing
  -- also, a terminal split must be present.
  if not vim.fn.executable("glances") then
    Usplit.content = "fortune"
  end
  if #wid > 0 then
    vim.fn.win_gotoid(wid[1])
    if Usplit.content == "sysmon" then
      vim.cmd(
        "rightbelow "
          .. width
          .. " vsplit|terminal glances --disable-plugin all --disable-bg --enable-plugin "
          .. Config.sysmon.modules
          .. " --time 3"
      )
      Usplit.winid = vim.fn.win_getid()
      vim.api.nvim_win_set_option(Usplit.winid, "statusline", "  System Monitor" .. verstr)
    elseif Usplit.content == "fortune" then
      vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(wid[1]), "modifiable", true)
      vim.cmd("rightbelow " .. width .. " vsplit new")
      vim.cmd("setlocal buftype=nofile")
      Usplit.winid = vim.fn.win_getid()
      --vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(wid[1]), "buftype", "nofile")
      vim.api.nvim_win_set_option(Usplit.winid, "statusline", "󰈙 Fortune cookie" .. verstr)
      vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(wid[1]), "modifiable", false)
    end
    vim.schedule(function()
      vim.api.nvim_win_set_width(Usplit.winid, __Globals.perm_config.sysmon.width - 2)
    end)
    vim.schedule(function()
      vim.api.nvim_win_set_width(Usplit.winid, __Globals.perm_config.sysmon.width)
    end)
    Usplit.bufid = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_option(Usplit.bufid, "buflisted", false)
    vim.api.nvim_win_set_option(Usplit.winid, "list", false)
    vim.cmd(
      "setlocal statuscolumn=%#NeoTreeNormalNC#\\ |set winfixheight | setlocal winbar= |set filetype=sysmon | set nonumber | set signcolumn=no | set winhl=SignColumn:NeoTreeNormalNC,Normal:NeoTreeNormalNC | set foldcolumn=0 | setlocal nocursorline"
    )
    vim.fn.win_gotoid(curwin)
  end
  if timer ~= nil then
    timer:stop()
  else
    timer = vim.loop.new_timer()
  end
  if timer ~= nil and Usplit.content == "fortune" then
    timer:start(0, timer_interval, vim.schedule_wrap(Usplit.refresh_on_timer))
  end
end

return Usplit
