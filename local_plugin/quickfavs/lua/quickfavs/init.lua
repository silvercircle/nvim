local M = {}

local conf = {
  filename = vim.fn.stdpath("config") .. "/favs"
}

function M.init()
  print("The filename is: " .. conf.filename)
end

function M.setup(opts)
  --local path =  require("plenary.path")
  opts = opts or {}
end

local function rpad(string, length, fill)
  local padlen = (length - #string)
  if #string >= length or padlen < 2 then
    return string
  end
  return string .. string.rep(fill, padlen)
end
local function string_split(s, delimiter)
  local result = {};
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    table.insert(result, match);
  end
  return result;
end

local function truncate(text, max_width)
  if #text > max_width then
    return string.sub(text, 1, max_width) .. "…"
  else
    return text
  end
end

local favs = {}

-- read favorite files and folders from the given file
local function ReadFolderFavs(favfile)
  -- local favs = {}
  local filename
  if #favs > 0 then
    print("Favs already read")
    return true, favs
  end

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
      local elem = string_split(line, '|')
      if #elem == 2 then
        local f = path:new(elem[2])
        local e = f:expand()
        if vim.fn.isdirectory(e) == 1 then
          table.insert(favs, { title = elem[1], filename = e, type = "@Dir" } )
        elseif vim.fn.filereadable(e) == 1 then
          table.insert(favs, { title = elem[1], filename = e, type = "@File" } )
        end
      end
    end
  end
  io.close(file)
  return true, favs
end

function M.Quickfavs()
  local max_width = 90
  local title_width = 30
  local status

  if pcall(require, "neo-tree") == false then
    print("This feature requires the NeoTree plugin")
    return
  end
  if pcall(require, 'telescope') == false then
    print("This feature requires the Telecope plugin.")
    return
  end
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local utils = require "telescope.utils"
 --  local make_entry = require "telescope.make_entry"

  status, favs = ReadFolderFavs(conf.filename)
  if status == false then
    vim.notify("Read favorite folders returned an error", 3)
    return
  end
  -- use telescope
  local favselector = function(opts)
    opts = opts or {}
    pickers.new(opts, {
      prompt_title = "Select directory favorite",
      layout_config = {
        horizontal = {
          prompt_position = "bottom"
        }
      },
      finder = finders.new_table {
        results = favs,
        entry_maker = function(entry)
          local icon, hl_group = utils.get_devicons(entry.filename, false)
          return {
            value = entry,
            display = function() return truncate(rpad(entry.type, 10, ' ') .. rpad(entry.title, title_width, ' ') .. "  " .. icon .. " " .. entry.filename, max_width) end,
            ordinal = entry.title .. "  " .. entry.type,
          }
        end,
      },
      mappings = {
        n = {
          ['<c-d>'] = actions.delete_buffer
        },
        i = {
          ['<c-d>'] = function() print("affen") end,
        },
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        map('i', '<c-d>', function(_)
          local selection = action_state.get_selected_entry()
          if vim.fn.isdirectory(selection.value.filename) ~= 0 then
            vim.notify("Set " .. selection.value.filename .. " as current working directory.", 3)
            vim.api.nvim_set_current_dir(selection.value.filename)
          end
        end)
        actions.select_default:replace(function()
          -- local path = require("plenary.path")
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection.value.filename ~= nil and #selection.value.filename > 0 then
            local name = selection.value.filename
            --local f = path:new(selection.value.filename)
            --local name = f:expand()
            if vim.fn.filereadable(name) ~= 0 then
              vim.cmd('e ' .. name)
            elseif vim.fn.isdirectory(name) ~= 0 then
              vim.cmd("Neotree position=float dir=" .. name)
            end
          end
        end)
      return true
      end,
    }):find()
  end
  favselector(Telescope_dropdown_theme{width=0.5, height=0.4, title="Select favorite (Enter=open in Neotree, <C-d> set as CWD)"})
end

return M

