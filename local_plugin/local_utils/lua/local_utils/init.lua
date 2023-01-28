-- local utils
-- can be used without calling setup(), but you can use it to set some (few) options.

local M = {}

local default_root_patterns = { "*.gpr", "Makefile", "CMakeLists.txt", "Cargo.toml", "*.nimble", ".vscode" }

local conf = {
  root_patterns = default_root_patterns,
  debugmode = false,
  -- experimental, try root patterns ONLY. not recommended, git_ancestor() is more relieable
  ignore_git = false
}

--- output a debug message
--- @param msg string - what's to be printed
--- does nothing when conf.debugmode = false (default)
function M.debug(msg)
  if conf.debugmode then
    print("Utils: " .. msg)
  end
end

function M.setup(opts)
  opts = opts or {}
  conf.root_patterns = opts.root_patterns or default_root_patterns
  conf.debugmode = opts.debug or false
  conf.ignore_git = opts.ignore_git or false
  if conf.debugmode then
    print("Utils: conf is: ", vim.inspect(conf))
  end
end

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

--- find root (guesswork) for the file with the full path fname
--- tries a git root first, then uses known patterns to identify a potential project root
--- patterns are in conf table.
--- @param fname string (a fullpath filename)
function M.getroot(fname)
  local lsputil = require('lspconfig.util')
  -- try git root first
  local path = nil
  if conf.ignore_git == false then
    path = lsputil.find_git_ancestor(fname)
  end
  if path == nil then
    if conf.ignore_git == false then
      M.debug("No git root found for " .. fname .. " trying root patterns")
    end
    path = lsputil.root_pattern(conf.root_patterns)(fname)
  end
  if path == nil then
    M.debug("No root found for " .. fname .." giving up")
    return "."
  else
    M.debug("Found root path for " .. fname .. ": " .. path)
    return path
  end
end

--- a helper function for M.getroot()
--- this always exands the filename for the current buffer.
function M.getroot_current()
  return M.getroot(vim.fn.expand("%:p:h"))
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
  lspselector(Telescope_dropdown_theme{width=0.4, height=0.2, prompt_title="Active LSP clients (Enter = terminate, ESC cancels)"})
end

-- confirm buffer close when file is modified. May discard the file but always save the view.
function M.BufClose()
  -- local closecmd = "call Mkview() | Kwbd"
  local closecmd = "Kwbd"
  local saveclosecmd = "update! | Kwbd"

  if vim.api.nvim_buf_get_option(0, "modified") == true then
    if vim.g.confirm_actions['close_buffer'] == true then
      vim.ui.select({ 'Save and Close', 'Close and discard', 'Cancel Operation' }, {
      prompt = 'Close modified buffer?',
        format_item = function(item)
          return M.pad(item, 46, ' ')
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
          return M.pad(item, 46, ' ')
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
          return M.pad(item, 46, ' ')
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

-----------------------------------------------------------------
--- TELESCOPE stuff, some global themes that are needed elsewhere
-----------------------------------------------------------------

local border_layout_prompt_top = {
  results = {"─", "│", "─", "│", '├', '┤', '┘', '└'},
  prompt =  {"─", "│", "─", "│", '┌', '┐', "┘", "└"},
  preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
}

local border_layout_prompt_bottom = {
  prompt  = {"─", "│", "─", "│", '┌', '┐', '┘', '└'},
  results = {"─", "│", "─", "│", '┌', '┐', '┤', '├'},
  preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
}

-- private modified version of the dropdown theme with a square border
function M.Telescope_dropdown_theme(opts)
  local lopts = opts or {}
  local defaults = require('telescope.themes').get_dropdown({
    -- borderchars = vim.g.config.telescope_dropdown == 'bottom' and border_layout_bottom_vertical or border_layout_top_center,
    borderchars = vim.g.config.telescope_dropdown == 'bottom' and border_layout_prompt_bottom or border_layout_prompt_top,
    layout_config = {
      anchor = "N",
      width = lopts.width or 0.5,
      height = lopts.height or 0.5,
      prompt_position=vim.g.config.telescope_dropdown,
    },
    -- layout_strategy=vim.g.config.telescope_dropdown == 'bottom' and 'vertical' or 'center',
    previewer = false,
    winblend = vim.g.float_winblend,
  })
  if lopts.cwd ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ': ' .. lopts.cwd
  end
  if lopts.path ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ': ' .. lopts.path
  end
  return vim.tbl_deep_extend('force', defaults, lopts)
end

--- a dropdown theme with vertical layout strategy
--- @param opts table of valid telescope options
function M.Telescope_vertical_dropdown_theme(opts)
  local lopts = opts or {}
  local defaults = require('telescope.themes').get_dropdown({
    borderchars = {
      results = {"─", "│", " ", "│", '┌', '┐', "│", "│"},
      prompt = {"─", "│", "─", "│", "├", "┤", "┘", "└"},
      preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
    },
    fname_width = vim.g.config['telescope_fname_width'],
    sorting_strategy = "ascending",
    layout_strategy = "vertical",
    path_display={smart = true},
    layout_config = {
      width = lopts.width or 0.8,
      height = lopts.height or 0.9,
      preview_height = lopts.preview_width or 0.4,
      prompt_position='bottom',
      scroll_speed = 2,
    },
    winblend = vim.g.float_winblend,
  })
  if lopts.search_dirs ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ': ' .. lopts.search_dirs[1]
  end
  if lopts.cwd ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ': ' .. lopts.cwd
  end
  if lopts.path ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ': ' .. lopts.path
  end
  return vim.tbl_deep_extend('force', defaults, lopts)
end

-- custom theme for the command_center Telescope plugin
-- reason: I have square borders everywhere
function M.command_center_theme(opts)
  local lopts = opts or {}
  local defaults = require('telescope.themes').get_dropdown({
    borderchars = vim.g.config.cpalette_dropdown == 'bottom' and border_layout_prompt_bottom or border_layout_prompt_top,
    layout_config = {
      anchor = "N",
      width = lopts.width or 0.6,
      height = lopts.height or 0.4,
      prompt_position = vim.g.config.cpalette_dropdown,
    },
    -- layout_strategy=vim.g.config.telescope_dropdown == 'bottom' and 'vertical' or 'center',
    previewer = false,
    winblend = vim.g.float_winblend,
  })
  if lopts.cwd ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ': ' .. lopts.cwd
  end
  if lopts.path ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ': ' .. lopts.path
  end
  return vim.tbl_deep_extend('force', defaults, lopts)
end
return M

