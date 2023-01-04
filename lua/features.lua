-- this implements some private features for my neovim config.
-- it depends on some plugins like telescope and Neotree and should therefore be required() after all
-- plugins were setup

-- this is a simple favorite folders feature, meant to be used with the Neotree plugin.
-- it reads ~/.config/nvim/favs for a table of favorites. The format for the file is
-- Name|directory
-- one entry per line
--
-- Requirements: Telescope for the searchable picker.

--- create a telescope picker with favorite folders, read from given file.
--- file must be relative to config directory.
--
function Neofavs(favfile)
  local max_width = 90
  local title_width = 30
  local favs = {}
  local filename

  local status, path = pcall(require, 'plenary.path')
  if status == false then
    vim.notify("A required plugin (plenary) is missing.", 3)
    return
  end

  if favfile ~= nil then
    filename = path:new(vim.fn.stdpath("config"), favfile)['filename']
  else
    filename = vim.fn.stdpath("config") .. "/favs"
  end
  if vim.fn.filereadable(filename) == 0 then
    vim.notify("The given file (" .. filename .. ") does not exist", 3)
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

  local file = io.open(filename)
  if file == nil then
    print("Favorite file not found, should be in " .. filename)
    return
  end
  if pcall(require, "neo-tree") == false then
    print("This feature requires the NeoTree plugin")
    io.close(file)
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
    local entry = Rpad(v['title'], title_width, ' ') .. "  " .. v['dir']
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
      layout_config = {
        horizontal = {
          prompt_position = "bottom"
        }
      },
      finder = finders.new_table {
        results = entries
      },
      sorter = conf.generic_sorter(opts),
      mappings = {
        i = {
          ['<C-d>'] = function() print("foobar") end
        }
      },
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection[1] ~= nil and #selection[1] > 0 then
            for _,v in pairs(entries) do
              if string.sub(selection[1], 1, #v['title']) == v['title'] then
                vim.cmd("Neotree dir=" .. v['dir'])
                return
              end
            end
          end
        end)
      return true
      end,
    }):find()
  end
  favselector(Telescope_dropdown_theme{width=0.5, height=0.4, title="Force - quit LSP server"})
end

function Editfavs()
  vim.cmd("e " .. vim.fn.stdpath("config") .. "/favs")
end

function StopLsp()
  local entries = {}
  clients = vim.lsp.get_active_clients()
  for _, client in ipairs(clients) do
    local entry = Rpad(tostring(client['id']), 10, ' ') .. Rpad(client['name'], 20, ' ') .. Rpad(client['config']['cmd'][1], 40, ' ')
    table.insert(entries, entry)
  end
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local favs

  local lspselector = function(opts)
    opts = opts or {}
    pickers.new(opts, {
      prompt_title = "Active LSP servers",
      layout_config = {
        horizontal = {
          prompt_position = "bottom"
        }
      },
      finder = finders.new_table {
        results = entries
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection[1] ~= nil and #selection[1] > 0 then
            local id = tonumber(string.sub(selection[1], 1, 6))
            if id ~= nil and id > 0 then
              vim.lsp.stop_client({id, true})
            end
          end
        end)
      return true
      end,
    }):find()
  end
  lspselector(Telescope_dropdown_theme{width=0.4, height=0.3, title="Active LSP clients"})
end
