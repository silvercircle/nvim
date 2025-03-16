-- implements a simple telescope picker for the notification history kept
-- by the fidget plugin
-- based on the Telescope extension in the nvim-notify plugin by rcarriga
-- https://github.com/rcarriga/nvim-notify
--
-- written by Alex Vie in 2024, part of my Neovim configuation at
-- https://gitlab.com/silvercircle74/nvim
--
-- this requires nui libary and (obviously) the telescope plugin
-- https://github.com/MunifTanjim/nui.nvim

local notify = require("fidget.notification")

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
    title =     { hl = "String", width = 30 },
    message =   { hl = "String", width = 30 },
  }
}

local snacks_fidgethistory = function(layout)
  local Snacks = require("snacks")
  local utils = require("subspace.lib")
  local cols = conf.snacks_picker_cols
  local align = Snacks.picker.util.align

  local notifs = notify.get_history()
  --local reversed = {}
  --for i, notif in ipairs(notifs) do
  --  reversed[#notifs - i + 1] = notif
  --end
  layout.layout.title = "Fidget notification history"
  local message_width = layout.layout.width - cols.timestamp.width - cols.group.width - cols.title.width - 5
  return Snacks.picker({
    finder = function()
      for _, item in ipairs(notifs) do
        item.text = (item.annote or "") .. item.group_name .. " " .. item.message
      end
      return notifs
    end,
    win = {
      preview = {
        wo = { wrap = true, signcolumn = "no", number = false, statuscolumn = "" }
      }
    },
    focus = "input",
    auto_close = false,
    layout = layout,
    format = function(item, _)
      local entry = {}
      local pos = #entry

      entry[pos + 1] = { align(vim.fn.strftime(conf.dateformat.short, item.last_updated), cols.timestamp.width), cols.timestamp.hl }
      entry[pos + 2] = { align(utils.truncate(item.group_name, cols.group.width - 1),
                         cols.group.width ), cols.group.hl}
      entry[pos + 3] = { align(item.group_icon or " ", 3), item.style or "DeepRedBold" }
      entry[pos + 4] = { align(utils.truncate(item.annote and (" (" .. item.annote .. ")") or " (No Information)",
                         cols.title.width - 1), cols.title.width), cols.title.hl }
      entry[pos + 5] = { align(utils.truncate(item.message or item.content_key, message_width - 1), message_width, { align = "right" }), item.style or "DeepRedBold" }

      return entry
    end,
    sort = {
      fields = { 'last_updated:desc'  }
    },
    matcher = {
      sort_empty = true
    },
    preview = function(ctx)
      ctx.item.preview = {
        text = ctx.item.message,
        ft = "markdown"
      }
      Snacks.picker.preview.preview(ctx)
    end,
    confirm = function(_, item)
      vim.notify(item.msg, vim.log.levels.INFO, { title = item.title or ""})
    end,
  })
end

function M.open(opts)
  opts = opts or {}
  local layout = opts.layout or conf.snacks_layout
  snacks_fidgethistory(layout)
end

function M.setup(opts)
  local o = opts or {}
  conf = vim.tbl_deep_extend("force", conf, o)
end

return M
