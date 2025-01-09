-- user tweakable stuff
-- most of this is for cosmetical or performance purpose. Other tweaks are still
-- in config.lua and options.lua, but the goal is to have all user-tweakable options,
-- that are not neovim core options, here. This is WIP.
--
-- how to use this file:
-- 1. make a copy and name it mytweaks.lua (exactly that name, on Linux, the name is case-
--    sensitive)
-- 2. mytweaks.lua can be edited and will overwrite settings in this file as long as it is
--    present. Updating the repo with git pull won't overwrite your changes in mytweaks.
--    So do NOT change this file directly, because your changes may be lost when updating
--    from the repo.
-- 3. for performance reasons, you can edit your mytweaks.lua and delete everything that
--    you do not want to change. The file does not have to be complete.
local Tweaks = {}
Tweaks.lsp = {}

-- plugin choices.
-- notification system
-- either "mini", "fidget" or "nvim-notify". All three are supported and can act as
-- vim.notify backend.
-- Tweaks.notifier = "fidget"

-- set this to "Outline" to use the symbols-outline plugin.
-- set it to "aerial" to use the Aerial plugin.
-- this is a ONLY A DEFAULT, it can be switched at runtime and the setting
-- will be remembered
Tweaks.outline_plugin = "outline"

-- what plugin to use for breadcrumbs in the winbar
-- valid are 'aerial' and 'navic'. Defaults to 'navic' when unrecognized
Tweaks.breadcrumb = 'navic'

-- which multicursor plugin to use: either "brenton-leighton" or "jake-stewart"
-- see:
-- https://github.com/jake-stewart/multicursor.nvim
-- https://github.com/brenton-leighton/multiple-cursors.nvim
-- for more information about these plugins. They are quite similar in functionality, so
-- choose whatever looks better to you.
Tweaks.multicursor = "jake-stewart"

-- completion framework to use. Can be "blink" or "nvim-cmp"
-- if you set this to any other value, completion will be UNAVAILABLE
-- If set to nvim-cmp, the magazine fork (optimized for performance) is used.
-- blink is more modern and probably faster, but should be considered beta
-- quality software (as of December 2024). Breaking changes are likely.
--
-- look further below for plugin-specific tweaks.
Tweaks.completion = {
  version = "blink"
}

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
    -- phpactor      =   '/usr/local/bin/phpactor',
    rust_analyzer =   Tweaks.lsp.masonbinpath .. 'rust-analyzer',
    gopls         =   Tweaks.lsp.masonbinpath .. 'gopls',
    nimls         =   Tweaks.lsp.homepath .. '/.nimble/bin/nimlangserver',
    texlab        =   Tweaks.lsp.localbin .. 'texlab',
    clangd        =   '/usr/bin/clangd',
    -- dartls        =   '/opt/flutter/bin/dart',
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
    csharp_ls     =   Tweaks.lsp.masonbasepath .. "packages/csharpls/CSharpLanguageServer",
    marksman      =   Tweaks.lsp.masonbinpath .. 'marksman',
    lemminx       =   Tweaks.lsp.masonbinpath .. 'lemminx',
    -- haskell       =   Tweaks.lsp.homepath .. '/.ghcup/hls/1.9.0.0/bin/haskell-language-server-9.4.4',
    bashls        =   Tweaks.lsp.masonbinpath .. 'bash-language-server',
    taplo         =   Tweaks.lsp.masonbinpath .. 'taplo',
    emmet         =   Tweaks.lsp.masonbinpath .. 'emmet-language-server',
    groovy        =   Tweaks.lsp.masonbinpath .. 'groovy-language-server',
    roslyn        =   vim.fn.stdpath("data") .. "/roslyn/Microsoft.CodeAnalysis.LanguageServer.dll",
    jsonls        =   Tweaks.lsp.masonbinpath .. "vscode-json-language-server",
    zls           =   Tweaks.lsp.localbin .. "zls"
  },
  -- use either omnisharp or csharp_ls for c# and .NET development
  -- both options work reasonably well with a few issues and missing features
  -- the third option "roslyn" is highly experimental and not recommended
  csharp = "roslyn",
  -- when set to true, use the lsp_lines plugin to display virtual text diagnostics
  -- this can show multiple diagnostic messages for a single line.
  -- otherwise, use normal virtual text.
  virtual_lines = false
}

-- blink.cmp related tweaks
Tweaks.blink = {
  -- if false, you have to manually invoke the completion popup (Control-Space)
  auto_show = false,
  -- auto-show after that many milliseconds
  border = "single",
  -- show the documentation window automatically
  auto_doc = true,
  -- keymap preset to use. Read the blink docs. Note that some
  -- keys are overriden or customized from the preset. See lua/plugins/blink.lua
  keymap_preset = "enter",
  ghost_text = false,  -- this might still be a bit buggy in blink.cmp.
  -- maximum height of the popup window
  window_height = 12,
  -- maximum width of the completion label
  label_max_width = 40,
  -- label_description maximum width
  desc_max_width = 30,
  -- prefetch on InsertEnter. This might improve performance but might have
  -- memory leaks at the moment.
  prefetch = false,
  -- if you use a theme that does not yet support blink.cmp, set this to true
  -- to use the fallback nvim-cmp hl groups which are supported by most themes
  use_cmp_hl = false,
  winblend = {
    doc = 0,
    menu = 0
  },
  -- list of filetypes for which we want to allow the "buffer" source to
  -- collect all the buffer words.
  -- set this to an empty table to allow buffer words for all filetype
  buffer_source_ft_allowed = {} -- { "tex", "markdown" }
}

