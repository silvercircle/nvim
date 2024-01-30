-- highlight support for common plugins, including:
-- * nvim-tree
-- * NeoTree
-- * cmp
-- * GitSigns
-- * Telescope
-- * Mini.pick
-- * Navic
-- * Aerial
-- * Navbuddy
-- * Cokeline

local function _set()
  local c = require("darkmatter")
  local conf = c.get_conf()

  c.hl_with_defaults("NvimTreeNormal", c.P.fg_dim, c.P.treebg)
  c.hl_with_defaults("NvimTreeEndOfBuffer", c.P.bg_dim, c.P.treebg)
  c.hl_with_defaults("NvimTreeVertSplit", c.P.bg0, c.P.bg0)
  c.link("NvimTreeSymlinkFolderName", "Blue")
  c.link("NvimTreeSymlinkFolderIcon", "BlueBold")
  c.link("NvimTreeFolderName", "Green")
  c.link("NvimTreeRootFolder", "Darkyellow")
  c.link("NvimTreeFolderIcon", "GreenBold")
  c.link("NeoTreeDirectoryIcon", "GreenBold")
  c.link("NeoTreeDirectoryName", "GreenBold")

  c.link("NvimTreeEmptyFolderName", "Fg")
  c.link("NvimTreeOpenedFolderName", "GreenBold")
  c.link("NvimTreeExecFile", "Fg")
  c.link("NvimTreeOpenedFile", "Orange")
  c.link("NvimTreeSpecialFile", "Fg")
  c.link("NvimTreeImageFile", "Fg")
  c.link("NvimTreeMarkdownFile", "Fg")
  c.link("NvimTreeIndentMarker", "SymbolsOutlineConnector")
  c.link("NvimTreeFolderArrowOpen", "SymbolsOutlineConnector")
  c.link("NvimTreeFolderArrowClosed", "SymbolsOutlineConnector")
  c.link("NvimTreeGitDirty", "Yellow")
  c.link("NvimTreeGitStaged", "Blue")
  c.link("NvimTreeGitMerge", "Orange")
  c.link("NvimTreeGitRenamed", "Purple")
  c.link("NvimTreeGitNew", "Green")
  c.link("NvimTreeGitDeleted", "Red")
  c.link("NvimTreeLspDiagnosticsError", "RedSign")
  c.link("NvimTreeLspDiagnosticsWarning", "YellowSign")
  c.link("NvimTreeLspDiagnosticsInformation", "BlueSign")
  c.link("NvimTreeLspDiagnosticsHint", "GreenSign")
  c.link("NvimTreeCursorLine", "TreeCursorLine")

  c.link("MiniNotifyNormal", "NeoTreeNormalNC")
  c.link("MiniNotifyBorder", "CmpBorder")
  c.link("NeoTreeFilenameOpened", "Builtin")
   -- CMP (with custom menu setup)
  c.link("CmpItemMenu", "Fg")
  c.link("CmpItemMenuDetail", "@include")
  c.link("CmpItemMenuBuffer", "FgDim")
  c.link("CmpItemMenuSnippet", "Number")
  c.link("CmpItemMenuLSP", "StorageClass")
  c.link("CmpItemAbbr", "Fg")
  c.set_hl(0, "CmpItemAbbrDeprecated", { bg = "NONE", strikethrough = true, fg = "#808080" })
  c.link("CmpItemAbbrMatch", "RedBold")
  c.link("CmpItemAbbrMatchFuzzy", "DarkPurpleBold")
  c.hl_with_defaults("CmpPmenu", c.P.fg, c.P.bg_dim)
  c.hl_with_defaults("CmpPmenuBorder", c.P.grey_dim, c.P.bg_dim)
  c.hl_with_defaults("CmpGhostText", c.P.grey, c.NONE)
  c.link("CmpItemKindDefault", "FgDim")
  c.link("CmpItemKind", "CmpItemKindDefault")
  c.link("CmpItemMenuPath", "CmpItemMenu")
  c.link("CmpItemKindStruct", "Structure")
  c.link("CmpItemKindConstructor", "@constructor")
  c.link("CmpItemKindMethod", "Method")
  c.link("CmpItemKindModule", "@include")
  c.link("CmpItemKindClass", "Class")
  c.link("CmpItemKindVariable", "Fg")
  c.link("CmpItemKindProperty", "Member")
  c.link("CmpItemKindField", "Member")
  c.link("CmpItemKindFunction", "Function")
  c.link("CmpItemKindKeyword", "Keyword")
  c.link("CmpItemKindText", "String")
  c.link("CmpItemKindUnit", "@include")
  c.link("CmpItemKindConstant", "Constant")
  c.link("CmpItemKindEnum", "CmpItemKindConstant")
  c.link("CmpItemKindSnippet", "CmpItemMenuSnippet")
  c.link("CmpItemKindOperator", "Operator")
  c.link("CmpItemKindInterface", "Interface")
  c.link("CmpItemKindValue", "StorageClass")
  c.link("CmpItemKindTypeParameter", "Type")

  c.hl_with_defaults("CmpFloat", c.P.fg_dim, c.P.treebg)
  c.hl_with_defaults("CmpBorder", c.P.accent, c.P.treebg)
  c.link("Pmenu", "CmpFloat")
  c.hl_with_defaults("PmenuSbar", c.NONE, c.P.bg2)
  c.link("PmenuSel", "Visual")

  c.hl_with_defaults("TelescopeBorder", c.P.accent, c.P.treebg)
  c.hl_with_defaults("TelescopePromptBorder", c.P.accent, c.P.treebg)
  c.hl_with_defaults("TelescopeNormal", c.P.fg_dim, c.P.treebg)
  c.hl("TelescopeTitle", c.P.accent_fg, c.P.accent, conf.attrib.bold)
  c.hl("TelescopePromptNormal", c.P.fg_dim, c.P.treebg, conf.attrib.bold)
  c.hl("TelescopeMatching", c.P.deepred, c.NONE, conf.attrib.bold)

  c.link("MiniPickBorder", "TelescopeBorder")
  c.link("MiniPickBorderBusy", "TelescopeBorder")
  c.link("MiniPickBorderText", "TelescopeBorder")
  c.link("MiniPickNormal", "TelescopeNormal")
  c.link("MiniPickHeader", "TelescopeTitle")
  c.link("MiniPickMatchCurrent", "Visual")
  c.link("TelescopeResultsLineNr", "Yellow")
  c.link("TelescopePromptPrefix", "Blue")
  c.link("TelescopeSelection", "TreeCursorLine")
  c.link("FzfLuaNormal", "TelescopeNormal")
  c.link("FzfLuaBorder", "TelescopeBorder")
  c.link("FzfLuaSearch", "TelescopeMatching")

  c.link("GitSignsAdd", "GreenSign")
  c.link("GitSignsAddNr", "GreenSign")
  c.link("GitSignsChange", "BlueSign")
  c.link("GitSignsChangeNr", "BlueSign")
  c.link("GitSignsDelete", "RedSign")
  c.link("GitSignsDeleteNr", "RedSign")
  c.link("GitSignsAddLn", "GreenSign")
  c.link("GitSignsChangeLn", "BlueSign")
  c.link("GitSignsDeleteLn", "RedSign")
  c.link("GitSignsCurrentLineBlame", "Grey")
  c.link("GitSignsAddInline", "Visual")
  c.link("GitSignsChangeInline", "Visual")
  c.link("GitSignsDeleteInline", "Visual")

  c.link("TroubleNormal", "NeoTreeNormalNC")

  -- Glance plugin: https://github.com/DNLHC/glance.nvim
  c.hl_with_defaults("GlancePreviewNormal", c.P.fg, c.P.black)
  c.hl_with_defaults("GlancePreviewMatch", c.P.yellow, c.NONE)
  c.hl_with_defaults("GlanceListMatch", c.P.yellow, c.NONE)
  c.link("GlanceListCursorLine", "Visual")

  vim.api.nvim_set_hl(0, "NavicIconsFile",          {bg = c.P.accent[1], fg = c.P.fg[1]})

  vim.api.nvim_set_hl(0, "NavicIconsModule",        {bg = c.P.accent[1], fg = c.P.olive[1]})
  c.link("AerialModuleIcon", "@module")

  vim.api.nvim_set_hl(0, "NavicIconsNamespace",     {bg = c.P.accent[1], fg = c.P.darkpurple[1]})
  c.link("AerialNamespaceIcon", "@module")

  vim.api.nvim_set_hl(0, "NavicIconsPackage",       {bg = c.P.accent[1], fg = c.P.olive[1]})
  c.link("AerialPackageIcon", "@module")

  vim.api.nvim_set_hl(0, "NavicIconsClass",         {bg = c.P.accent[1], fg = c.P.special.class[1]})
  c.link("AerialClassIcon", "Class")

  vim.api.nvim_set_hl(0, "NavicIconsMethod",        {bg = c.P.accent[1], fg = c.P.brightteal[1]})
  c.link("AerialMethodIcon", "Method")

  vim.api.nvim_set_hl(0, "NavicIconsProperty",      {bg = c.P.accent[1], fg = c.P.orange[1]})
  c.link("AerialPropertyIcon", "Member")

  vim.api.nvim_set_hl(0, "NavicIconsField",         {bg = c.P.accent[1], fg = c.P.orange[1]})
  c.link("AeriaFieldIcon", "Member")

  vim.api.nvim_set_hl(0, "NavicIconsConstructor",   {bg = c.P.accent[1], fg = c.P.yellow[1]})
  c.link("AerialConstructorIcon", "@constructor")

  vim.api.nvim_set_hl(0, "NavicIconsEnum",          {bg = c.P.accent[1], fg = c.P.darkpurple[1]})
  c.link("AerialEnumIcon", "@type")

  vim.api.nvim_set_hl(0, "NavicIconsInterface",     {bg = c.P.accent[1], fg = c.P.purple[1]})
  c.link("AerialInterfaceIcon", "Interface")

  vim.api.nvim_set_hl(0, "NavicIconsFunction",      {bg = c.P.accent[1], fg = c.P.teal[1]})
  c.link("AerialFunctionIcon", "Function")

  vim.api.nvim_set_hl(0, "NavicIconsVariable",      {bg = c.P.accent[1], fg = c.P.fg[1]})

  vim.api.nvim_set_hl(0, "NavicIconsConstant",      {bg = c.P.accent[1], fg = c.P.purple[1]})
  c.link("AerialConstantIcon", "@constant" )

  vim.api.nvim_set_hl(0, "NavicIconsString",        {bg = c.P.accent[1], fg = c.P.string[1]})
  c.link("AerialStringIcon", "String")

  vim.api.nvim_set_hl(0, "NavicIconsNumber",        {bg = c.P.accent[1], fg = c.P.special.number[1]})
  c.link("AerialNumberIcon", "Number")

  vim.api.nvim_set_hl(0, "NavicIconsBoolean",       {bg = c.P.accent[1], fg = c.P.deepred[1]})
  c.link("AerialBooleanIcon", "Boolean")

  vim.api.nvim_set_hl(0, "NavicIconsArray",         {bg = c.P.accent[1], fg = c.P.lpurple[1]})

  vim.api.nvim_set_hl(0, "NavicIconsObject",        {bg = c.P.accent[1], fg = c.P.darkpurple[1]})
  c.link("AerialObjectIcon", "Type")

  vim.api.nvim_set_hl(0, "NavicIconsKey",           {bg = c.P.accent[1], fg = c.P.darkpurple[1]})
  vim.api.nvim_set_hl(0, "NavicIconsNull",          {bg = c.P.accent[1], fg = c.P.lpurple[1]})

  vim.api.nvim_set_hl(0, "NavicIconsEnumMember",    {bg = c.P.accent[1], fg = c.P.orange[1]})
  c.link("AerialEnumMemberIcon", "@constant")

  vim.api.nvim_set_hl(0, "NavicIconsStruct",        {bg = c.P.accent[1], fg = c.P.darkpurple[1]})
  c.link("AerialStructIcon", "Struct")
  -- c.link("AerialStruct", "CmpItemKindStruct")
  --
  vim.api.nvim_set_hl(0, "NavicIconsEvent",         {bg = c.P.accent[1], fg = c.P.darkpurple[1]})

  vim.api.nvim_set_hl(0, "NavicIconsOperator",      {bg = c.P.accent[1], fg = c.P.special.operator[1]})
  c.link("AerialOperatorIcon", "@operator")

  vim.api.nvim_set_hl(0, "NavicIconsTypeParameter", {bg = c.P.accent[1], fg = c.P.darkpurple[1]})
  vim.api.nvim_set_hl(0, "NavicText",               {bg = c.P.accent[1], fg = c.P.fg_dim[1]})
  vim.api.nvim_set_hl(0, "NavicSeparator",          {bg = c.P.accent[1], fg = c.P.fg_dim[1]})
  c.link("NavbuddyNormalFloat", "NeoTreeNormalNC")
  c.link("NavbuddyFloatBorder", "TelescopeBorder")

  -- cokeline
  local cokeline_active_bg = c.P.bg4[1]
  c.set_hl(0, "CokelineInactive", { bg = c.P.statuslinebg[1], fg = c.cokeline_colors.fg })
  c.set_hl(0, "CokelineInactivePad", { bg = c.P.statuslinebg[1], fg = c.cokeline_colors.fg })
  c.set_hl(0, "CokelineActive", { bg = cokeline_active_bg, fg = c.T.accent_fg })
  c.set_hl(0, "CokelineActivePad", { bg = cokeline_active_bg, fg = c.P.statuslinebg[1]})
  c.set_hl(0, "CokelineActiveModified", { bg = cokeline_active_bg, fg = c.P.red[1] })
  c.set_hl(0, "CokelineInactiveModified", { bg = c.P.statuslinebg[1], fg = c.P.red[1] })

  c.link("MultiCursor", "CurSearch")
  c.link("MultiCursorMain", "CurSearch")
  c.hl_with_defaults("QuickFixLine", c.NONE, c.P.accent)
  -- quick fix
  c.link("qfLineNr", "Number")
  c.link("qfFileName", "String")
end

local M = {}
function M.set()
  _set()
end

return M

