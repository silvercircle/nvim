local M = {}

-- some library functions
-- pad string left and right to length with fill as fillchar
function M.pad(string, length, fill)
  local padlen = (length - #string) / 2
  if #string >= length or padlen < 2 then
    return string
  end
  return string.rep(fill, padlen) .. string .. string.rep(fill, padlen)
end

function M.lpad(string, length, fill)
  local padlen = (length - #string)
  if #string >= length or padlen < 2 then
    return string
  end
  return string.rep(fill, padlen) .. string
end

function M.rpad(string, length, fill)
  local padlen = (length - #string)
  if #string >= length or padlen < 2 then
    return string
  end
  return string .. string.rep(fill, padlen)
end

function M.string_split(s, delimiter)
  local result = {};
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    table.insert(result, match);
  end
  return result;
end

function M.truncate(text, max_width)
  if #text > max_width then
    return string.sub(text, 1, max_width) .. "…"
  else
    return text
  end
end

-- find root (guesswork) for the file with the full path fname
-- @param fname: string (a fullpath filename)
-- @param pattern: varargs strings or table of strings: pattern that occur in a project
--  root directory. Full filenames and wildcards allowed. For example: .git, *.gpr, Cargo.toml are all
--  valid patterns. This uses the LSP utility library.
function M.getroot(fname, pattern, ...)
  local lsputil = require('lspconfig.util')
  local path = lsputil.root_pattern(pattern, ...)(fname)
  if path == nil then
    vim.notify("Utils: " .. fname .. ": no root found", 3)
    return "."
  else
    return path
  end
end

-- a helper function for M.getroot()
-- @param pattern: varargs string. see above
-- this always exands the filename for the current buffer.
function M.getroot_current(pattern, ...)
  return M.getroot(vim.fn.expand("%:p:h"), pattern, ...)
end

--- simple telescope picker to list active LSP servers. Allows to terminate a server on selection.
function M.StopLsp()
  local entries = {}
  local clients = vim.lsp.get_active_clients()
  for _, client in ipairs(clients) do
    local entry = M.rpad(tostring(client['id']), 10, ' ') .. M.rpad(client['name'], 20, ' ') .. M.rpad(client['config']['cmd'][1], 40, ' ')
    table.insert(entries, entry)
  end
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local tconf = require("telescope.config").values
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
      sorter = tconf.generic_sorter(opts),
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

-- confirm buffer close when file is modified. May discard the file but always save the view.
function M.BufClose()
  local closecmd = "Kwbd"
  local saveclosecmd = "update! | Kwbd"

  if vim.api.nvim_buf_get_option(0, "modified") == true then
    if vim.g.confirm_actions['close_buffer'] == true then
      vim.ui.select({ 'Save and Close', 'Close and discard', 'Cancel Operation' }, {
      prompt = 'Close modified buffer?',
        format_item = function(item)
          return M.pad(item, 44, ' ')
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

function M.Quitapp()
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
          return M.pad(item, 44, ' ')
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
          return M.pad(item, 44, ' ')
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

return M

