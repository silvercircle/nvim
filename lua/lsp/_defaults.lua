-- main configuration for lspconfig
-- it imports config.handlers and config.misc
-- it will also try to import lsp/user.lua via pcall()
-- This is where you should add your own server configurations.
--
-- NOTE: This does not include configurations for C#, Java and scala, because
-- they are all handled by separate plugins.

local lspconfig = require("lspconfig")
local util = require('lspconfig.util')
local navic_status, navic = pcall(require, "nvim-navic")
local configs = require("lspconfig.configs")

-- Customize LSP behavior via on_attach
On_attach = function(client, buf)
  if navic_status then
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
end

-- custom config for ada, because als is deprecated in future nvim-lspconfig
if not configs.ada then
  configs.ada = {
    default_config = {
      capabilities = CGLOBALS.lsp_capabilities,
      on_attach = On_attach,
      cmd = { Tweaks.lsp.server_bin['als'] },
      filetypes = { 'ada' },
      root_dir = util.root_pattern('Makefile', '.git', '*.gpr', '*.adc'),
      lspinfo = function(cfg)
        local extra = {}
        local function find_gpr_project()
          local function split(inputstr)
            local t = {}
            for str in string.gmatch(inputstr, '([^%s]+)') do
              table.insert(t, str)
            end
            return t
          end
          local projectfiles = split(vim.fn.glob(cfg.root_dir .. '/*.gpr'))
          if #projectfiles == 0 then
            return 'None (error)'
          elseif #projectfiles == 1 then
            return projectfiles[1]
          else
            return 'Ambiguous (error)'
          end
        end
        table.insert(extra, 'GPR project:     ' .. ((cfg.settings.ada or {}).projectFile or find_gpr_project()))
        return extra
      end
    }
  }
end

if not configs.ctags_lsp then
  configs.ctags_lsp = {
    default_config = {
      cmd = { "ctags-lsp" },
      filetypes = nil,
      root_dir = function()
        return vim.fn.getcwd()
      end
    }
  }
end


for k,v in pairs(Tweaks.lsp.serverconfigs) do
  if v.active == true then
    lspconfig[k].setup(require(v.name))
  end
end

-- require("lsp.hls")        -- haskell (unused)
-- require("lsp.dartls")     -- dart/flutter (unused)

-- user-supplied lsp configurations
_, _ = pcall(require, "lsp.user")

require("lsp.config.handlers")
require("lsp.config.misc")

