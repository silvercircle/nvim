-- configuration variables

-- when NVIM_PLAIN is set (to whatever value), the editor will start plain without a neotree and
-- terminal split.
local env_plain = os.getenv("NVIM_PLAIN")
local status, tw = pcall(require, "mytweaks")
local tweaks = require("tweaks-dist")

if status == true then
  tweaks = vim.tbl_deep_extend("force", tweaks, tw)
end
vim.g.tweaks = tweaks

if vim.fn.has("nvim-0.9") == 0 then
  vim.notify("Warning, this configuration requires Neovim version 0.9 or later.", 3)
end

local nvim_10 = vim.fn.has("nvim-0.10")

Config = {
  telescope_fname_width = tweaks.telescope_fname_width,
  telescope_vertical_preview_layout = tweaks.telescope_vertical_preview_layout,
  nightly = nvim_10,
  telescope_dropdown='bottom',                  -- position for the input box in the dropdown theme. 'bottom' or 'top'
  cpalette_dropdown = 'top',                    -- same for the command palette
  -- the minipicker is the small telescope picker used for references, symbols and
  -- treesitter-symbols. It also works in insert mode.
  minipicker_symbolwidth = tweaks.telescope_symbol_width,
  minipicker_layout = {
    height = 0.85,
    width = tweaks.telescope_mini_picker_width,
    preview_height =10,
    anchor = "N",
  },
  cmp = {
    autocomplete = tweaks.cmp.autocomplete,
    autocomplete_kwlen = tweaks.cmp.keywordlen,
    max_abbr_item_width = 40,                   -- item name width (maximum for truncate())
    max_detail_item_width = 40,                 -- item detail field maxium width
    -- the following lists file types that are allowed to use the cmp_buffer source
    buffer_ft_allowed = {tex = true, md = true, markdown = true, telekasten = true, text =true, mail = true },
    buffer_maxsize = tweaks.cmp.buffer_maxsize, -- PERF: maximum buffer size allowed to use cmp_buffer source. 300kB
    ghost_text = tweaks.cmp.ghost
  },
  minipicker_iprefix = "#>",
  -- these are minimal values
  filetree_width = 44,                          -- width nvim-tree plugin (file tree)
  outline_width = 36,                           -- split width for symbols-outline window (right sidebar)
  -- some optional plugins
  mason = true,                                 -- on demand, setup in setup_lsp.lua
  null_ls = false,                              -- setup by lazy loader
  treesitter = true,
  plain = (env_plain ~= nil or vim.g.want_plain == true) and true or false,
  -- statuscol_normal = '%s%=%{printf("%4d", v:lnum)} %C ',
  statuscol_normal = '%s%=%l %C ',
  --statuscol_normal = '%s%=%#LineNr#%{v:relnum != 0 ? printf("%4d",v:lnum) : ""}%#Yellow#%{v:relnum == 0 ? printf("%4d", v:lnum) : ""} %C%#IndentBlankLineChar#│ ',
  --statuscol_rel = '%s%=%{printf("%4d", v:relnum)} %C ',
  statuscol_rel = '%s%=%r %C ',
  --again, with highlighting relative number
  --statuscol_rel = '%s%=%#LineNr#%{v:relnum != 0 ? printf("%4d",v:relnum) : ""}%#Yellow#%{v:relnum == 0 ? printf("%4d", v:relnum) : ""} %C%#IndentBlankLineChar#│ ',
  nvim_tree = true,
  cokeline_filename_width = tweaks.cokeline_filename_width,               -- max filename length on cokeline tabs
  fortunecookie = false,                      --"fortune science politics -s -n500 | cowsay -W 120",  -- display a fortune cookie on start screen.
                                              -- needs fortune and cowsay installed.
                                              -- set to false or an empty string to disable
                                              -- set this to "" or false if your start screen throws errors.
                                              -- when false, views are only written on write/update or manually (f4)
  breadcrumb = (nvim_10 == 1 and tweaks.breadcrumb == 'dropbar') and 'dropbar' or (tweaks.breadcrumb ~= 'dropbar' and tweaks.breadcrumb or 'navic'),
  termheight = 11,
  iconpad = '',                              -- additional padding for devicons.
  texoutput = "~/Documents/TEXOUTPUT/",
  texviewer = 'zathura',                      -- must be able to display PDFs, must be in $PATH
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
  treesitter_types = { "c", "cpp", "lua", "vim", "python", "dart", "go", --[["c_sharp",]]
                       "scala", "java", "kdl", "ada", "json", "nim", "d",
                       "yaml", "rust", "javascript", "ruby", "objc", "groovy" },
  treesitter_context_types = { "tex", "markdown", "telekasten" },
  outline_plugin = nil,
  theme = require("colors.darkmatter")
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
    text = "  Quit NVIM",
    command = ":qa!<CR>"
  },
  {
    key = 'c',
    text = "  Edit config",
    command = ":e ~/.config/nvim/init.vim<CR>:NvimTreeFindFile<CR>"
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
--g.loaded_netrw       = 1
--g.loaded_netrwPlugin = 1

g.loaded_zipPlugin= 1
g.loaded_zip = 1

g.loaded_tarPlugin= 1
g.loaded_tar = 1

g.loaded_gzipPlugin= 1
g.loaded_gzip = 1

-- global variables for plugins
g.mapleader = ','

function _Config_SetKey(modes, lhs, rhs, _desc)
  vim.keymap.set(modes, lhs, rhs, { noremap = true, silent = true, desc = _desc })
end
__Globals=require("globals")

vim.filetype.add({
  extension = {
    axaml = "xml",
    xaml = "xml"
  }
})

vim.g.lspkind_symbols = {
  Text        = "󰊄 ",
  Method      = " ",
  Function    = "󰡱 ",
  Constructor = " ",
  Field       = " ",
  Variable    = " ",
  Class       = " ",
  Interface   = " ",
  Module      = " ",
  Property    = " ",
  Unit        = "塞",
  Value       = " ",
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
  Package     = "󰏖 ",
  String      = " ",
  Number      = " ",
  Boolean     = " ",
  Array       = " ",
  Type        = " ",
  Object      = "⦿ ",
  Key         = " ",
  TypeParameter = "𝙏 "
}
