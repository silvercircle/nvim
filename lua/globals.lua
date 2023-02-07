local M = {}

M.statuscol_current = 'normal'
M.winid_bufferlist = 0

--- set the statuscol to either normal or relative line numbers
--- @param mode string: allowed values: 'normal' or 'rel'
function M.set_statuscol(mode)
  if mode ~= nil and mode ~= 'normal' and mode ~= 'rel' then
    return
  end
  M.statuscol_current = mode
  vim.o.statuscolumn = vim.g.config["statuscol_" .. mode ]
  if mode == 'normal' then
    vim.o.relativenumber = false
    vim.o.numberwidth=5
    vim.o.number = true
  else
    vim.o.relativenumber = true
    vim.o.numberwidth=5
    vim.o.number = false
  end
end

function M.toggle_statuscol()
  if M.statuscol_current == 'normal' then
    M.set_statuscol('rel')
    return
  end
  if M.statuscol_current == 'rel' then
    M.set_statuscol('normal')
    return
  end
end

--- find the first window for a given filetype.
--- @param type string: the filetype
--- @return table: a list of windows displaying the buffer or an empty list if none has been found
function M.findwinbyBufType(type)
  local ls = vim.api.nvim_list_bufs()
  for _, buf in pairs(ls) do
    if vim.api.nvim_buf_is_valid(buf) then
      local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
      if filetype == type then
        return vim.fn.win_findbuf(buf)
      end
    end
  end
  return {}
end

--- find a buffer with type and focus its primary window split
--- @param type string: buffer type (e.g. "NvimTree"
--- @return boolean: true if a window was found, false otherwise
function M.findbufbyType(type)
  local winid = M.findwinbyBufType(type)
  if #winid > 0 then
    vim.fn.win_gotoid(winid[1])
    return true
  end
  return false
end

function M.truncate(text, max_width)
  if #text > max_width then
    return string.sub(text, 1, max_width) .. "…"
  else
    return text
  end
end

--- global function to create a view
--- this creates a view using mkview unless the buffer has no file name or is not a file at all.
function M.mkview()
  if #vim.fn.expand("%") > 0 and vim.api.nvim_buf_get_option(0, "buftype") ~= 'nofile' then
    vim.cmd("silent! mkview!")
  end
end

-- functions to set/clear/toggle formatoptions
function M.set_fo(fo)
  vim.opt_local.formatoptions:append(fo)
end

function M.clear_fo(fo)
  vim.opt_local.formatoptions:remove(fo)
end

function M.toggle_fo(fo)
  if vim.opt_local.formatoptions:get()[fo] == true then
    M.clear_fo(fo)
  else
    M.set_fo(fo)
  end
end

--- split the file tree horizontally to about 1/3 of its height.
function M.splittree(bufnr)
  local winid = M.findwinbyBufType("NvimTree")
  if #winid > 0 then
    local splitheight = vim.fn.winheight(winid[1]) * 0.33
    vim.fn.win_gotoid(winid[1])
    vim.cmd("below " .. splitheight .. " sp")
    M.winid_bufferlist = vim.fn.win_getid()
    vim.api.nvim_win_set_option(M.winid_bufferlist, "list", false)
    vim.api.nvim_win_set_option(M.winid_bufferlist, "statusline", "Buffer List")
    vim.cmd("set nonumber | set signcolumn=no | set winhl=Normal:NeoTreeNormalNC | set foldcolumn=0")
    vim.fn.win_gotoid(vim.g.config.main_winid)
    return M.winid_bufferlist
  end
  return 0
end

return M
