---@class tab
---@field id_main integer    -- main window id
---@field id_page integer   -- tabpage #
---@field term term         -- term split
---@field wsplit wsplit
---@field usplit usplit
---@field id_outline integer?

---@class term
---@field id_buf  number?
---@field id_win  integer?
---@field height  number
---@field visible boolean

---@class wsplit
---@field id_win  integer?
---@field id_buf  integer?
---@field timer   uv.uv_timer_t?
---@field cookie_timer   uv.uv_timer_t?
---@field watch   uv.uv_fs_event_t?
---@field cookie  table<integer, string>
---@field old_dimensions table
---@field width   integer?
---@field height  integer?
---@field content_id_win integer?
---@field content string
---@field freeze  boolean

---@class usplit
---@field id_win  integer?
---@field id_buf  integer?
---@field content string
---@field width   integer
---@field cookie  table<integer, string>
---@field old_dimensions table
---@field timer   uv.uv_timer_t?

local M = {}

---@type table<number, tab>
M.T = {}

M.active = 1

function M.new(tabpage)
  M.T[tabpage] = {
    id_main = 0,
    id_page = tabpage,
    id_outline = nil,
    term = { id_buf = nil, id_win = nil, height = 0, visible = false },
    wsplit = { id_win = nil, id_buf = nil, width = 0, height = 0,
      content = "info",
      content_id_win = nil,
      cookie = {},
      old_dimensions = { w = 0, h = 0 },
      timer = nil,
      cookie_timer = nil,
      watch = nil,
      freeze = false
    },
    usplit = { id_win = nil, id_buf = nil, content = "fortune", width = 0,
      cookie = {},
      old_dimensions = { w = 0, h = 0 },
      timer = nil
    }
  }
end

function M.clonetab()
  local from_id = vim.api.nvim_get_current_tabpage()
  local from = M.T[from_id]
  local tree = M.findWinByFiletype(Tweaks.tree.filetype, true)
  local ol = M.is_outline_open()
  vim.cmd("tabnew")
  if ol ~= false then M.open_outline() end
  if from.term.visible then M.termToggle(12) end
  if tree and #tree >= 1 then M.open_tree() end
end

-- cleanup a tab page.
---@param tabpage integer
function M.remove(tabpage)
  local Symbols = require("symbols")
  local tab = M.T[tabpage]
  if tab then
    -- id == 1 is the first tab created at startup. do not allow to remove it.
    if tab.id_page == 1 then return end
    if tab.id_outline then
      local id = Symbols.sidebar.get(tab.id_main)
      Symbols.sidebar.close(id)
    end
    if tab.usplit then
      if tab.usplit.timer then
        tab.usplit.timer:stop()
        tab.usplit.timer:close()
      end
      if tab.usplit.id_buf ~= nil then vim.api.nvim_buf_delete(tab.usplit.id_buf, { force = true }) end
    end
    if tab.term then
      if tab.term.id_buf ~= nil then vim.api.nvim_buf_delete(tab.term.id_buf, { force = true }) end
    end
    if tab.wsplit then
      if tab.wsplit.timer then
        tab.wsplit.timer:stop()
        tab.wsplit.timer:close()
      end
      if tab.wsplit.cookie_timer then
        tab.wsplit.cookie_timer:stop()
        tab.wsplit.cookie_timer:close()
      end
      if tab.wsplit.id_buf ~= nil then vim.api.nvim_buf_delete(tab.wsplit.id_buf, { force = true }) end
    end
  end
  M.T[tabpage] = nil
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
  local outline_win = TABM.findWinByFiletype(PCFG.outline_filetype, true)

  if outline_win[1] ~= nil and vim.api.nvim_win_is_valid(outline_win[1]) then
    M.close_outline()
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
    TABM.T[curtab].usplit.content = PCFG.sysmon.content
    require("subspace.content.usplit").open()
  end

  if reopen_outline == true then
    vim.fn.win_gotoid(M.T[curtab].id_main)
    TABM.open_outline()
    vim.schedule(function()
      vim.fn.win_gotoid(M.T[curtab].id_main)
    end)
  end
end

