-------------------------
-- LSP Handlers (general)
-------------------------

do
  local on_references = vim.lsp.handlers["textDocument/references"]
  local lsp_handlers_hover = vim.lsp.with(vim.lsp.handlers.hover, {
    border = PCFG.float_borders
  })
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      -- delay update diagnostics
      update_in_insert = false,
    }
  )
  vim.lsp.handlers['workspace/diagnostic/refresh'] = function(_, _, ctx)
    local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.diagnostic.reset(ns, bufnr)
    return true
  end
  vim.lsp.handlers["textDocument/references"] = vim.lsp.with(
    on_references, {
    }
  )
  vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
    local bufnr, winnr = lsp_handlers_hover(err, result, ctx, config)
    return bufnr, winnr
  end

  -- this is for vim.lsp.buf.signature_help()
  -- Bound to C-p in insert mode
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
      border = PCFG.float_borders,
      focusable = false
    })
end
