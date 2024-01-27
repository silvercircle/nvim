local lspconfig = require("lspconfig")
local util = require('lspconfig.util')
local navic_status, navic = pcall(require, "nvim-navic")
local capabilities = __Globals.get_lsp_capabilities()

-- Customize LSP behavior via on_attach
On_attach = function(client, buf)
  if navic_status then
    navic.attach(client, buf)
    require("nvim-navbuddy").attach(client, buf)
  end
  if client.name == 'gopls' then
    client.server_capabilities.semanticTokensProvider = {
      full = true,
      legend = {
        tokenTypes = { 'namespace', 'type', 'class', 'enum', 'interface', 'struct', 'typeParameter', 'parameter', 'variable', 'property', 'enumMember', 'event', 'function', 'method', 'macro', 'keyword', 'modifier', 'comment', 'string', 'number', 'regexp', 'operator', 'decorator' },
        tokenModifiers = { 'declaration', 'definition', 'readonly', 'static', 'deprecated', 'abstract', 'async', 'modification', 'documentation', 'defaultLibrary' }
      }
    }
  end
end

lspconfig.tsserver.setup({
  init_options = { hostInfo = 'neovim' },
  cmd = { vim.g.lsp_server_bin['tsserver'], '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx'
  },
  root_dir = function(fname)
    return util.root_pattern 'tsconfig.json' (fname) or util.root_pattern('package.json', 'jsconfig.json', '.git')(fname)
  end,
  on_attach = On_attach,
  capabilities = capabilities
})

lspconfig.texlab.setup({
  cmd = { vim.g.lsp_server_bin['texlab'] },
  on_attach = On_attach,
  capabilities = capabilities
})

lspconfig.nimls.setup({
  on_attach = On_attach,
  capabilities = capabilities,
  cmd = { vim.g.lsp_server_bin['nimls'] },
  filetypes = { 'nim' },
  root_dir = function(fname)
    return util.root_pattern '*.nimble' (fname) or util.find_git_ancestor(fname)
  end,
  single_file_support = true
})

lspconfig.bashls.setup({
  on_attach = On_attach,
  capabilities = capabilities,
  cmd = { vim.g.lsp_server_bin['bashls'], 'start' },
  filetypes = { 'sh' },
  root_dir = util.find_git_ancestor,
  single_file_support = true,
  settings = {
    bashIde = {
      -- Glob pattern for finding and parsing shell script files in the workspace.
      -- Used by the background analysis features across files.

      -- Prevent recursive scanning which will cause issues when opening a file
      -- directly in the home directory (e.g. ~/foo.sh).
      --
      -- Default upstream pattern is "**/*@(.sh|.inc|.bash|.command)".
      globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)',
    }
  }
})
local clangd_root_files = {
  '.clangd',
  '.clang-tidy',
  '.clang-format',
  'compile_commands.json',
  'compile_flags.txt',
  'configure.ac', -- AutoTools
}
lspconfig.clangd.setup({
  cmd = { 'clangd', "--header-insertion-decorators", "--malloc-trim", "--background-index", "--pch-storage=memory" },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
  root_dir = function(fname)
    return util.root_pattern(unpack(clangd_root_files))(fname) or util.find_git_ancestor(fname)
  end,
  single_file_support = true,
  on_attach = On_attach,
  capabilities = capabilities
})

-- ada language server
lspconfig.als.setup({
  capabilities = capabilities,
  on_attach = On_attach,
  cmd = { vim.g.lsp_server_bin['als'] },
  filetypes = { 'ada' },
  root_dir = util.root_pattern('Makefile', '.git', '*.gpr', '*.adc'),
})

local function rust_reload_workspace(bufnr)
  bufnr = util.validate_bufnr(bufnr)
  vim.lsp.buf_request(bufnr, 'rust-analyzer/reloadWorkspace', nil, function(err)
    if err then
      error(tostring(err))
    end
    vim.notify 'Cargo workspace reloaded'
  end)
end

