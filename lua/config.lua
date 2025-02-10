-- configuration variables

-- when NVIM_PLAIN is set (to whatever value), the editor will start plain without a neotree and
-- terminal split.
local env_plain = os.getenv("NVIM_PLAIN")
local status, tw = pcall(require, "mytweaks")
local tweaks = require("tweaks-dist")

-- merge mytweaks into the default tweaks file to allow for user-customizable 
-- settings that won't be overwritten when updating the config.
if status == true then
  tweaks = vim.tbl_deep_extend("force", tweaks, tw)
end
vim.g.tweaks = tweaks
Tweaks = tweaks
Borderfactory = vim.g.tweaks.borderfactory
-- FIXME: silence deprecation warnings in dev builds. currently 0.11
-- adjust this for future dev builds
local nvim_11 = vim.fn.has("nvim-0.11")
if nvim_11 == 1 then
  vim.deprecate = function() end
end

Config = {
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
  statuscol_rel = '%s%=%r %C ',
  nvim_tree = true,
  fortunecookie = false,                      --"fortune science politics -s -n500 | cowsay -W 120",  -- display a fortune cookie on start screen.
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
                       "yaml", "rust", "javascript", "ruby", "objc", "groovy", "org", "markdown", "zig" },
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
g.mapleader = vim.g.tweaks.keymap.mapleader

function vim.g.setkey(modes, lhs, rhs, _desc)
  vim.keymap.set(modes, lhs, rhs, { noremap = true, silent = true, desc = _desc })
end
__Globals=require("globals")

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
  TypeParameter = "𝙏 "
}

vim.g.is_tmux = vim.fn.exists("$TMUX")

