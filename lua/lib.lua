-- some library functions
-- pad string left and right to length with fill as fillchar
function MyPad(string, length, fill)
  local padlen = (length - #string) / 2
  if #string >= length or padlen < 2 then
    return string
  end
  return string.rep(fill, padlen) .. string .. string.rep(fill, padlen)
end

function Lpad(string, length, fill)
  local padlen = (length - #string)
  if #string >= length or padlen < 2 then
    return string
  end
  return string.rep(fill, padlen) .. string
end
function Rpad(string, length, fill)
  local padlen = (length - #string)
  if #string >= length or padlen < 2 then
    return string
  end
  return string .. string.rep(fill, padlen)
end

function String_split(s, delimiter)
  local result = {};
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    table.insert(result, match);
  end
  return result;
end

-- confirm force-quit (Alt-q)
function Quitapp()
  local bufs = vim.api.nvim_list_bufs()
  local have_modified_buf = false

  for _, bufnr in ipairs(bufs) do
    if vim.api.nvim_buf_get_option(bufnr, "modified") == true then
      have_modified_buf = true
    end
  end
  if have_modified_buf == false then
    -- no modified files, but we want to confirm exit anyway
    if vim.g.confirm_actions['exit'] == true then
      vim.ui.select({ 'Really exit?', 'Cancel operation' }, {
        prompt = 'Exit (no modified buffers)',
        border="single",
        format_item = function(item)
          return MyPad(item, 44, ' ')
        end,
      },
      function(choice)
        if choice == 'Really exit?' then
          vim.cmd("qa!")
        else
          return
        end
      end)
    else
      vim.cmd("qa!")
    end
  else
    -- let the user choose (save all, discard all, cancel)
    vim.ui.select({ 'Save all modified buffers and exit', 'Discard all modified buffers and exit', 'Cancel operation' }, {
      prompt = 'Exit (all unsaved changes are lost)',
        format_item = function(item)
          return MyPad(item, 44, ' ')
        end,
      },
      function(choice)
        if choice == 'Discard all modified buffers and exit' then
          vim.cmd("qa!")
        elseif choice == 'Save all modified buffers and exit' then
          vim.cmd("wa!")
          vim.cmd("qa!")
        else
          return
        end
      end)
  end
end

-- confirm buffer close when file is modified. May discard the file but always save the view.
function BufClose()
  local closecmd = "call Mkview() | Kwbd"
  local saveclosecmd = "update! | Kwbd"

  if vim.api.nvim_buf_get_option(0, "modified") == true then
    if vim.g.confirm_actions['close_buffer'] == true then
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
        elseif choice == 'Close and discard' then
          vim.cmd(closecmd)
          return
        else
          return
        end
      end)
    else
      vim.cmd(closecmd)
    end
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

-- read favorite files and folders from the given file
function ReadFolderFavs(favfile)
  local favs = {}
  local filename

  local status, path = pcall(require, 'plenary.path')
  if status == false then
    vim.notify("A required plugin (plenary) is missing.", 3)
    return false, {}
  end

  if favfile ~= nil then
    filename = path:new(vim.fn.stdpath("config"), favfile)['filename']
  else
    filename = vim.fn.stdpath("config") .. "/favs"
  end
  if vim.fn.filereadable(filename) == 0 then
    vim.notify("The given file (" .. filename .. ") does not exist", 3)
    return false, {}
  end
  local file = io.open(filename)
  if file == nil then
    print("Favorite file not found, should be in " .. filename)
    return false, {}
  end
  local lines = file:lines()
  for line in lines do
    if line ~= nil and #line > 1 then
      local elem=String_split(line, '|')
      if #elem == 2 then
        table.insert(favs, { title = elem[1], dir = elem[2] } )
      end
    end
  end
  io.close(file)
  return true, favs
end

