local lspconfig = require("lspconfig")
local util = require('lspconfig.util')
local navic
if vim.g.config.use_winbar == true then
  navic = require('nvim-navic')
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
--local cmp_nvim_lsp = require("cmp_nvim_lsp")
--capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

-- capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true

-- Customize LSP behavior via on_attach
local on_attach = function(client, bufnr)
  if vim.g.config.use_winbar == true then
    navic.attach(client, bufnr)
  end
  if client.name == 'marksman' then
-- disable semantic tokens, might be buggy with some LSP servers
    client.server_capabilities.semanticTokensProvider = {}
  end
  if client.name == 'gopls' then
    print("set semantic for gopls")
    client.server_capabilities.semanticTokensProvider = {
      full = true,
      legend = {
        tokenTypes = { 'namespace', 'type', 'class', 'enum', 'interface', 'struct', 'typeParameter', 'parameter', 'variable', 'property', 'enumMember', 'event', 'function', 'method', 'macro', 'keyword', 'modifier', 'comment', 'string', 'number', 'regexp', 'operator', 'decorator' },
        tokenModifiers = { 'declaration', 'definition', 'readonly', 'static', 'deprecated', 'abstract', 'async', 'modification', 'documentation', 'defaultLibrary'}
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
      'typescript.tsx',
  },
  root_dir = function(fname)
    return util.root_pattern 'tsconfig.json'(fname) or util.root_pattern('package.json', 'jsconfig.json', '.git')(fname)
  end,
  on_attach = on_attach,
  capabilities = capabilities
})

lspconfig.texlab.setup({
  cmd = { vim.g.lsp_server_bin['texlab'] },
  on_attach = on_attach,
  capabilities = capabilities
})

lspconfig.nimls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { vim.g.lsp_server_bin['nimls'] },
  filetypes = { 'nim' },
  root_dir = function(fname)
    return util.root_pattern '*.nimble'(fname) or util.find_git_ancestor(fname)
  end,
  single_file_support = true
})

lspconfig.clangd.setup({
  cmd = { 'clangd', "--header-insertion-decorators" },
  on_attach = on_attach,
  capabilities = capabilities
})

lspconfig.als.setup({
  on_attach = on_attach,
  cmd = { vim.g.lsp_server_bin['als'] },
  filetypes = { 'ada' },
  root_dir = util.root_pattern('Makefile', '.git', '*.gpr', '*.adc'),
--  settings = {
--    ada = {
--      projectFile = "project.gpr"
--    }
--  }
})

