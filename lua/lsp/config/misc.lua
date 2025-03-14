------------------
-- LSP diagnostics
------------------
if vim.diagnostic then
  vim.diagnostic.config({
    update_in_insert = false,
    virtual_text = not Tweaks.lsp.virtual_lines,
    virtual_lines = (Tweaks.lsp.virtual_lines == true) and { only_current_line = true, highlight_whole_line = false } or false,
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
-- set a border for the default hover and diagnostics windows
require('lspconfig.ui.windows').default_options.border = PCFG.float_borders
