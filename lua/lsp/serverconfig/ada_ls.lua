local util = require("lsp.utils")

---@type vim.lsp.Config
return {
  cmd = { LSPDEF.serverconfigs["ada_ls"].cmd[1] },
  root_markers = { ".als.json"},
  filetypes = { "ada" },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(util.root_pattern(".als.json", ".git", "alire.toml", "*.gpr")(fname))
  end
}
