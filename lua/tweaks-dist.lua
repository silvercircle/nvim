-- user tweakable stuff
-- most of this is for cosmetical or performance purpose. Other tweaks are still
-- in config.lua and options.lua, but the goal is to have all user-tweakable options
-- here. This is WIP.
--
-- how to use this file:
-- 1. make a copy and name it mytweaks.lua
-- 2. mytweaks can be edited and will overwrite settings in this file as long as it is 
--    present. Updating the repo with git pull won't overwrite your changes in mytweaks.
--    So do NOT change this file directly, because your changes may be lost when updating
--    from the repo..
--
-- if NO mytweaks.lua exists, then this file will be used instead, but be warned, that
-- updating via git pull will overwrite your changes.
local Tweaks = {}
Tweaks.lsp = {}

-- telescope field widths. These depend on the characters per line in the terminal
-- setup. So it needs to be tweakable
Tweaks.telescope_symbol_width = 60
Tweaks.telescope_fname_width = 120
-- the width for the vertical layout with preview on top
Tweaks.telescope_vertical_preview_layout = {
  width = 120,
  preview_height = 15
}
-- the overall width for the "mini" telescope picker. These are used for LSP symbols
-- and references.
Tweaks.telescope_mini_picker_width = 76
-- length of the filename in the cokeline winbar
Tweaks.cokeline_filename_width = 25

-- edit this to reflect your installation directories for lsp servers. Most will
-- be in masonbinpath. Also supported are $HOME/.local/.bin and $HOME itself
-- for everything else, you can use full paths in the server_bin table.
-- for LSP servers that are in $PATH, the executable name alone should be enough.
-- This paths should work on most Linux systems, but you have to adjust them for 
-- Windows or macOS

Tweaks.lsp.masonbasepath = vim.fn.stdpath('data') .. '/mason/'
Tweaks.lsp.masonbinpath = Tweaks.lsp.masonbasepath .. 'bin/'
Tweaks.lsp.localbin      = vim.fn.getenv('HOME') .. '/.local/bin/'
Tweaks.lsp.homepath      = vim.fn.getenv('HOME')

Tweaks.lsp = {
  -- if verify is set to true, the config will, at startup, check for the
  -- server executables to be present and warn you about missing ones.
  verify        = false,
  server_bin = {
    phpactor      =   '/usr/local/bin/phpactor',
    rust_analyzer =   Tweaks.lsp.masonbinpath .. 'rust-analyzer',
    gopls         =   Tweaks.lsp.localbin .. 'gopls',
    nimls         =   Tweaks.lsp.homepath .. '/.nimble/bin/nimlsp',
    texlab        =   Tweaks.lsp.localbin .. 'texlab',
    clangd        =   '/usr/bin/clangd',
    dartls        =   '/opt/flutter/bin/dart',
    vimlsp        =   Tweaks.lsp.masonbinpath .. 'vim-language-server',
    omnisharp     =   vim.fn.stdpath("data") .. "/omnisharp/OmniSharp",
    metals        =   '/home/alex/.local/share/coursier/bin/metals',
    pyright       =   Tweaks.lsp.masonbinpath .. 'pyright-langserver',
    lua_ls        =   Tweaks.lsp.masonbinpath .. 'lua-language-server',
    serve_d       =   Tweaks.lsp.localbin .. 'serve-d',
    cssls         =   Tweaks.lsp.masonbinpath .. 'vscode-css-language-server',
    tsserver      =   Tweaks.lsp.masonbinpath .. 'typescript-language-server',
    html          =   Tweaks.lsp.masonbinpath .. 'vscode-html-language-server',
    yamlls        =   Tweaks.lsp.masonbinpath .. 'yaml-language-server',
    als           =   Tweaks.lsp.masonbinpath .. 'ada_language_server',
    -- jdtls is unused.
    -- jdtls         =   Tweaks.lsp.masonbinpath .. 'jdtls',
    csharp_ls     =   Tweaks.lsp.masonbasepath .. "packages/csharpls/CSharpLanguageServer",
    marksman      =   Tweaks.lsp.masonbinpath .. 'marksman',
    lemminx       =   Tweaks.lsp.masonbinpath .. 'lemminx',
    haskell       =   Tweaks.lsp.homepath .. '/.ghcup/hls/1.9.0.0/bin/haskell-language-server-9.4.4',
    bashls        =   Tweaks.lsp.masonbinpath .. 'bash-language-server',
    pylyzer       =   Tweaks.lsp.localbin .. "pylyzer",
    taplo         =   Tweaks.lsp.masonbinpath .. 'taplo',
    emmet         =   Tweaks.lsp.masonbinpath .. 'emmet-language-server',
    ltex          =   "/opt/ltex/bin/ltex-ls",
    groovy        =   Tweaks.lsp.masonbinpath .. 'groovy-language-server',
    roslyn        =   vim.fn.stdpath("data") .. "/roslyn/Microsoft.CodeAnalysis.LanguageServer.dll",
    zls           =   Tweaks.lsp.masonbinpath .. 'zls'
  }
}

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
  ghost = false,
  border = "single"
}

