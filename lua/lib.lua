-- some library functions

-- pad string left and right to length with fill as fillchar
local function MyPad(string, length, fill)
  local padlen = (length - #string) / 2
  if #string >= length or padlen < 2 then
    return string
  end
  return string.rep(fill, padlen) .. string .. string.rep(fill, padlen)
end


-- confirm force-quit (Alt-q)
function Quitapp()
  if vim.g.confirm_actions['exit'] == true then
    vim.ui.select({ 'Yes, exit now', 'Cancel exit' }, {
      prompt = 'Exit (all unsaved changes are lost)',
        format_item = function(item)
          return MyPad(item, 44, ' ')
        end,
      },
      function(choice)
        if choice == 'Yes, exit now' then
          vim.cmd("qa!")
        else
          return
        end
      end)
  else
    vim.cmd("qa!")
  end
end

-- confirm buffer close when file is modified. May discard the file but always save the view.
function BufClose()
  local closecmd = "call Mkview() | Kwbd"
  local saveclosecmd = "update! | Kwbd"

  if vim.api.nvim_buf_get_option(0, "modified") == true and vim.g.confirm_actions['close_buffer'] == true then
    vim.ui.select({ 'Save and Close', 'Close and discard', 'Cancel Operation' }, {
      prompt = 'Close modified buffer?',
        format_item = function(item)
          return MyPad(item, 44, ' ')
        end,
      },
      function(choice)
        if choice == "Cancel Operation" then
          return
        elseif choice == 'Save and Close' then
          vim.cmd(saveclosecmd)
          return
        else
          vim.cmd(closecmd)
          return
        end
      end)
  else
    vim.cmd(closecmd)
  end
end

-- this global function is used in cokeline, cmp and maybe other modules to truncate strings.
Truncate = function(text, max_width)
  if #text > max_width then
    return string.sub(text, 1, max_width) .. "…"
  else
    return text
  end
end