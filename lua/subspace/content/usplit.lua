local Usplit = {}
Usplit.nsid = vim.api.nvim_create_namespace("usplit")

local num_cookies = Tweaks.fortune.numcookies or 1
local cookie_command = Tweaks.fortune.command

-- timer interval is in minutes. We accept nothing lower than one minute
local timer_interval = Tweaks.fortune.refresh * 60 * 1000
if timer_interval < 30000 then timer_interval = 30000 end

---@type uv.uv_timer_t?
local usplit_timer = nil


-- this is called from the winresized / winclosed handler in auto.lua
-- when the window has disappeared, the buffer is deleted.
function Usplit.resize_or_closed(_)
  local usplit = TABM.get().usplit
  if usplit.id_win ~= nil then
    if vim.api.nvim_win_is_valid(usplit.id_win) == false then -- window has disappeared
      if usplit.id_buf ~= nil and vim.api.nvim_buf_is_valid(usplit.id_buf) then
        vim.api.nvim_buf_delete(usplit.id_buf, { force = true })
        usplit.id_buf = nil
      end
      usplit.id_win = nil
    else
      Usplit.refresh("resize")
      PCFG.sysmon.width = vim.api.nvim_win_get_width(usplit.id_win)
    end
  end
end

-- toggle content. close() will stop and open() will restart the timer
function Usplit.toggle_content()
  local usplit = TABM.get().usplit
  if usplit.content == "sysmon" then
    usplit.content = "fortune"
  elseif usplit.content == "fortune" then
    usplit.content = "sysmon"
  end
  PCFG.sysmon.content = usplit.content
  Usplit.close()
  Usplit.open()
end

-- force refreshing the cookie. just restart the timer should be enough
function Usplit.refresh_cookie()
  if TABM.get().usplit.content ~= "fortune" then
    return
  end
  if usplit_timer ~= nil then
    usplit_timer:stop()
    usplit_timer:start(0, timer_interval, vim.schedule_wrap(Usplit.refresh_on_timer))
  end
end

---@param id_tab? integer the tab page on which to act
function Usplit.close(id_tab)
  id_tab = id_tab or vim.api.nvim_get_current_tabpage()
  if not TABM.T[id_tab] then return end
  local usplit = TABM.get(id_tab).usplit
  if usplit.id_win ~= nil then
    vim.api.nvim_win_close(usplit.id_win, { force = true })
  end
  if usplit.timer ~= nil then
    usplit.timer:stop()
  end
  usplit.id_win = nil
end

