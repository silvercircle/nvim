------------------
-- LSP diagnostics
------------------
if vim.diagnostic then
  vim.diagnostic.config({
    update_in_insert = false,
    virtual_text = (LSPDEF.virtual_text) and { current_line = false },
    virtual_lines = (LSPDEF.virtual_lines == true) and { current_line = true, highlight_whole_line = false } or false,
    underline = {
      -- Do not underline text when severity is low (INFO or HINT).
      severity = { min = vim.diagnostic.severity.WARN },
    },
    signs = {
      text = {
        [vim.diagnostic.severity.HINT]  = "",
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.INFO]  = "◉",
        [vim.diagnostic.severity.WARN]  = ""
      },
      numhl = {
        [vim.diagnostic.severity.WARN] = "WarningMsg",
        [vim.diagnostic.severity.ERROR] = "ErrorMsg",
        [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
        [vim.diagnostic.severity.HINT] = "DiagnosticHint",
      }
    },
    float = {
      source = "always",
      focusable = true,
      focus = false,
      border = PCFG.float_borders,
      -- Customize how diagnostic message will be shown: show error code.
      format = function(diagnostic)
        local user_data
        user_data = diagnostic.user_data or {}
        user_data = user_data.lsp or user_data.null_ls or user_data
        local code = (
        -- TODO: symbol is specific to pylint (will be removed)
          diagnostic.symbol
          or diagnostic.code
          or user_data.symbol
          or user_data.code
        )
        if code then
          return string.format("%s (%s)", diagnostic.message, code)
        else
          return diagnostic.message
        end
      end,
    },
  })
end
do
  vim.fn.sign_define("DiagnosticSignError", { text = "✘", texthl = "RedSign" })
  vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "YellowSign" })
  vim.fn.sign_define("DiagnosticSignInfo", { text = "◉", texthl = "BlueSign" })
  vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "GreenSign" })
end

--- LSP progress handler for snacks.notifier
--- not needed when notifier is set to "fidget", because it has its own
--- implementation
if Tweaks.notifier == "snacks" then
  local progress = vim.defaulttable()
  vim.api.nvim_create_autocmd("LspProgress", {
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
      if not client or type(value) ~= "table" then
        return
      end
      local p = progress[client.id]

      for i = 1, #p + 1 do
        if i == #p + 1 or p[i].token == ev.data.params.token then
          p[i] = {
            token = ev.data.params.token,
            msg = ("`%3d%%` %s%s"):format(
              value.kind == "end" and 100 or value.percentage or 100,
              value.title or "",
              value.message and (" **%s**"):format(value.message) or ""
            ),
            done = value.kind == "end",
          }
          break
        end
      end

      local msg = {} ---@type string[]
      progress[client.id] = vim.tbl_filter(function(v)
        return table.insert(msg, v.msg) or not v.done
      end, p)

      local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
      vim.notify(table.concat(msg, "\n"), "info", {
        id = "lsp_progress",
        title = client.name,
        opts = function(notif)
          notif.icon = #progress[client.id] == 0 and " "
            or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
        end,
      })
    end,
  })
end
