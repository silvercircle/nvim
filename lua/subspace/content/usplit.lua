local Usplit = {}
Usplit.winid = nil -- window id
Usplit.bufid = nil -- buffer id
Usplit.content = "fortune"
Usplit.cookie = {}
Usplit.width = 0

local timer = nil
local num_cookies = Tweaks.fortune.numcookies or 1
local cookie_command = Tweaks.fortune.command

-- timer interval is in minutes. We accept nothing lower than one minute
local timer_interval = Tweaks.fortune.refresh * 60 * 1000
if timer_interval < 60000 then
  timer_interval = 60000
end

-- this is called from the winresized / winclosed handler in auto.lua
-- when the window has disappeared, the buffer is deleted.
function Usplit.resize_or_closed(_)
  if Usplit.winid ~= nil then
    if vim.api.nvim_win_is_valid(Usplit.winid) == false then -- window has disappeared
      if Usplit.bufid ~= nil and vim.api.nvim_buf_is_valid(Usplit.bufid) then
        vim.api.nvim_buf_delete(Usplit.bufid, { force = true })
        Usplit.bufid = nil
      end
      Usplit.winid = nil
    else
      Usplit.refresh()
      PCFG.sysmon.width = vim.api.nvim_win_get_width(Usplit.winid)
    end
  end
end

-- toggle content. close() will stop and open() will restart the timer
function Usplit.toggle_content()
  if Usplit.content == "sysmon" then
    Usplit.content = "fortune"
  elseif Usplit.content == "fortune" then
    Usplit.content = "sysmon"
  end
  PCFG.sysmon.content = Usplit.content
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
  vim.api.nvim_set_option_value("modifiable", true, { buf = Usplit.bufid })
  -- prevent the winbar from appearing (nvim 0.10 or higher)
  vim.api.nvim_buf_clear_namespace(Usplit.bufid, -1, 0, -1)
  table.insert(lines, " ")
  table.insert(lines, "    *** Quote of the moment ***")
  table.insert(lines, " ")
  for _, v in ipairs(Usplit.cookie) do
    table.insert(lines, " " .. v)
  end
  vim.api.nvim_buf_set_lines(Usplit.bufid, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = Usplit.bufid })
  vim.api.nvim_set_option_value("winbar", "", { win = Usplit.winid })
  vim.api.nvim_set_option_value("modified", false, { buf = Usplit.bufid })
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
  local width = PCFG.sysmon.width
  local wid = CGLOBALS.findWinByFiletype("terminal")
  local curwin = vim.api.nvim_get_current_win() -- remember active win for going back
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
          .. CFG.sysmon.modules
          .. " --time 3"
      )
      Usplit.winid = vim.fn.win_getid()
      vim.api.nvim_set_option_value("statusline", "  System Monitor", { win = Usplit.winid })
    elseif Usplit.content == "fortune" then
      vim.api.nvim_set_option_value("modifiable", true, { buf = vim.api.nvim_win_get_buf(wid[1]) })
      vim.cmd("rightbelow " .. width .. " vsplit new")
      vim.cmd("setlocal buftype=nofile")
      Usplit.winid = vim.fn.win_getid()
      vim.api.nvim_set_option_value("statusline", "󰈙  Fortune cookie", { win = Usplit.winid })
      vim.api.nvim_set_option_value("modifiable", false, { buf = vim.api.nvim_win_get_buf(wid[1]) })
    end
    vim.schedule(function()
      vim.api.nvim_win_set_width(Usplit.winid, PCFG.sysmon.width - 2)
    end)
    vim.schedule(function()
      vim.api.nvim_win_set_width(Usplit.winid, PCFG.sysmon.width)
    end)
    Usplit.bufid = vim.api.nvim_get_current_buf()
    vim.api.nvim_set_option_value("buflisted", false, { buf = Usplit.bufid })
    vim.api.nvim_set_option_value("list", false, { win = Usplit.winid })
    vim.cmd(
      "setlocal statuscolumn=%#TreeNormalNC#\\ |set winfixheight | setlocal winbar= |set filetype=sysmon | set nonumber | set signcolumn=no | set winhl=SignColumn:TreeNormalNC,Normal:TreeNormalNC | set foldcolumn=0 | setlocal nocursorline"
    )
    vim.fn.win_gotoid(curwin)
  end
  if timer ~= nil then
    timer:stop()
  else
    timer = vim.uv.new_timer()
  end
  if timer ~= nil and Usplit.content == "fortune" then
    timer:start(0, timer_interval, vim.schedule_wrap(Usplit.refresh_on_timer))
  end
end

return Usplit
