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

-- this is a simple favorite folders feature, meant to be used with the Neotree plugin.
-- it reads ~/.config/nvim/favs for a table of favorites. The format for the file is
-- Name|directory
-- one entry per line
--
-- Requirements: Telescope for the searchable picker.
function Neofavs()
  local max_width = 90
  local favs = {}
  -- TODO: make the path and filename customizeable.
  local filename = vim.fn.stdpath("config") .. "/favs"
  if pcall(require, 'telescope') == false then
    print("This feature requires the Telecope plugin.")
    return
  end
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  local file = io.open(filename)
  if pcall(require, "neo-tree") == false then
    print("This feature requires the NeoTree plugin")
    io.close(file)
    return
  end
  if file == nil then
    print("Favorite file not found, should be in " .. vim.fn.stdpath("config") .. "/favs")
    return
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
  local entries = {}
  for _,v in pairs(favs) do
    local entry = Rpad(v['title'], 30, ' ') .. "  " .. v['dir']
    if #entry > max_width then
      entry = Truncate(entry, max_width)
    else
      entry = Rpad(entry, max_width, ' ')
    end
    table.insert(entries, entry)
  end
  -- use telescope
  local favselector = function(opts)
    opts = opts or {}
    pickers.new(opts, {
      prompt_title = "Select directory favorite",
      finder = finders.new_table {
        results = entries
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection[1] ~= nil and #selection[1] > 0 then
            for _,v in pairs(favs) do
              if string.sub(selection[1], 1, #v['title']) == v['title'] then
                if vim.g.features['neotree']['enable'] == true then
                  vim.cmd("Neotree dir=" .. v['dir'])
                end
                return
              end
            end
          end
        end)
      return true
      end,
    }):find()
  end
  favselector(require("telescope.themes").get_dropdown{})
end

function Editfavs()
  vim.cmd("e " .. vim.fn.stdpath("config") .. "/favs")
end