-- tweaks for the cmp autocompletion system
Tweaks.cmp = {
  -- max buffer size to enable the buffer words autocompletion source in cmp
  -- this is a performance tweak. Value is in bytes and 300kB is a reasonable default, even for
  -- slower machines. On fast hardware you can increase this to much higher values
  buffer_maxsize = 7000 * 1024,
  -- maximum width for the item abbreviation. This is the completion item's name
  abbr_maxwidth = 40,
  -- max length of item kind description (without the symbol)
  kind_maxwidth = 12,
  source_maxwidth = 12,
  -- maximum width for the details column. Normally the rightmost column
  details_maxwidth = 40,
  -- I prefer to have only manual cmp complation (hit Ctrl-Space)
  autocomplete = false,
  -- minimum keyword length for auto-complete to kick in (only if the above is true)
  keywordlen = 2,
  --enable experimental ghost text feature. Set to false (disable) or a table
  --containing the highlight group to use for ghost text.
  --for example: ghost = { hl_group = 'CmpGhostText' }
  ghost = false, -- { hl_group = "CmpGhostText" },
  -- this can be either "standard" or "experimental"
  -- this is the style for the completion menu CONTENT. The border layout and background
  -- options are specified by decoration options further down.
  style = "standard",
  -- which decoration to use for the completion menu and the doc window
  -- flat: no border at all
  -- topflat: documentation window has top and bottom border for padding
  -- bordered: both windows have single line border
  -- rounded: rounded border
  decoration = {
    comp = "bordered",
    doc = "bordered"
  },
  winblend = {
    doc = 0,
    menu = 0
  },
  -- list of available decorations
  decorations = {
    flat = {
      -- border specifies what borderfactory() will use to create the window border
      border = "none",
      -- windowhighlight options for the docs and complation popup
      whl_doc = "Normal:NormalFloat,FloatBorder:CmpBorder,CursorLine:Visual,Search:None",
      whl_comp = "Normal:NeoTreeNormalNC,FloatBorder:CmpBorder,CursorLine:Visual"

    },
    topflat = {
      border = "topflat",
      whl_doc = "Normal:NormalFloat,FloatBorder:CmpBorder,CursorLine:Visual,Search:None",
      whl_comp = "Normal:NormalFloat,FloatBorder:CmpBorder,CursorLine:Visual"
    },
    bordered = {
      border = "thicc",
      whl_comp = "Normal:CmpFloat,FloatBorder:CmpBorder,CursorLine:Visual,Search:None",
      whl_doc =  "Normal:CmpFloat,FloatBorder:CmpBorder,CursorLine:Visual,Search:None"
    }
  },
}

