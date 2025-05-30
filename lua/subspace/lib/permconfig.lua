-- contains functions to save and retrieve a subset of settings to/from a JSON
-- file in statedir.

---@class permconfig.weather
---@field active boolean
---@field width  integer
---@field content string

---@class permconfig.sysmon
---@field active boolean
---@field width  integer
---@field content string

---@class permconfig.term
---@field active  boolean
---@field height  integer

---@class permconfig.tree
---@field width integer

---@class permconfig.outline
---@field width integer

---@class permconfig.theme.schemeconfig
---@field transbg boolean
---@field variant string
---@field palette string

---@class permconfig.theme
---@field scheme string
---@field gruv   permconfig.theme.schemeconfig

---@class permconfig
---@field sysmon  permconfig.sysmon
---@field weather permconfig.weather
---@field terminal permconfig.term
---@field tree     permconfig.tree
---@field outline  permconfig.outline
---@field statuscol_current string
---@field theme   permconfig.theme
---@field debug   boolean
---@field indent_guides boolean
---@field scrollbar boolean
---@field statusline_verbosity integer
---@field outline_filetype string
---@field treesitter_context boolean
---@field show_indicators boolean
---@field float_borders string
---@field cmp_show_docs boolean
---@field autopair boolean
---@field cmp_layout string
---@field cmp_automenu boolean
---@field cmp_ghost boolean
---
local function get_permconfig_filename()
  return vim.fs.joinpath(vim.fn.stdpath("state"), "permconfig.json")
end

local M = {}

-- these are the defaults for the permanent configuration structure. it will be saved to a JSON
-- file on exit and read on startup.
---@class permconfig
M.perm_config_default = {
  sysmon = {
    active = false,
    width = CFG.sysmon.width,
    content = "sysmon",
  },
  weather = {
    active = false,
    width = CFG.weather.width,
    content = "info",
  },
  terminal = {
    active = true,
    height = 12,
  },
  tree = {
    width = Tweaks.tree.width,
    active = true,
  },
  outline = {
    width = Tweaks.outline.width,
  },
  statuscol_current = "normal",
  theme = {
    scheme = "gruv",
    gruv = {
      variant = "warm",
      transbg = false,
      palette = "vivid"
    }
  },
  debug = false,
  indent_guides = true,
  scrollbar = true,
  statusline_verbosity = Tweaks.statusline.lualine.verbosity,
  outline_filetype = "SymbolsSidebar",
  treesitter_context = true,
  show_indicators = true,
  float_borders = "single",
  cmp_show_docs = true,
  autopair = true,
  cmp_layout = "classic",
  cmp_automenu = Tweaks.cmp.autocomplete,
  cmp_ghost = false,
  lsp = {
    inlay_hints = LSPDEF.inlay_hints
  },
  is_dev = Tweaks.use_foldlevel_patch,
  outline_view = false,
  minimap_view = false,
}

---@diagnostic disable-next-line
M.perm_config = {}

-- write the configuration to the json file
-- do not write it when running in plain mode (without additional frames and content)
-- this runs only once on VimLeave event
function M.write_config()
  if CFG.plain == true then
    return
  end
  local Tabs = require("subspace.lib.tabmanager")
  local file = get_permconfig_filename()
  local f = io.open(file, "w+")
  if f ~= nil then
    local wsplit_id = TABM.get(1).wsplit.id_win
    local usplit_id = TABM.get(1).usplit.id_win
    local state = {
      terminal = {
        active = Tabs.T[1].term.id_win ~= nil and true or false,
      },
      weather = {
        active = wsplit_id ~= nil and true or false,
      },
      sysmon = {
        active = usplit_id ~= nil and true or false,
      },
      tree = {
        active = #TABM.findWinByFiletype(Tweaks.tree.version == "Neo" and "neo-tree" or "NvimTree") > 0 and true or false,
      },
      theme = {}
    }
    if Tweaks.theme.disable == false then
      local theme_conf = CFG.theme.get_conf()
      state.theme.scheme = theme_conf.scheme
      state.theme[theme_conf.scheme] = {}
      state.theme[theme_conf.scheme]['variant'] = theme_conf.variant
      state.theme[theme_conf.scheme]['palette'] = theme_conf.colorpalette
      state.theme[theme_conf.scheme]['transbg'] = theme_conf.is_trans
    end
    if wsplit_id ~= nil then
      state.weather.width = vim.api.nvim_win_get_width(wsplit_id)
    end
    if usplit_id and usplit_id ~= 0 then
      state.sysmon.width = vim.api.nvim_win_get_width(usplit_id)
    end
    -- don't record state of minimap and outline window(s) when still in the start
    -- screen
    if TABM.T[1].id_main and vim.api.nvim_win_is_valid(TABM.T[1].id_main) and
        vim.bo[vim.api.nvim_win_get_buf(TABM.T[1].id_main)].filetype ~= "alpha" then
      state.outline_view = TABM.is_outline_open()
      state.minimap_view = TABM.findWinByFiletype("neominimap")[1] or 0
    else
      state.outline_view = PCFG.outline_view
      state.minimap_view = PCFG.minimap_view
    end
    local string = vim.fn.json_encode(vim.tbl_deep_extend("force", M.perm_config, state))
    f:write(string)
    io.close(f)
  end
