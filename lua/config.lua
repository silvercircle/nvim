-- configuration variables

-- when NVIM_PLAIN is set (to whatever value), the editor will start plain without a neotree and
-- terminal split.
local env_plain = os.getenv("NVIM_PLAIN")
local status, mtw = pcall(require, "mytweaks")
local tweaks = require("tweaks-dist")

-- merge mytweaks into the default tweaks file to allow for user-customizable 
-- settings that won't be overwritten when updating the config.
if status == true then
  tweaks = vim.tbl_deep_extend("force", tweaks, mtw)
end
Tweaks = tweaks
Borderfactory = Tweaks.borderfactory

local tree_fts = {
  ['Neo']       = "neo-tree",
  ['Nvim']      = "NvimTree",
  ['Explorer']  = "snacks_picker_list"
}
Tweaks.tree.filetype = tree_fts[Tweaks.tree.version]

-- FIXME: silence deprecation warnings in dev builds. currently 0.11
-- adjust this for future dev builds
local nvim_11 = vim.fn.has("nvim-0.11")
if nvim_11 == 1 then
  vim.deprecate = function() end
end

CFG = {
  nightly = (nvim_11 ~= 0) and true or false,
  cmp = {
    -- the following lists file types that are allowed to use the cmp_buffer source
    buffer_ft_allowed = {tex = true, md = true, markdown = true, telekasten = true, text =true, mail = true, liquid = true },
  },
  minipicker_iprefix = "#>",
  -- these are minimal values
  filetree_width = 42,                          -- width nvim-tree plugin (file tree)
  outline_width = 36,                           -- split width for symbols-outline window (right sidebar)
  -- some optional plugins
  mason = true,                                 -- on demand, setup in setup_lsp.lua
  null_ls = false,                              -- setup by lazy loader
  treesitter = true,
  plain = (env_plain ~= nil or vim.g.want_plain == true) and true or false,
  statuscol_normal = '%s%=%l %C ',
  statuscol_rel = nvim_11 == 1 and '%s%=%l %C ' or "%s%=%r %C ",
  nvim_tree = true,
  fortunecookie = false, -- "fortune science politics -s -n500 | cowsay -W 120",  -- display a fortune cookie on start screen.
                                              -- needs fortune and cowsay installed.
                                              -- set to false or an empty string to disable
                                              -- set this to "" or false if your start screen throws errors.
                                              -- when false, views are only written on write/update or manually (f4)
  termheight = 11,
  iconpad = '',                              -- additional padding for devicons.
  texoutput = "~/Documents/TEXOUTPUT/",
  wordcount_limit = 5,                         -- file size limit in megabytes. Above it, the word count will be disabled for performance reasons
  sysmon = {
    width = 51,
    modules = "cpu,mem,memswap,network,load,system,uptime"
    -- modules = "cpu,mem,network,load,system,uptime,quicklook", -- this requiers a width of 58 or more
  },
  weather = {
    width = 42,
    file = "~/.weather/weather",
    splitright = false,
    required_height = 15
  },
  -- this is a table of filetype <> colorcolumns associations. it's used by globals.toggle_colorcolumn()
  -- to figure out where the color column for the given filetype should be.
  colorcolumns = {
    all = {
      filetype ="all",
      value = "100"
    },
    text = {
      filetype = "tex,markdown,liquid,telekasten",
      value = "107"
    },
    mail = {
      filetype = "mail",
      value = "76"
    }
  },
  treesitter_types = { "c", "cpp", "lua", "vim", "python", "dart", "go", "c_sharp", "css", "scss", "xml",
                       "scala", "java", "kdl", "ada", "json", "nim", "d", "vimdoc", "liquid", "typst",
                       "yaml", "rust", "javascript", "ruby", "objc", "groovy", "org", "markdown",
                       "markdown_inline", "zig", "latex" },
  treesitter_context_types = { "tex", "markdown", "telekasten" },
  outline_plugin = nil,
  theme = require("darkmatter")
}

-- quick actions for the alpha start screen
vim.g.startify_top = {
  {
    key = 'e',
    text = "  New file",
    command = ":ene <BAR> startinsert <CR>"
  },
  {
    key = 'q',
    text = "󰗼  Quit NVIM",
    command = ":qa!<CR>"
  },
  {
    key = 'c',
    text = "  Edit config",
    command = ":e ~/.config/nvim/init.vim<CR>"
  }
}

-- this table holds full path information for lsp server binaries. They can be installed with mason or
-- manually. plugins/lsp.lua does all the real work. Mason and mason-lspconfig are optional.
-- They allow easy installation and upgrading of your lsp servers, but if you do this manually,
-- nvim-lspconfig alone is enough for a working LSP setup.

vim.g.lsp_server_bin = tweaks.lsp.server_bin

vim.g.confirm_actions = {
  exit = true,            -- ALWAYS confirm force-close (Alt-q), even when no buffers are modified
  close_buffer = true,    -- <C-x><C-c>: only confirm when buffer modified
}

local g = vim.g
-- disable some standard plugins

-- global variables for plugins
g.mapleader = Tweaks.keymap.mapleader

