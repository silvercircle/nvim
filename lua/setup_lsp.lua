-- set up lspconfig, lsp-installer, null-ls and cmp
require("mason").setup()
require("mason-lspconfig").setup()
local lspconfig = require("lspconfig")
local util = require('lspconfig.util')
if vim.g.config_neodev then
  require("neodev").setup({ })
end

local cmp_nvim_lsp = require("cmp_nvim_lsp")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

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

---------------------------------
-- nvim-cmp: completion support
---------------------------------
-- https://github.com/hrsh7th/nvim-cmp#recommended-configuration
-- ~/.vim/plugged/nvim-cmp/lua/cmp/config/default.lua

vim.opt.completeopt = { "menu", "menuone", "noselect" }

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local luasnip = require("luasnip")
local cmp = require("cmp")
-- local cmp_helper = {}
local cmp_types = require("cmp.types.cmp")
local max_abbr_item_width = 40
local max_detail_item_width = 40
local lspkind = require("lspkind")

-- See ~/.vim/plugged/nvim-cmp/lua/cmp/config/default.lua
cmp.setup({
  completion = {
    --autocomplete = false,
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  window = {
    documentation = {
      -- border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }, a rounded
      -- variant
      border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" }, -- square
    },
    completion = {
      border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
      winhighlight = "Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None",
    },
  },
  mapping = {
    -- See ~/.vim/plugged/nvim-cmp/lua/cmp/config/mapping.lua
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
--    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete({
        reason = cmp.ContextReason.Auto,
      }), {"i", "c"}),
    ["<C-y>"] = cmp.config.disable,
    ["<Esc>"] = cmp.mapping.close(), -- ESC close complete popup. Feels more natural than <C-e>
    ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp_types.SelectBehavior.Select }),
    ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp_types.SelectBehavior.Select }),
    --    ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp_types.SelectBehavior.Insert }),
    --    ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp_types.SelectBehavior.Insert }),
    ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
    ["<Tab>"] = { -- see GH-880, GH-897
      i = function(fallback) -- see GH-231, GH-286
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end,
    },
    ["<S-Tab>"] = {
      i = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
        else
          fallback()
        end
      end,
    },
  },
  formatting = {
    format = function(entry, vim_item)
      -- Truncate the item if it is too long
      vim_item.abbr = Truncate(vim_item.abbr, max_abbr_item_width)
      -- fancy icons and a name of kind
      vim_item.kind_symbol = (lspkind.symbolic or lspkind.get_symbol)(vim_item.kind)
      vim_item.kind = " " .. vim_item.kind_symbol .. " " .. vim_item.kind
      -- The 'menu' section: source, detail information (lsp, snippet), etc.
      -- set a name for each source (see the sources section below)
      vim_item.menu = ({
        buffer = "Buffer",
        nvim_lsp = "LSP",
        nvim_lua = "Lua",
        latex_symbols = "Latex",
      })[entry.source.name] or string.format("%s", entry.source.name)

      -- highlight groups for item.menu
      vim_item.menu_hl_group = ({
        buffer = "CmpItemMenuBuffer",
        nvim_lsp = "CmpItemMenuLSP",
        path = "CmpItemMenuPath",
      })[entry.source.name] -- default is CmpItemMenu
      -- detail information (optional)
      local cmp_item = entry:get_completion_item()

      if entry.source.name == "nvim_lsp" then
        -- Display which LSP servers this item came from.
        local lspserver_name = nil
        pcall(function()
          lspserver_name = entry.source.source.client.name
          vim_item.menu = lspserver_name
        end)

        -- Some language servers provide details, e.g. type information.
        -- The details info hide the name of lsp server, but mostly we'll have one LSP
        -- per filetype, and we use special highlights so it's OK to hide it..
        local detail_txt = (function(cmp_item)
          if not cmp_item.detail then
            return nil
          end

          if lspserver_name == "pyright" and cmp_item.detail == "Auto-import" then
            local label = (cmp_item.labelDetails or {}).description
            return label and (" " .. Truncate(label, 20)) or nil
          else
            return Truncate(cmp_item.detail, max_detail_item_width)
          end
        end)(cmp_item)
        if detail_txt then
          vim_item.menu = detail_txt
          vim_item.menu_hl_group = "CmpItemMenuDetail"
        end
      end

      -- Add a little bit more padding
      vim_item.menu = " " .. vim_item.menu
      return vim_item
    end,
  },
  sources = {
    -- Note: make sure you have proper plugins specified in plugins.vim
    -- https://github.com/topics/nvim-cmp
    { name = "nvim_lsp", priority = 100, keyword_length = 1, max_item_count = 40 },
    { name = "path", priority = 30 },
--    {
--      name = "buffer",
--      priority = 10,
--      keyword_length = 3,
--      max_item_count = 20,
--      option = {
--        indexing_interval = 300,
--        indexing_batchsize = 1000,
--        max_indexed_line_length = 160,
--        keyword_pattern = [[\k\+]],
--      },
--    },
    { name = "luasnip", priority = 120, keyword_length = 3 },
    { name = "nvim_lsp_signature_help", priority = 110, keyword_length = 2 },
    { name = 'emoji', priority = 120, keyword_length = 2 }  -- cmp-emoji source
  },
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
--      function(...)
--        return cmp_helper.compare.prioritize_argument(...)
--      end,
--      function(...)
--        return cmp_helper.compare.deprioritize_underscore(...)
--      end,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order
    }
  }
})

-- Command line completion
cmp.setup.cmdline("/", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = { { name = "buffer" } },
})

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
})

-- null-ls: Linting, diagnostics, formatting etc.
if vim.g.config_null_ls == true then
  -- vim.cmd([[ PackerLoad null-ls.nvim ]])
  local null_ls = require("null-ls")
  null_ls.setup({
   -- the external tools must be installed separately. see comments
    -- to verify they are working: checkhealth null-ls
    sources = {
      -- lua
      null_ls.builtins.formatting.stylua, -- cargo install stylua (rust dev environment needed)
      -- but binaries available
      -- python
      null_ls.builtins.formatting.autopep8, -- autopep8 via pip
      null_ls.builtins.diagnostics.flake8, -- flake8 via pip
      -- null_ls.builtins.diagnostics.pylint, -- pylint via pip, disabled
      -- because sometimes annoyingly slow
      -- js, css, HTML, json etc.
      null_ls.builtins.formatting.prettier.with({ disabled_filetypes = { 'markdown', 'markdown.mdx' }}), -- npm install -g prettier
      -- astyle (artistic style): C/CPP, ObjC, Java, C#
      -- null_ls.builtins.formatting.astyle, -- astyle package (fedora, Ubuntu etc)
      -- clang_format
      -- null_ls.builtins.formatting.clang_format.with({ extra_args={"--style", "file" } })
    },
  })
  -- set up some custom commands (formatting, diagnostics)
  -- needs null-ls
  do
    vim.cmd([[
     command! LspFormatDoc :lua vim.lsp.buf.format()
     command! -range LspFormatRange :lua vim.lsp.buf.format( {range={}} )
    ]])
  end
end

if vim.g.config_lspsaga then
  require('lspsaga').init_lsp_saga({
    code_action_lightbulb = { enable = false },
    show_outline = {
      win_width=36,
      auto_refresh = true,
      auto_preview = false
    }
  })
end