end

--- read the permanent config from the JSON dump.
--- restore the defaults if anything goes wrong
--- it also configures darkmatter theme unless it is disabled in Tweaks.
function M.restore_config()
  local file = get_permconfig_filename()
  local f = io.open(file, "r")
  -- do some checks to avoid invalid data
  if f ~= nil then
    local json = f:read()
    if json == nil or #json <= 1 then
      M.perm_config = M.perm_config_default
    else
      local tmp = vim.fn.json_decode(json)
      if #tmp ~= nil then
        M.perm_config = vim.tbl_deep_extend("force", M.perm_config_default, tmp)
      else
        M.perm_config = M.perm_config_default
      end
    end
  else
    M.perm_config = M.perm_config_default
  end
  PCFG = M.perm_config

  PCFG.outline_filetype = "SymbolsSidebar"
  PCFG.indent_guides = Tweaks.indent.enabled
  -- configure the theme
  local cmp_kind_attr = { bold=true, reverse=true }
  if Tweaks.theme.disable == false then
    CFG.theme.setup({
      scheme = M.perm_config.theme.scheme,
      variant = M.perm_config.theme[M.perm_config.theme.scheme].variant,
      colorpalette = M.perm_config.theme[M.perm_config.theme.scheme].palette,
      is_trans = M.perm_config.theme[M.perm_config.theme.scheme].transbg,
      sync_kittybg = Tweaks.theme.sync_kittybg,
      kittysocket = Tweaks.theme.kittysocket,
      kittenexec = Tweaks.theme.kittenexec,
      callback = require("subspace.lib.darkmatter").theme_callback,
      indentguide_colors = {
        dark = Tweaks.indent.color.dark,
        light = Tweaks.indent.color.light
      },
      rainbow_contrast = Tweaks.theme.rainbow_contrast,
      custom_colors = {
        c1 = "#5a8aba"
      },
      usercolors = {
        user1 = "#ffffff",
        user2 = "#4a7099",
        user3 = "#708070"
      },
      --colorstyles_ovr = {
      --  defaultlib = "user2",
      --  staticmethod = "user2",
      --  attribute = "user3"
      --},
      attrib = {
        dark = {
          cmpkind = cmp_kind_attr,
          tabline = Tweaks.cokeline.underline == true and { underline = true } or {},
          types = Tweaks.theme.all_types_bold == true and { bold = true } or {},
          class = Tweaks.theme.all_types_bold == true and { bold = true } or {},
          interface = Tweaks.theme.all_types_bold == true and { bold = true } or {},
          struct = Tweaks.theme.all_types_bold == true and { bold = true } or {},
          defaultlib = { italic = false },
          attribute = { italic = false, bold = true },
        },
        gruv = {
          cmpkind = cmp_kind_attr,
          tabline = Tweaks.cokeline.underline == true and { underline = true } or {},
          types = Tweaks.theme.all_types_bold == true and { bold = true } or {},
          class = Tweaks.theme.all_types_bold == true and { bold = true } or {},
          interface = Tweaks.theme.all_types_bold == true and { bold = true } or {},
          struct = Tweaks.theme.all_types_bold == true and { bold = true } or {},
          defaultlib = { italic = false },
          attribute = { italic = false, bold = true },
        }
      },
    })
  end
end

return M
