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

  vim.lsp.config("*", {
    on_attach = ON_LSP_ATTACH,
    capabilities = caps
  })

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
      config._valid = true
      -- in debug mode, we check whether the LSP executable is available and executable
      -- and inform the user when it is not.
      if LSPDEF.debug then
        if not LSPDEF.debug_output then LSPDEF.debug_output = {} end
        if not (config.cmd and config.cmd[1] and vim.fn.executable(config.cmd[1]) == 1) then
          table.insert(LSPDEF.debug_output,
            string.format("LSP **%s**: The executable (%s) is not available", k, config.cmd[1] or "Unknown"))
          config._valid = false
        end
      end
      if config._valid then
        if config.on_attach and type(config.on_attach) == "function" then
          config.on_attach_orig = vim.deepcopy(config.on_attach, 1)
          config.on_attach = nil
        end
        table.insert(to_enable, k)
        vim.lsp.config[k] = config
      end
    end
    ::continue::
  end

  vim.lsp.enable(to_enable)
end

M.lsp_capabilities = nil

M.local_caps = {
  workspace = {
    didChangeWatchedFiles = {
      dynamicRegistration = LSPDEF.use_dynamic_registration
    },
    executeCommand = {
      dynamicRegistration = true
    }
  },
  textDocument = {
    completion = {
      editsNearCursor = true
    }
  }
}
--- obtain lsp capabilities from lsp and cmp-lsp plugin
--- @return table
function M.get_lsp_capabilities()
  if M.lsp_capabilities == nil then
    if Tweaks.completion.version == "blink" then
      M.lsp_capabilities = require("blink.cmp").get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities())
      M.lsp_capabilities = vim.tbl_deep_extend("force", M.lsp_capabilities, M.local_caps)
    else
      local caps = require("cmp_nvim_lsp").default_capabilities()
      M.lsp_capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), M.local_caps)
      M.lsp_capabilities = vim.tbl_deep_extend("force", M.lsp_capabilities, caps)
    end
    --M.lsp_capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = LSPDEF.use_dynamic_registration
    --M.lsp_capabilities.textDocument.completion.editsNearCursor = true
    --M.lsp_capabilities.workspace.executeCommand = {
    --  dynamicRegistration = true
    --}
  end
  return M.lsp_capabilities
end

function M.setup()
  require("lsp.utils")
  do_setup()
  require("lsp.config.misc")
end

return M
