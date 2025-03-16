-- main configuration for lspconfig
-- it imports config.handlers and config.misc
-- it will also try to import lsp/user.lua via pcall()
-- This is where you should add your own server configurations.
--
-- NOTE: This does not include configurations for C#, Java and scala, because
-- they are all handled by separate plugins.

local lspconfig = require("lspconfig")
local Configs = require("lspconfig.configs")
local navic = require("nvim-navic")

-- Customize LSP behavior via on_attach
On_attach = function(client, buf)
  navic.attach(client, buf)
  vim.g.inlay_hints_visible = true
  if client.server_capabilities.inlayHintProvider then
    vim.g.inlay_hints_visible = PCFG.lsp.inlay_hints
    vim.lsp.inlay_hint.enable(PCFG.lsp.inlay_hints)
  end
  if client.name == "rzls" then
    vim.cmd("hi! link @lsp.type.field Member")
  end
end

local local_configs = {
  ctags_lsp = {
    default_config = {
      cmd = { "ctags-lsp" },
      filetypes = nil,
      root_dir = function()
        return vim.fn.getcwd()
      end
    }
  }
}

for k,v in pairs(LSPDEF.serverconfigs) do
  if v.active == true then
    if v.cfg == "_defaults_" then
      local s, config = pcall(require, "lspconfig.configs." .. k)
      if not s then
        config = local_configs[k]
        Configs[k] = config
      end
      config.default_config.cmd[1] = LSPDEF.server_bin[k] or config.default_config.cmd[1]
      config.default_config.on_attach = On_attach
      config.default_config.capabilities = CGLOBALS.lsp_capabilities
      lspconfig[k].setup({})
    else
      local config = require(v.cfg)
      config.capabilities = CGLOBALS.lsp_capabilities
      config.on_attach = On_attach
      lspconfig[k].setup(config)
    end
  end
end

require("lsp.config.handlers")
require("lsp.config.misc")

