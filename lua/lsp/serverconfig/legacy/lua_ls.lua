local Util = require('lsp.utils')
local lua_root_files = {
  '.luarc.json',
  '.luarc.jsonc',
  '.luacheckrc',
  '.stylua.toml',
  'stylua.toml',
  'selene.toml',
  'selene.yml',
}

return {
  root_dir = function(fname)
    local root = Util.root_pattern(unpack(lua_root_files))(fname)
    if root and root ~= vim.env.HOME then
      return root
    end
    root = Util.root_pattern 'lua/' (fname)
    if root then
      return root .. '/lua/'
    end
    return vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
  end,
  filetypes = { "lua" },
  single_file_support = true,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
        workspaceEvent = "OnSave",
        disable = {
          "param-type-mismatch",
          "undefined-field",
          "invisible"
        }
      },
      hint = {
        enable = true
      },
      runtime = {
        version = "LuaJIT", -- Lua 5.1/LuaJIT
      },
      telemetry = {
        enable = false
      },
      window = {
        progressBar = true
      }
    }
  }
}

