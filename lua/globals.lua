
function Set_statuscol(mode)
  if mode == 'normal' then
    Statuscol_current = 'normal'
    vim.o.statuscolumn = vim.g.config.statuscol_normal
    vim.o.relativenumber = false
    vim.o.numberwidth=5
    vim.o.number = true
    return
  elseif mode == 'rel' then
    Statuscol_current = 'rel'
    vim.o.statuscolumn = vim.g.config.statuscol_rel
    vim.o.relativenumber = true
    vim.o.numberwidth=5
    vim.o.number = false
    return
  end
end

function Toggle_statuscol()
  if Statuscol_current == 'normal' then
    Set_statuscol('rel')
    return
  end
  if Statuscol_current == 'rel' then
    Set_statuscol('normal')
    return
  end
end

function FindbufbyType(type)
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

Truncate = function(text, max_width)
  if #text > max_width then
    return string.sub(text, 1, max_width) .. "…"
  else
    return text
  end
end

--- global function to create a view

function MK_view()
  if #vim.fn.expand("%") > 0 and vim.api.nvim_buf_get_option(0, "buftype") ~= 'nofile' then
    vim.cmd("silent! mkview!")
  end
end

function Set_fo(fo)
  vim.opt_local.formatoptions:append(fo)
end

function Clear_fo(fo)
  vim.opt_local.formatoptions:remove(fo)
end

function Toggle_fo(fo)
  if vim.opt_local.formatoptions:get()[fo] == true then
    Clear_fo(fo)
  else
    Set_fo(fo)
  end
end

Telescope_dropdown_theme = require("local_utils").Telescope_dropdown_theme
Telescope_vertical_dropdown_theme = require("local_utils").Telescope_vertical_dropdown_theme
