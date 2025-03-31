-- it imports config.handlers and config.misc
--
-- NOTE: This does not include configurations for C#, Java and scala, because
-- they are all handled by separate plugins.

-- the reason why we are doing it this was is that I want to have control
-- over config.cmd, because language servers might be installed everywhere
-- not always necessarily in the $PATH
-- That's why lspdef.lua contains the cmd definitions and this can be easily
-- overridden by using a lspdef_user.lua

local M = {}
local to_enable = {}

local function do_setup()
  local caps = M.get_lsp_capabilities()

  for k, v in pairs(LSPDEF.serverconfigs) do
    if v.active == true then
      local s, config = pcall(require, "lsp.serverconfig." .. k)
      if not s then
        if LSPDEF.debug then
          vim.notify("LSP: no server configuration file for " .. k .. " found.")
        end
        goto continue
      end
      if v.cmd then
        if config.cmd == nil then
          config.cmd = v.cmd
        else
          config.cmd[1] = v.cmd[1]
        end
      end
      config.name = k
      table.insert(to_enable, k)
      vim.lsp.config[k] = config
    end
    ::continue::
  end

  vim.lsp.enable(to_enable)
  -- modify defaults for all configurations
  vim.lsp.config("*", {
    on_attach = ON_LSP_ATTACH,
    capabilities = caps
  })
end

M.lsp_capabilities = nil

--- obtain lsp capabilities from lsp and cmp-lsp plugin
--- @return table
function M.get_lsp_capabilities()
  if M.lsp_capabilities == nil then
    M.lsp_capabilities = Tweaks.completion.version == "blink"
      and require("blink.cmp").get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities())
      or require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
    M.lsp_capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = LSPDEF.use_dynamic_registration
    M.lsp_capabilities.textDocument.completion.editsNearCursor = true
    M.lsp_capabilities.workspace.executeCommand = {
      dynamicRegistration = true
    }
  end
  return M.lsp_capabilities
end

function M.setup()
  require("lsp.utils")
  do_setup()
  require("lsp.config.misc")
end

return M
