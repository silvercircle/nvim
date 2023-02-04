local M = {}

M.statuscol_current = 'normal'

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

--- find a buffer with type and focus its primary window split
--- @param type string: buffer type (e.g. "NvimTree"
--- @return boolean false=buffer has no window
function M.findbufbyType(type)
  local ls = vim.api.nvim_list_bufs()
  for _, buf in pairs(ls) do
    if vim.api.nvim_buf_is_valid(buf) then
      local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
      if filetype == type then
        local winid = vim.fn.win_findbuf(buf)
        if winid[1] ~= nil then
          vim.fn.win_gotoid(winid[1])
          return true
        end
      end
    end
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

return M
