---@class tab
---@field id_main number    -- main window id
---@field id_page integer   -- tabpage #
---@field term term         -- term split
---@field wsplit wsplit
---@field usplit usplit

---@class term
---@field id_buf  number?
---@field id_win  integer?
---@field height  number
---@field visible boolean

---@class wsplit
---@field id_win  integer?
---@field id_buf  number?

---@class usplit
---@field id_win  integer?
---@field id_buf  number?

local M = {}

---@type table<number, tab>
M.T = {}

M.active = nil

function M.new(tabpage)
  M.T[tabpage] = {
    id_main = 0,
    id_page = tabpage,
    term = {
      id_buf = nil,
      id_win = nil,
      height = 0,
      visible = false
    },
    wsplit = {
      id_win = nil,
      id_buf = nil
    },
    usplit = {
      id_win = nil,
      id_buf = nil
    }
  }
end

---@param nr? integer the desired tab index or the active when nr is not given
---@return tab
function M.get(nr)
  nr = nr or M.active
  return M.T[nr] and M.T[nr] or M.T[1]
end

--- opens a terminal split at the bottom. May also open the sysmon/fortune split
--- @param _height number: height of the terminal split to open.
function M.termToggle(_height)
  local curtab = vim.api.nvim_get_current_tabpage()
  local term = M.T[curtab].term
  local height = _height or term.height

  height = height <= vim.o.lines/2 and height or vim.o.lines/2
  local reopen_outline = false
  -- if it is visible, then close it an all sub frames
  -- but leave the buffer open
  if term.visible == true then
    require("subspace.content.usplit").close()
    vim.api.nvim_win_hide(term.id_win)
    term.visible = false
    term.id_win = nil
    return
  end
  local outline_win = CGLOBALS.findWinByFiletype(PCFG.outline_filetype, true)

  if outline_win[1] ~= nil and vim.api.nvim_win_is_valid(outline_win[1]) then
    CGLOBALS.close_outline()
    reopen_outline = true
  end

  vim.fn.win_gotoid(M.T[curtab].id_main)
  -- now, if we have no terminal buffer (yet), create one. Otherwise just select
  -- the existing one.
  if term.id_buf == nil then
    local shell = Tweaks.shell or "$SHELL"
    vim.cmd("belowright " .. height .. " sp|terminal export NOCOW=1 && " .. shell )
  else
    vim.cmd("belowright " .. height .. " sp")
    vim.api.nvim_win_set_buf(0, term.id_buf)
  end
  -- configure the terminal window
  vim.cmd(
    "setlocal statuscolumn=%#TreeNormalNC#\\  | set filetype=terminal | set nonumber | set norelativenumber | set foldcolumn=0 | set signcolumn=no | set winfixheight | set nocursorline | set winhl=SignColumn:TreeNormalNC,Normal:TreeNormalNC"
  )
  term.id_win = vim.fn.win_getid()
  term.height = vim.api.nvim_win_get_height(term.id_win)
  vim.api.nvim_set_option_value("statusline", "  Terminal", { win = term.id_win })
  term.id_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_option_value("buflisted", false, { buf = term.bufid })
  term.visible = true

  -- finally, open the sub frames if they were previously open
  if PCFG.sysmon.active == true then
    require("subspace.content.usplit").content = PCFG.sysmon.content
    require("subspace.content.usplit").open()
  end

  if reopen_outline == true then
    vim.fn.win_gotoid(M.main_winid[PCFG.tab])
    CGLOBALS.open_outline()
    vim.schedule(function()
      vim.fn.win_gotoid(M.main_winid[PCFG.tab])
    end)
  end
end
return M
