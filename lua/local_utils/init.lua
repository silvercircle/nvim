-- local utils
-- can be used without calling setup(), but you can use it to set some (few) options.

local Utils = {}

local conf = {
  root_patterns = vim.g.tweaks.default_root_patterns,
  debugmode = false,
  -- experimental, try root patterns ONLY. not recommended, git_ancestor() is more relieable
  ignore_git = false,
}

-- Fallback file symbol for devicon
Utils.default_file = ""
-- File symbol for a terminal split
Utils.terminal_symbol = ""

--- Get file symbol from devicons
--- @param filename string: a valid filename
--- @return string, string|nil: the symbol (can be an empty string) and highlight group (can be nil)
--- nvim-web-devicons plugin is REQUIRED
function Utils.getFileSymbol(filename)
  if filename == nil or #filename == 0 then
    return "", nil
  end
  local ext = string.match(filename, "%.([^%.]*)$")

  local symbol, hl = require("nvim-web-devicons").get_icon(filename, ext)
  if not symbol then
    if filename:match("^term://") then
      symbol = Utils.terminal_symbol
    else
      symbol = Utils.default_file
    end
  end
  return symbol, hl
end

--- output a debug message
--- @param msg string - what's to be printed
--- does nothing when conf.debugmode = false (default)
function Utils.debug(msg)
  if conf.debugmode then
    print("Utils: " .. msg)
  end
end

function Utils.setup(opts)
  opts = opts or {}
  conf.root_patterns = opts.root_patterns or vim.g.tweaks.default_root_patterns
  conf.debugmode = opts.debug or false
  conf.ignore_git = opts.ignore_git or false
  if conf.debugmode then
    print("Utils: conf is: ", vim.inspect(conf))
  end
end

-- some library functions
-- pad string left and right to length with fill as fillchar
function Utils.pad(string, length, fill)
  local len = vim.fn.strcharlen(string)
  local padlen = (length - len) / 2
  if len >= length or padlen < 2 then
    return string
  end
  return string.rep(fill, padlen) .. string .. string.rep(fill, padlen)
end

function Utils.lpad(string, length, fill)
  local len = vim.fn.strcharlen(string)
  local padlen = (length - len)
  if len >= length or padlen < 2 then
    return string
  end
  return string.rep(fill, padlen) .. string
end

function Utils.rpad(string, length, fill)
  local len = vim.fn.strcharlen(string)
  local padlen = (length - len)
  if len >= length or padlen < 2 then
    return string
  end
  return string .. string.rep(fill, padlen)
end

function Utils.string_split(s, delimiter)
  local result = {}
  for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result
end

--- get prompt prefix to determine whether a picker has been called in insert mode
--- this is hack-ish, but works.
function Utils.getTelescopePromptPrefix()
  return vim.api.nvim_get_mode().mode == "i" and Config.minipicker_iprefix or "> "
end

--- this function determines the path where a latex-generated PDF may reside. It depends on the
--- setting of config.texoutput. If this is set and _useglobal is true, then the global output
--- path will be used. Otherwise, the .pdf is expected in the same directory as the .tex file
--- @param _filename string: the filename to analyze
--- @param _useglobal boolean: use the global texoutput directory
function Utils.getLatexPreviewPath(_filename, _useglobal)
  local useglobal = _useglobal or false
  local path = vim.fn.expand(Config.texoutput)
  local finalpath
  __Globals.debugmsg("The preview path is: " .. path)
  if useglobal == true and #path > 0 and vim.fn.isdirectory(path) == 1 then
    finalpath = path .. vim.fn.expand(vim.fn.fnamemodify(_filename, ":t:r")) .. ".pdf"
  else
    finalpath = vim.fn.expand(vim.fn.fnamemodify(_filename, ":r")) .. ".pdf"
  end
  if vim.fn.filereadable(finalpath) == 1 then
    return true, finalpath
  else
    return false, ""
  end
end

function Utils.view_latex()
  return function()
    local result, path = Utils.getLatexPreviewPath(vim.fn.expand("%"), true)
    if result == true then
      local cmd = "silent !" .. vim.g.tweaks.texviewer .. " '" .. path .. "' &"
      vim.cmd.stopinsert()
      vim.schedule(function()
        vim.cmd(cmd)
      end)
    else
      print("The PDF output does not exist. Please recompile.")
      return
    end
  end
