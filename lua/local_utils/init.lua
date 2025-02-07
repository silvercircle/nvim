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

function Utils.getLongestString(items, labelname)
  local maxlength = 0

  for _, v in ipairs(items) do
    if vim.fn.strwidth(v[labelname]) > maxlength then
      maxlength = vim.fn.strwidth(v[labelname])
    end
  end
  return maxlength
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
  if vim.bo.filetype == "typst" then
    finalpath = vim.fn.expand("%:p:r") .. ".pdf"
  else
    __Globals.debugmsg("The preview path is: " .. path)
    if useglobal == true and #path > 0 and vim.fn.isdirectory(path) == 1 then
      finalpath = path .. vim.fn.expand(vim.fn.fnamemodify(_filename, ":t:r")) .. ".pdf"
    else
      finalpath = vim.fn.expand(vim.fn.fnamemodify(_filename, ":r")) .. ".pdf"
    end
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
  local Snacks = require("snacks")
  local Align = Snacks.picker.util.align
  local entries = {}
  local clients = vim.lsp.get_active_clients()

  for _, client in ipairs(clients) do
    local attached = client["attached_buffers"]
    local count = 0
    for _ in pairs(attached) do count = count + 1 end
    local entry = {
      id      = client["id"],
      name    = client["name"],
      buffers = count,
      type = (type(client["config"]["cmd"]) == "table" and (vim.fn.fnamemodify(client["config"]["cmd"][1], ":t")) or client["name"]),
      text = client['name']
    }
    table.insert(entries, entry)
  end

  --- terminate the client given by id
  --- @param id number client id
  --- @oaram nrbufs number the number of attached buffers
  local function do_terminate(id, picker)
    if id ~= nil and id > 0 then
      if #vim.lsp.get_buffers_by_client_id(id) > 0 then
        vim.notify("The LSP server with id " .. id .. " has attached buffers and cannot be terminated.")
      else
        vim.lsp.stop_client(id, true)
        entries = vim.iter(entries):filter(function(k, _)
          if k.id == id then return nil else return k end
        end):totable()
        picker:find()
        collectgarbage("collect")
      end
    end
  end

  return Snacks.picker({
    finder = function()
      return entries
    end,
    sort = { fields = {"id:desc"} },
    matcher = { sort_empty = true },
    layout = __Globals.gen_snacks_picker_layout( { width=90, height=20, row=10, input="bottom",
                                                   title="Active LSP clients, <C-d> or <Enter> to terminate, ESC cancels" } ),
    format = function(item)
      local entry = {}
      local pos = #entry
      local hl = item.buffers > 0 and "DeepRedBold" or "Number"

      entry[pos + 1] = { Align(tostring(item.id), 6, { align="right" }), hl }
      entry[pos + 2] = { Align(item.name, 15, { align="center" }), hl }
      entry[pos + 3] = { Align(tostring(item.buffers) .. " Buffers", 20, { align="right" }), hl }
      entry[pos + 4] = { Align(item.type, 40, { align="right" }), hl }

      return entry
    end,
    win = {
      list = {
        keys = {
          ['<C-d>'] = { 'del_entry', mode = { 'i', 'n' }}
        }
      },
      input = {
        keys = {
          ['<C-d>'] = { 'del_entry', mode = { 'i', 'n' }}
        }
      }
    },
    confirm = function(picker, item)
      do_terminate(picker:current().id, picker)
    end,
    actions = {
      del_entry = function(picker)
        local id = picker:current().id
        do_terminate(id, picker)
      end
    }
  })
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
    local items = {
      { cmd = "save", text = "Save and Close", hl = "Number" },
      { cmd = "discard", text = "Close and discard", hl = "DeepRedBold" },
      { cmd = "cancel", text = "Cancel operation", hl = "Keyword" },
    }
    local maxlength = Utils.getLongestString(items, "text")

    if vim.g.confirm_actions["close_buffer"] == true then
      local Snacks = require("snacks")
      local Align = Snacks.picker.util.align
      return Snacks.picker({
        finder = function()
          return items
        end,
        focus = "list",
        layout = __Globals.gen_snacks_picker_layout( { input = "off", height = 3, width = maxlength + 8, title = "File modified" } ),
        format = function(item)
          local entry = {}
          entry[#entry + 1] = { Align(item.text, maxlength + 6, { align="center" }), item.hl }
          return entry
        end,
        confirm = function(picker, item)
          picker:close()
          if item.cmd == "cancel" then
            return
          elseif item.cmd == "save" then
            vim.cmd(saveclosecmd)
            return
          elseif item.cmd == "discard" then
            vim.cmd(closecmd)
            return
          else
            return
          end
        end
      })
    else
      vim.cmd(closecmd)
    end
  else
    vim.cmd(closecmd)
  end
end

local fdm = {
  { pos = 2, text = "Indent", val = "indent" },
  { pos = 3, text = "Expression", val = "expr" },
  { pos = 4, text = "Syntax", val = "syntax" },
  { pos = 5, text = "Marker", val = "marker" },
  { pos = 6, text = "Diff",  val = "diff" },
  { pos = 7, text = "Manual", val = "manual" },
}

local fdm_maxlength = Utils.getLongestString(fdm, "text")

function Utils.PickFoldingMode(currentmode)
  local Snacks = require("snacks")
  local Align = Snacks.picker.util.align

  if currentmode == nil or currentmode == "" then
    return
  end

  return Snacks.picker({
    layout = __Globals.gen_snacks_picker_layout({ height = #fdm, width = fdm_maxlength + 6,
                                                  title = "Select Folding", input = "off" }),
    focus = "list",
    finder = function()
      return fdm
    end,
    sort = {
      fields = { "pos:desc" }
    },
    matcher = { sort_empty = true },
    format = function(item, _)
      local entry = {}

      entry[#entry + 1] = { Align(item.text, fdm_maxlength + 4, { align="center" }), "Fg" }
      return entry
    end,
    confirm = function(picker, item)
      if item.val ~= "none" then
        picker:close()
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
    end
  })
end

function Utils.Quitapp()
  local bufs = vim.api.nvim_list_bufs()
  local have_modified_buf = false
  local menuitems = {}
  local prompt = ""
  local Snacks = require("snacks")
  local Align = Snacks.picker.util.align

  for _, bufnr in ipairs(bufs) do
    have_modified_buf = vim.api.nvim_buf_get_option(bufnr, "modified") == true and true or have_modified_buf
  end

  if have_modified_buf == false then
    menuitems = {
      { cmd = "hardexit", text = "Really exit?", hl = "DeepRedBold" },
      { cmd = "cancel", text = "Cancel operation", hl = "Keyword" }
    }
    prompt = "Exit (no modified buffers)"
  else
    prompt = "Exit (all unsaved changes are lost)"
    menuitems = {
      { cmd = "save", text = "Save all modified buffers and exit", hl = "Number" },
      { cmd = "discard", text = "Discard all modified buffers and exit", hl = "DeepRedBold" },
      { cmd = "cancel", text = "Cancel operation", hl = "Keyword" }
    }
  end

  local maxlength = Utils.getLongestString(menuitems, "text")
  maxlength = #prompt > maxlength and #prompt or maxlength

  return Snacks.picker({
    finder = function()
      return menuitems
    end,
    focus = "list",
    layout = __Globals.gen_snacks_picker_layout( {input = "off", width = maxlength + 6, height = #menuitems, title = prompt } ),
    format = function(item)
      local entry = {}
      entry[#entry + 1] = { Align(item.text, maxlength + 4, { align="center" }), item.hl }
      return entry
    end,
    confirm = function(picker, item)
      picker:close()
      if item.cmd == "hardexit" or item.cmd == "discard" then
        vim.cmd("qa!")
      elseif item.cmd == "cancel" then
        return
      elseif item.cmd == "save" then
        vim.cmd("wa!")
        vim.cmd("qa!")
      end
    end
  })
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
  thicc = {
    results = { "━", "┃", "━", "┃", "┣", "┫", "┛", "┗" },
    prompt =  { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" },
    preview = { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" }
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
  thicc = {
    results = { "━", "┃", "━", "┃", "┏", "┓", "┫", "┣" },
    prompt =  { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" },
    preview = { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" }
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
  thicc = {
    results = { "━", "┃", " ", "┃", "┏", "┓", "┃", "┃" },
    prompt =  { "━", "┃", "━", "┃", "┣", "┫", "┛", "┗" },
    preview = { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" }
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
      width = lopts.width or 120,
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

--- show notification history, depending on which plugin we use for notifications
function Utils.notification_history()
  if vim.g.tweaks.notifier == "mini" then
    require("detour").DetourCurrentWindow()
    require("mini.notify").show_history()
  elseif vim.g.tweaks.notifier == "fidget" then
    require("plugins.fidgethistory_snacks").open( {
            layout = __Globals.gen_snacks_picker_layout( { preview = true, width=120, height = 40, input = "top", psize = 20, row = 8 } ) } )
  elseif vim.g.tweaks.notifier == "nvim-notify" then
    require("telescope").extensions.notify.notify(__Telescope_vertical_dropdown_theme({
        width_text = 40,
        width_annotation = 50,
        prompt_title = "Notifications",
        layout_config = Config.telescope_vertical_preview_layout
      }))
  end
end

-- helper function for cmp <TAB> mapping.
Utils.has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- send the tab key via feedkeys()
Utils.send_tab_key = function()
  local tab_key = vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
  vim.api.nvim_feedkeys(tab_key, "n", true)
end

--- when visual mode is active, return current selection
function Utils.get_selection()
  if vim.fn.mode() ~= 'v' then
    return ""
  end

  local result = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { mode = vim.fn.mode() } )
  if result[1] ~= nil and #result[1] > 0 then
    return result[1]
  else
    return ""
  end
end

return Utils
