-- this is the main anchor for lsp server configuration. If you want to personalize this,
-- make a copy and name it lspdef_user.lua. If this exists (in the same directory as this 
-- lspdef.lua file), it will be used instead and you will not lose your settings when updating
-- the config with git pull.
local jp = vim.fs.joinpath

local M = {}
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
  phpactor      =   '/usr/local/bin/phpactor',
  rust_analyzer =   jp(M.masonbinpath, 'rust-analyzer'),
  gopls         =   jp(M.masonbinpath, 'gopls'),
  nimls         =   jp(M.homepath, '/.nimble/bin/nimlangserver'),
  texlab        =   jp(M.localbin, 'texlab'),
  clangd        =   '/usr/bin/clangd',
  vimlsp        =   jp(M.masonbinpath, 'vim-language-server'),
  omnisharp     =   jp(vim.fn.stdpath("data"), "/omnisharp/OmniSharp"),
  metals        =   '/home/alex/.local/share/coursier/bin/metals',
  basedpyright  =   jp(M.masonbinpath, 'basedpyright-langserver'),
  lua_ls        =   jp(M.masonbinpath, 'lua-language-server'),
  serve_d       =   jp(M.localbin .. 'serve-d'),
  cssls         =   jp(M.masonbinpath, 'vscode-css-language-server'),
  tsserver      =   jp(M.masonbinpath, 'typescript-language-server'),
  html          =   jp(M.masonbinpath, 'vscode-html-language-server'),
  yamlls        =   jp(M.masonbinpath, 'yaml-language-server'),
  ada_ls        =   jp(M.masonbinpath, 'ada_language_server'),
  marksman      =   jp(M.masonbinpath, 'marksman'),
  lemminx       =   jp(M.localbin,     'lemminx'),
  bashls        =   jp(M.masonbinpath, 'bash-language-server'),
  taplo         =   jp(M.masonbinpath, 'taplo'),
  groovy        =   jp(M.masonbinpath, 'groovy-language-server'),
  roslyn        =   jp(vim.fn.stdpath("data"), "/roslyn/Microsoft.CodeAnalysis.LanguageServer.dll"),
  jsonls        =   jp(M.masonbinpath, "vscode-json-language-server"),
  zls           =   jp(M.localbin, "zls"),
  ccls          =   jp(M.localbin, "ccls"),
  hls           =   "/usr/bin/hls",
  emmet_language_server = jp(M.masonbinpath, 'emmet-language-server')
}

-- serverconfigs lists all servers which will be configured. Set active to false
-- to ignore a server. Set cfg to "_defaults_" to use the defaults from the
-- nvim-lspconfig registry. The server binary locations from server_bin will still
-- be used when using a default config.

-- Set cfg to a valid lua module to use your own configuration
-- For example: You can set cfg to "lsp.user.myserver" and then put the config in
-- lua/lsp/user/myserver.lua. The config file must return a table with configuration
-- options. See the examples like rust_analyzer.lua or lua_ls.lua
M.serverconfigs = {
  ["ts_ls"]                 = { cfg = "_defaults_", active = true },
  ["texlab"]                = { cfg = "_defaults_", active = true },
  ["tinymist"]              = { cfg = "_defaults_", active = true },
  ["nim_langserver"]        = { cfg = "lsp.serverconfig.nim_langserver", active = false },
  ["bashls"]                = { cfg = "_defaults_", active = true },
  ["clangd"]                = { cfg = "lsp.serverconfig.clangd", active = true },
  ["ccls"]                  = { cfg = "_defaults_", active = false },
  ["ada_ls"]                = { cfg = "lsp.serverconfig.ada_ls", active = false },
  ["emmet_language_server"] = { cfg = "_defaults_", active = true },
  ["cssls"]                 = { cfg = "_defaults_", active = true },
  ["html"]                  = { cfg = "_defaults_", active = true },
  ["gopls"]                 = { cfg = "lsp.serverconfig.gopls", active = true },
  ["vimls"]                 = { cfg = "_defaults_", active = true },
  ["yamlls"]                = { cfg = "_defaults_", active = true },
  ["marksman"]              = { cfg = "_defaults_", active = true },
  ["lemminx"]               = { cfg = "_defaults_", active = true },
  ["taplo"]                 = { cfg = "_defaults_", active = true },
  ["lua_ls"]                = { cfg = "lsp.serverconfig.lua_ls", active = true },
  ["rust_analyzer"]         = { cfg = "lsp.serverconfig.rust_analyzer", active = false },
  ["groovyls"]              = { cfg = "_defaults_", active = false },
  ["jsonls"]                = { cfg = "_defaults_", active = true },
  ["zls"]                   = { cfg = "lsp.serverconfig.zls", active = true },
  ["ctags_lsp"]             = { cfg = "_defaults_", active = false },
  ["basedpyright"]          = { cfg = "lsp.serverconfig.basedpyright", active = true },
  ["phpactor"]              = { cfg = "_defaults_", active = false },
  ["dartls"]                = { cfg = "_defaults_", active = false },
  ["hls"]                   = { cfg = "lsp.serverconfig.hls", active = false },
  ["neocmake"]              = { cfg = "_defaults_", active = true }
}
  -- when set to true, use the lsp_lines plugin to display virtual text diagnostics
  -- this can show multiple diagnostic messages for a single line.
  -- otherwise, use normal virtual text.
M.virtual_lines = false

return M