lspconfig.rust_analyzer.setup({
  cmd = { vim.g.lsp_server_bin['rust_analyzer'] },
  on_attach = On_attach,
  capabilities = capabilities,
  filetypes = { 'rust' },
  root_dir = function(fname)
    local cargo_crate_dir = util.root_pattern 'Cargo.toml' (fname)
    local cmd = { 'cargo', 'metadata', '--no-deps', '--format-version', '1' }
    if cargo_crate_dir ~= nil then
      cmd[#cmd + 1] = '--manifest-path'
      cmd[#cmd + 1] = util.path.join(cargo_crate_dir, 'Cargo.toml')
    end
    local cargo_metadata = ''
    local cargo_metadata_err = ''
    local cm = vim.fn.jobstart(cmd, {
      on_stdout = function(_, d, _)
        cargo_metadata = table.concat(d, '\n')
      end,
      on_stderr = function(_, d, _)
        cargo_metadata_err = table.concat(d, '\n')
      end,
      stdout_buffered = true,
      stderr_buffered = true,
    })
    if cm > 0 then
      cm = vim.fn.jobwait({ cm })[1]
    else
      cm = -1
    end
    local cargo_workspace_dir = nil
    if cm == 0 then
      cargo_workspace_dir = vim.json.decode(cargo_metadata)['workspace_root']
      if cargo_workspace_dir ~= nil then
        cargo_workspace_dir = util.path.sanitize(cargo_workspace_dir)
      end
    else
      vim.notify(
        string.format('[lspconfig] cmd (%q) failed:\n%s', table.concat(cmd, ' '), cargo_metadata_err),
        vim.log.levels.WARN
      )
    end
    return cargo_workspace_dir
        or cargo_crate_dir
        or util.root_pattern 'rust-project.json' (fname)
        or util.find_git_ancestor(fname)
  end,
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = {
        command = "clippy"
      }
    },
  },
  commands = {
    CargoReload = {
      function()
        rust_reload_workspace(0)
      end,
      description = 'Reload current cargo workspace',
    },
  }
})
lspconfig.emmet_language_server.setup({
  capabilities = capabilities,
  cmd = { vim.g.lsp_server_bin['emmet'], '--stdio' },
  filetypes = { "css", "eruby", "html", "javascript", "javascriptreact", "less", "sass",
                "scss", "svelte", "pug", "typescriptreact", "vue", "liquid", "jsp" },
  root_dir = util.root_pattern('package.json', '.git'),
  -- Read more about this options in the [vscode docs](https://code.visualstudio.com/docs/editor/emmet#_emmet-configuration).
  -- **Note:** only the options listed in the table are supported.
  init_options = {
    --- @type string[]
    excludeLanguages = {},
    --- @type string[]
    extensionsPath = {},
    --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/preferences/)
    preferences = {},
    --- @type boolean Defaults to `true`
    showAbbreviationSuggestions = true,
    --- @type "always" | "never" Defaults to `"always"`
    showExpandedAbbreviation = "always",
    --- @type boolean Defaults to `false`
    showSuggestionsAsSnippets = false,
    --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/syntax-profiles/)
    syntaxProfiles = {},
    --- @type table<string, string> [Emmet Docs](https://docs.emmet.io/customization/snippets/#variables)
    variables = {},
  },
})

