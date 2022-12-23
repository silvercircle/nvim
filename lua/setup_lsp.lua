-- set up lspconfig and mason

require("mason").setup()
require("mason-lspconfig").setup()
local lspconfig = require("lspconfig")
local util = require('lspconfig.util')

local capabilities = vim.lsp.protocol.make_client_capabilities()

if vim.g.features['cmp']['enable'] == true then
  local cmp_nvim_lsp = require("cmp_nvim_lsp")
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

if vim.g.features['coq']['enable'] == true then
  vim.g.coq_settings = {
    auto_start = 'shut-up',
    keymap = {
      recommended = true,
      jump_to_mark = "<c-,>"
    },
    completion = {
      always = true
    },
    limits = {
      completion_auto_timeout = 1000
    },
    clients = {
      paths = {
        path_seps = {
          "/"
        }
      },
      buffers = {
        match_syms = true
      }
    },
    display = {
      ghost_text = {
        enabled = true
      },
      pum = {
        fast_close = false
      }
    }
  }
  local coq = require('coq')
  vim.cmd('COQnow')
--  capabilities = coq.lsp_ensure_capabilities{}
end
-- Customize LSP behavior via on_attach
local on_attach = function(client, bufnr)
  -- Activate LSP signature on attach.
  -- on_attach_lsp_signature(client, bufnr)

  -- Disable specific LSP capabilities: see nvim-lspconfig#1891
  if client.name == "sumneko_lua" and client.server_capabilities then
    client.server_capabilities.documentFormattingProvider = false
  elseif client.name == 'omnisharp' and client.server_capabilities then
    client.server_capabilities.semanticTokensProvider = {}
  end
end

lspconfig.tsserver.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.texlab.setup({ on_attach = on_attach })
lspconfig.nimls.setup({ on_attach = on_attach })
lspconfig.clangd.setup({ on_attach = on_attach })
lspconfig.dartls.setup({ on_attach = on_attach })
lspconfig.rust_analyzer.setup({ on_attach = on_attach })
lspconfig.cssls.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.html.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.phpactor.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.gopls.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.vimls.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.jdtls.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.serve_d.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.omnisharp.setup({ on_attach = on_attach,
   -- Enables support for reading code style, naming convention and analyzer
    -- settings from .editorconfig.
  enable_editorconfig_support = true,

    -- If true, MSBuild project system will only load projects for files that
    -- were opened in the editor. This setting is useful for big C# codebases
    -- and allows for faster initialization of code navigation features only
    -- for projects that are relevant to code that is being edited. With this
    -- setting enabled OmniSharp may load fewer projects and may thus display
    -- incomplete reference lists for symbols.
  enable_ms_build_load_projects_on_demand = false,

    -- Enables support for roslyn analyzers, code fixes and rulesets.
  enable_roslyn_analyzers = true,

    -- Specifies whether 'using' directives should be grouped and sorted during
    -- document formatting.
  organize_imports_on_format = false,

    -- Enables support for showing unimported types and unimported extension
    -- methods in completion lists. When committed, the appropriate using
    -- directive will be added at the top of the current file. This option can
    -- have a negative impact on initial completion responsiveness,
    -- particularly for the first few completion sessions after opening a
    -- solution.
  enable_import_completion = false,

    -- Specifies whether to include preview versions of the .NET SDK when
    -- determining which version to use for project loading.
  sdk_include_prereleases = true,

    -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
    -- true
  analyze_open_documents_only = false,

  filetypes = { 'cs', 'vb' },
  root_dir = function(fname)
    return util.root_pattern '*.sln'(fname) or util.root_pattern '*.csproj'(fname)
  end,
  on_new_config = function(new_config, new_root_dir)
    new_config.cmd = { "omnisharp" }
    table.insert(new_config.cmd, '-z') -- https://github.com/OmniSharp/omnisharp-vscode/pull/4300
    vim.list_extend(new_config.cmd, { '-s', new_root_dir })
    vim.list_extend(new_config.cmd, { '--hostPID', tostring(vim.fn.getpid()) })
    table.insert(new_config.cmd, 'DotNet:enablePackageRestore=false')
    vim.list_extend(new_config.cmd, { '--encoding', 'utf-8' })
    table.insert(new_config.cmd, '--languageserver')
    table.insert(new_config.cmd, 'csharp.semanticHighlighting.enabled=false')
    table.insert(new_config.cmd, 'FormattingOptions:EnableEditorConfigSupport=true')
    if new_config.organize_imports_on_format then
      table.insert(new_config.cmd, 'FormattingOptions:OrganizeImports=true')
    end
    if new_config.enable_ms_build_load_projects_on_demand then
      table.insert(new_config.cmd, 'MsBuild:LoadProjectsOnDemand=true')
    end
    if new_config.enable_roslyn_analyzers then
      table.insert(new_config.cmd, 'RoslynExtensionsOptions:EnableAnalyzersSupport=true')
    end
    if new_config.enable_import_completion then
      table.insert(new_config.cmd, 'RoslynExtensionsOptions:EnableImportCompletion=true')
    end
    if new_config.sdk_include_prereleases then
      table.insert(new_config.cmd, 'Sdk:IncludePrereleases=true')
    end
    if new_config.analyze_open_documents_only then
      table.insert(new_config.cmd, 'RoslynExtensionsOptions:AnalyzeOpenDocumentsOnly=true')
    end
  end,
  init_options = {}
})
lspconfig.metals.setup({
  cmd = { '/home/alex/.local/share/coursier/bin/metals' },
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
lspconfig.pyright.setup({ on_attach = on_attach })
lspconfig.sumneko_lua.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
  end,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      runtime = {
        version = "LuaJIT", -- Lua 5.1/LuaJIT
      },
      completion = { callSnippet = "Disable" },
      workspace = {
        maxPreload = 8000,
        -- Add additional paths for lua packages
        library = (function()
          local library = {}
          if vim.fn.has("mac") > 0 then
            -- http://www.hammerspoon.org/Spoons/EmmyLua.html
            -- Add a line `hs.loadSpoon('EmmyLua')` on the top in ~/.hammerspoon/init.lua
            library[string.format("%s/.hammerspoon/Spoons/EmmyLua.spoon/annotations", os.getenv("HOME"))] = true
          end
          return library
        end)(),
      },
    },
  },
}

-------------------------
-- LSP Handlers (general)
-------------------------

do
  -- :help lsp-method
  -- :help lsp-handler
  -- :help lsp-handler-configuration
  local lsp_handlers_hover = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "single",
  })

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
    --see ~/.vim/plugged/fidget.nvim/lua/fidget/spinners.lua
    spinner = "zip",
  },
  window = {
    relative = "win",
    blend = 50,
  },
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
    enable = true, -- Will generate colors for the plugin based on your current colorscheme
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