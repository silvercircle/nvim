---@class subspace.Usplit
---@field id_win integer
---@field id_buf integer
---@field id_tab integer
---@field id_ns  integer
---@field width  integer
---@field content string
---@field old_dimensions table
---@field provider? subspace.providers.Fortune
---@field timer uv.uv_timer_t

local Usplit = {}
Usplit.__index = Usplit

---@return subspace.Usplit
---@param  t integer - the tabpage
---@param  tim uv.uv_timer_t timer object
function Usplit:new(t, tim)
  return setmetatable({
    id_win = 0,
    id_tab = t,
    id_buf = 0,
    id_ns  = vim.api.nvim_create_namespace("usplit_" .. tostring(t)),
    content = "test",
    provider = nil,
    timer = tim,
    old_dimensions = {
      w = 0, h = 0
    }
  }, self)
end


-- toggle content. close() will stop and open() will restart the timer
function Usplit:toggle_content()
  if self.content == "sysmon" then
    self.content = "content"
  elseif self.content == "content" then
    self.content = "sysmon"
  end
  PCFG.sysmon.content = self.content
  self:close()
  self:open()
end

-- force refreshing the cookie. just restart the timer should be enough
function Usplit:refresh_cookie()
  local us = require("subspace.content.usplit")
  if self.timer ~= nil then
    self.timer:stop()
    self.timer:start(0, us.timer_interval, vim.schedule_wrap(us.refresh_on_timer))
  end
end

function Usplit:close()
  if self.id_win and self.id_win ~= 0 then
    vim.api.nvim_win_close(self.id_win, { force = true })
  end
  if self.id_buf and vim.api.nvim_buf_is_valid(self.id_buf) then
    vim.api.nvim_buf_clear_namespace(self.id_buf, self.id_ns, 0, -1)
    vim.api.nvim_buf_delete(self.id_buf, { force = true })
    self.id_buf = nil
  end
  self.id_win = nil
  if self.provider then
    self.provider:destroy()
    self.provider = nil
  end
end

function Usplit:destroy()
  self:close()
  self.id_win = nil
  self.id_buf = nil
end
--- this renders the fortune cookie content. In sysmon mode, it
--- does nothing.
function Usplit:refresh(reason)
  reason = reason or "resize"
  if self.content == "sysmon" then return end
  local w, h = vim.api.nvim_win_get_width(self.id_win), vim.api.nvim_win_get_height(self.id_win)
  if reason == "resize" and w == self.old_dimensions.w and h == self.old_dimensions.h then return end
  self.old_dimensions.w = w
  self.old_dimensions.h = h
  if self.provider then
    self.provider:update()
    self.provider:render()
  end
end

--- timer event. fetch a new fortune cookie and store it. On completion
--- it calls refresh() to render
function Usplit:refresh_tab_on_timer()
  self:refresh("content")
end

--- this opens a split next to the terminal split and launches an instance of glances
--- system monitor in it. See: https://nicolargo.github.io/glances/
function Usplit:open()
  local width = PCFG.sysmon.width
  local wid = TABM.findWinByFiletype("terminal", true)
  local curwin = vim.api.nvim_get_current_win() -- remember active win for going back
  -- glances must be executable otherwise do nothing
  -- also, a terminal split must be present.
  if not vim.fn.executable("glances") then
    self.content = "content"
  end
  if #wid > 0 then
    vim.fn.win_gotoid(wid[1])
    if self.content == "sysmon" then
      vim.cmd(
        "rightbelow "
          .. width
          .. " vsplit|terminal glances --disable-plugin all --disable-bg --enable-plugin "
          .. CFG.sysmon.modules
          .. " --time 3"
      )
      self.id_win = vim.fn.win_getid()
      vim.api.nvim_set_option_value("statusline", "  System Monitor", { win = self.id_win })
      if self.provider then
        self.provider:destroy()
        self.provider = nil
      end
    else
      vim.cmd("rightbelow " .. width .. " vsplit new_usplit_" .. TABM.active)
      self.id_win = vim.fn.win_getid()
      vim.api.nvim_set_option_value("statusline", "󰈙  Fortune cookie", { win = self.id_win })
      vim.api.nvim_set_option_value("buftype", "nofile", { buf = vim.api.nvim_get_current_buf() })
    end
    self.id_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_set_option_value("winbar", "", { win = self.id_win })
    vim.api.nvim_set_option_value("buflisted", false, { buf = self.id_buf })
    vim.api.nvim_set_option_value("list", false, { win = self.id_win })
    vim.cmd(
      "setlocal statuscolumn=%#TreeNormalNC#\\ |set winfixheight | set filetype=sysmon | set nonumber | set signcolumn=no | set winhl=SignColumn:TreeNormalNC,Normal:TreeNormalNC | set foldcolumn=0 | setlocal nocursorline"
    )
    vim.fn.win_gotoid(curwin)
  end
  vim.api.nvim_win_set_width(self.id_win, width)
  vim.schedule_wrap(function() Usplit.refresh_tab_on_timer(TABM.active) end)
  if self.content ~= "sysmon" then
    self.provider = require("subspace.content.providers.fortune").new(self.id_buf, self.id_win, TABM.active, self.id_ns)
  end
  self:refresh("content")
end

local M = {}

M.timer_interval = Tweaks.fortune.refresh * 60 * 1000

---@type uv.uv_timer_t?
M.usplit_timer = nil

-- this is called from the winresized / winclosed handler in auto.lua
-- when the window has disappeared, the buffer is deleted.
function M.resize_or_closed(_)
  local usplit = TABM.get().usplit
  if usplit.id_win ~= nil then
    if vim.api.nvim_win_is_valid(usplit.id_win) == false then -- window has disappeared
      if usplit.id_buf ~= nil and vim.api.nvim_buf_is_valid(usplit.id_buf) then
        vim.api.nvim_buf_delete(usplit.id_buf, { force = true })
        usplit.id_buf = nil
      end
      usplit.id_win = nil
    else
      usplit:refresh("resize")
    end
  end
end

function M.refresh_on_timer()
  for _,v in ipairs(TABM.T) do
    if v.usplit.id_win and vim.api.nvim_win_is_valid(v.usplit.id_win) then
      v.usplit:refresh_tab_on_timer()
    end
  end
end

function M.new(id_tab)
  if M.timer_interval < 30000 then M.timer_interval = 30000 end

  if M.usplit_timer == nil then
    M.usplit_timer = vim.uv.new_timer()
  end

  if M.usplit_timer ~= nil then
    M.usplit_timer:stop()
    M.usplit_timer:start(0, M.timer_interval, vim.schedule_wrap(M.refresh_on_timer))
  end
  return Usplit:new(id_tab, M.usplit_timer)
end

return M