function vim.g.setkey(modes, lhs, rhs, _desc)
  vim.keymap.set(modes, lhs, rhs, { noremap = true, silent = true, desc = _desc })
end
CGLOBALS=require("globals")
PCFG = require("subspace.lib.permconfig").perm_config

vim.filetype.add({
  extension = {
    axaml = "xml",
    xaml = "xml"
  }
})

--
-- These symbols are used by:
-- Cmp plugin
-- aerial plugin
-- outline plugin
-- lspkind plugin
-- navic & navbuddy plugins
vim.g.lspkind_symbols = {
  Text        = "󰊄 ",
  Method      = " ",
  Function    = "󰡱 ",
  Constructor = " ",
  Field       = " ",
  Variable    = "󰫧 ",
  Class       = " ",
  Interface   = " ",
  Module      = " ",
  Property    = " ",
  Unit        = "塞",
  Value       = " ",
  Enum        = " ",
  Keyword     = " ",
  Snippet     = " ",
  Color       = " ",
  File        = "󰈔 ",
  Reference   = " ",
  Folder      = " ",
  EnumMember  = " ",
  Constant    = " ",
  Struct      = " ",
  Event       = " ",
  Operator    = " ",
  Namespace   = " ",
  Package     = " ",
  String      = " ",
  Number      = " ",
  Boolean     = " ",
  Array       = " ",
  Type        = " ",
  Object      = " ",
  Key         = " ",
  Null        = "󰟢 ",
  TypeParameter = "𝙏 ",
  Dict        = " ",
}

vim.g.is_tmux = vim.fn.exists("$TMUX")

function FWO(class, title)
  local wo = vim.deepcopy(Tweaks.fzf.winopts[class])
  if title ~= nil and #title > 2 then
    wo.title = " " .. title .. " "
  else
    wo.title = nil
  end
  return wo
end

--- output a notification, supports markdown format
--- level and title are optional
function STATMSG(msg, state, level, title)
  level = level or 0
  title = title or ""
  local _msg = msg or ""
  local _state = state or false
  vim.notify(_msg .. (_state and " `Enabled`" or " `Disabled`"), 0, { title = title } )
end
-- generate a snacks picker layout
function SPL(params)
  -- local opts = params or { preview = false, width = 80, height = 0.8 }
  local opts = params or {}
  local input_pos = opts.input or "bottom"
  return (input_pos == "bottom" or input_pos == "off") and {
    preview = opts.preview or false,
    preset = opts.preset or "vertical",
    layout = {
      backdrop = opts.backdrop or Tweaks.theme.picker_backdrop,
      box = opts.box or "vertical",
      row = opts.row or nil,
      col = opts.col or nil,
      position = opts.position or "float",
      width = opts.width or 80,
      min_height = opts.height,
      min_width = opts.width,
      height = opts.height or 0.9,
      title = opts.title or nil,
      border = opts.border and Borderfactory(opts.border) or Borderfactory("thicc"),
      { win = "preview", title = "{preview}", height = opts.psize or 10, border = "bottom", wo = { winbar = "" } },
      { win = "list",  border = "none" },
      input_pos ~= "off" and { win = "input", height = 1,
        border = opts.iborder and Borderfactory(opts.iborder) or "top" } or nil,
    }
  } or {
    preview = opts.preview or false,
    preset = opts.preset or "vertical",
    layout = {
      backdrop = opts.backdrop or Tweaks.theme.picker_backdrop,
      box = opts.box or "vertical",
      row = opts.row or nil,
      col = opts.col or nil,
      position = opts.position or "float",
      width = opts.width or 80,
      min_width = opts.width,
      min_height = opts.height,
      height = opts.height or 0.9,
      title = opts.title or nil,
      border = opts.border and Borderfactory(opts.border) or Borderfactory("thicc"),
      input_pos ~= "off" and { win = "input", height = 1, border = "bottom" } or nil,
      { win = "list",  border = "none" },
      { win = "preview", title = "{preview}", height = opts.psize or 10, border = "top", wo = { winbar = "" } },
    }
  }
end

CFG.SIDEBAR_FancySymbols = {
  providers = {
    lsp = {
      kinds = {
        default = vim.g.lspkind_symbols,
      }
    },
    treesitter = {
      kinds = {
        help = {
          H1 = "",
          H2 = "",
          H3 = "",
          Tag = "",
        },
        markdown = {
          H1 = "",
          H2 = "",
          H3 = "",
          H4 = "",
          H5 = "",
          H6 = "",
        },
        json = {
          Array       = " ",
          Object      = " ",
          String      = " ",
          Number      = " ",
          Boolean     = " ",
          Null        = "󰟢 ",
        },
        jsonl = {
          Array       = " ",
          Object      = " ",
          String      = " ",
          Number      = " ",
          Boolean     = " ",
          Null        = "󰟢 ",
        },
        org = {
          H1 = "",
          H2 = "",
          H3 = "",
          H4 = "",
          H5 = "",
          H6 = "",
          H7 = "",
          H8 = "",
          H9 = "",
          H10 = "",
        },
        make = {
          Target = "",
        }
      }
    },
  }
}
