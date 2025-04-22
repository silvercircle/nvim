-- info provider for the wsplit

---@class subspace.providers.Info
---@field owner wsplit
---@field id_content integer
---@field ws    table
---@field Utils table,
---@field min_height integer
local Info = {}
Info.__index = Info

---@return subspace.providers.Info
---@param  _owner wsplit
function Info:new(_owner)
  return setmetatable({
    content     = "test",
    owner       = _owner,
    id_content  = nil,
    ws       = require("subspace.content.wsplit"),
    Utils    = require("subspace.lib"),
    min_height  = 15
  }, self)
end

--- filetypes we are not interested in
local info_exclude_ft = { "terminal", "SymbolsSidebar", "NvimTree", "sysmon", "weather", "help" }
local info_exclude_bt = { "terminal", "nofile" }

-- folding modes (translate foldmethod to readable terms)
local fdm = {
  expr = "Expression",
  manual = "Manual",
  syntax = "Syntax",
  indent = "Indent",
  marker = "Marker",
  diff = "Diff",
}

-- shorten some lsp names.
local lsp_server_abbrev = {
  ["emmet_language_server"] = "emmet"
}

function Info:render()
  self.owner.content_id_win = vim.fn.win_getid()
  self.id_content = self.owner.content_id_win
  local relpath = vim.fs.relpath

  if self.id_content ~= nil and vim.api.nvim_win_is_valid(self.id_content) then
    local curbuf = vim.api.nvim_win_get_buf(self.id_content)
    if vim.tbl_contains(info_exclude_ft, vim.api.nvim_get_option_value("filetype", { buf = curbuf })) == true or
        vim.tbl_contains(info_exclude_bt, vim.api.nvim_get_option_value("buftype", { buf = curbuf })) then
      return
    end
    -- ignore floating windows
    if vim.api.nvim_win_get_config(self.id_content).relative ~= "" then
      return
    end
    local name = nil

    vim.api.nvim_buf_clear_namespace(self.owner.id_buf, self.ws.nsid, 0, -1)
    vim.api.nvim_set_option_value("modifiable", true, { buf = self.owner.id_buf })
    local lines = {}
    local buf_filename = vim.api.nvim_buf_get_name(curbuf)
    if buf_filename ~= nil and vim.bo[curbuf].bt == "" and vim.fn.filereadable(buf_filename) then
      name = self.Utils.path_truncate(relpath(self.Utils.getroot(buf_filename), buf_filename), self.owner.width - 3)
    else
      return
    end
    local fn_symbol, fn_symbol_hl = self.Utils.getFileSymbol(vim.api.nvim_buf_get_name(curbuf))
    local ft = vim.api.nvim_get_option_value("filetype", { buf = curbuf })

    table.insert(lines, self.Utils.pad("Buffer Info", self.owner.width + 1, " "))
    table.insert(lines, " " .. self.Utils.pad(name, self.owner.width, " ") .. "  ")
    table.insert(lines, " ")
    -- size of buffer. Bytes, KB or MB
    local size = vim.api.nvim_buf_get_offset(curbuf, vim.api.nvim_buf_line_count(curbuf))
    if size < 1024 then
      table.insert(
        lines,
        self.ws.prepare_line(" Size: " .. size .. " Bytes", "Lines: " .. vim.api.nvim_buf_line_count(curbuf), 4)
      )
    elseif size < 1024 * 1024 then
      table.insert(
        lines,
        self.ws.prepare_line(
          " Size: " .. string.format("%.2f", size / 1024) .. " KB",
          "Lines: " .. vim.api.nvim_buf_line_count(curbuf),
          4
        )
      )
    else
      table.insert(
        lines,
        self.ws.prepare_line(
          " Size: " .. string.format("%.2f", size / 1024 / 1024) .. " MB",
          "Lines: " .. vim.api.nvim_buf_line_count(curbuf),
          4
        )
      )
    end
    table.insert(
      lines,
      self.ws.prepare_line(
        " Type: " .. ft .. " " .. fn_symbol,
        "Enc: " .. vim.opt.fileencoding:get(),
        4
      )
    )
    table.insert(lines, " ")
    table.insert(
      lines,
      self.ws.prepare_line(
        " Textwidth: "
        .. vim.api.nvim_get_option_value("textwidth", { buf = curbuf })
        .. " / "
        .. (
          vim.api.nvim_get_option_value("wrap", { win = self.id_content }) == false and "No Wrap" or "Wrap"
        ),
        "Fmt: " .. (vim.api.nvim_get_option_value("fo", { buf = curbuf })),
        4
      )
    )
    table.insert(
      lines,
      self.ws.prepare_line(
        " Folding method:",
        fdm[vim.api.nvim_get_option_value("foldmethod", { win = self.id_content })],
        4
      )
    )
    if vim.api.nvim_get_option_value("foldmethod", { win = self.id_content }) == "expr" then
      table.insert(lines, " Expr: " .. vim.api.nvim_get_option_value("foldexpr", { win = self.id_content }))
    else
      table.insert(lines, " ")
    end
    local treesitter = "Off"
    if vim.tbl_contains(CFG.treesitter_types, ft) then
      treesitter = "On"
    end
    local val = CGLOBALS.get_buffer_var(curbuf, "tsc")
    table.insert(lines, self.ws.prepare_line(" Treesitter: " .. treesitter,
                 "Context: " .. ((val == true) and "On" or "Off"), 4))

    local lsp_clients = vim.lsp.get_clients({ bufnr = curbuf })
    if #lsp_clients > 0 then
      local line, k = " LSP: ", 0
      for _, v in pairs(lsp_clients) do
        line = line .. string.format(k == 0 and "%d:%s" or ", %d:%s", v.id, lsp_server_abbrev[v.name] or v.name)
        k = k + 1
      end
      table.insert(lines, line)
    else
      table.insert(lines, self.ws.prepare_line(" LSP ", "None attached", 4))
    end
    table.insert(lines, " ")
    -- add the cookie
    if #self.owner.cookie >= 1 then
      for _, v in ipairs(self.owner.cookie) do
        table.insert(lines, " " .. v)
      end
    end
    vim.api.nvim_buf_set_lines(self.owner.id_buf, 0, -1, false, lines)
    -- set highlights
    if #lines >= 12 then
      vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 0, 0, { hl_group = "Visual", end_col = #lines[1] })
      if string.len(name) > 0 then
        vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 1, 0, { hl_group = "CursorLine", end_col = #lines[2] })
      end
      if fn_symbol_hl ~= nil and lines[5] then
        vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 4, 0, { hl_group = fn_symbol_hl, end_col = #lines[5] })
      end
      vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 6, 0, { hl_group = "Debug", end_col = #lines[7] })
      vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 7, 0, { hl_group = "BlueBold", end_col = #lines[8] })
      vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 8, 0, { hl_group = "BlueBold", end_col = #lines[9] })
      vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 9, 0, { hl_group = "PurpleBold", end_col = #lines[10] })
      vim.api.nvim_buf_set_extmark(self.owner.id_buf, self.ws.nsid, 10, 0, { hl_group = "String", end_col = #lines[11] })
    end
    vim.api.nvim_set_option_value("modifiable", false, { buf = self.owner.id_buf })
  end
end

function Info:destroy()
end

local M = {}

---@return subspace.providers.Info
---@param owner wsplit
function M.new(owner)
  return Info:new(owner)
end

return M
