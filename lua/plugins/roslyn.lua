require("roslyn").setup({
  filewatching = "off",
  vim.lsp.config("roslyn", {
    cmd = { "dotnet", LSPDEF.server_bin["roslyn"],
      "--stdio",
      "--logLevel=Information",
      "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.log.get_filename()),
      "--razorSourceGenerator=" .. LSPDEF.roslyn.razor_compiler,
      "--razorDesignTimePath=" ..  LSPDEF.roslyn.razor_designer,
      "--extension",
      LSPDEF.roslyn.razor_extension
    },
    filetypes = { "cs", "razor" },
    capabilities = require("lsp.config").get_lsp_capabilities(),
    -- handlers = require "rzls.roslyn_handlers",
    --the project root needs a .sln file (mandatory)
    root_markers = { ".sln "},
    on_attach = ON_LSP_ATTACH,
    settings = {
      ["csharp|background_analysis"] = {
        dotnet_analyzer_diagnostics_scope = "fullSolution",
        dotnet_compiler_diagnostics_scope = "fullSolution"
      },
      ["csharp|inlay_hints"] = {
        csharp_enable_inlay_hints_for_implicit_object_creation = true,
        csharp_enable_inlay_hints_for_implicit_variable_types = true,
        csharp_enable_inlay_hints_for_lambda_parameter_types = true,
        csharp_enable_inlay_hints_for_types = true,
        dotnet_enable_inlay_hints_for_indexer_parameters = true,
        dotnet_enable_inlay_hints_for_literal_parameters = true,
        dotnet_enable_inlay_hints_for_object_creation_parameters = true,
        dotnet_enable_inlay_hints_for_other_parameters = true,
        dotnet_enable_inlay_hints_for_parameters = true,
        dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
        dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
        dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
      },
      ["csharp|code_lens"] = {
        dotnet_enable_references_code_lens = true,
      }
    }
  })
})
