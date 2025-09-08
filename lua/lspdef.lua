-- this is the main anchor for lsp server configuration. If you want to personalize this,
-- make a copy and name it lspdef_user.lua. If this exists (in the same directory as this 
-- lspdef.lua file), it will be used instead and you will not lose your settings when updating
-- this file via git.
local jp = vim.fs.joinpath

local M = {}

-- these non-standard paths are known and can be used for lsp binaries. All standard paths
-- like /usr/bin, /usr/local/bin would also work

-- you can add your own paths as needed, use vim.fs.joinpath() to construct them
-- in os-agnostic ways. Remember, on Windows you need to double-escape the \ or just
-- use / instead (it will be normalized automatically)
M.masonbasepath   = jp(vim.fn.stdpath('data'), 'mason/')
M.masonbinpath    = jp(M.masonbasepath, 'bin/')
M.homepath        = vim.fn.getenv('HOME')
M.localbin        = jp(M.homepath, '.local/bin/')

-- binaries for external LSP plugins not covered by lspconfig
M.server_bin = {
  metals        =   '$HOME/.local/share/coursier/bin/metals',
  roslyn        =   jp(M.masonbasepath, "packages/roslyn/libexec/Microsoft.CodeAnalysis.LanguageServer.dll"),
}

-- exceptions:
-- the language servers for Java (jdtls), C# (roslyn) and Scala (metal) are NOT
-- covered by this. They have dedicated plugins with more complex configurations.
-- see: ftplugin/java.lua for Java support
--      plugins/roslyn.lua for C#/Razor support
--      Scala is implemented as filetype autocommand.

-- cmd follows the rules for LSP server configurations. It's a list of strings, the
-- first element must be the executable of the language server. Unless it can be found
-- in your $PATH, a full path must be given. The remaining entries of cmd will be passed
-- as command line args to the LSP
M.serverconfigs = {
  ["ts_ls"]                 = { active = false,
    cmd = { jp(M.masonbinpath, 'typescript-language-server') }
  },
  ["vtsls"]                 = { active = true,
    cmd = { jp(M.masonbinpath, 'vtsls'), '--stdio' }
  },
  ["texlab"]                = { active = true,
    cmd = { jp(M.localbin, 'texlab') }
  },
  ["tinymist"]              = { active = true,
    cmd = { jp(M.localbin, "tinymist") },
    attach_config = function(client, _)
      client.server_capabilities.semanticTokensProvider = {
        full = false,
        legend = false
      }
    end
  },
  ["bashls"]                = { active = true,
    cmd = { jp(M.masonbinpath, 'bash-language-server') }
  },
  ["clangd"]                = { active = true,
    cmd = { "clangd", "--background-index", "--malloc-trim",
            "--pch-storage=memory", "--log=error", "--header-insertion=never",
            "--completion-style=detailed", "--function-arg-placeholders=1",
            "--inlay-hints=true" }
  },
  ["ccls"]                = { active = false,
    cmd = { "ccls" }
  },
  ["ada_ls"]                = { active = false,
    cmd = { jp(M.masonbinpath, 'ada_language_server') }
  },
  ["emmet_language_server"] = { active = true,
    cmd = { jp(M.masonbinpath, 'emmet-language-server') }
  },
  ["cssls"]                 = { active = true,
    cmd = { jp(M.masonbinpath, 'vscode-css-language-server') }
  },
  ["html"]                  = { active = true,
    cmd = { jp(M.masonbinpath, 'vscode-html-language-server') }
  },
  ["gopls"]                 = { active = true,
    cmd = { jp(M.masonbinpath, 'gopls') }
  },
  ["vimls"]                 = { active = true,
    cmd = { jp(M.masonbinpath, 'vim-language-server') }
  },
  ["yamlls"]                = { active = true,
    cmd = { jp(M.masonbinpath, 'yaml-language-server') }
  },
  ["marksman"]              = { active = false,
    cmd = { jp(M.masonbinpath, 'marksman') }
  },
  ["iwe"]                   = { active = false,
    cmd = { jp(M.localbin, 'iwes') }
  },
  ["markdown-oxide"]        = { active = true,
    cmd = { jp(M.localbin, 'markdown-oxide') }
  },
  ["lemminx"]               = { active = true,
    cmd = { jp(M.localbin, 'lemminx-linux') }
  },
  ["taplo"]                 = { active = true,
    cmd = { jp(M.masonbinpath, 'taplo') }
  },
  ["lua_ls"]                = { active = true,
    cmd = { jp(M.masonbinpath, "lua-language-server"), '--logpath=' .. vim.fn.stdpath("state") },
  },
  ["emmylua_ls"]            = { active = false,
    cmd = { jp(M.localbin, "emmylua_ls") },
  },
  ["rust_analyzer"]         = { active = false,
    cmd = { jp(M.masonbinpath, 'rust-analyzer') }
  },
  ["groovyls"]              = { active = false,
    cmd = { jp(M.masonbinpath, 'groovy-language-server') }
  },
  ["kotlin"]               = { active = true,
    cmd = { jp(M.masonbasepath, 'kotlinlsp', "kotlin-lsp.sh"), "--stdio" }
  },
  ["jsonls"]                = { active = true,
    cmd = { jp(M.masonbinpath, "vscode-json-language-server") }
  },
  ["zls"]                   = { active = true,
    cmd = { jp(M.localbin, "zls") }
  },
  ["ctags"]             = { active = false,
    cmd = { jp(M.localbin, "ctags-lsp") }
  },
  ["basedpyright"]          = { active = true,
    cmd = { jp(M.masonbinpath, 'basedpyright-langserver') }
  },
  ["dartls"]                = { active = false,
    cmd = { jp(M.masonbinpath, "dartls") }
  },
  ["hls"]                   = { active = false,
    cmd = { "/usr/bin/hls" }
  },
  ["neocmake"]              = { active = true,
    cmd = { jp(M.localbin, "neocmakelsp") }
  },
  ["zk"]             = { active = false,
    cmd = { jp(M.localbin, "zk") }
  },
  ["ruff"]                  = { active = true,
    cmd = { jp(M.localbin, "ruff"), "server" }
  },
  ["sqlls"]                  = { active = false,
    cmd = { jp(M.masonbinpath, "sql-language-server"), "up", "--method", "stdio" }
  },
  --- these are DUMMY entries. They are handled by dedicated plugins in this
  --- config.
  ["roslyn"]                = { active = false },
  ["jdtls"]                 = { active = false }
}
  -- when set to true, use the lsp_lines plugin to display virtual text diagnostics
  -- this can show multiple diagnostic messages for a single line.
  -- otherwise, use normal virtual text.
