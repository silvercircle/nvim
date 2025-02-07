local has_snacks, Snacks = pcall(require, "snacks")

if not has_snacks then
   error "This plugins requires the Snacks plugin"
end
local config = require("bookmarks.config").config
local Align = Snacks.picker.util.align

local M = {}
local function get_text(annotation)
   local pref = string.sub(annotation, 1, 2)
   local ret = config.keywords[pref]
   if ret == nil then
      ret = config.signs.ann.text .. " "
   end
   return ret .. annotation
end

local keys = { ['<CR>'] = { { 'jump', 'close' }, mode = {'n', 'i'}} }

function M.open(opts)
  local lutils = require("local_utils")
  opts = opts or {}
  local allmarks = config.cache.data
  local marklist = {}
  for k, ma in pairs(allmarks) do
    for l, v in pairs(ma) do
      vim.notify("filename is " .. k)
      table.insert(marklist, {
        file = k,
        pos = { tonumber(l), 1 },
        annot = v.a and get_text(v.a) or v.m,
        text = (v.a and get_text(v.a) or v.m) .. k
      })
    end
  end
  return Snacks.picker({
    finder = function()
      return marklist
    end,
    focus = "input",
    matcher = { sort_empty = true },
    layout = opts.layout or { preset = "select", preview = true, layout = { width = 120, height = 0.7 } },
    win = {
      input = { keys = keys },
      list = { keys = keys }
    },
    format = function(item)
      local entry = {}

      local pos = #entry
      entry[pos + 1] = { Align(tostring(item.pos[1]), 6, { align = "left" }), "Number" }
      entry[pos + 2] = { Align(lutils.trim(item.annot), 40, { align = "left" }), "Fg" }
      entry[pos + 3] = { "│", "Comment" }
      entry[pos + 4] = { Align(item.file, 60, { align = "right" }), "String" }

      return entry
    end,
    confirm = function(picker, item)
      picker:close()
    end,
  })
end
return M
