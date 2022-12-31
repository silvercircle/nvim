-- this implements some private features for my neovim config.
-- it depends on some plugins like telescope and Neotree and should therefore be required() after all
-- plugins were setup

-- this is a simple favorite folders feature, meant to be used with the Neotree plugin.
-- it reads ~/.config/nvim/favs for a table of favorites. The format for the file is
-- Name|directory
-- one entry per line
--
-- Requirements: Telescope for the searchable picker.
function Neofavs()
  local max_width = 90
  local title_width = 30
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
  favselector(Telescope_dropdown_theme{width=0.5, height=0.4})
end

function Editfavs()
  vim.cmd("e " .. vim.fn.stdpath("config") .. "/favs")
end