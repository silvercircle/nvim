local lspconfig = require("lspconfig")
local util = require 'lspconfig.util'

lspconfig.omnisharp.setup({
  on_attach = function(client, buf)
    On_attach(client, buf)
    -- client.server_capabilities.semanticTokensProvider = semantic_tokens_config()
  end,
  flags = {
    debounce_text_changes = 1000
  },
  settings = {
    FormattingOptions = {
      -- Enables support for reading code style, naming convention and analyzer
      -- settings from .editorconfig.
      EnableEditorConfigSupport = true,
      -- Specifies whether 'using' directives should be grouped and sorted during
      -- document formatting.
      OrganizeImports = nil,
    },
    MsBuild = {
      -- If true, MSBuild project system will only load projects for files that
      -- were opened in the editor. This setting is useful for big C# codebases
      -- and allows for faster initialization of code navigation features only
      -- for projects that are relevant to code that is being edited. With this
      -- setting enabled OmniSharp may load fewer projects and may thus display
      -- incomplete reference lists for symbols.
      LoadProjectsOnDemand = nil,
    },
    RoslynExtensionsOptions = {
      -- Enables support for roslyn analyzers, code fixes and rulesets.
      EnableAnalyzersSupport = true,
      -- Enables support for showing unimported types and unimported extension
      -- methods in completion lists. When committed, the appropriate using
      -- directive will be added at the top of the current file. This option can
      -- have a negative impact on initial completion responsiveness,
      -- particularly for the first few completion sessions after opening a
      -- solution.
      EnableImportCompletion = true,
      -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
      -- true
      AnalyzeOpenDocumentsOnly = nil,
    },
    Sdk = {
      -- Specifies whether to include preview versions of the .NET SDK when
      -- determining which version to use for project loading.
      IncludePrereleases = true,
    },
  },
  single_file_support = true,
  filetypes = { "cs", "vb" },
  root_dir = util.root_pattern('*.sln', '*.csproj', 'omnisharp.json', 'function.json'),
  on_new_config = function(new_config, new_root_dir)
    new_config.cmd = { vim.g.lsp_server_bin["omnisharp"] }
    table.insert(new_config.cmd, "-z") -- https://github.com/OmniSharp/omnisharp-vscode/pull/4300
    vim.list_extend(new_config.cmd, { "-s", new_root_dir })
    vim.list_extend(new_config.cmd, { "--hostPID", tostring(vim.fn.getpid()) })
    table.insert(new_config.cmd, "DotNet:enablePackageRestore=false")
    vim.list_extend(new_config.cmd, { "--encoding", "utf-8" })
    table.insert(new_config.cmd, "--languageserver")
    table.insert(new_config.cmd, "csharp.semanticHighlighting.enabled=true")
    table.insert(new_config.cmd, "FormattingOptions:EnableEditorConfigSupport=true")
    if new_config.organize_imports_on_format then
      table.insert(new_config.cmd, "FormattingOptions:OrganizeImports=true")
    end
    if new_config.enable_ms_build_load_projects_on_demand then
      table.insert(new_config.cmd, "MsBuild:LoadProjectsOnDemand=true")
    end
    table.insert(new_config.cmd, "RoslynExtensionsOptions:EnableAnalyzersSupport=true")
    table.insert(new_config.cmd, "RoslynExtensionsOptions:EnableImportCompletion=true")
    table.insert(new_config.cmd, "RoslynExtensionsOptions:AnalyzeOpenDocumentsOnly=false")
    table.insert(new_config.cmd, "RoslynExtensionsOptions:EnableDecompilationSupport=true")
    new_config.handlers = {
      ["textDocument/definition"] = require("omnisharp_extended").handler,
    }
    -- Append configuration-dependent command arguments
    local function flatten(tbl)
      local ret = {}
      for k, v in pairs(tbl) do
        if type(v) == "table" then
          for _, pair in ipairs(flatten(v)) do
            ret[#ret + 1] = k .. ":" .. pair
          end
        else
          ret[#ret + 1] = k .. "=" .. vim.inspect(v)
        end
      end
      return ret
    end
    if new_config.settings then
      vim.list_extend(new_config.cmd, flatten(new_config.settings))
    end

    local capabilities = __Globals.get_lsp_capabilities()
    new_config.capabilities = vim.deepcopy(capabilities)
    new_config.capabilities.workspace.workspaceFolders = false
  end,
  init_options = {}
})
