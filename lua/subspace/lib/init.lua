-- local utils
-- can be used without calling setup(), but you can use it to set some (few) options.

local Utils = {}

local conf = {
  root_patterns = Tweaks.default_root_patterns,
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
  conf.root_patterns = opts.root_patterns or Tweaks.default_root_patterns
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
  return vim.api.nvim_get_mode().mode == "i" and CFG.minipicker_iprefix or "> "
end

--- this function determines the path where a latex-generated PDF may reside. It depends on the
--- setting of config.texoutput. If this is set and _useglobal is true, then the global output
--- path will be used. Otherwise, the .pdf is expected in the same directory as the .tex file
--- @param _filename string: the filename to analyze
--- @param _useglobal boolean: use the global texoutput directory
function Utils.getLatexPreviewPath(_filename, _useglobal)
  local useglobal = _useglobal or false
  local path = vim.fn.expand(CFG.texoutput)
  local finalpath
  if vim.bo.filetype == "typst" then
    finalpath = vim.fn.expand("%:p:r") .. ".pdf"
  else
    CGLOBALS.debugmsg("The preview path is: " .. path)
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
      local cmd = "silent !" .. Tweaks.texviewer .. " '" .. path .. "' &"
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
      .. vim.fn.expand(CFG.texoutput)
      .. " '"
      .. vim.fn.expand("%:p")
      .. "'"
    CGLOBALS.debugmsg(cmd)
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
  local lsputil = require("lsp.utils")
  -- try git root first
  local path = nil
  if conf.ignore_git == false then
    path = lsputil.find_git_ancestor(fname)
  end
  if path == nil then
    if conf.ignore_git == false then
      Utils.debug("No git root found for " .. fname .. " trying root patterns")
    end
    -- path = lsputil.root_pattern(conf.root_patterns)(fname)
    path = vim.fs.root(fname, conf.root_patterns)
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
function Utils.StopLsp(auto)
  auto = auto or false
  local Snacks = require("snacks")
  local Align = Snacks.picker.util.align
  local entries = {}
  local clients = vim.lsp.get_clients()

  for _, client in ipairs(clients) do
    local attached = client["attached_buffers"]
    local count = 0
    for _ in pairs(attached) do count = count + 1 end
    if auto and count == 0 then
      vim.notify(string.format("Auto shutdown for LSP: %d:%s", client["id"], client["name"]))
      vim.lsp.stop_client(client["id"], true)
    end
    if not auto then
      local entry = {
        id      = client["id"],
        name    = client["name"],
        buffers = count,
        type    = (type(client["config"]["cmd"]) == "table" and (vim.fn.fnamemodify(client["config"]["cmd"][1], ":t")) or client["name"]),
        text    = client["name"]
      }
      table.insert(entries, entry)
    end
  end
  if auto then return end
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
    layout = SPL( { width=100, height=20, row=10, input="bottom",
                                                   title="Active LSP clients, <C-d> or <Enter> to terminate, ESC cancels" } ),
    format = function(item)
      local entry = {}
      local pos = #entry
      local hl = item.buffers > 0 and "Red" or "Green"

      entry[pos + 1] = { Align("ID:" .. tostring(item.id), 6, { align="right" }), "Fg" }
      entry[pos + 2] = { Align(" " .. item.name, 25, { align="left" }), "Fg" }
      entry[pos + 3] = { Align(string.format("%3d", item.buffers) .. (item.buffers == 1 and " Buffer " or " Buffers"), 20, { align="right" }), hl }
      entry[pos + 4] = { Align(item.type, 45, { align="right" }), "String" }

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
    confirm = function(picker, _)
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

  local function execute(item)
    local cmd = item.cmd or ""
    if cmd == "cancel" then
      return
    elseif cmd == "save" then
      vim.cmd(saveclosecmd)
      return
    elseif cmd == "discard" then
      vim.cmd(closecmd)
      return
    else
      return
    end
  end

  if vim.api.nvim_buf_get_option(0, "modified") == true then
    local items = {
      { p = 1, cmd = "save", text = "Save and Close", hl = "Number" },
      { p = 1, cmd = "discard", text = "Close and discard", hl = "DeepRedBold" },
      { p = 1, cmd = "cancel", text = "Cancel operation", hl = "BlueBold" },
    }

    if vim.g.confirm_actions["close_buffer"] == true then
      Utils.simplepicker(items, execute, { prompt = "Buffer is modified" })
    else
      vim.cmd(closecmd)
    end
  else
    vim.cmd(closecmd)
  end
end

local fdm = {
  { hl = "Fg", p = 2, text = "Indent", cmd = "indent" },
  { hl = "Fg", p = 3, text = "Expression", cmd = "expr" },
  { hl = "Fg", p = 4, text = "Syntax", cmd = "syntax" },
  { hl = "Fg", p = 5, text = "Marker", cmd = "marker" },
  { hl = "Fg", p = 6, text = "Diff",  cmd = "diff" },
  { hl = "Fg", p = 7, text = "Manual", cmd = "manual" },
}

function Utils.PickFoldingMode(currentmode)
  if currentmode == nil or currentmode == "" then
    return
  end

  fdm = vim.iter(fdm):map(function(k)
    -- if k.cmd == currentmode then k.p = 1000 k.hl = "Number" else k.p = 1 k.hl = "Fg" end
    if k.cmd == currentmode then k.current = true k.hl = "Number" else k.current = false k.hl = "Fg" end
    return k
  end):totable()

  local function execute(item)
    local cmd = item.cmd or ""
    if cmd ~= "none" then
      CGLOBALS.debugmsg("Selected folding method: " .. cmd)
      vim.schedule(function()
        vim.o.foldmethod = cmd
      end)
      if cmd == "expr" then
        vim.schedule(function()
          vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end)
      end
    end
  end
  Utils.simplepicker(fdm, execute,  { sortby = { "p:desc" }, prompt = "Pick a folding mode", pre = "current" })
end

function Utils.Quitapp()
  local bufs = vim.api.nvim_list_bufs()
  local have_modified_buf = false
  local menuitems = {}
  local prompt = ""

  for _, bufnr in ipairs(bufs) do
    if vim.api.nvim_buf_get_option(bufnr, "buflisted") then
      have_modified_buf = vim.api.nvim_buf_get_option(bufnr, "modified") == true and true or have_modified_buf
    end
  end

  if have_modified_buf == false then
    menuitems = {
      { cmd = "hardexit", text = "Really exit?", hl = "DeepRedBold", p = 1 },
      { cmd = "cancel", text = "Cancel operation", hl = "BlueBold", p = 1 }
    }
    prompt = "Exit (no modified buffers)"
  else
    prompt = "Exit (all unsaved changes are lost)"
    menuitems = {
      { cmd = "save", text = "Save all modified buffers and exit", hl = "Number", p = 1 },
      { cmd = "discard", text = "Discard all modified buffers and exit", hl = "DeepRedBold", p = 1 },
      { cmd = "cancel", text = "Cancel operation", hl = "Keyword", p = 1 }
    }
  end
  local function execute(item)
    local result = item.cmd or ""
    if result == "hardexit" or result == "discard" then
      vim.cmd("qa!")
    elseif result == "cancel" then
      return
    elseif result == "save" then
      vim.cmd("wa!")
      vim.cmd("qa!")
    end
  end
  Utils.simplepicker(menuitems, execute, { prompt = prompt, sortby = { 'p:desc' }})
end

--- truncate the path and display the rightmost maxlen characters
--- @param path string: A filepath
--- @param maxlen integer: the desired length
--- @return string: the truncated path
function Utils.path_truncate(path, maxlen)
  path = path or ""
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
  if Tweaks.notifier == "mini" then
    require("detour").DetourCurrentWindow()
    require("mini.notify").show_history()
  elseif Tweaks.notifier == "snacks" then
    require("subspace.content.notifierhistory").open( {
            layout = SPL( { preview = true, width=120, height = 40, input = "top", psize = 20, row = 8 } ) } )
  elseif Tweaks.notifier == "fidget" then
    require("subspace.content.fidgethistory").open( {
            layout = SPL( { preview = true, width=120, height = 40, input = "top", psize = 20, row = 8 } ) } )
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
--- @return string selection the selected text or empty string if nothing is selected
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

--- create a simple picker from the list of entries
--- @param entries table: the items
--- @param fn function: function to execute on confirm
--- @param opts table: the options
--- opts.sortby list sort by this field, may contain a :desc suffix
--- opts.pre    string use this item field to determine the current item
--- opts.prompt string: the prompt for the picker
---
function Utils.simplepicker(entries, fn, opts)
  opts = opts or {}
  local prompt = opts.prompt or ""
  local Snacks = require("snacks")
  local Align = Snacks.picker.util.align
  local maxlength = Utils.getLongestString(entries, "text")

  maxlength = vim.fn.strwidth(prompt) <= maxlength and maxlength or vim.fn.strwidth(prompt)

  local layout = SPL( { width = maxlength + 6, height = #entries, input = "off", title = prompt } )
  return Snacks.picker({
    finder = function()
      return entries
    end,
    sort = {
      fields = opts.sortby or {},
    },
    focus = "list",
    matcher = { sort_empty = true },
    format = function(item)
      local e = {}
      e[#e + 1] = { Align(item.text, maxlength + 4, { align="center"}), item.hl }
      return e
    end,
    confirm = function(picker, item)
      picker:close()
      fn(item)
    end,
    layout = layout,
    --- NOTE: how to preselect a picker item. if the field given in @param pre
    --- is found and true, this item will be preselected.
    on_show = function(picker)
      if opts.pre ~= nil then
        for i, item in ipairs(picker:items()) do
          if item[opts.pre] ~= nil and item[opts.pre] == true then
            picker.list:view(i)
            Snacks.picker.actions.list_scroll_center(picker)
          end
        end
      end
    end
  })
end

return Utils
