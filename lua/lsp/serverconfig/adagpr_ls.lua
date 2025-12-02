local util = require("lsp.utils")

---@type vim.lsp.Config
return {
  cmd = { LSPDEF.serverconfigs["adagpr_ls"].cmd[1], "--language-gpr" },
  filetypes = { "adagpr" },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(util.root_pattern("Makefile", ".git", "alire.toml", "*.gpr", "*.adc")(fname))
  end
}
