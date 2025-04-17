
local num_cookies = Tweaks.fortune.numcookies or 1
local cookie_command = Tweaks.fortune.command

---@class subspace.Fortune
---@field content string
---@field id_buf integer
---@field id_tab integer
---@field id_win integer
---@field cookie table<string>
---@field lines  table<string>
local Fortune = {}
Fortune.__index = Fortune

---@return subspace.Fortune
---@param b integer  -- buf_id
---@param w integer  -- window_id this object belongs to
---@param t integer  -- tab id
---@param n integer  -- namespace id
function Fortune:new(b, w, t, n)
  return setmetatable({
    id_win = w,
    id_tab = t,
    id_buf = b,
    id_ns  = n,
    lines = {},
    cookie = {},
    content = "test"
  }, self)
end

function Fortune:render()
  -- prevent the winbar from appearing (nvim 0.10 or higher)
  if #self.lines >= 1 then
    for i,_ in pairs(self.lines) do self.lines[i] = nil end
  end
  if not vim.api.nvim_buf_is_valid(self.id_buf) then return end
  vim.api.nvim_buf_clear_namespace(self.id_buf, self.id_ns, 0, -1)
  vim.api.nvim_set_option_value("modifiable", true, { buf = self.id_buf })
  table.insert(self.lines, " ")
  table.insert(self.lines, "    *** Quote of the moment ***")
  table.insert(self.lines, " ")
  for _, v in ipairs(self.cookie) do
    table.insert(self.lines, " " .. v)
  end
  vim.api.nvim_buf_set_lines(self.id_buf, 0, -1, false, self.lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = self.id_buf })
  vim.api.nvim_set_option_value("winbar", "", { win = self.id_win })
  vim.api.nvim_set_option_value("modified", false, { buf = self.id_buf })
  vim.api.nvim_buf_set_extmark(self.id_buf, self.id_ns, 1, 1, { hl_group = "Debug", end_col = #self.lines[2] })
end

function Fortune:update()
  if #self.cookie > 0 then
    for i,_ in pairs(self.cookie) do self.cookie[i] = nil end
  end
  local width = vim.api.nvim_win_get_width(self.id_win)
  if not vim.api.nvim_buf_is_valid(self.id_buf) then return end
  for _ = 1, num_cookies, 1 do
    vim.fn.jobstart(cookie_command .. "|fmt -" .. width - 2, {
      on_stdout = function(_, b, _)
        for _, v in ipairs(b) do
          if #v > 1 then
            table.insert(self.cookie, v)
          end
        end
      end,
      on_exit = function()
        table.insert(self.cookie, " ")
        self:render()
      end,
    })
  end
end

function Fortune:destroy()
  for i,_ in pairs(self.cookie) do self.cookie[i] = nil end
  for i,_ in pairs(self.lines) do self.lines[i] = nil end
end

local M = {}

---@param id_buf integer
---@param id_win integer
---@param id_tab integer
---@param id_ns  integer
---@return subspace.Fortune
function M.new(id_buf, id_win, id_tab, id_ns)
  return Fortune:new(id_buf, id_win, id_tab, id_ns)
end

return M

