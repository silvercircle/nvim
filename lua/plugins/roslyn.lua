local util = require 'lspconfig.util'

--- the following functions are necessary to support semantic tokens with the roslyn
--- language server.

--- reference: https://github.com/seblyng/roslyn.nvim/wiki#semantic-tokens
--- this function should work with 0.10 and 0.11 of Neovim
local function fix_semantic_tokens(client)
  if client.is_patched then
    return
  end
  client.is_patched = true

  -- let the runtime know the server can do semanticTokens/full now
  client.server_capabilities = vim.tbl_deep_extend("force", client.server_capabilities, {
    semanticTokensProvider = {
      full = true,
    },
  })

  -- monkey patch the request proxy
  local request_inner = client.request

  if vim.fn.has("nvim-0.11") == 1 then
    function client:request(method, params, handler, req_bufnr)
      if method ~= vim.lsp.protocol.Methods.textDocument_semanticTokens_full then
        return request_inner(self, method, params, handler)
      end

      local target_bufnr = vim.uri_to_bufnr(params.textDocument.uri)
      local line_count = vim.api.nvim_buf_line_count(target_bufnr)
      local last_line = vim.api.nvim_buf_get_lines(target_bufnr, line_count - 1, line_count, true)[1]

      return request_inner(self, "textDocument/semanticTokens/range", {
        textDocument = params.textDocument,
        range = {
          ["start"] = {
            line = 0,
            character = 0,
          },
          ["end"] = {
            line = line_count - 1,
            character = string.len(last_line) - 1,
          },
        },
      }, handler, req_bufnr)
    end
  else
    client.request = function(method, params, handler, req_bufnr)
      if method ~= vim.lsp.protocol.Methods.textDocument_semanticTokens_full then
        return request_inner(method, params, handler, req_bufnr)
      end

      --local target_bufnr = find_buf_by_uri(params.textDocument.uri)
      local target_bufnr = vim.uri_to_bufnr(params.textDocument.uri)
      local line_count = vim.api.nvim_buf_line_count(target_bufnr)
      local last_line = vim.api.nvim_buf_get_lines(target_bufnr, line_count - 1, line_count, true)[1]

      return request_inner("textDocument/semanticTokens/range", {
        textDocument = params.textDocument,
        range = {
          ["start"] = {
            line = 0,
            character = 0,
          },
          ["end"] = {
            line = line_count - 1,
            character = string.len(last_line) - 1,
          },
        },
      }, handler, req_bufnr)
    end
  end
end

local on_attach = function(client, buf)
  local _s, navic = pcall(require, "nvim-navic")
  if _s then
    navic.attach(client, buf)
  end
  if client.server_capabilities.inlayHintProvider then
    vim.g.inlay_hints_visible = true
    vim.lsp.inlay_hint.enable(false)
  end
  if client.name == "rzls" then
    vim.cmd("hi! link @lsp.type.field Member")
  end
  fix_semantic_tokens(client)
end

require("roslyn").setup({
  config = {
    filetypes = { "cs", "razor" },
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    handlers = require "rzls.roslyn_handlers",
    --the project root needs a .sln file (mandatory)
    root_dir = function(fname)
      return util.root_pattern "*.sln" (fname)
    end,
    on_attach = on_attach,
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
  },
  roslyn_version = "4.14.0-3.25054.1",
  dotnet_cmd = "dotnet",
  exe = {
    "dotnet",
     vim.fs.joinpath(vim.fn.stdpath("data"), "roslyn", "Microsoft.CodeAnalysis.LanguageServer.dll"),
  },
  args = {
    "--stdio",
    "--logLevel=Information",
    "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
    "--razorSourceGenerator=" .. vim.fs.joinpath(
      vim.fn.stdpath('data'),
      -- 'mason',
      -- 'packages',
      'roslyn',
      'Microsoft.CodeAnalysis.Razor.Compiler.dll'
    ),
    "--razorDesignTimePath=" .. vim.fs.joinpath(
      vim.fn.stdpath('data'),
      'mason',
      'packages',
      'rzls',
      'libexec',
      'Targets',
      'Microsoft.NET.Sdk.Razor.DesignTime.targets'
    )
  },
})