lspconfig.dartls.setup({
  cmd = { vim.g.lsp_server_bin['dartls'], 'language-server', '--protocol=lsp' },
  on_attach = on_attach,
  filetypes = { 'dart' },
  root_dir = util.root_pattern 'pubspec.yaml',
  init_options = {
    onlyAnalyzeProjectsWithOpenFiles = true,
    suggestFromUnimportedLibraries = true,
    closingLabels = true,
    outline = true,
    flutterOutline = true,
  },
  settings = {
    dart = {
      completeFunctionCalls = true,
      showTodos = true,
    }
  }
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
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { 'rust' },
  root_dir = function(fname)
    local cargo_crate_dir = util.root_pattern 'Cargo.toml'(fname)
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
      or util.root_pattern 'rust-project.json'(fname)
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

lspconfig.cssls.setup({
  cmd = { vim.g.lsp_server_bin['cssls'], '--stdio' },
  on_attach = on_attach,
  capabilities = capabilities
})

lspconfig.html.setup({
  cmd = { vim.g.lsp_server_bin['html'], '--stdio' },
  filetypes = { 'html', 'xhtml', 'liquid' },
  root_dir = util.root_pattern('package.json', '.git'),
  single_file_support = true,
  settings = {},
  init_options = {
    provideFormatter = false,
    embeddedLanguages = { css = true, javascript = true },
    configurationSection = { 'html', 'css', 'javascript' },
  },
  on_attach = on_attach,
  capabilities = capabilities
})

lspconfig.phpactor.setup({
  cmd = { vim.g.lsp_server_bin['phpactor'], 'language-server' },
  filetypes = { 'php' },
  root_dir = function(pattern)
      local cwd = vim.loop.cwd()
      local root = util.root_pattern('composer.json', '.git')(pattern)

      -- prefer cwd if root is a descendant
      return util.path.is_descendant(cwd, root) and cwd or root
  end,
  on_attach = on_attach,
  capabilities = capabilities
})

lspconfig.gopls.setup({
  on_attach = on_attach,
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
    return util.root_pattern 'go.work'(fname) or util.root_pattern('go.mod', '.git')(fname)
  end
})

lspconfig.vimls.setup({
  cmd = { vim.g.lsp_server_bin['vimlsp'], '--stdio' },
  on_attach = on_attach,
  capabilities = capabilities
})

lspconfig.serve_d.setup({
  cmd = { vim.g.lsp_server_bin['serve_d'] },
  on_attach = on_attach,
  capabilities = capabilities
})

lspconfig.yamlls.setup({
  on_attach = on_attach,
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

lspconfig.csharp_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { vim.g.lsp_server_bin['csharp_ls'] },
    root_dir = util.root_pattern('*.sln', '*.csproj', '*.fsproj', '.git'),
    filetypes = { 'cs' },
    init_options = {
      AutomaticWorkspaceInit = true,
    }
})

-- metals = scala language server.
lspconfig.metals.setup({
  on_attach = on_attach,
  cmd = { vim.g.lsp_server_bin['metals'] },
  filetypes = { 'scala' },
  root_dir = util.root_pattern('build.sbt', 'build.sc', 'build.gradle', 'pom.xml'),
  message_level = vim.lsp.protocol.MessageType.Error,
  init_options = {
    statusBarProvider = 'show-message',
    isHttpEnabled = true,
    compilerOptions = {
      snippetAutoIndent = false,
    },
  },
  capabilities = {
    workspace = {
      configuration = false,
    },
  },
})

-- python pyright
lspconfig.pyright.setup({
  cmd = { vim.g.lsp_server_bin['pyright'], '--stdio' },
  on_attach = on_attach,
  capabilities = capabilities
})

lspconfig.marksman.setup({
  on_attach = on_attach,
  cmd ={ vim.g.lsp_server_bin['marksman'] },
  filetypes = { 'markdown', 'telekasten' },
  root_dir = function(fname)
    local root_files = { '.marksman.toml' }
    return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
  end,
  single_file_support = true,
  capabilities = capabilities
})

lspconfig.lemminx.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { vim.g.lsp_server_bin['lemminx'] },
  filetypes = { 'xml', 'xsd', 'xsl', 'xslt', 'svg' },
  root_dir = util.find_git_ancestor,
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
  on_attach = on_attach,
  cmd = { vim.g.lsp_server_bin['lua_ls'], '--logpath=' .. vim.fn.stdpath("state") },
  root_dir = function(fname)
    local root = util.root_pattern(unpack(lua_root_files))(fname)
    if root and root ~= vim.env.HOME then
      return root
    end
    root = util.root_pattern 'lua/'(fname)
    if root then
      return root .. '/lua/'
    end
    return util.find_git_ancestor(fname)
  end,
  single_file_support = true,
  log_level = vim.lsp.protocol.MessageType.Warning,
  -- new_folder_restart = true,
  --handlers = {
  --  ['workspace/diagnostic/refresh'] = on_diagnostic_refresh
  --},
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      hint = {
        enable = true
      },
      --workspace = {
      --  -- Make the server aware of Neovim runtime files
      --  library = vim.api.nvim_get_runtime_file("", true),
      --},
      runtime = {
        version = "LuaJIT", -- Lua 5.1/LuaJIT
      },
      telemetry = {
        enable = false
      }
    }
  }
}

-- outsourced because it's too big
require("lsp.jdtls")

-- require("lsp.omnisharp")
-- require("lsp.hls")      -- hls (haskell)
-------------------------
-- LSP Handlers (general)
-------------------------

do
  local on_references = vim.lsp.handlers["textDocument/references"]
  local lsp_handlers_hover = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "single",
  })
  vim.lsp.handlers['workspace/diagnostic/refresh'] = function(_, _, ctx)
    local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.diagnostic.reset(ns, bufnr)
    return true
  end
  vim.lsp.handlers["textDocument/references"] = vim.lsp.with(
    on_references, {
      -- loclist = true,
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
      border = "single",
      focusable = false
    })
