-- user tweakable stuff
-- most of this is for cosmetical or performance purpose. Other tweaks are still
-- in config.lua and options.lua, but the goal is to have all user-tweakable options
-- here. This is WIP.
--
-- how to use this file:
-- 1. make a copy and name it mytweaks.lua
-- 2. mytweaks can be edited and will be used instead of this file as long as it is 
--    present. Updating the repo with git pull won't overwrite your changes.
--
-- if NO mytweaks.lua exists, then this file will be used instead, but be warned, that
-- updating via git pull will overwrite your changes.
local Tweaks = {}

-- telescope field widths. These depend on the characters per line in the terminal
-- setup. So it needs to be tweakable
Tweaks.telescope_symbol_width = 60
Tweaks.telescope_fname_width = 120
-- the width for the vertical layout with preview on top
Tweaks.telescope_vertical_preview_layout = {
  width = 120,
  preview_height = 15
}

-- edit this to reflect your installation directories for lsp servers. Most will
-- be in masonbinpath. Also supported are $HOME/.local/.bin and $HOME itself
-- for everything else, you can use full paths in 
Tweaks.lsp = {
  masonbasepath = vim.fn.stdpath('data') .. '/mason/',
  masonbinpath  = Tweaks.lsp.masonbasepath .. 'bin/',
  localbin      = vim.fn.getenv('HOME') .. '/.local/bin/',
  homepath      = vim.fn.getenv('HOME'),
  server_bin = {
    phpactor      =   '/usr/local/bin/phpactor',
    rust_analyzer =   Tweaks.lsp.masonbinpath .. 'rust-analyzer',
    gopls         =   Tweaks.lsp.localbin .. 'gopls',
    nimls         =   Tweaks.lsp.homepath .. '/.nimble/bin/nimlsp',
    texlab        =   Tweaks.lsp.localbin .. 'texlab',
    clangd        =   '/usr/bin/clangd',
    dartls        =   '/opt/flutter/bin/dart',
    vimlsp        =   Tweaks.lsp.masonbinpath .. 'vim-language-server',
    omnisharp     =   Tweaks.lsp.masonbinpath .. 'omnisharp',
    metals        =   '/home/alex/.local/share/coursier/bin/metals',
    pyright       =   Tweaks.lsp.masonbinpath .. 'pyright-langserver',
    lua_ls        =   Tweaks.lsp.masonbinpath .. 'lua-language-server',
    serve_d       =   Tweaks.lsp.localbin .. 'serve-d',
    cssls         =   Tweaks.lsp.masonbinpath .. 'vscode-css-language-server',
    tsserver      =   Tweaks.lsp.masonbinpath .. 'typescript-language-server',
    html          =   Tweaks.lsp.masonbinpath .. 'vscode-html-language-server',
    yamlls        =   Tweaks.lsp.masonbinpath .. 'yaml-language-server',
    als           =   Tweaks.lsp.masonbinpath .. 'ada_language_server',
    jdtls         =   Tweaks.lsp.masonbinpath .. 'jdtls',
    csharp_ls     =   Tweaks.lsp.masonbasepath .. "packages/csharpls/CSharpLanguageServer",
    marksman      =   Tweaks.lsp.masonbinpath .. 'marksman',
    lemminx       =   Tweaks.lsp.masonbinpath .. 'lemminx',
    haskell       =   Tweaks.lsp.homepath .. '/.ghcup/hls/1.9.0.0/bin/haskell-language-server-9.4.4',
    bashls        =   Tweaks.lsp.masonbinpath .. 'bash-language-server',
    pylyzer       =   Tweaks.lsp.localbin .. "pylyzer",
    taplo         =   Tweaks.lsp.masonbinpath .. 'taplo',
    emmet         =   Tweaks.lsp.masonbinpath .. 'emmet-language-server',
    ltex          =   "/opt/ltex/bin/ltex-ls",
    groovy        =   Tweaks.lsp.masonbinpath .. 'groovy-language-server'
  }
}

-- the overall width for the "mini" telescope picker. These are used for LSP symbols
-- and references.
Tweaks.telescope_mini_picker_width = 76
-- length of the filename in the cokeline winbar
Tweaks.cokeline_filename_width = 25

-- tweaks for the cmp autocompletion system
Tweaks.cmp = {
  -- max buffer size to enable the buffer words autocompletion source in cmp
  -- this is a performance tweak. Value is in bytes and 300kB is a reasonable default, even for
  -- slower machines. On fast hardware you can increase this to much higher values
  buffer_maxsize = 300 * 1024,
  -- I prefer to have only manual cmp complation (hit Ctrl-Space)
  -- set this to true to always have auto-completion when typing
  autocomplete = false,
  -- minimum keyword length for auto-complete to kick in (only if the above is true)
  keywordlen = 2,
  --enable experimental ghost text feature. Set to false (disable) or a table
  --containing the highlight group to use for ghost text.
  --for example: ghost = { hl_group = 'CmpGhostText' }
  ghost = false
}

-- set this to "Outline" to use the symbols-outline plugin.
-- set it to "aerial" to use the Aerial plugin.
-- this is a default, it can be switched at runtime
Tweaks.outline_plugin = "aerial"

-- list of filetypes for which no views are created when saving or leaving the buffer
-- by default, help files and terminals don't need views
-- you can add other filetypes here if you wish.
Tweaks.mkview_exclude = { "help", "terminal", "floaterm" }
-- create a view when leaving a buffer.
Tweaks.mkview_on_leave = true
-- create a view when saving a buffer
Tweaks.mkview_on_save = true
Tweaks.cmdheight = 0

-- width of line number (absolute numbers)
Tweaks.numberwidth = 6
-- for relative numbers, 2 should normally be sufficient, but then 
Tweaks.numberwidth_rel = 2
Tweaks.signcolumn = "yes:3"

-- valid are 'dropbar' and 'navic'. Defaults to 'navic' when unrecognized
-- note that dropbar requires neovim 0.10 which is currently in development
-- and only available as nightly build.
Tweaks.breadcrumb = 'aerial'
Tweaks.cookie_source = 'curl -s -m 5 --connect-timeout 10 https://vtip.43z.one'

-- settings for the fortune cookie split
Tweaks.fortune = {
  refresh = 10, -- in minutes - the minimum is one minute, lower values are corrected.
  -- fetch 2 cookies and merge them.
  numcookies = 2,
  -- see man fortune (-s = short cookies, max. 300 characters long)
  command = "fortune -s -n300"
}

-- nvim-cmp tweak: enable ghost text with this highlight group. Set to false to
-- disable the feature.
Tweaks.use_foldlevel_patch = (os.getenv('NVIM_USE_PRIVATE_FORKS') ~= nil) and true or false

-- the key prefix used for various utility functions. See keymap.lua
Tweaks.utility_key = "<C-l>"
Tweaks.treesitter = {
  perf_tweaks = true
}
Tweaks.cokeline = {
  enabled = true,
  closebutton = false
}

Tweaks.theme = {
  sync_kittybg = true,
  kittenexec = "kitten",
  kittysocket = "/tmp/mykittysocket"
}
Tweaks.tree = "Nvim"

-- a list of filename patterns that define a project root. This will be used as some kind of
-- fallback when no other means of finding a project's root are successfull. This is highly
-- incomplete and inaccurate, but you can expand this with whatever you want.
Tweaks.default_root_patterns = { "*.gpr", "Makefile", "CMakeLists.txt", "Cargo.toml", "*.nimble", ".vscode", "settings.gradle", "pom.xml" }
return Tweaks