--- find a buffer with type and focus its primary window split
--- @param type string: filetype (e.g. "NvimTree"
--- @param intab? boolean: stay in the current tab when searching
--- @param focus? boolean: focus the window
--- @return integer: id of the window or 0 if none was found
function M.findbufbyType(type, intab, focus)
  intab = intab or false
  focus = focus or true
  local winid = M.findWinByFiletype(type, intab)
  if #winid > 0 then
    if focus then vim.fn.win_gotoid(winid[1]) end
    return winid[1]
  end
  return 0
end

--- find the first window for a given filetype.
--- @param filetypes string|table: the filetype(s)
--- @param intab? boolean: stay in tab
--- @return table: a list of windows displaying the buffer or an empty list if none has been found
function M.findWinByFiletype(filetypes, intab)
  intab = intab or false
  local curtab = vim.api.nvim_get_current_tabpage()

  local function finder(ft, where)
    if type(where) == "string" then
      return ft == where
    else
      return vim.tbl_contains(where, ft)
    end
  end

  local ls = vim.api.nvim_list_bufs()
  local win_ids = {}
  for i = 1, #ls, 1 do
    if vim.api.nvim_buf_is_valid(ls[i]) then
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = ls[i] })
      if finder(filetype, filetypes) then
        local wins = vim.fn.win_findbuf(ls[i])
        if #wins == 1 and (not intab or (vim.api.nvim_win_get_tabpage(wins[1]) == curtab)) then
          table.insert(win_ids, wins[1])
        else
          for j = 1, #wins, 1 do
            if (not intab or (vim.api.nvim_win_get_tabpage(wins[1]) == curtab)) then
              table.insert(win_ids, wins[j])
            end
          end
        end
      end
    end
  end
  return win_ids
end

-- outline (Symbols plugin) related

function M.is_outline_open()
  local _o = M.findWinByFiletype(PCFG.outline_filetype, true)
  if #_o > 0 and _o[1] ~= nil then
    return _o[1]
  end
  return false
end

--- open the outline window
function M.open_outline()
  local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
  if buftype ~= "" then  --current buffer is no ordinary file. Ignore it.
    return
  end
  vim.cmd("Symbols!")
  local id_win = M.is_outline_open()
  if id_win and vim.api.nvim_win_is_valid(id_win) then
    vim.api.nvim_set_option_value("winhl", "Normal:TreeNormalNC,CursorLine:TreeCursorLine", { win = id_win })
    vim.api.nvim_win_set_width(id_win, PCFG.outline.width)
    M.T[M.active].id_outline = id_win
  end
end

--- close the outline window
function M.close_outline()
  local tab = TABM.get()
  vim.cmd("SymbolsClose")
  tab.id_outline = nil
end

-- file-tree related

--- open the tree (file manager tree on the left). It can be either NvimTree
--- or NeoTree
function M.open_tree()
  if Tweaks.tree.version == "Nvim" then
    require('nvim-tree.api').tree.toggle({ focus = false })
  elseif Tweaks.tree.version == "Neo" then
    require("neo-tree.command").execute({
      action = "show",
      source = "filesystem",
      position = "left"
    })
  -- TODO: make it work with snacks explorer
  elseif Tweaks.tree.version == "Explorer" then
    require("snacks").picker.explorer( { jump = {close=false},
      auto_close = false, layout={position="left", layout={ border="none", width=40, min_width=40}} } )
  end
end

--- called by the event handler in NvimTree or NeoTree to inidicate that
--- the file tree has been opened.
function M.tree_open_handler()
  local wsplit = require("subspace.content.wsplit")
  local ws = M.get().wsplit

  vim.opt.statuscolumn = ''
  local w = vim.fn.win_getid()
  vim.api.nvim_set_option_value('statusline', '   ' .. (Tweaks.tree.version == "Neo" and "NeoTree" or "NvimTree"), { win = w })
  vim.cmd('setlocal winhl=Normal:TreeNormalNC,CursorLine:Visual | setlocal statuscolumn= | setlocal signcolumn=no | setlocal nonumber')
  vim.api.nvim_win_set_width(w, PCFG.tree.width)
  M.adjust_layout()
  if PCFG.weather.active == true then
    ws.content = PCFG.weather.content
    if ws.id_win == nil then
      wsplit.openleftsplit(CFG.weather.file)
    end
  end
end

--- called by the event handler in NvimTree or NeoTree to inidicate that
--- the file tree was opened.
function M.tree_close_handler()
  local wsplit = require("subspace.content.wsplit")
  wsplit.close()
  M.T[M.active].wsplit.id_win = nil
  M.adjust_layout()
  if M.T[M.active].term.id_win ~= nil then
    vim.api.nvim_win_set_height(M.T[M.active].term.id_win, M.T[M.active].term.height)
  end
end

--- adjust the optional frames so they will keep their width when the side tree opens or closes
function M.adjust_layout()
  local usplit = M.T[M.active].usplit.id_win
  local term = M.T[M.active].term

  vim.o.cmdheight = Tweaks.cmdheight
  if usplit ~= nil then
    vim.api.nvim_win_set_width(usplit, PCFG.sysmon.width)
  end
  vim.api.nvim_win_set_height(M.T[M.active].id_main, 200)
  if term.id_win ~= nil then
    local width = vim.api.nvim_win_get_width(term.id_win)
    vim.api.nvim_win_set_height(term.id_win, term.height)
    vim.api.nvim_win_set_width(term.id_win, width - 1)
    vim.api.nvim_win_set_width(term.id_win, width)
  end
  local outline = M.findWinByFiletype(PCFG.outline_filetype, true)
  if #outline > 0 then
    vim.api.nvim_win_set_width(outline[1], PCFG.outline.width)
  end
end

return M