end


------------------
-- LSP diagnostics
------------------
if vim.diagnostic then
  vim.diagnostic.config({
    -- No virtual text (distracting!), show popup window on hover.
    virtual_text = false,
    underline = {
      -- Do not underline text when severity is low (INFO or HINT).
      severity = { min = vim.diagnostic.severity.WARN },
    },
    float = {
      source = "always",
      focusable = true,
      focus = false,
      border = "single",
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

-- Redefine signs (:help diagnostic-signs)

do
  vim.fn.sign_define("DiagnosticSignError", { text = "✘", texthl = "DiagnosticSignError" })
  vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
  vim.fn.sign_define("DiagnosticSignInfo", { text = "◉", texthl = "DiagnosticSignInfo" })
  vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })
  vim.cmd([[
    hi DiagnosticSignError    guifg=#e6645f ctermfg=167
    hi DiagnosticSignWarn     guifg=#b1b14d ctermfg=143
    hi DiagnosticSignHint     guifg=#3e6e9e ctermfg=75
  ]])
end

-- Commands for temporarily turning on and off diagnostics (for the current buffer or globally)
do
  vim.cmd([[
    command! DiagnosticsDisable     :lua vim.diagnostic.disable(0)
    command! DiagnosticsEnable      :lua vim.diagnostic.enable(0)
    command! DiagnosticsDisableAll  :lua vim.diagnostic.disable()
    command! DiagnosticsEnableAll   :lua vim.diagnostic.enable()
  ]])
end

-- Fidget.nvim (LSP status widget)
require("fidget").setup({
  text = {
    spinner = "zip",
  },
  window = {
    relative = "win",
    blend = 100
  },
  timer = {
    spinner_rate = 500
  }
})

local glance = require("glance")
local actions = glance.actions
glance.setup({
  height = 30, -- Height of the window
  border = {
    enable = true, -- Show window borders. Only horizontal borders allowed
    top_char = "—",
    bottom_char = "—",
  },
  preview_win_opts = { -- Configure preview window options
    cursorline = true,
    number = true,
    wrap = false,
    foldcolumn = "0",
  },
  list = {
    position = "right", -- Position of the list window 'left'|'right'
    width = 0.25, -- 33% width relative to the active window, min 0.1, max 0.5
  },
  theme = { -- This feature might not work properly in nvim-0.7.2
    enable = false, -- Will generate colors for the plugin based on your current colorscheme
    mode = "darken", -- 'brighten'|'darken'|'auto', 'auto' will set mode based on the brightness of your colorscheme
  },
  mappings = {
    list = {
      ["j"] = actions.next, -- Bring the cursor to the next item in the list
      ["k"] = actions.previous, -- Bring the cursor to the previous item in the list
      ["<Down>"] = actions.next,
      ["<Up>"] = actions.previous,
      ["<Tab>"] = actions.next_location, -- Bring the cursor to the next location skipping groups in the list
      ["<S-Tab>"] = actions.previous_location, -- Bring the cursor to the previous location skipping groups in the list
      ["<C-u>"] = actions.preview_scroll_win(5),
      ["<C-d>"] = actions.preview_scroll_win(-5),
      ["v"] = actions.jump_vsplit,
      ["s"] = actions.jump_split,
      ["t"] = actions.jump_tab,
      ["<CR>"] = actions.jump,
      ["o"] = actions.jump,
      ["<A-Left>"] = actions.enter_win("preview"), -- Focus preview window
      ["q"] = actions.close,
      ["Q"] = actions.close,
      ["<Esc>"] = actions.close,
    },
    preview = {
      ["Q"] = actions.close,
      ["<Tab>"] = actions.next_location,
      ["<S-Tab>"] = actions.previous_location,
      ["<A-Right>"] = actions.enter_win("list"), -- Focus list window
    },
  },
  folds = {
    fold_closed = "",
    fold_open = "",
    folded = true, -- Automatically fold list on startup
  },
  indent_lines = {
    enable = true,
    icon = "│",
  },
  winbar = {
    enable = true, -- Available strating from nvim-0.8+
  },
})

if vim.g.config.neodev == true then
  require("neodev").setup({})
end

vim.diagnostic.config({ virtual_text = true })