-- set this to "Outline" to use the symbols-outline plugin.
-- set it to "aerial" to use the Aerial plugin.
-- this is a ONLY A DEFAULT, it can be switched at runtime and the setting
-- will be remembered
Tweaks.outline_plugin = "aerial"

-- list of filetypes for which no views are created when saving or leaving the buffer
-- by default, help files and terminals don't need views
-- you can add other filetypes here if you wish. This can help to declutter your
-- statefolder/view directory.
Tweaks.mkview_exclude = { "help", "terminal", "floaterm" }
-- create a view when leaving a buffer.
Tweaks.mkview_on_leave = true
-- create a view when saving a buffer
Tweaks.mkview_on_save = true
-- directly affects vim.o.cmdheight
Tweaks.cmdheight = 0

-- width of line number (absolute numbers)
Tweaks.numberwidth = 6
-- for relative numbers, 2 should normally be sufficient
Tweaks.numberwidth_rel = 2
-- 3 signs should be sufficient in most cases. If you don't mind a "jumping"
-- signcolumn, you can use something like auto:3-5. see :h signcolumn
Tweaks.signcolumn = "yes:3"

-- valid are 'aerial' and 'navic'. Defaults to 'navic' when unrecognized
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

-- leave this alone. Do not set the environment variable unless you know what you're
-- doing..
Tweaks.use_foldlevel_patch = (os.getenv('NVIM_USE_PRIVATE_FORKS') ~= nil) and true or false

-- the key prefix used for various utility functions. See keymap.lua
Tweaks.utility_key = "<C-l>"
Tweaks.treesitter = {
  -- disable injections which are known to slow down treesitter for a few file
  -- types. mostly JavaScript.
  perf_tweaks = true
}
-- cokeline is used as a buffer line. Unless you disable it here in which case, lualine's
-- buffer line is used.
Tweaks.cokeline = {
  enabled = true,
  closebutton = false
}

Tweaks.theme = {
  sync_kittybg = true,
  kittenexec = "kitten",
  kittysocket = "/tmp/mykittysocket"
}
-- filetree tweaks
Tweaks.tree = {
  -- valid versions are Neo (for NeoTree) or Nvim (for NvimTree)
  version = "Nvim",
  -- use the git integration (currently only available for NeoTree)
  use_git = false
}

-- settings for the nvim-jdtls plugin. See ftplugin/java.lua
Tweaks.jdtls = {
  workspace_base = "/home/alex/.cache/jdtls_workspace/",
  java_executable = "/usr/bin/java",
  jdtls_install_dir = "/home/alex/.local/share/nvim/mason/packages/jdtls/",
  equinox_version = "1.6.600.v20231106-1826",
  config = "config_linux"
}
-- a list of filename patterns that define a project root. This will be used as some kind of
-- fallback when no other means of finding a project's root are successfull. This is highly
-- incomplete and inaccurate, but you can expand this with whatever you want.
Tweaks.default_root_patterns = { "*.gpr", "Makefile", "CMakeLists.txt", "Cargo.toml", "*.nimble", ".vscode", "settings.gradle", "pom.xml", "*.sln" }
return Tweaks
