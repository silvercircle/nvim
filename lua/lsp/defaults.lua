-- main configuration for lspconfig
-- it imports config.handlers and config.misc
--
-- NOTE: This does not include configurations for C#, Java and scala, because
-- they are all handled by separate plugins.

local navic = require("nvim-navic")

-- Customize LSP behavior via on_attach
ON_LSP_ATTACH = function(client, buf)
  if LSPDEF.debug then
    vim.notify("Attaching " .. client.name .. " " .. vim.inspect(client.config.cmd) .. " to buffer nr " .. buf)
  end
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

local caps = CGLOBALS.get_lsp_capabilities()

vim.lsp.config("*", {
  on_attach = ON_LSP_ATTACH,
  capabilities = caps
})

for k,v in pairs(LSPDEF.serverconfigs) do
  if v.active == true then
    if v.cfg == false then
      local config = require("lsp.serverconfig." .. k)
      if v.cmd and #v.cmd == 1 then
        config.cmd[1] = v["cmd"][1] or config.cmd[1]
      elseif v.cmd then
        config.cmd = v.cmd
      end
      config.name = k
      vim.lsp.config[k] = config
      vim.lsp.enable(k, true)
    elseif type(v.cfg) == "string" then
      local config = require(v.cfg)
      config.name = k
      if config.cmd == nil then
        config.cmd = v.cmd
      else
        config.cmd[1] = v.cmd[1]
      end
      if CFG.have_lsp_config then
        config.root_dir = nil
        vim.lsp.config[k] = config
        vim.lsp.enable(k, true)
      end
    end
  end
end

require("lsp.config.handlers")
require("lsp.config.misc")

local M = {}

function M.get_active_client_by_name(bufnr, servername)
  --TODO(glepnir): remove this for loop when we want only support 0.10+
  for _, client in pairs(vim.lsp.get_clients { bufnr = bufnr }) do
    if client.name == servername then
      return client
    end
  end
end

return M

