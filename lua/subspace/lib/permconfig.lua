-- contains functions to save and retrieve a subset of settings to/from a JSON
-- file in statedir.

local function get_permconfig_filename()
  return vim.fs.joinpath(vim.fn.stdpath("state"), "/permconfig.json")
end

local M = {}

-- these are the defaults for the permanent configuration structure. it will be saved to a JSON
-- file on exit and read on startup.
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
    width = CFG.filetree_width,
    active = true,
  },
  outline = {
    width = CFG.outline_width,
  },
  statuscol_current = "normal",
  blist = true,
  blist_height = 0.33,
  theme_variant = "warm",
  transbg = false,
  theme_palette = "vivid",
  theme_strings = "yellow",
  theme_scheme = "gruv",
  debug = false,
  ibl_rainbow = true,
  ibl_enabled = true,
  ibl_context = false,
  scrollbar = true,
  statusline_declutter = 0,
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
    inlay_hints = true
  }
}

M.perm_config = {}

-- write the configuration to the json file
-- do not write it when running in plain mode (without additional frames and content)
-- this runs only once on VimLeave event
function M.write_config()
  if CFG.plain == true then
    return
  end
  local file = get_permconfig_filename()
  local f = io.open(file, "w+")
  if f ~= nil then
    local wsplit_id = require("subspace.content.wsplit").winid
    local usplit_id = require("subspace.content.usplit").winid
    local state = {
      terminal = {
        active = CGLOBALS.term.winid ~= nil and true or false,
      },
      weather = {
        active = wsplit_id ~= nil and true or false,
      },
      sysmon = {
        active = usplit_id ~= nil and true or false,
      },
      tree = {
        active = #CGLOBALS.findWinByFiletype(Tweaks.tree.version == "Neo" and "neo-tree" or "NvimTree") > 0 and true or false,
      }
    }
    if Tweaks.theme.disable == false then
      local theme_conf = CFG.theme.get_conf()
      state['theme_variant'] = theme_conf.variant
      state['theme_palette'] = theme_conf.colorpalette
      state['transbg'] = theme_conf.is_trans
      state['theme_strings'] = theme_conf.theme_strings
      state['theme_scheme'] = theme_conf.scheme
    end
    if wsplit_id ~= nil then
      state.weather.width = vim.api.nvim_win_get_width(wsplit_id)
    end
    if usplit_id ~= nil then
      state.sysmon.width = vim.api.nvim_win_get_width(usplit_id)
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
  -- configure the theme
  local cmp_kind_attr = { bold=true, reverse=true }
  if Tweaks.theme.disable == false then
    CFG.theme.setup({
      scheme = M.perm_config.theme_scheme,
      variant = M.perm_config.theme_variant,
      colorpalette = M.perm_config.theme_palette,
      theme_strings = M.perm_config.theme_strings,
      is_trans = M.perm_config.transbg,
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
