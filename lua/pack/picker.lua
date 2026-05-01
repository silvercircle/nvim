local M = {}


local conf = {
  -- the default filename
  prompt = "List of installed vim.pack plugins",
  width = 144,
  picker = 'snacks',
  snacks_layout   = {
    preset = "vertical",
    preview = false,
    layout = {
      backdrop = false,
      border = "single",
      box = "vertical",
      width = 144,
      height = 0.6,
      { win = "list",  border = "none" },
      { win = "input", height = 1, border = "top" },
    },
  },
  snacks_keys = {
    ['<leader>g'] = { { 'close', 'grep' }, mode = { 'n', 'i' } },
    ['<leader>n'] = { { 'close', 'tree' }, mode = { 'n', 'i' } },
    ['<leader>f'] = { { 'close', 'files' }, mode = { 'n', 'i' } },
    ['<leader>m'] = { { 'close', 'explorer' }, mode = { 'n', 'i' } },
    ['<leader>o'] = { { 'close', 'oil' }, mode = { 'n', 'i' } },
    ['<c-d>'] = { 'setdir', mode = { 'n', 'i' } }
  },
  explorer_layout = { },
  snacks_picker_cols= {
    active =    { hl = "Type", width = 12 },
    title =     { hl = "String", width = 40 },
    source =    { hl = "Member", width = 0 }, -- note: the width for the filename is auto-calculated
    version =   { hl = "Number", width = 15 }, -- note: the width for the filename is auto-calculated
  }
}

function M.pick()
  local snacks = require("snacks")
  local align = snacks.picker.util.align

  local plugins = vim.pack.get()
  if conf.snacks_layout.layout.title == nil then
    conf.snacks_layout.layout.title = conf.prompt
  end

  local filename_width = conf.snacks_layout.layout.width - conf.snacks_picker_cols.active.width -
      conf.snacks_picker_cols.title.width - conf.snacks_picker_cols.version.width - 3 --[[col gaps]]
  return snacks.picker({
    finder = function()
      local items = {}
      for i, item in ipairs(plugins) do
        table.insert(items, {
          idx = i,
          title = item.spec.name,
          src = item.spec.src,
          active = item.active and "Active" or "Inactive",
          is_active = item.active,
          version = item.spec.version ~= nil and item.spec.version or "<Unknown>",
          text = item.spec.name .. " " .. item.spec.src
        })
      end
      return items
    end,
    focus = "input",
    auto_close = false,
    layout = conf.snacks_layout,
    win = {
      input = {
        keys = conf.snacks_keys
      },
      list = {
        keys = conf.snacks_keys
      }
    },
    actions = {
      view = function(picker)
        local item = picker:current()
        vim.schedule(function() vim.notify(vim.inspect(item)) end)
      end,
    },
    sort = {
      fields = { "active:desc", "title:asc" }
    },
    matcher = {
      sort_empty = true
    },
    format = function(item, _)
      local entry = {}
      -- local icon, icon_hl = snacks.util.icon(item.ft, item.type == "@File" and "filetype" or "directory")
      local pos = #entry

      entry[pos + 1] = { align(item.active, conf.snacks_picker_cols.active.width), item.is_active and conf.snacks_picker_cols.active.hl or "Red" }
      entry[pos + 2] = { align(item.title, conf.snacks_picker_cols.title.width), conf.snacks_picker_cols.title.hl }
      entry[pos + 3] = { align(item.src, filename_width), conf.snacks_picker_cols.source.hl }
      entry[pos + 4] = { align(item.version == "<Unknown>" and "DEFAULT" or item.version, conf.snacks_picker_cols.version.width, { align = "right" }), conf.snacks_picker_cols.version.hl }
      return entry
    end,
    confirm = function(picker, item)
      picker:close()
      vim.schedule(function() vim.notify(vim.inspect(item)) end)
    end,
  })
end

return M