-- internal function to create the border characters. You can expand it with more styles
-- and use them in the "decoration" option above.
Tweaks.borderfactory = function(style)
  if style == "single" then
    return { "┌", "─", "┐", "│", "┘", "─", "└", "│" }
  elseif style == "rounded" then
    return { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
  elseif style == "flat" then
    return { " ", " ", " ", " ", " ", " ", " ", " " }
  elseif style == "topflat" then
    return { " ", " ", " ", "", " ", " ", " ", "" }
  elseif style == "none" then
    return { "", "", "", "", "", "", "", "" }
  elseif style == "thicc" then
    return { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" }
  elseif style == "thiccc" then
    return { "▛", "▀", "▜", "▐", "▟", "▄", "▙", "▌" }
  else
    -- default to single
    return { "┌", "─", "┐", "│", "┘", "─", "└", "│" }
  end
end

-- don't touch this unless you know what you're doing
--Tweaks.cmp.kind_attr = Tweaks.cmp.style == "experimental" and { bold=true, reverse=true } or {}
Tweaks.cmp.kind_attr = { bold = true, reverse = false }

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
Tweaks.numberwidth = 5
-- for relative numbers, 2 should normally be sufficient
Tweaks.numberwidth_rel = 2
-- 3 signs should be sufficient in most cases. If you don't mind a "jumping"
-- signcolumn, you can use something like auto:3-5. see :h signcolumn
Tweaks.signcolumn = "yes:3"

Tweaks.cookie_source = 'curl -s -m 5 --connect-timeout 10 https://vtip.43z.one'
--Tweaks.cookie_source = 'curl -s -m 5 --connect-timeout 10 https://vtip.43z.one'

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
Tweaks.use_foldlevel_patch = false --(os.getenv('NVIM_USE_PRIVATE_FORKS') ~= nil) and true or false

-- the key prefix used for various utility functions. See keymap.lua
Tweaks.keymap = {
  utility_key = "<C-l>",
  mapleader = ",",
  fzf_prefix = "<C-q>"
}

Tweaks.treesitter = {
  -- disable injections which are known to slow down treesitter for a few file
  -- types. mostly JavaScript.
  perf_tweaks = true
}

Tweaks.theme = {
  sync_kittybg = true,
  kittenexec = "kitten",
  kittysocket = "/tmp/mykittysocket",
  rainbow_contrast = "low",
  scheme = "dark",
  all_types_bold = false,
  disable = false
}

-- which status line plugin to use.
-- right now, only lualine is supported by this config. This might change in the
-- future.
Tweaks.statusline = {
  version = "lualine",
  -- specific tweaks for lualine. Currently none.
  lualine = {}
}

-- filetree tweaks
Tweaks.tree = {
  -- valid versions are Neo (for NeoTree) or Nvim (for NvimTree)
  version = "Neo",
  -- use the git integration (currently only available for NeoTree)
  use_git = true
}

-- settings for the nvim-jdtls plugin. See ftplugin/java.lua
-- avoid absolute paths except for system binaries, we vim.fn.expand() it when
-- needed
Tweaks.jdtls = {
  workspace_base = "~/.cache/jdtls_workspace/",
  java_executable = "/usr/bin/java",
  jdtls_install_dir = "~/.local/share/nvim/mason/packages/jdtls/",
  equinox_version = "1.6.900.v20240613-2009",
  config = "config_linux"
}
-- a list of filename patterns that define a project root. This will be used as some kind of
-- fallback when no other means of finding a project's root are successfull. This is highly
-- incomplete and inaccurate, but you can expand this with whatever you want.
Tweaks.default_root_patterns = { "*.gpr", "Makefile", "CMakeLists.txt", "Cargo.toml", "*.nimble", "settings.gradle", "pom.xml", "*.sln", "build.zig" }
-- tweaks for the indent guides
Tweaks.indentguide = {
  -- character used by the indent-blankline plugin to draw vertical indent guides
  -- a light dotted line, sometimes barely visible
  --char = "",
  -- solid, thicker line
  char = "│",
  color = {
    -- the color for light- and dark background themes.
    light = "#808080",
    dark = "#404040"
  }
}
Tweaks.cokeline = {
  enabled = true,
  closebutton = false,
  underline = false,
  active_tab_style = "full_padded",
  styles = {
    slanted = {
      left = "",
      right = "",
      inactive = " "
    },
    half_padded = {
      left = "▌",
      right = "▐",
      inactive = ""
    },
    full_padded = {
      left = " ",
      right = " ",
      inactive = " "
    },
    slanted_padded = {
      left = " ",
      right = " ",
      inactive = ""
    }
  }
}
Tweaks.texviewer = "okular"
Tweaks.mdguiviewer = "okular"

-- base folder for your zettelkasten when using zk. This is used for the zettelkasten
-- live grep feature via telescope/fzf-lua
Tweaks.zk = {
  root_dir = "~/Documents/zettelkasten"
}

-- tweaks for the fzf-lua plugin
-- fzf-lua is an alternative to telescope. It offers a bit more pickers and features, but some
-- extensions are only available for telescope. So both plugins are kept available in this confit
-- and care has been taken to make them appear visually similar and consistent.
Tweaks.fzf = {
  -- customize for what feature sets fzf-lua should be preferred over telescope
  enable_keys = true,       -- use generic (grep, files...) fzf-lua pickers instead of telescope
  prefer_for = {
    lsp       = true,       -- use fzf-lua for lsp pickers
    git       = true,       -- use fzf-lua for git pickers
    selector  = true        -- use-fzf-lua for basic selectors (buffers, oldfiles)
  },
  -- some predefined window layouts
  winopts = {
    small_no_preview     =  { row = 0.25, width=0.5, height = 0.4, preview = { hidden="hidden" } },
    mini_list            =  { row = 0.25, width=50, height = 0.6, preview = { hidden="hidden" } },
    std_preview_top      =  { width = 0.6, height = 0.8, preview = { border = 'border', layout = 'vertical', vertical = "up:30%" } },
    std_preview_none     =  { width = 0.6, height = 0.8, preview = { hidden = 'hidden' } },
    big_preview_top      =  { width = 0.7, height = 0.9, preview = { border = 'border', layout = 'vertical', vertical = "up:35%" } },
    big_preview_topbig   =  { width = 0.7, height = 0.9, preview = { border = 'border', layout = 'vertical', vertical = "up:45%" } },
    narrow_no_preview    =  { width = 0.5, height = 0.8, preview = { hidden = 'hidden' } },
    narrow_small_preview =  { width = 0.5, height = 0.8, preview = { border = 'border', layout = 'vertical', vertical = "up:35%" } },
    narrow_big_preview   =  { width = 0.5, height = 0.9, preview = { border = 'border', layout = 'vertical', vertical = "up:45%" } },
    mini_with_preview    =  { width = 80, height = 0.8, preview = { border = 'border', layout = 'vertical', vertical = "up:30%" } },
  },
  image_preview = {
    png = { "chafa" },
    svg = { "chafa" },
    jpeg = { "chafa" }
  }
}
return Tweaks