lspconfig.cssls.setup({
  cmd = { vim.g.lsp_server_bin['cssls'], '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_dir = util.root_pattern('package.json', '.git'),
  single_file_support = true,
  on_attach = On_attach,
  capabilities = capabilities,
  settings = {
    css = { validate = true },
    scss = { validate = true },
    less = { validate = true },
  },
})

lspconfig.html.setup({
  cmd = { vim.g.lsp_server_bin['html'], '--stdio' },
  filetypes = { 'html', 'xhtml', 'liquid', 'jsp' },
  root_dir = util.root_pattern('package.json', '.git'),
  single_file_support = true,
  settings = {},
  init_options = {
    provideFormatter = false,
    embeddedLanguages = { css = true, javascript = true },
    configurationSection = { 'html', 'css', 'javascript' },
  },
  on_attach = On_attach,
  capabilities = capabilities
})

lspconfig.gopls.setup({
  on_attach = On_attach,
  cmd = { vim.g.lsp_server_bin['gopls'] },
  capabilities = capabilities,
  single_file_support = true,
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  settings = {
    gopls = {
      semanticTokens = true
    }
  },
  root_dir = function(fname)
    return util.root_pattern 'go.work' (fname) or util.root_pattern('go.mod', '.git')(fname)
  end
})

lspconfig.vimls.setup({
  cmd = { vim.g.lsp_server_bin['vimlsp'], '--stdio' },
  on_attach = On_attach,
  capabilities = capabilities
})

lspconfig.serve_d.setup({
  cmd = { vim.g.lsp_server_bin['serve_d'] },
  on_attach = On_attach,
  capabilities = capabilities
})

lspconfig.yamlls.setup({
  on_attach = On_attach,
  capabilities = capabilities,
  cmd = { vim.g.lsp_server_bin['yamlls'], '--stdio' },
  filetypes = { 'yaml', 'yaml.docker-compose' },
  root_dir = util.find_git_ancestor,
  single_file_support = true,
  settings = {
    -- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
    redhat = { telemetry = { enabled = false } },
  }
})

-- python pyright
lspconfig.pyright.setup({
  cmd = { vim.g.lsp_server_bin['pyright'], '--stdio' },
  on_attach = On_attach,
  capabilities = capabilities
})

-- markdown
lspconfig.marksman.setup({
  on_attach = On_attach,
  cmd = { vim.g.lsp_server_bin['marksman'] },
  filetypes = { 'markdown', 'telekasten' },
  root_dir = function(fname)
    local root_files = { '.marksman.toml' }
    return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
  end,
  single_file_support = true,
  capabilities = capabilities
})

-- xml
lspconfig.lemminx.setup({
  on_attach = On_attach,
  capabilities = capabilities,
  cmd = { vim.g.lsp_server_bin['lemminx'] },
  filetypes = { 'xml', 'xsd', 'xsl', 'xslt', 'svg' },
  root_dir = util.find_git_ancestor,
  single_file_support = true
})

-- toml
lspconfig.taplo.setup({
  on_attach = On_attach,
  capabilities = capabilities,
  cmd = { vim.g.lsp_server_bin['taplo'], 'lsp', 'stdio' },
  filetypes = { 'toml' },
  root_dir = function(fname)
    return util.root_pattern '*.toml' (fname) or util.find_git_ancestor(fname)
  end,
  single_file_support = true
})

local lua_root_files = {
  '.luarc.json',
  '.luarc.jsonc',
  '.luacheckrc',
  '.stylua.toml',
  'stylua.toml',
  'selene.toml',
  'selene.yml',
}

lspconfig.lua_ls.setup {
  capabilities = capabilities,
  on_attach = On_attach,
  cmd = { vim.g.lsp_server_bin['lua_ls'], '--logpath=' .. vim.fn.stdpath("state") },
  root_dir = function(fname)
    local root = util.root_pattern(unpack(lua_root_files))(fname)
    if root and root ~= vim.env.HOME then
      return root
    end
    root = util.root_pattern 'lua/' (fname)
    if root then
      return root .. '/lua/'
    end
    return util.find_git_ancestor(fname)
  end,
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
        enable = false
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

lspconfig.groovyls.setup {
  capabilities = capabilities,
  on_attach = On_attach,
  cmd = { vim.g.lsp_server_bin['groovy'] },
  filetypes = { 'groovy' },
  root_dir = function(fname)
    return util.root_pattern 'settings.gradle'(fname) or util.find_git_ancestor(fname)
  end
}

lspconfig.jsonls.setup {
  cmd = { vim.g.lsp_server_bin[ "jsonls" ], "--stdio" },
  filetypes = { "json", "jsonc" },
  init_options = {
    provideFormatter = true,
  },
  root_dir = util.find_git_ancestor,
  single_file_support = true,
  on_attach = On_attach
}
-- outsourced because it's too big
if vim.g.tweaks.lsp.csharp == "omnisharp" then
  require("lsp.omnisharp")
elseif vim.g.tweaks.lsp.csharp == "roslyn" then
  require("lsp.roslyn")
elseif vim.g.tweaks.lsp.csharp == "csharp_ls" then
  require("lsp.csharp_ls")
end

-- require("lsp.hls")      -- hls (haskell)
-- require("lsp.phpactor") -- php (unused)
-- require("lsp.dartls")   -- dart/flutter (unused)
-------------------------
-- LSP Handlers (general)
-------------------------

do
  local on_references = vim.lsp.handlers["textDocument/references"]
  local lsp_handlers_hover = vim.lsp.with(vim.lsp.handlers.hover, {
    border = __Globals.perm_config.float_borders
  })
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      -- delay update diagnostics
      update_in_insert = false,
    }
  )
  vim.lsp.handlers['workspace/diagnostic/refresh'] = function(_, _, ctx)
    local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.diagnostic.reset(ns, bufnr)
    return true
  end
  vim.lsp.handlers["textDocument/references"] = vim.lsp.with(
    on_references, {
    }
  )
  vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
    local bufnr, winnr = lsp_handlers_hover(err, result, ctx, config)
    return bufnr, winnr
  end

  -- this is for vim.lsp.buf.signature_help()
  -- Bound to C-p in insert mode
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
      border = __Globals.perm_config.float_borders,
      focusable = false
    })
end

------------------
-- LSP diagnostics
------------------
if vim.diagnostic then
  vim.diagnostic.config({
    update_in_insert = false,
    virtual_text = not vim.g.tweaks.lsp.virtual_lines,
    virtual_lines = (vim.g.tweaks.lsp.virtual_lines == true) and { only_current_line = true, highlight_whole_line = false } or false,
    underline = {
      -- Do not underline text when severity is low (INFO or HINT).
      severity = { min = vim.diagnostic.severity.WARN },
    },
    signs = {
      text = {
        [vim.diagnostic.severity.HINT]  = "",
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.INFO]  = "◉",
        [vim.diagnostic.severity.WARN]  = ""
      }
    },
    float = {
      source = "always",
      focusable = true,
      focus = false,
      border = __Globals.perm_config.float_borders,
      -- Customize how diagnostic message will be shown: show error code.
      format = function(diagnostic)
        local user_data
        user_data = diagnostic.user_data or {}
        user_data = user_data.lsp or user_data.null_ls or user_data
        local code = (
        -- TODO: symbol is specific to pylint (will be removed)
          diagnostic.symbol
          or diagnostic.code
          or user_data.symbol
          or user_data.code
        )
        if code then
          return string.format("%s (%s)", diagnostic.message, code)
        else
          return diagnostic.message
        end
      end,
    },
  })
end
do
  if vim.fn.has("nvim-0.10") == 0 then
    vim.fn.sign_define("DiagnosticSignError", { text = "✘", texthl = "RedSign" })
    vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "YellowSign" })
    vim.fn.sign_define("DiagnosticSignInfo", { text = "◉", texthl = "BlueSign" })
    vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "GreenSign" })
  end
end
require('lspconfig.ui.windows').default_options.border = 'single'

