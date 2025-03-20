-- it imports config.handlers and config.misc
--
-- NOTE: This does not include configurations for C#, Java and scala, because
-- they are all handled by separate plugins.

require("lsp.utils")

local caps = CGLOBALS.get_lsp_capabilities()

-- the reason why we are doing it this was is that I want to have control
-- over config.cmd, because language servers might be installed everywhere
-- not always necessarily in the $PATH
-- That's why lspdef.lua contains the cmd definitions and this can be easily
-- overridden by using a lspdef_user.lua

for k,v in pairs(LSPDEF.serverconfigs) do
  if v.active == true then
    local config = require("lsp.serverconfig." .. k)
    if config.cmd == nil then
      config.cmd = v.cmd
    else
      config.cmd[1] = v.cmd[1]
    end
    config.name = k
    vim.lsp.config[k] = config
    vim.lsp.enable(k, true)
  end
end

-- modify defaults for all configurations
vim.lsp.config("*", {
  on_attach = ON_LSP_ATTACH,
  capabilities = caps
})

require("lsp.config.handlers")
require("lsp.config.misc")

