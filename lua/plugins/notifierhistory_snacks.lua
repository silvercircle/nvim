-- implements a simple snacks picker for the notification history kept
-- by the snacks.notifier plugin

-- written by as@subspace.cc in 2025, part of my Neovim configuation at
-- https://gitlab.com/silvercircle74/nvim
--
-- LICENSE: MIT

local M = {}

local conf = {
  dateformat = {
    short     = "%a, %d.%b.%Y : %H:%M:%S",
    long      = "%a, %d.%B %Y - %H:%M:%S",
    timestamp = "%H:%M:%S"
  },
  snacks_layout   = {
    preset = "vertical",
    preview = false,
    layout = {
      backdrop = false,
      border = "single",
      box = "vertical",
      width = 120,
      height = 0.4,
      { win = "list",  border = "none" },
      { win = "input", height = 1, border = "top" },
    },
  },
  snacks_picker_cols= {
    timestamp = { hl = "Operator", width = 30 },
    group =     { hl = "Type", width = 15 },
    title =     { hl = "String", width = 12 },
    message =   { hl = "String", width = 30 },
  }
}

local level_to_hl = {
  error = "DiagnosticError",
  debug = "Debug",
  warn = "DiagnosticWarn",
  info = "DiagnosticInfo",
  trace = "DiagnosticHint"
}

local show_history = function(layout)
  local Snacks = require("snacks")
  local Utils = require("subspace.lib")
  local cols = conf.snacks_picker_cols
  local align = Snacks.picker.util.align

  local notifs = Snacks.notifier.get_history()
  layout.layout.title = "Notification history (snacks notifier)"
  local message_width = layout.layout.width - cols.timestamp.width - cols.group.width - 5
  return Snacks.picker({
    finder = function()
      for _, item in ipairs(notifs) do
        if type(item.id) == "number" then item.id = tostring(item.id) end
        item.text = item.id .. " " .. item.msg .. " " .. item.title
      end
      return notifs
    end,
    focus = "input",
    auto_close = false,
    layout = layout,
    win = {
      preview = {
        wo = { conceallevel = 2 }
      }
    },
    format = function(item, _)
      local entry = {}
      local pos = #entry
      entry[pos + 1] = { align(vim.fn.strftime(conf.dateformat.short,
        math.floor(item.added)), cols.timestamp.width), cols.timestamp.hl }
      entry[pos + 2] = { align(Utils.truncate(item.title, cols.group.width - 1),
                         cols.group.width ), cols.group.hl}
      entry[pos + 3] = { align(item.icon or " ", 3), level_to_hl[item.level] or "Fg" }
      entry[pos + 4] = { align(Utils.truncate(item.msg, message_width - 1), message_width, { align = "right" }),
        level_to_hl[item.level] or "Fg" }

      return entry
    end,
    preview = function(ctx)
      ctx.item.preview = {
        text = ctx.item.msg,
        ft = "markdown"
      }
      Snacks.picker.preview.preview(ctx)
    end,
    sort = {
      fields = { 'added:desc'  }
    },
    matcher = {
      sort_empty = true
    },
    confirm = function(_, item)
      vim.notify(item.msg, vim.log.levels[string.upper(item.level)], { title = item.title or ""})
    end,
  })
end

function M.open(opts)
  opts = opts or {}
  local layout = opts.layout or conf.snacks_layout
  show_history(layout)
end

function M.setup(opts)
  local o = opts or {}
  conf = vim.tbl_deep_extend("force", conf, o)
end

return M