M.virtual_lines = false

-- These LSP servers won't attach to navic (used for the breadcrumbs) because they
-- do not support the required LSP feature sets.
-- M.exclude_navic = { "emmet_language_server", "ctags" }
M.exclude_navic = { "ctags" }


-- settings for the nvim-jdtls plugin. See ftplugin/java.lua
-- avoid absolute paths except for system binaries, we vim.fn.expand() it when
-- needed
M.jdtls = {
  workspace_base = "~/.cache/jdtls_workspace/",
  -- java_executable = "/usr/bin/java",
  java_executable = vim.fn.expand("~/.sdkman/candidates/java/current/bin/java"),
  jdtls_install_dir = "~/.local/share/nvim/mason/packages/jdtls/",
  equinox_version = "1.7.0.v20250519-0528",
  config = "config_linux"
}

-- definitions for the roslyn plugin. You may need to change this, depending on the
-- locations you have installed the Roslyn and rzls language servers.
M.roslyn = {
  razor_compiler = jp(
    M.masonbasepath,
    'packages',
    "rzls",
    "libexec",
    "Microsoft.CodeAnalysis.Razor.Compiler.dll"
  ),
  razor_designer = jp(
    M.masonbasepath,
    "packages",
    "rzls",
    "libexec",
    "Targets",
    "Microsoft.NET.Sdk.Razor.DesignTime.targets"
  )
}
-- local custom lsp definitions that are not provided by nvim-lspconfig.
-- they still need an entry in serverconfigs.
M.local_configs = {
  ctags_lsp = {
    default_config = {
      cmd = { "ctags-lsp" },
      filetypes = nil,
      root_dir = function()
        return vim.fn.getcwd()
      end
    }
  }
}

-- set to true to get some debugging output via notifications
M.debug = false
M.verbose = true
M.virtual_lines = false
M.virtual_text = true
M.use_dynamic_registration = true
M.disable_breadcrumb = false
-- automatically terminate unused (= 0 clients) lsp servers
M.auto_shutdown = true
M.advanced_config = {
  scala = true,
  roslyn = true
}
M.inlay_hints = true
M.color_support = false

return M

