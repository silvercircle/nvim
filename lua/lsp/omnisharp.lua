local lspconfig = require("lspconfig")
local util = require 'lspconfig.util'

lspconfig.omnisharp.setup({
   -- Enables support for reading code style, naming convention and analyzer
    -- settings from .editorconfig.
  on_attach = function(client, _)
    client.server_capabilities.semanticTokensProvider = {
      full = vim.empty_dict(),
      legend = {
        tokenModifiers = { "static" },
        tokenTypes = vim.empty_dict(),
        --tokenTypes = {
        --  "comment",
        --  "excluded_code",
        --  "identifier",
        --  "keyword",
        --  "keyword_control",
        --  "number",
        --  "operator",
        --  "operator_overloaded",
        --  "preprocessor_keyword",
        --  "string",
        --  "whitespace",
        --  "text",
        --  "static_symbol",
        --  "preprocessor_text",
        --  "punctuation",
        --  "string_verbatim",
        --  "string_escape_character",
        --  "class_name",
        --  "delegate_name",
        --  "enum_name",
        --  "interface_name",
        --  "module_name",
        --  "struct_name",
        --  "type_parameter_name",
        --  "field_name",
        --  "enum_member_name",
        --  "constant_name",
        --  "local_name",
        --  "parameter_name",
        --  "method_name",
        --  "extension_method_name",
        --  "property_name",
        --  "event_name",
        --  "namespace_name",
        --  "label_name",
        --  "xml_doc_comment_attribute_name",
        --  "xml_doc_comment_attribute_quotes",
        --  "xml_doc_comment_attribute_value",
        --  "xml_doc_comment_cdata_section",
        --  "xml_doc_comment_comment",
        --  "xml_doc_comment_delimiter",
        --  "xml_doc_comment_entity_reference",
        --  "xml_doc_comment_name",
        --  "xml_doc_comment_processing_instruction",
        --  "xml_doc_comment_text",
        --  "xml_literal_attribute_name",
        --  "xml_literal_attribute_quotes",
        --  "xml_literal_attribute_value",
        --  "xml_literal_cdata_section",
        --  "xml_literal_comment",
        --  "xml_literal_delimiter",
        --  "xml_literal_embedded_expression",
        --  "xml_literal_entity_reference",
        --  "xml_literal_name",
        --  "xml_literal_processing_instruction",
        --  "xml_literal_text",
        --  "regex_comment",
        --  "regex_character_class",
        --  "regex_anchor",
        --  "regex_quantifier",
        --  "regex_grouping",
        --  "regex_alternation",
        --  "regex_text",
        --  "regex_self_escaped_character",
        --  "regex_other_escape",
        --}
      },
      range = false
    }
  end,
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
    new_config.cmd = { vim.g.lsp_server_bin['omnisharp'] }
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
    table.insert(new_config.cmd, 'RoslynExtensionsOptions:EnableDecompilationSupport=true')
    new_config.handlers = {
      ["textDocument/definition"] = require('omnisharp_extended').handler,
    }
    new_config.capabilities = __Globals.get_lsp_capabilities()
  end,
  init_options = {}
})


