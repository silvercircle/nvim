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
local borderstyles = {
  single    = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
  rounded   = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
  flat      = { " ", " ", " ", " ", " ", " ", " ", " " },
  topflat   = { " ", " ", " ", "", " ", " ", " ", "" },
  none      = { "", "", "", "", "", "", "", "" },
  thicc     = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
  thiccc    = { "▛", "▀", "▜", "▐", "▟", "▄", "▙", "▌" },
}
local Tweaks = {}

-- plugin choices.
-- notification system
-- either "mini", "fidget" or "snacks".
Tweaks.notifier = "fidget"

-- set this to "outline" to use the symbols-outline plugin.
-- set it to "symbols" to use the symbols plugin.
-- this is a ONLY A DEFAULT, it can be switched at runtime and the setting
-- will be remembered
Tweaks.outline_plugin = "symbols"

-- what plugin to use for breadcrumbs in the winbar
-- valid are 'aerial' and 'navic'. Defaults to 'navic' when unrecognized
Tweaks.breadcrumb = 'navic'

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

-- which indent guides plugin to use. Options are "blink" or "snacks"
-- This plugin is responsible for drawing the indent guides.
Tweaks.indent = {
  enabled = true,
  rainbow_guides = true,
  -- colors for the non-rainbow lines
  color = {
    -- the color for light- and dark background themes.
    light = "#808080",
    dark = "#404040"
  },
  -- see snacks.indent documentation for available styles and options
  animate = {
    enabled = false,
    style = "out",
    easing = "linear",
    duration = {
      step = 10,   -- ms per step
      total = 100, -- maximum duration
    }
  },
  -- mark the current scope
  -- again, see snacks.indent docs.
  scope = {
    enabled = true,
    priority = 200,
    char = "┃",
    hl = "Brown",
    underline = false,      -- underline the start of the scope
    only_current = false,   -- only show scope in the current window
  },
  chunk = {
    -- when enabled, scopes will be rendered as chunks, except for the
    -- top-level scope which will be rendered as a scope.
    enabled = true,
    -- only show chunk scopes in the current window
    only_current = true,
    priority = 200,
    hl = "Brown",
  },
  blank = {
    char = " ",
    -- char = "·",
    hl = "SnacksIndentBlank", ---@type string|string[] hl group for blank spaces
  },
}

-- this enabled DAP and dap-ui
Tweaks.dap = {
  enabled = true
}

-- blink.cmp related tweaks
Tweaks.blink = {
  -- if false, you have to manually invoke the completion popup (Control-Space)
  auto_show = false,
  -- auto-show after that many milliseconds
  border = "thicc", -- see borderfactory() for supported values
  -- show the documentation window automatically
  auto_doc = true,
  -- keymap preset to use. Read the blink docs. Note that some
  -- keys are overriden or customized from the preset. See lua/plugins/blink.lua
  keymap_preset = "enter",
  ghost_text = true,  -- this might still be a bit buggy in blink.cmp.
  -- maximum height of the popup window
  window_height = 15,
  -- maximum width of the completion label
  label_max_width = 40,
  -- label_description maximum width
  desc_max_width = 30,
  -- prefetch on InsertEnter. This might improve performance but might have
  -- memory leaks at the moment.
  prefetch = true,
  -- if you use a theme that does not yet support blink.cmp, set this to true
  -- to use the fallback nvim-cmp hl groups which are supported by most themes
  use_cmp_hl = false,
  winblend = {
    doc = 0,
    menu = 0,
    signature = 0
  },
  --- show the effective LSP client name in the last column when available
  --- otherwise show just the source name (LSP, snippets etc.)
  show_client_name = true,
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
      whl_comp = "Normal:CmpBrightBack,FloatBorder:CmpBorder,CursorLine:Visual"

    },
    topflat = {
      border = "none",
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
  style = (style and borderstyles[style] ~= nil) and style or "single"
  return borderstyles[style]
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
Tweaks.numberwidth_rel = 5
-- 3 signs should be sufficient in most cases. If you don't mind a "jumping"
-- signcolumn, you can use something like auto:3-5. see :h signcolumn
Tweaks.signcolumn = "yes:3"

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
Tweaks.keymap = {
  utility_key = "<C-l>",
  mapleader = ",",
  fzf_prefix = "<C-q>",
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
  scheme = "gruv",
  all_types_bold = false,
  disable = false,
  picker_backdrop = 100
}

-- which status line plugin to use.
-- right now, only lualine is supported by this config. This might change in the
-- future.
Tweaks.statusline = {
  version = "lualine",
  -- specific tweaks for lualine.
  lualine = {
    -- Set this to "internal" to use darkmatter integration or to some available
    -- lualine theme, eg "dracula"
    theme = "internal",
    -- redraw debounce (in milliseconds)
    refresh = 2000
  }
}

-- filetree tweaks
Tweaks.tree = {
  -- valid versions are Neo (for NeoTree), Nvim (for NvimTree)
  version = "Nvim",
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
Tweaks.default_root_patterns = { "*.gpr", "Makefile", "CMakeLists.txt", "Cargo.toml", "*.nimble", "settings.gradle", "pom.xml", "*.sln", "build.zig", "go.mod", "go.sum" }
Tweaks.srclocations = { "src", "source", "sources", "SRC", "Src", "SOURCE", "Source", "Sources", "lua" }
Tweaks.cokeline = {
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
    std_preview_top      =  { width = 0.6, height = 0.8, preview = { border = 'thicc', layout = 'vertical', vertical = "up:30%" } },
    std_preview_none     =  { width = 0.6, height = 0.8, preview = { hidden = 'hidden' } },
    big_preview_top      =  { width = 0.7, height = 0.9, preview = { border = 'thicc', layout = 'vertical', vertical = "up:35%" } },
    big_preview_topbig   =  { width = 0.7, height = 0.9, preview = { border = 'thicc', layout = 'vertical', vertical = "up:45%" } },
    narrow_no_preview    =  { width = 0.5, height = 0.8, preview = { hidden = 'hidden' } },
    very_narrow_no_preview= { width = 70, height = 0.8, preview = { hidden = 'hidden' } },
    narrow_small_preview =  { width = 0.5, height = 0.8, preview = { border = 'thicc', layout = 'vertical', vertical = "up:35%" } },
    narrow_big_preview   =  { width = 0.5, height = 0.9, preview = { border = 'thicc', layout = 'vertical', vertical = "up:45%" } },
    mini_with_preview    =  { width = 80, height = 0.8, preview = { border = 'thicc', layout = 'vertical', vertical = "up:30%" } },
  },
  image_preview = {
    png = { "chafa" },
    svg = { "chafa" },
    jpeg = { "chafa" }
  }
}

Tweaks.snacks = {
  enabled_modules = { "picker", --[["image",]] "indent", "lazygit" }
}

Tweaks.minimap = {
  features = { treesitter = true, git = false, search = false, diagnostic = true },
  debounce = 800
}
Tweaks.smartpicker = {
  project_types = {
    lua = { names = {"stylua.toml", "init.vim"} }
  }
}

local chunklines = Tweaks.borderfactory(Tweaks.indent.chunk.lines)

Tweaks["indent"]["chunk"]["char"] = {
  corner_top = chunklines[1],
  corner_bottom = chunklines[7],
  horizontal = chunklines[2],
  vertical = chunklines[4],
  arrow = ">",
}

return Tweaks
