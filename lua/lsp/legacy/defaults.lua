-- this is the legacy mode
-- it requires nvim-lspconfig to setup langauge servers.

local lspconfig
lspconfig = require("lspconfig")
require("lsp.utils")

local caps = CGLOBALS.get_lsp_capabilities()

for k,v in pairs(LSPDEF.serverconfigs) do
  local s, config = pcall(require, "lsp.serverconfig.legacy." .. k)
  if not s then
    s, config = pcall(require, "lspconfig.configs." .. k)
    if not s then
      vim.notify("Failed to obtain LSP configuration for " .. k)
      goto continue
    end
    if v.cmd and #v.cmd > 1 then
      config.default_config.cmd = v.cmd
    else
      config.default_config.cmd[1] = v.cmd[1]
    end
    config.default_config.settings = config.settings or {}
    config.default_config.commands = config.commands or {}
    config.default_config.capabilities = caps
    config.default_config.on_attach = ON_LSP_ATTACH
    lspconfig[k].setup(config.default_config)
  else
    if not config.cmd then
      config.cmd = v.cmd or {}
    else
      if v.cmd and #v.cmd > 1 then
        config.cmd = v.cmd
      else
        config.cmd[1] = v.cmd[1]
      end
    end
    config.capabilities = caps
    config.on_attach = ON_LSP_ATTACH
    lspconfig[k].setup(config)
  end
  ::continue::
end

require("lsp.config.handlers")
require("lsp.config.misc")