end

function Utils.compile_latex()
  return function()
    -- must change cwd to current, otherwise latex may not found subdocuments using relative
    -- file names.
    local cwd = "cd " .. vim.fn.expand("%:p:h")
    vim.cmd(cwd)
    local cmd = "!lualatex --output-directory="
      .. vim.fn.expand(Config.texoutput)
      .. " '"
      .. vim.fn.expand("%:p")
      .. "'"
    __Globals.debugmsg(cmd)
    vim.cmd.stopinsert()
    vim.schedule(function()
      vim.cmd(cmd)
    end)
  end
end

--- find root (guesswork) for the file with the full path fname
--- tries a git root first, then uses known patterns to identify a potential project root
--- patterns are in conf table.
--- @param fname string (a fullpath filename)
function Utils.getroot(fname)
  local lsputil = require("lspconfig.util")
  -- try git root first
  local path = nil
  if conf.ignore_git == false then
    path = lsputil.find_git_ancestor(fname)
  end
  if path == nil then
    if conf.ignore_git == false then
      Utils.debug("No git root found for " .. fname .. " trying root patterns")
    end
    path = lsputil.root_pattern(conf.root_patterns)(fname)
  end
  if path == nil then
    Utils.debug("No root found for " .. fname .. " giving up")
    return "."
  else
    Utils.debug("Found root path for " .. fname .. ": " .. path)
    return path
  end
end

--- a helper function for M.getroot()
--- this always exands the filename for the current buffer.
function Utils.getroot_current()
  return Utils.getroot(vim.fn.expand("%:p:h"))
end

