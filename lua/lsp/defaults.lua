-- main configuration for lspconfig
-- it imports config.handlers and config.misc
--
-- NOTE: This does not include configurations for C#, Java and scala, because
-- they are all handled by separate plugins.

local lspconfig = require("lspconfig")
local Configs = require("lspconfig.configs")
local navic = require("nvim-navic")

local have_lsp_config = (vim.lsp.config ~= nil)

---@type table<string, table>
local lsp_filetypes = {}
-- list of filetypes used for the autocmd pattern
local auto_filetypes = {}

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

for k,v in pairs(LSPDEF.serverconfigs) do
  if v.active == true then
if v.cfg == false then
      local s, config = pcall(require, "lspconfig.configs." .. k)
      if not s then
        config = LSPDEF.local_configs[k]
        Configs[k] = config
      end
      if v.cmd and #v.cmd == 1 then
        config.default_config.cmd[1] = v["cmd"][1] or config.default_config.cmd[1]
      elseif v.cmd then
        config.default_config.cmd = v.cmd
      end
      config.default_config.on_attach = ON_LSP_ATTACH
      config.default_config.capabilities = caps
      config.default_config.name = k
      if have_lsp_config then
        local c = config.default_config
        c.settings = config.settings or {}
        c.commands = config.commands or {}
        table.insert(lsp_filetypes, { config = "lspconfig.configs." .. k, ft = c.lsp_filetypes })
        vim.iter(c.filetypes):map(function(kk)
          if not vim.tbl_contains(auto_filetypes, kk) then table.insert(auto_filetypes, kk) end
        end)
      else
        lspconfig[k].setup({})
      end
    elseif type(v.cfg) == "string" then
      local config = require(v.cfg)
      config.name = k
      config.capabilities = caps
      config.on_attach = ON_LSP_ATTACH
      if config.cmd == nil then
        config.cmd = v.cmd
      else
        config.cmd[1] = v.cmd[1]
      end
      if have_lsp_config then
        table.insert(lsp_filetypes, { config = v.cfg, ft = config.lsp_filetypes } )
        vim.iter(config.filetypes):map(function(kk)
          if not vim.tbl_contains(auto_filetypes, kk) then table.insert(auto_filetypes, kk) end
        end)
      else
        lspconfig[k].setup(config)
      end
    end
  end
end

-- this autocommand watches all filetypes for which we have an lsp
-- and launches them. 
vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = auto_filetypes,
  callback = function(args)
    for _,v in pairs(lsp_filetypes) do
      if vim.tbl_contains(v.ft, args.match) then
        local s, c = pcall(require, v.config)
        if s then
          vim.lsp.start(c.default_config or c)
        end
      end
    end
  end,
  group = nil
})
require("lsp.config.handlers")
require("lsp.config.misc")

