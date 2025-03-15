return {
  cmd = { Tweaks.lsp.server_bin['vimlsp'], '--stdio' },
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities
}