--- simple telescope picker to list active LSP servers. Allows to terminate a server on selection.
function Utils.StopLsp()
  local entries = {}
  local clients = vim.lsp.get_active_clients()
  for _, client in ipairs(clients) do
    local attached = client["attached_buffers"]
    local count = 0
    for _ in pairs(attached) do count = count + 1 end
    local entry = Utils.rpad(tostring(client["id"]), 10, " ")
      .. Utils.rpad(client["name"], 30, " ")
      .. Utils.rpad(count .. " Buffer(s)  ", 15, " ")
      .. (type(client["config"]["cmd"]) == "table" and Utils.rpad(vim.fn.fnamemodify(client["config"]["cmd"][1], ":t"), 40, " ") or client["name"])
    table.insert(entries, entry)
  end
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local tconf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local function do_terminate(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    if selection[1] ~= nil and #selection[1] > 0 then
      local id = tonumber(string.sub(selection[1], 1, 6))
      if id ~= nil and id > 0 then
        if #vim.lsp.get_buffers_by_client_id(id) > 0 then
          vim.notify("The LSP server with id " .. id .. " has attached buffers. Will not terminate.")
        else
          current_picker:delete_selection(function(_) end)
          vim.lsp.stop_client(id, true)
        end
      end
    end
  end

  local lspselector = function(opts)
    opts = opts or {}
    pickers
      .new(opts, {
        layout_config = {
          horizontal = {
            prompt_position = "bottom",
          },
        },
        finder = finders.new_table({
          results = entries,
        }),
        sorter = tconf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
          map("i", "<C-d>", function()
            do_terminate(prompt_bufnr)
          end)
          actions.select_default:replace(function()
            do_terminate(prompt_bufnr)
          end)
          return true
        end
      })
      :find()
  end
  lspselector(
    __Telescope_dropdown_theme({
      width = 0.4,
      height = 0.4,
      prompt_title = "Active LSP clients (<C-d> or <Enter> to terminate, ESC cancels)",
    })
  )
end

-- confirm buffer close when file is modified. May discard the file but always save the view.
function Utils.BufClose()
  -- local closecmd = "call Mkview() | Kwbd"
  local closecmd = "silent! Kwbd"
  local saveclosecmd = "update! | silent! Kwbd"

  -- do not close these filetypes
  local dontclose = { "neo-tree ", "NvimTree", "Outline", "weather", "terminal", "sysmon", "aerial" }
  if vim.tbl_contains(dontclose, vim.api.nvim_buf_get_option(0, "filetype")) then
    return
  end

  if vim.api.nvim_buf_get_option(0, "modified") == true then
    if vim.g.confirm_actions["close_buffer"] == true then
      vim.ui.select({ "Save and Close", "Close and discard", "Cancel Operation" }, {
        prompt = "Close modified buffer?",
        format_item = function(item)
          return Utils.pad(item, 46, " ")
        end
      }, function(choice)
        if choice == "Cancel Operation" then
          return
        elseif choice == "Save and Close" then
          vim.cmd(saveclosecmd)
          return
        elseif choice == "Close and discard" then
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

local fdm = {
  { text = Utils.pad("Indent", 25, " "), val = "indent" },
  { text = Utils.pad("Expression", 25, " "), val = "expr" },
  { text = Utils.pad("Syntax", 25, " "), val = "syntax" },
  { text = Utils.pad("Marker", 25, " "), val = "marker" },
  { text = Utils.pad("Diff", 25, " "), val = "diff" },
  { text = Utils.pad("Manual", 25, " "), val = "manual" },
}

--- use mini.pick to pick a folding method.
--- @param currentmode string: the current folding method will be placed on top of the list and highlighted
function Utils.PickFoldingMode(currentmode)
  if currentmode == nil or currentmode == "" then
    return
  end

  local pick = require("mini.pick")
  local index = 0
  for i, v in ipairs(fdm) do
    if v.val == currentmode then
      index = i
    end
  end
  if index > 0 then
    local swap = fdm[1]
    fdm[1] = fdm[index]
    fdm[index] = swap
  end
  pick.start({
    source = {
      items = fdm,
      name = "Foldmethod",
      choose = function(item)
        if item.val ~= "none" then
          __Globals.debugmsg("Selected folding method: " .. item.val)
          vim.schedule(function()
            vim.o.foldmethod = item.val
          end)
          if item.val == "expr" then
            vim.schedule(function()
              vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            end)
          end
        end
      end,
    },
    window = {
      config = __Globals.mini_pick_center(25, 6, 0.3),
    },
  })
end

function Utils.Quitapp()
  local bufs = vim.api.nvim_list_bufs()
  local have_modified_buf = false

  for _, bufnr in ipairs(bufs) do
    if vim.api.nvim_buf_get_option(bufnr, "modified") == true then
      have_modified_buf = true
    end
  end
  if have_modified_buf == false then
    -- no modified files, but we want to confirm exit anyway
    if vim.g.confirm_actions["exit"] == true then
      vim.ui.select({ "Really exit?", "Cancel operation" }, {
        prompt = "Exit (no modified buffers)",
        border = "single",
        format_item = function(item)
          return Utils.pad(item, 40, " ")
        end,
      }, function(choice)
        if choice == "Really exit?" then
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

    vim.ui.select({ "Save all modified buffers and exit",
                    "Discard all modified buffers and exit",
                    "Cancel operation" }, {
      prompt = "Exit (all unsaved changes are lost)",
      format_item = function(item)
        return Utils.pad(item, 41, " ")
      end,
    }, function(choice)
      if choice == "Discard all modified buffers and exit" then
        vim.cmd("qa!")
      elseif choice == "Save all modified buffers and exit" then
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

-- perm_config.telescope_borders decides which style is used. It can be
-- "squared", "rounded" or "none"
local border_layout_prompt_top = {
  single = {
    results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
    prompt =  { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
  },
  rounded = {
    results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
    prompt  = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  },
  none = {
    results = { " ", " ", " ", " ", " ", " ", " ", " " },
    prompt  = { " ", " ", " ", " ", " ", " ", " ", " " },
    preview = { " ", " ", " ", " ", " ", " ", " ", " " }
  }
}

local border_layout_prompt_bottom = {
  single = {
    results = { "─", "│", "─", "│", "┌", "┐", "┤", "├" },
    prompt =  { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
  },
  rounded = {
    results = { "─", "│", "─", "│", "╭", "╮", "┤", "├" },
    prompt =  { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  },
  none = {
    results = { " ", " ", " ", " ", " ", " ", " ", " " },
    prompt  = { " ", " ", " ", " ", " ", " ", " ", " " },
    preview = { " ", " ", " ", " ", " ", " ", " ", " " }
  }
}

function Utils.Telescope_dropdown_theme(opts)
  local lopts = opts or {}
  local defaults = require("telescope.themes").get_dropdown({
    -- borderchars = Config.telescope_dropdown == 'bottom' and border_layout_bottom_vertical or border_layout_top_center,
    borderchars = Config.telescope_dropdown == "bottom" and border_layout_prompt_bottom[__Globals.perm_config.telescope_borders]
      or border_layout_prompt_top[__Globals.perm_config.telescope_borders],
    layout_config = {
      anchor = "N",
      width = lopts.width or 0.5,
      height = lopts.height or 0.5,
      prompt_position = Config.telescope_dropdown,
    },
    -- layout_strategy=Config.telescope_dropdown == 'bottom' and 'vertical' or 'center',
    previewer = false,
    winblend = vim.g.float_winblend,
  })
  if lopts.cwd ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ": " .. lopts.cwd
  end
  if lopts.path ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ": " .. lopts.path
  end
  return vim.tbl_deep_extend("force", defaults, lopts)
end

local border_layout_vertical_dropdown = {
  single = {
    results = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
    prompt =  { "─", "│", "─", "│", "├", "┤", "┘", "└" },
    preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
  },
  rounded = {
    results = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
    prompt =  { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
    preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  },
  none = {
    results = { " ", " ", " ", " ", " ", " ", " ", " " },
    prompt  = { " ", " ", " ", " ", " ", " ", " ", " " },
    preview = { " ", " ", " ", " ", " ", " ", " ", " " }
  }
}

--- a dropdown theme with vertical layout strategy
--- @param opts table of valid telescope options
function Utils.Telescope_vertical_dropdown_theme(opts)
  local lopts = opts or {}
  local defaults = require("telescope.themes").get_dropdown({
    borderchars = border_layout_vertical_dropdown[__Globals.perm_config.telescope_borders],
    fname_width = Config["telescope_fname_width"],
    sorting_strategy = "ascending",
    layout_strategy = "vertical",
    path_display = { shorten = 10 },
    symbol_width = Config.minipicker_symbolwidth,
    layout_config = {
      width = lopts.width or 0.8,
      height = lopts.height or 0.9,
      preview_height = lopts.preview_width or 0.4,
      prompt_position = "bottom",
      scroll_speed = 2,
    },
    winblend = vim.g.float_winblend,
  })
  if lopts.search_dirs ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ": " .. lopts.search_dirs[1]
  end
  if lopts.cwd ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ": " .. lopts.cwd
  end
  if lopts.path ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ": " .. lopts.path
  end
  return vim.tbl_deep_extend("force", defaults, lopts)
end

-- custom theme for the command_center Telescope plugin
-- reason: I have square borders everywhere
function Utils.command_center_theme(opts)
  local lopts = opts or {}
  local defaults = require("telescope.themes").get_dropdown({

    borderchars = border_layout_prompt_top[__Globals.perm_config.telescope_borders],
    layout_config = {
      anchor = "N",
      width = lopts.width or 100,
      height = lopts.height or 0.4,
      prompt_position = Config.cpalette_dropdown,
    },
    -- layout_strategy=Config.telescope_dropdown == 'bottom' and 'vertical' or 'center',
    previewer = false,
    winblend = vim.g.float_winblend,
  })
  if lopts.cwd ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ": " .. lopts.cwd
  end
  if lopts.path ~= nil then
    lopts.prompt_title = lopts.prompt_title .. ": " .. lopts.path
  end
  return vim.tbl_deep_extend("force", defaults, lopts)
end

--- truncate the path and display the rightmost maxlen characters
--- @param path string: A filepath
--- @param maxlen integer: the desired length
--- @return string: the truncated path
function Utils.path_truncate(path, maxlen)
  local len = string.len(path)
  if len <= maxlen then
    return path
  end
  local effective_width = maxlen - 3 -- make space for leading ...
  return "..." .. string.sub(path, len - effective_width, len)
end

--- truncate a string to a maximum length, appending ellipses when necessary
--- @param text string:       the string to truncate
--- @param max_length integer: the maximum length. must be at least 4 because of ellipsis
--- @return string:           the truncated text
function Utils.truncate(text, max_length)
  if max_length > 1 and vim.fn.strwidth(text) > max_length then
    return vim.fn.strcharpart(text, 0, max_length - 1) .. "…"
  else
    return text
  end
end

return Utils
