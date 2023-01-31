local M = {}

M.statuscol_current = 'normal'

function M.set_statuscol(mode)
  if mode == 'normal' then
    M.statuscol_current = 'normal'
    vim.o.statuscolumn = vim.g.config.statuscol_normal
    vim.o.relativenumber = false
    vim.o.numberwidth=5
    vim.o.number = true
    return
  elseif mode == 'rel' then
    M.statuscol_current = 'rel'
    vim.o.statuscolumn = vim.g.config.statuscol_rel
    vim.o.relativenumber = true
    vim.o.numberwidth=5
    vim.o.number = false
    return
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

function M.mkview()
  if #vim.fn.expand("%") > 0 and vim.api.nvim_buf_get_option(0, "buftype") ~= 'nofile' then
    vim.cmd("silent! mkview!")
  end
end

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
