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
