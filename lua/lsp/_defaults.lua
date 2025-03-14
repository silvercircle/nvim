local lspconfig = require("lspconfig")
local util = require('lspconfig.util')
local navic_status, navic = pcall(require, "nvim-navic")
local capabilities = CGLOBALS.get_lsp_capabilities()
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

-- this was tsserver (will be deprecated in the future)
lspconfig.ts_ls.setup({
  init_options = { hostInfo = 'neovim' },
  cmd = { Tweaks.lsp.server_bin['tsserver'], '--stdio' },
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
  capabilities = CGLOBALS.lsp_capabilities
})

lspconfig.texlab.setup({
  cmd = { Tweaks.lsp.server_bin['texlab'] },
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities
})

lspconfig.tinymist.setup({
  cmd = { "tinymist" },
  filetypes = { 'typst' },
  root_dir = function(fname)
    return vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
  end,
  single_file_support = true,
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities
})

lspconfig.nim_langserver.setup({
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities,
  cmd = { Tweaks.lsp.server_bin['nimls'] },
  filetypes = { 'nim' },
  root_dir = function(fname)
    return util.root_pattern '*.nimble' (fname) or util.find_git_ancestor(fname)
  end,
  single_file_support = true
})

lspconfig.bashls.setup({
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities,
  cmd = { Tweaks.lsp.server_bin['bashls'], 'start' },
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

lspconfig.ada.setup({})

lspconfig.emmet_language_server.setup({
  capabilities = CGLOBALS.lsp_capabilities,
  cmd = { Tweaks.lsp.server_bin['emmet'], '--stdio' },
  filetypes = { "css", "eruby", "html", "javascript", "javascriptreact", "less", "sass",
                "scss", "svelte", "pug", "typescriptreact", "vue", "jsp", "razor" },
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
  cmd = { Tweaks.lsp.server_bin['cssls'], '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_dir = util.root_pattern('package.json', '.git'),
  single_file_support = true,
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities,
  settings = {
    css = { validate = true },
    scss = { validate = true },
    less = { validate = true },
  },
})

lspconfig.html.setup({
  cmd = { Tweaks.lsp.server_bin['html'], '--stdio' },
  filetypes = { 'html', 'xhtml', 'jsp', 'razor' },
  root_dir = util.root_pattern('package.json', '.git'),
  single_file_support = true,
  settings = {},
  init_options = {
    provideFormatter = false,
    embeddedLanguages = { css = true, javascript = true },
    configurationSection = { 'html', 'css', 'javascript' },
  },
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities
})

lspconfig.gopls.setup({
  on_attach = On_attach,
  cmd = { Tweaks.lsp.server_bin['gopls'] },
  capabilities = CGLOBALS.lsp_capabilities,
  single_file_support = true,
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  settings = {
    gopls = {
      semanticTokens = false,
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    }
  },
  root_dir = function(fname)
    return util.root_pattern 'go.work' (fname) or util.root_pattern('go.mod', '.git')(fname)
  end
})

lspconfig.vimls.setup({
  cmd = { Tweaks.lsp.server_bin['vimlsp'], '--stdio' },
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities
})

lspconfig.yamlls.setup({
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities,
  cmd = { Tweaks.lsp.server_bin['yamlls'], '--stdio' },
  filetypes = { 'yaml', 'yaml.docker-compose' },
  root_dir = util.find_git_ancestor,
  single_file_support = true,
  settings = {
    -- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
    redhat = { telemetry = { enabled = false } },
  }
})

-- markdown
lspconfig.marksman.setup({
  on_attach = On_attach,
  cmd = { Tweaks.lsp.server_bin['marksman'] },
  filetypes = { 'markdown', 'telekasten', 'liquid' },
  root_dir = function(fname)
    local root_files = { '.marksman.toml' }
    return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
  end,
  single_file_support = true,
  capabilities = CGLOBALS.lsp_capabilities
})

-- xml
lspconfig.lemminx.setup({
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities,
  cmd = { Tweaks.lsp.server_bin['lemminx'] },
  filetypes = { 'xml', 'xsd', 'xsl', 'xslt', 'svg' },
  root_dir = util.find_git_ancestor,
  single_file_support = true
})

-- toml
lspconfig.taplo.setup({
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities,
  cmd = { Tweaks.lsp.server_bin['taplo'], 'lsp', 'stdio' },
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
  capabilities = CGLOBALS.lsp_capabilities,
  on_attach = On_attach,
  cmd = { Tweaks.lsp.server_bin['lua_ls'], '--logpath=' .. vim.fn.stdpath("state") },
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

lspconfig.groovyls.setup {
  capabilities = CGLOBALS.lsp_capabilities,
  on_attach = On_attach,
  cmd = { Tweaks.lsp.server_bin['groovy'] },
  filetypes = { 'groovy' },
  root_dir = function(fname)
    return util.root_pattern 'settings.gradle'(fname) or util.find_git_ancestor(fname)
  end
}

lspconfig.jsonls.setup {
  cmd = { Tweaks.lsp.server_bin[ "jsonls" ], "--stdio" },
  filetypes = { "json", "jsonc" },
  init_options = {
    provideFormatter = true,
  },
  root_dir = util.find_git_ancestor,
  single_file_support = true,
  on_attach = On_attach,
  capabilities = CGLOBALS.lsp_capabilities
}

vim.g.zig_fmt_parse_errors = 0
vim.g.zig_fmt_autosave = 0
lspconfig.zls.setup {
  on_attach = function(client, buf)
    On_attach(client, buf)
  end,
  cmd = { Tweaks.lsp.server_bin[ "zls" ] },
  on_new_config = function(new_config, new_root_dir)
    if vim.fn.filereadable(vim.fs.joinpath(new_root_dir, "zls.json")) ~= 0 then
      new_config.cmd = { "zls", "--config-path", "zls.json" }
    end
  end,
  filetypes = { "zig", "zir" },
  root_dir = util.root_pattern("zls.json", "build.zig", ".git"),
  single_file_support = true,
  capabilities = CGLOBALS.lsp_capabilities
}

lspconfig.neocmake.setup {
  cmd = { 'neocmakelsp', '--stdio' },
  filetypes = { 'cmake' },
  root_dir = function(fname)
    return util.root_pattern(unpack({ '.git', 'build', 'cmake' }))(fname)
  end,
  single_file_support = true,
  capabilities = CGLOBALS.lsp_capabilities
}

lspconfig.ctags_lsp.setup {
  cmd = { "ctags-lsp" },
  filetypes = { '*' },
  root_dir = function()
    return vim.fn.getcwd()
  end
}

require("lsp.cpp")        -- clangd (c/c++/objc)
require("lsp.basedpyright")
-- require("lsp.phpactor")   -- php (unused)
-- require("lsp.hls")        -- haskell (unused)
-- require("lsp.dartls")     -- dart/flutter (unused)

-- user-supplied lsp configurations
_, _ = pcall(require, "lsp.user")

require("lsp.config.handlers")
require("lsp.config.misc")

