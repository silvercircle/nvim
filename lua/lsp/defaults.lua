-- main configuration for lspconfig
-- it imports config.handlers and config.misc
--
-- NOTE: This does not include configurations for C#, Java and scala, because
-- they are all handled by separate plugins.

local lspconfig = require("lspconfig")
local Configs = require("lspconfig.configs")
local navic = require("nvim-navic")

local have_lsp_config = false -- (vim.lsp.config ~= nil)

-- Customize LSP behavior via on_attach
ON_LSP_ATTACH = function(client, buf)
  if not vim.tbl_contains(LSPDEF.exclude_navic, client.name) then
    navic.attach(client, buf)
  end
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

local caps = CGLOBALS.get_lsp_capabilities()

for k,v in pairs(LSPDEF.serverconfigs) do
  if v.active == true then
    if v.cfg == false then
      local s, config = pcall(require, "lspconfig.configs." .. k)
      if not s then
        config = local_configs[k]
        Configs[k] = config
      end
      config.default_config.cmd[1] = v["bin"] or config.default_config.cmd[1]
      config.default_config.on_attach = ON_LSP_ATTACH
      config.default_config.capabilities = caps
      if have_lsp_config then
        local c = config.default_config
        c.settings = config.settings or {}
        c.commands = config.commands or {}
        vim.lsp.config(k, c)
      else
        lspconfig[k].setup({})
      end
    elseif type(v.cfg) == "string" then
      local config = require(v.cfg)
      config.capabilities = caps
      config.on_attach = ON_LSP_ATTACH
      if have_lsp_config then
        vim.lsp.config(k, config)
      else
        lspconfig[k].setup(config)
      end
    end
  end
end

require("lsp.config.handlers")
require("lsp.config.misc")

