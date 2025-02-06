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
-- TODO: make a fzf-lua version. OR a snacks.picker version

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
  local utils = require("local_utils")
  local cols = conf.snacks_picker_cols

  local notifs = notify.get_history()
  --local reversed = {}
  --for i, notif in ipairs(notifs) do
  --  reversed[#notifs - i + 1] = notif
  --end

  local message_width = layout.layout.width - cols.timestamp.width - cols.group.width - cols.title.width - 5
  return Snacks.picker({
    results_title = "Fidget notification history",
    prompt_title = "Filter notifications",
    finder = function()
      for _, item in ipairs(notifs) do
        item.text = (item.annotate or "") .. item.group_name .. " " .. item.message
      end
      return notifs
    end,
    focus = "input",
    auto_close = false,
    layout = layout,
    format = function(item, _)
      local entry = {}
      local align = Snacks.picker.util.align
      local pos = #entry

      entry[pos + 1] = { align(vim.fn.strftime(conf.dateformat.short, item.last_updated), cols.timestamp.width), cols.timestamp.hl }
      entry[pos + 2] = { align(utils.truncate(item.group_name, cols.group.width - 1),
                         cols.group.width ), cols.group.hl}
      entry[pos + 3] = { align(item.group_icon or " ", 3), item.style or "DeepRedBold" }
      entry[pos + 4] = { align(utils.truncate(item.annote and (" (" .. item.annote .. ")") or "No source",
                         cols.title.width - 1), cols.title.width), cols.title.hl }
      entry[pos + 5] = { align(item.content_key or item.message, message_width, { align = "right" }), item.style or "DeepRedBold" }

      return entry
    end,
    sort = {
      fields = {
        'last_updated:desc'
      }
    },
    filter = {

    },
    confirm = function(picker, item)
      -- picker:close()
      print(vim.inspect(item))
      local event = require("nui.utils.autocmd").event
      local status, popup = pcall(require, "nui.popup")
      if status == true then
        local lines = {}
        local p = popup({
          position = {
            col = "50%",
            row = "50%"
          },
          relative = "editor",
          enter = true,
          focusable = true,
          zindex = 1000,
          border = {
            style = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
            padding = { 1, 1 },
            text = {
              top = " Message text:",
              top_align = "left"
            }
          },
          size = {
            width = 100,
            height = 10,
          },
        })
        p:mount()
        p:on(event.BufLeave, function() p:unmount() end)

        for s in item.message:gmatch("[^\r\n]+") do
          table.insert(lines, s)
        end

        vim.api.nvim_buf_clear_namespace(p.bufnr, -1, 0, -1)
        vim.api.nvim_buf_set_lines(p.bufnr, 0, 1, false, lines)
        for i = 0, #lines, 1 do
          vim.api.nvim_buf_add_highlight(p.bufnr, -1, item.style, i, 0, -1)
        end
      end
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
