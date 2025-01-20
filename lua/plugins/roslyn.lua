--- the following functions are necessary to support semantic tokens with the roslyn
--- language server.
--- this function works with current nightly (neovim-0.11)
local function monkey_patch_semantic_tokens_11(client)
    -- NOTE: Super hacky... Don't know if I like that we set a random variable on
    -- the client Seems to work though ~seblj
    if client.is_hacked then
        return
    end
    client.is_hacked = true

    -- let the runtime know the server can do semanticTokens/full now
    client.server_capabilities = vim.tbl_deep_extend("force", client.server_capabilities, {
        semanticTokensProvider = {
            full = true,
        },
    })

    -- monkey patch the request proxy
    local request_inner = client.request
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
end

--- and this is for neovim-0.10.
local function monkey_patch_semantic_tokens_10(client)
  if not client.is_hacked_roslyn then
    client.is_hacked_roslyn = true

    -- let the runtime know the server can do semanticTokens/full now
    if client.server_capabilities.semanticTokensProvider then
      client.server_capabilities = vim.tbl_deep_extend("force", client.server_capabilities, {
        semanticTokensProvider = {
          full = true,
        },
      })
    end

    -- -- monkey patch the request proxy
    local request_inner = client.request
    client.request = function(method, params, handler, req_bufnr)
      if method ~= vim.lsp.protocol.Methods.textDocument_semanticTokens_full then
        return request_inner(method, params, handler, req_bufnr)
      end

      local function find_buf_by_uri(search_uri)
        local bufs = vim.api.nvim_list_bufs()
        for _, buf in ipairs(bufs) do
          local name = vim.api.nvim_buf_get_name(buf)
          local uri = "file://" .. name
          if uri == search_uri then
            return buf
          end
        end
      end

      local doc_uri = params.textDocument.uri

      local target_bufnr = find_buf_by_uri(doc_uri)
      local line_count = vim.api.nvim_buf_line_count(target_bufnr)
      local last_line = vim.api.nvim_buf_get_lines(target_bufnr, line_count - 1, line_count,
        true)[1]

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
        },
        handler,
        req_bufnr
      )
    end
  end
end

local util = require 'lspconfig.util'
require("roslyn").setup({
  config = {
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    --handlers = require "rzls.roslyn_handlers",
    --the project root needs a .sln file (mandatory)
    root_dir = function(fname)
      return util.root_pattern "*.sln" (fname)
    end,
    on_attach = function(client, bufnr)
      require("nvim-navic").attach(client, bufnr)
      -- require("nvim-navbuddy").attach(client, bufnr)
      if vim.fn.has("nvim-0.11") == 1 then
        monkey_patch_semantic_tokens_11(client)
      else
        monkey_patch_semantic_tokens_10(client)
      end
    end,
  },
  roslyn_version = "4.13.0-3.25054.1",
  dotnet_cmd = "dotnet",
  exe = {
    "dotnet",
     vim.fs.joinpath(vim.fn.stdpath("data"), "roslyn", "Microsoft.CodeAnalysis.LanguageServer.dll"),
  },
  args = {
    "--logLevel=Information", "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path())
  },
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
