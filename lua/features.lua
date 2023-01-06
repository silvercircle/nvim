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

  local status, favs = ReadFolderFavs(favfile)
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
          local display = utils.transform_path({}, entry.dir)
          local icon, hl_group = utils.transform_devicons(display, display, false)
          print(hl_group)
          return {
            value = entry,
            display = function() return Truncate(Rpad(entry.title, title_width, ' ') .. " | " .. icon, max_width) end,
            ordinal = entry.title
          }
        end,
      },
      sorter = conf.generic_sorter(opts),
      mappings = {
        i = {
          ['<C-d>'] = function() print("foobar") end
        }
      },
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          local path = require("plenary.path")
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection.value.dir ~= nil and #selection.value.dir > 0 then
            local f = path:new(selection.value.dir)
            local name = f:expand()
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
  favselector(Telescope_dropdown_theme{width=0.5, height=0.4, title="Select favorite folder"})
end

function Editfavs()
  vim.cmd("e " .. vim.fn.stdpath("config") .. "/favs")
end

--- simple telescope picker to list active LSP servers. Allows to terminate a server on selection.
function StopLsp()
  local entries = {}
  local clients = vim.lsp.get_active_clients()
  for _, client in ipairs(clients) do
    local entry = Rpad(tostring(client['id']), 10, ' ') .. Rpad(client['name'], 20, ' ') .. Rpad(client['config']['cmd'][1], 40, ' ')
    table.insert(entries, entry)
  end
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

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
  lspselector(Telescope_dropdown_theme{width=0.4, height=0.2, title="Active LSP clients (Enter = terminate, ESC cancels)"})
end
