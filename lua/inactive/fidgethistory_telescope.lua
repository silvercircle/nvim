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
-- TODO: make a fzf-lua version

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local entry_display = require("telescope.pickers.entry_display")
local notify = require("fidget.notification")

local M = {}

local config = {
  dateformat = {
    short     = "%a, %d.%b.%Y : %H:%M:%S",
    long      = "%a, %d.%B %Y - %H:%M:%S",
    timestamp = "%H:%M:%S"
  },
  hl = {
    preview_header  = "Normal",
    timestamp       = "Number",
    title           = "String"
  },
  fieldsize = {
    time    = 28,
    icon    = 2,
    title   = nil,
    message = nil,
  },
  telescope = {
    theme = require("telescope.themes").get_dropdown,
    layout_config = {}
  }
}

local displayer = entry_display.create({
  separator = " ",
  items = {
    { width = config.fieldsize.time },
    { width = config.fieldsize.icon },
    { width = config.fieldsize.title },
    { width = config.fieldsize.message },
  },
})

local telescope_fidgethistory = function(opts)
  local notifs = notify.get_history()
  local reversed = {}
  for i, notif in ipairs(notifs) do
    reversed[#notifs - i + 1] = notif
  end
  pickers.new(opts, {
    results_title = "Fidget notification history",
    prompt_title = "Filter notifications",
    finder = finders.new_table({
      results = reversed,
      entry_maker = function(notif)
        if notif.annote == nil then
          notif.annote = "NONE"
        end
        return {
          value = notif,
          display = function(entry)
            --print(vim.inspect(entry))
            return displayer({
              { vim.fn.strftime(config.dateformat.short, entry.value.last_updated), config.hl.timestamp },
              { entry.value.group_icon,                                             entry.value.style },
              { entry.value.group_name .. " (" .. entry.value.annote .. ")",        config.hl.title },
              { entry.value.message,                                                entry.value.style },
            })
          end,
          ordinal = notif.last_updated .. " " .. notif.annote .. " " .. notif.content_key
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(_, _)  -- params: prompt_bufnr, map
      -- generate a preview of the message, using a nui popup window.
      -- Requires nui: https://github.com/MunifTanjim/nui.nvim
      -- do nothing if this plugin is not available.
      actions.select_default:replace(function()
        local event = require("nui.utils.autocmd").event
        local status, popup = pcall(require, "nui.popup")

        if status == true then
          local lines = {}
          local selection = action_state.get_selected_entry()
          local notification = selection.value
          local p = popup({
            position = {
              col = "50%",
              row = "50%"
            },
            relative = "editor",
            enter = true,
            focusable = true,
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

          for s in notification.message:gmatch("[^\r\n]+") do
            table.insert(lines, s)
          end

          vim.api.nvim_buf_clear_namespace(p.bufnr, -1, 0, -1)
          vim.api.nvim_buf_set_lines(p.bufnr, 0, 1, false, lines)
          for i = 0, #lines, 1 do
            vim.api.nvim_buf_add_highlight(p.bufnr, -1, notification.style, i, 0, -1)
          end
        end
      end)
      return true
    end,
    previewer = previewers.new_buffer_previewer({
      title = "Message details",
      define_preview = function(self, entry, status)
        -- render preview
        local lines = {}
        local notification = entry.value
        local bufnr = self.state.bufnr
        local headersize = 3
        vim.api.nvim_set_option_value("wrap", true, { win = status.preview_win })
        vim.api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)
        table.insert(lines, "Source:    " .. notification.group_name)
        table.insert(lines, "Title:     " .. notification.annote)
        table.insert(lines, "Timestamp: " .. vim.fn.strftime(config.dateformat.long, notification.last_updated))
        table.insert(lines, " ")
        -- message may contain newlines, so split them into lines
        for s in notification.message:gmatch("[^\r\n]+") do
          table.insert(lines, s)
        end
        -- table.insert(lines, notification.message)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        for i = 0, headersize - 1, 1 do
          vim.api.nvim_buf_add_highlight(bufnr, -1, config.hl.preview_header, i, 0, -1)
        end
        for i = headersize + 1, #lines, 1 do
          vim.api.nvim_buf_add_highlight(bufnr, -1, notification.style, i, 0, -1)
        end
      end,
    }),
  }):find()
end

function M.open()
  telescope_fidgethistory(config.telescope.theme({
    prompt_title = "Filter notifications",
    results_title = "Fidget notifications history",
    layout_config = config.telescope.layout_config
  }))
end

function M.setup(opts)
  local o = opts or {}
  config = vim.tbl_deep_extend("force", config, o)
end

return M
