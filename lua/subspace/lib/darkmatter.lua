-- contains support functions for the darkmatter theme engine

local Dmtheme = require("darkmatter")
local Utils = require("subspace.lib")

local M = {}

M.keys_set = false;

-- provide a simple ui selector to select and activate one of the available
-- color schemes.
function M.ui_select_scheme()
  local schemes = {
    { cmd = "dark", text = "Sonokai-inspired dark" },
    { cmd = "gruv", text = "Frankengruv, A Gruvbox inspired scheme" },
    { cmd = "transylvania", text = "Transylvania - A Dracula inspired scheme" }
  }
  local conf = Dmtheme.get_conf()
  vim.iter(schemes):filter(function(k)
    if k.cmd == conf.scheme then k.current = true k.hl = "Green" else k.current = nil k.hl = "Fg" end
  end)

  local function execute(item)
    conf.scheme = item.cmd
    PCFG.theme_scheme = item.cmd
    Dmtheme.set()
    if conf.callback ~= nil and type(conf.callback) == "function" then
      conf.callback("scheme")
    end
  end

  Utils.simplepicker(schemes, execute, { pre = "current", sortby = { "text:desc" }, prompt = "Select theme scheme" })
end

-- use vim.ui.select to choose from a list of themes
function M.ui_select_variant()
  local conf = Dmtheme.get_conf()
  local variants = conf.schemeconfig.variants

  vim.iter(variants):filter(function(k)
    if k.cmd == conf.variant then k.current = true k.hl = "Green" else k.current = false k.hl = "Fg" end
  end)

  local function execute(item)
    conf.variant = item.cmd
    Dmtheme.set()
    if conf.callback ~= nil and type(conf.callback) == "function" then
      conf.callback("variant")
    end
  end

  Utils.simplepicker(variants, execute, { pre = "current", sortby = { "p:desc" }, prompt = "Select theme background variant" })
end

-- use UI to present a selection of possible color configurations
function M.ui_select_colorweight()
  local conf = Dmtheme.get_conf()
  local items = conf.schemeconfig.palettes

  vim.iter(items):map(function(k)
    if conf.colorpalette == k.cmd then k.current = true k.hl = "Green" else k.current = false k.hl = "Fg" end
  end)

  local function execute(item)
    conf.colorpalette = item.cmd
    Dmtheme.set()
    if conf.callback ~= nil and type(conf.callback) == "function" then
      conf.callback("palette")
    end
  end

  Utils.simplepicker(items, execute, { pre = "current", sortby = { "p:desc" }, prompt = "Select Color variant" })
end

-- toggle background transparency and notify the registered callback
-- subscriber.
function M.toggle_transparency()
  local conf = Dmtheme.get_conf()
  conf.is_trans = not conf.is_trans
  Dmtheme.set_bg()
  if conf.callback ~= nil and type(conf.callback) == "function" then
    conf.callback("trans")
  end
end

function M.map_keys()
  -- bind keys, but do this only once
  if M.keys_set == false then
    local conf = Dmtheme.get_conf()

    M.keys_set = true
    vim.keymap.set({ "n" }, conf.keyprefix .. "tc", function()
      M.ui_select_scheme()
    end, { silent = true, noremap = true, desc = "Select theme scheme" })
    vim.keymap.set({ "n" }, conf.keyprefix .. "tv", function()
      M.ui_select_variant()
    end, { silent = true, noremap = true, desc = "Select theme variant" })
    vim.keymap.set({ "n" }, conf.keyprefix .. "td", function()
      M.ui_select_colorweight()
    end, { silent = true, noremap = true, desc = "Select theme color weight" })
    vim.keymap.set({ "n" }, conf.keyprefix .. "tt", function()
      M.toggle_transparency()
    end, { silent = true, noremap = true, desc = "Toggle theme transparency" })
  end
end

--- the callback is called from internal theme functions that change its
--- configuration.
--- @param what string: description what has changed
function M.theme_callback(what)
  local conf = CFG.theme.get_conf()
  if what == 'variant' then
    PCFG.theme_variant = conf.variant
    vim.notify("Theme variant is now: " .. conf.variant, vim.log.levels.INFO, { title="Theme" } )
  elseif what == 'palette' then
    PCFG.theme_palette = conf.colorpalette
    vim.notify("Selected color palette: " .. conf.colorpalette, vim.log.levels.INFO, { title="Theme" } )
  elseif what == "trans" then
    PCFG.transbg = conf.is_trans
    vim.notify("Theme transparency is now " .. (conf.is_trans == true and "On" or "Off"), vim.log.levels.INFO, { title="Theme" } )
  elseif what == "scheme" then
    vim.notify("Selected scheme: " .. conf.scheme, vim.log.levels.INFO, { title="Theme" } )
    require("plugins.lualine_setup").update_internal_theme()
  end
  if vim.g.tweaks.completion.version == "blink" then
    require("plugins.blink").update_hl()
  else
    require("plugins.cmp_setup").update_hl()
  end
end

return M
