
local M = {}
local conf = {
  columns = {
    desc = {width = 43, hl = "String"},
    cat  = {width = 18, hl = "Class", align = "right"},
    cmd  = {width = 14, hl = "DefaultLib", "right"},
    keys = {width = 43, hl = "Operator"},
    err  = {width = 0, hl = "DeepRedBold"}
  }
}

M.pickeritems = {}

--- truncate a string to a maximum length, appending ellipses when necessary
--- @param text string:       the string to truncate
--- @param max_length integer:  the maximum length. must be at least 2
---                             (one character + ellipis)
--- @return string:           the truncated text
local function truncate(text, max_length)
  if max_length > 1 and vim.fn.strwidth(text) > max_length then
    return vim.fn.strcharpart(text, 0, max_length - 1) .. "…"
  else
    return text
  end
end

---this adds a list of command definitions to the picker source
---desc and cmd are mandatory
---commands can have any number of keybinds or none at all.
---@param entries table of commands to add
function M.add(entries)
  vim.iter(entries):map(function(l)
    local pos = #M.pickeritems
    if l.cmd == nil or l.desc == nil then return end
    M.pickeritems[pos + 1] = {
      cat = l.category or '',
      cmd = l.cmd,
      desc = l.desc,
      text = (l.category or '') .. " " .. l.desc .. (type(l.cmd) == "string" and l.cmd or ""),
      keys = l.keys or nil
    }
    if l.keys ~= nil then
      if type(l.keys[1]) == "string" then
        vim.g.setkey(l.keys[1], l.keys[2], l.cmd, l.desc)
      elseif type(l.keys[1]) == "table" then
        vim.iter(l.keys):map(function(w)
          -- print(vim.inspect(w))
          vim.g.setkey(w[1], w[2], l.cmd, l.desc)
        end)
      end
    end
  end)
end

function M.open()
  if #M.pickeritems == 0 then
    vim.notify("There are no commands to show.")
    return
  end

  local Snacks = require("snacks")
  local Align = Snacks.picker.util.align

  local oldmode = vim.fn.mode()
  return Snacks.picker({
    finder = function()
      return M.pickeritems
    end,
    focus = "input",
    -- TODO: move to setup
    layout = __Globals.gen_snacks_picker_layout( { width=120, height=25, row=5, input="bottom", prompt="Command Palette", preview=false } ),
    sort = {
      fields = {
        'cat',
        'desc'
      }
    },
    matcher = {
      match_empty = true
    },
    format = function(item)
      local e = {}
      local c = conf.columns
      local keys = ""
      local key_align
      local key_hl

      if item.keys == nil then
        keys = "<No keys defined>"
        key_align = "center"
        key_hl = c.err.hl
      else
        if type(item.keys[1]) == "string" then
          keys = item.keys[1] .. '|' .. item.keys[2]
        elseif type(item.keys[1]) == "table" then
          vim.iter(item.keys):map(function(k)
            keys = keys .. (k[1] .. '|' .. k[2] .. ' ')
          end)
        else
          keys = "Unknown"
        end
        key_align = "left"
        key_hl = c.keys.hl
      end
      e[#e + 1] = { Align(truncate(item.desc, c.desc.width), c.desc.width, {align = c.desc.align or "left"}), c.desc.hl }
      e[#e + 1] = { Align(truncate(keys, c.keys.width), c.keys.width, {align = key_align}), key_hl }
      e[#e + 1] = { Align(type(item.cmd) == "function" and "LUA Function" or item.cmd, c.cmd.width, {align = c.cmd.align or "left"}), c.cmd.hl }
      e[#e + 1] = { Align(item.cat, c.cat.width, {align=c.cat.align or "left"}), c.cat.hl }
      return e
    end,
    confirm = function(picker, item)
      picker:close()
      if type(item.cmd) == "function" then
        vim.schedule(function() item.cmd() end)
      elseif type(item.cmd) == "string" then
        vim.schedule(function() vim.cmd(item.cmd) end)
      end
      if oldmode == 'i' then vim.schedule(function() vim.cmd.startinsert() end) end
    end
  })
end

function M.setup(opts)
  opts = opts or {}
  if opts.keys ~= nil then
    M.add(opts.keys)
    opts.keys = nil
  end
  conf = vim.tbl_deep_extend("force", conf, opts)
end
return M
