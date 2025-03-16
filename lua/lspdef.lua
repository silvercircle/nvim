-- this is the main anchor for lsp server configuration. If you want to personalize this,
-- make a copy and name it lspdef_user.lua. If this exists (in the same directory as this 
-- lspdef.lua file), it will be used instead and you will not lose your settings when updating
-- the config with git pull.
local jp = vim.fs.joinpath

local M = {}

-- these non-standard paths are known and can be used for lsp binaries. All standard paths
-- like /usr/bin, /usr/local/bin would also work
M.masonbasepath   = jp(vim.fn.stdpath('data'), '/mason/')
M.masonbinpath    = jp(M.masonbasepath, 'bin/')
M.homepath        = vim.fn.getenv('HOME')
M.localbin        = jp(M.homepath, '/.local/bin/')

-- edit this to reflect your installation directories for lsp servers. Most will
-- be in masonbinpath. Also supported are $HOME/.local/.bin and $HOME itself
-- for everything else, you can use full paths in the server_bin table.
-- for LSP servers that are in $PATH, the executable name alone should be enough.
-- This paths should work on most Linux systems, but you have to adjust them for 
-- Windows or macOS
M.server_bin = {
  metals        =   '/home/alex/.local/share/coursier/bin/metals',
  roslyn        =   jp(vim.fn.stdpath("data"), "/roslyn/Microsoft.CodeAnalysis.LanguageServer.dll"),
}

-- serverconfigs lists all servers which will be configured. Set active to false
-- to ignore a server. Set cfg to false to use the defaults from the
-- nvim-lspconfig registry. The server binary locations from server_bin will still
-- be used when using a default config.

-- Set cfg to a valid lua module to use your own configuration
-- For example: You can set cfg to "lsp.user.myserver" and then put the config in
-- lua/lsp/user/myserver.lua. The config file must return a table with configuration
-- options. See the examples like rust_analyzer.lua or lua_ls.lua.
M.serverconfigs = {
  ["ts_ls"]                 = { cfg = false, active = true,
    cmd = { jp(M.masonbinpath, 'typescript-language-server') }
  },
  ["texlab"]                = { cfg = false, active = true,
    cmd = { jp(M.localbin, 'texlab') }
  },
  ["tinymist"]              = { cfg = false, active = true,
    cmd = { jp(M.localbin, "tinymist") }
  },
  ["bashls"]                = { cfg = false, active = true,
    cmd = { jp(M.masonbinpath, 'bash-language-server') }
  },
  ["clangd"]                = { cfg = "lsp.serverconfig.clangd", active = true,
    cmd = { "clangd", "--background-index", "--malloc-trim",
            "--pch-storage=memory", "--log=error", "--header-insertion=never",
            "--completion-style=detailed", "--function-arg-placeholders=1",
            "--inlay-hints=true" }
  },
  ["ada_ls"]                = { cfg = "lsp.serverconfig.ada_ls", active = true,
    cmd = { jp(M.masonbinpath, 'ada_language_server') }
  },
  ["emmet_language_server"] = { cfg = false, active = true,
    cmd = { jp(M.masonbinpath, 'emmet-language-server') }
  },
  ["cssls"]                 = { cfg = false, active = true,
    cmd = { jp(M.masonbinpath, 'vscode-css-language-server') }
  },
  ["html"]                  = { cfg = false, active = true,
    cmd = { jp(M.masonbinpath, 'vscode-html-language-server') }
  },
  ["gopls"]                 = { cfg = "lsp.serverconfig.gopls", active = true,
    cmd = { jp(M.masonbinpath, 'gopls') }
  },
  ["vimls"]                 = { cfg = false, active = true,
    cmd = { jp(M.masonbinpath, 'vim-language-server') }
  },
  ["yamlls"]                = { cfg = false, active = true,
    cmd = { jp(M.masonbinpath, 'yaml-language-server') }
  },
  ["marksman"]              = { cfg = false, active = true,
    cmd = { jp(M.masonbinpath, 'marksman') }
  },
  ["lemminx"]               = { cfg = false, active = true,
    cmd = { jp(M.localbin, 'lemminx') }
  },
  ["taplo"]                 = { cfg = false, active = true,
    cmd = { jp(M.masonbinpath, 'taplo') }
  },
  ["lua_ls"]                = { cfg = "lsp.serverconfig.lua_ls", active = true,
    cmd = { jp(M.masonbinpath, "lua-language-server"), '--logpath=' .. vim.fn.stdpath("state") },
  },
  ["rust_analyzer"]         = { cfg = "lsp.serverconfig.rust_analyzer", active = false,
    cmd = { jp(M.masonbinpath, 'rust-analyzer') }
  },
  ["groovyls"]              = { cfg = false, active = false,
    cmd = { jp(M.masonbinpath, 'groovy-language-server') }
  },
  ["jsonls"]                = { cfg = false, active = true,
    cmd = { jp(M.masonbinpath, "vscode-json-language-server") }
  },
  ["zls"]                   = { cfg = "lsp.serverconfig.zls", active = true,
    cmd = { jp(M.localbin, "zls") }
  },
  ["ctags_lsp"]             = { cfg = false, active = false,
    cmd = { jp(M.localbin, "ctags_lsp") }
  },
  ["basedpyright"]          = { cfg = "lsp.serverconfig.basedpyright", active = true,
    cmd = { jp(M.masonbinpath, 'basedpyright-langserver') }
  },
  ["dartls"]                = { cfg = false, active = false,
    cmd = { jp(M.masonbinpath, "dartls") }
  },
  ["hls"]                   = { cfg = "lsp.serverconfig.hls", active = false,
    cmd = { "/usr/bin/hls" }
  },
  ["neocmake"]              = { cfg = false, active = true,
    cmd = { jp(M.localbin, "neocmakelsp") }
  }
}
  -- when set to true, use the lsp_lines plugin to display virtual text diagnostics
  -- this can show multiple diagnostic messages for a single line.
  -- otherwise, use normal virtual text.
M.virtual_lines = false

-- These LSP servers won't attach to navic (used for the breadcrumbs) because they
-- do not support the required LSP feature sets.
M.exclude_navic = { "emmet_language_server" }


-- settings for the nvim-jdtls plugin. See ftplugin/java.lua
-- avoid absolute paths except for system binaries, we vim.fn.expand() it when
-- needed
M.jdtls = {
  workspace_base = "~/.cache/jdtls_workspace/",
  java_executable = "/usr/bin/java",
  jdtls_install_dir = "~/.local/share/nvim/mason/packages/jdtls/",
  equinox_version = "1.6.900.v20240613-2009",
  config = "config_linux"
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

M.debug = true
return M

