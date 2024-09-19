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
    short = "%d.%m.%Y : %H:%M",
    long = "%a, %d.%B %Y - %H:%M:%S",
    timestamp = "%H:%M:%S"
  },
  hl = {
    header = "Yellow"
  }
}

local widths = {
  time = 8,
  title = nil,
  icon = nil,
  level = nil,
  message = nil,
}

local displayer = entry_display.create({
  separator = " ",
  items = {
    { width = widths.time },
    { width = widths.title },
    { width = widths.icon },
    { width = widths.level },
    { width = widths.message },
  },
})

local telescope_fidgethistory = function(opts)
  local time_format = "%H:%M:%S"
  local notifs = notify.get_history()
  local reversed = {}
  for i, notif in ipairs(notifs) do
    reversed[#notifs - i + 1] = notif
  end
  pickers
    .new(opts, {
      results_title = "Notifications",
      prompt_title = "Filter Notifications",
      finder = finders.new_table({
        results = reversed,
        entry_maker = function(notif)
          return {
            value = notif,
            display = function(entry)
              --print(vim.inspect(entry))
              return displayer({
                { vim.fn.strftime(config.dateformat.timestamp, entry.value.last_updated), "NotifyLogTime" },
                { entry.value.annote, "NotifyLogTitle" },
                { entry.value.group_icon, "Notify" .. entry.value.style .. "Title" },
                { entry.value.style, "Notify" .. entry.value.style .. "Title" },
                { entry.value.content_key, "Notify" .. entry.value.style .. "Body" },
              })
            end,
            ordinal = notif.annote .. " " .. notif.last_updated .. " " .. notif.content_key
          }
        end,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection == nil then
            return
          end

          local notification = selection.value
          local opened_buffer = notify.open(notification)

          local lines = vim.opt.lines:get()
          local cols = vim.opt.columns:get()

          local win = vim.api.nvim_open_win(opened_buffer.buffer, true, {
            relative = "editor",
            row = (lines - opened_buffer.height) / 2,
            col = (cols - opened_buffer.width) / 2,
            height = opened_buffer.height,
            width = opened_buffer.width,
            border = "rounded",
            style = "minimal",
          })
          -- vim.wo does not behave like setlocal, thus we use setwinvar to set local
          -- only options. Otherwise our changes would affect subsequently opened
          -- windows.
          -- see e.g. neovim#14595
          vim.fn.setwinvar(
            win,
            "&winhl",
            "Normal:"
              .. opened_buffer.highlights.body
              .. ",FloatBorder:"
              .. opened_buffer.highlights.border
          )
          vim.fn.setwinvar(win, "&wrap", 0)
        end)
        return true
      end,
      previewer = previewers.new_buffer_previewer({
        title = "Message",
        define_preview = function(self, entry, status)
          local lines = {}
          local notification = entry.value
          local bufnr = self.state.bufnr
          local max_width = vim.api.nvim_win_get_config(status.preview_win).width
          vim.api.nvim_win_set_option(status.preview_win, "wrap", true)
          vim.api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)
          table.insert(lines, "Source:    " .. notification.group_name)
          table.insert(lines, "Title:     " .. notification.annote)
          table.insert(lines, "Timestamp: " .. vim.fn.strftime(config.dateformat.long, notification.last_updated))
          table.insert(lines, " ")
          table.insert(lines, notification.message)
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines )
          vim.api.nvim_buf_add_highlight(bufnr, -1, config.hl.header, 0, 0, -1)
          vim.api.nvim_buf_add_highlight(bufnr, -1, config.hl.header, 1, 0, -1)
          vim.api.nvim_buf_add_highlight(bufnr, -1, config.hl.header, 2, 0, -1)

          for i = 4, #lines, 1 do
            vim.api.nvim_buf_add_highlight(bufnr, -1, notification.style, i, 0, -1)
          end
        end,
      }),
    })
    :find()
end

function M.Fidgethistory()
  telescope_fidgethistory(__Telescope_vertical_dropdown_theme({
        shorten_path = true,
        width_text = 40,
        width_annotation = 50,
        path_display = false,
        prompt_title = "Notifications",
        hide_filename = false,
        layout_config = Config.telescope_vertical_preview_layout
      }))
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts)
end
return M