--- this renders the fortune cookie content. In sysmon mode, it
--- does nothing.
function Usplit.refresh(reason, id_tab)
  reason = reason or "resize"
  id_tab = id_tab or TABM.active
  local usplit = TABM.T[id_tab].usplit
  if usplit.content == "sysmon" then
    return
  end
  local id_win = usplit.id_win
  local w, h = vim.api.nvim_win_get_width(id_win), vim.api.nvim_win_get_height(id_win)
  if reason == "resize" and w == usplit.old_dimensions.w and h == usplit.old_dimensions.h then return end
  usplit.old_dimensions.w = w
  usplit.old_dimensions.h = h
  local lines = {}
  vim.api.nvim_set_option_value("modifiable", true, { buf = usplit.id_buf })
  -- prevent the winbar from appearing (nvim 0.10 or higher)
  vim.api.nvim_buf_clear_namespace(usplit.id_buf, Usplit.nsid, 0, -1)
  table.insert(lines, " ")
  table.insert(lines, "    *** Quote of the moment ***")
  table.insert(lines, " ")
  for _, v in ipairs(usplit.cookie) do
    table.insert(lines, " " .. v)
  end
  vim.api.nvim_buf_set_lines(usplit.id_buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = usplit.id_buf })
  vim.api.nvim_set_option_value("winbar", "", { win = id_win })
  vim.api.nvim_set_option_value("modified", false, { buf = usplit.id_buf })
  vim.api.nvim_buf_set_extmark(usplit.id_buf, Usplit.nsid, 1, 1, { hl_group = "Debug", end_col = #lines[2] })
end

--- timer event. fetch a new fortune cookie and store it. On completion
--- it calls refresh() to render
--- @param id_tab integer tabpage id
function Usplit.refresh_tab_on_timer(id_tab)
  if not TABM.T[id_tab] then return end
  local usplit = TABM.T[id_tab].usplit
  if #usplit.cookie > 0 then
    for i,_ in pairs(usplit.cookie) do
      usplit.cookie[i] = nil
    end
  end
  local width = vim.api.nvim_win_get_width(usplit.id_win)
  for _ = 1, num_cookies, 1 do
    vim.fn.jobstart(cookie_command .. "|fmt -" .. width - 2, {
      on_stdout = function(_, b, _)
        for _, v in ipairs(b) do
          if #v > 1 then
            table.insert(usplit.cookie, v)
          end
        end
      end,
      on_exit = function()
        table.insert(usplit.cookie, " ")
        Usplit.refresh("content", id_tab)
      end,
    })
  end
end

function Usplit.refresh_on_timer()
  for _,v in ipairs(TABM.T) do
    if v.usplit.id_win and vim.api.nvim_win_is_valid(v.usplit.id_win) then
      Usplit.refresh_tab_on_timer(v.id_page)
    end
  end
end

--- this opens a split next to the terminal split and launches an instance of glances
--- system monitor in it. See: https://nicolargo.github.io/glances/
function Usplit.open()
  local usplit = TABM.get().usplit
  local width = PCFG.sysmon.width
  local wid = TABM.findWinByFiletype("terminal", true)
  local curwin = vim.api.nvim_get_current_win() -- remember active win for going back
  -- glances must be executable otherwise do nothing
  -- also, a terminal split must be present.
  if not vim.fn.executable("glances") then
    usplit.content = "fortune"
  end
  if #wid > 0 then
    vim.fn.win_gotoid(wid[1])
    if usplit.content == "sysmon" then
      vim.cmd(
        "rightbelow "
          .. width
          .. " vsplit|terminal glances --disable-plugin all --disable-bg --enable-plugin "
          .. CFG.sysmon.modules
          .. " --time 3"
      )
      usplit.id_win = vim.fn.win_getid()
      vim.api.nvim_set_option_value("statusline", "  System Monitor", { win = usplit.id_win })
    elseif usplit.content == "fortune" then
      vim.api.nvim_set_option_value("modifiable", true, { buf = vim.api.nvim_win_get_buf(wid[1]) })
      vim.cmd("rightbelow " .. width .. " vsplit new_usplit_" .. TABM.active)
      vim.cmd("setlocal buftype=nofile")
      usplit.id_win = vim.fn.win_getid()
      vim.api.nvim_set_option_value("statusline", "󰈙  Fortune cookie", { win = usplit.id_win })
      vim.api.nvim_set_option_value("modifiable", false, { buf = vim.api.nvim_win_get_buf(wid[1]) })
    end
    vim.schedule(function()
      vim.api.nvim_win_set_width(usplit.id_win, PCFG.sysmon.width - 2)
    end)
    vim.schedule(function()
      vim.api.nvim_win_set_width(usplit.id_win, PCFG.sysmon.width)
    end)
    usplit.id_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_set_option_value("buflisted", false, { buf = usplit.id_buf })
    vim.api.nvim_set_option_value("list", false, { win = usplit.id_win })
    vim.cmd(
      "setlocal statuscolumn=%#TreeNormalNC#\\ |set winfixheight | setlocal winbar= |set filetype=sysmon | set nonumber | set signcolumn=no | set winhl=SignColumn:TreeNormalNC,Normal:TreeNormalNC | set foldcolumn=0 | setlocal nocursorline"
    )
    vim.fn.win_gotoid(curwin)
  end
  if usplit_timer ~= nil then
    usplit_timer:stop()
  else
    usplit_timer = vim.uv.new_timer()
  end
  if usplit_timer ~= nil and usplit.content == "fortune" then
    usplit_timer:start(0, timer_interval, vim.schedule_wrap(Usplit.refresh_on_timer))
  end
  vim.schedule_wrap(function() Usplit.refresh_tab_on_timer(TABM.active) end)
end

return Usplit
