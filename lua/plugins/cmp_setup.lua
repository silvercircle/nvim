-- nvim-cmp: completion support
local utils = require("subspace.lib")
local cmp_helper = {}

local T = Tweaks.cmp

local function reverse_hl_groups()
  local groups = {
  "CmpItemKindDefault", "CmpItemKind", "CmpItemMenuPath",
  "CmpItemKindStruct", "CmpItemKindConstructor", "CmpItemKindMethod",
  "CmpItemKindModule", "CmpItemKindClass", "CmpItemKindVariable",
  "CmpItemKindProperty", "CmpItemKindField", "CmpItemKindFunction",
  "CmpItemKindKeyword", "CmpItemKindText", "CmpItemKindUnit",
  "CmpItemKindConstant", "CmpItemKindEnum", "CmpItemKindEnumMember",
  "CmpItemKindSnippet", "CmpItemKindOperator", "CmpItemKindInterface",
  "CmpItemKindValue", "CmpItemKindTypeParameter", "CmpItemKindFile",
  "CmpItemKindFolder", "CmpItemKindEvent", "CmpItemKindReference",
  "CmpItemKindDict"}

  for _,v in ipairs(groups) do
    local fg, name
    local hl = vim.api.nvim_get_hl(0, { name = v })
    if hl.link ~= nil then
      name = hl.link
    else
      name = v
    end
    fg = vim.api.nvim_get_hl(0, { name = name }).fg
    vim.api.nvim_set_hl(0, v .. "Rev", { fg = fg, bg = "NONE", reverse = true })
  end
end

local function italizemenugroups()
  local groups = {
    "CmpItemMenu", "CmpItemMenuPath", "CmpItemMenuDetail",
    "CmpItemMenuBuffer", "CmpItemMenuSnippet", "CmpItemMenuLSP" }

  vim.iter(groups):map(function(k)
    local hl = vim.api.nvim_get_hl(0, { name = k })
    local name = hl.link or k
    local fg = vim.api.nvim_get_hl(0, { name = name }).fg
    local bg = vim.api.nvim_get_hl(0, { name = name }).bg
    vim.api.nvim_set_hl(0, k, { fg = fg, bg = bg, italic = true })
  end)
end

reverse_hl_groups()
italizemenugroups()

local cmp = require("cmp")
local cmp_types = require("cmp.types.cmp")
local types = require("cmp.types")

-- make the completion popup a little more fancy with lspkind. Now mandatory.
local lspkind = require("lspkind")
lspkind.init({
  -- defines how annotations are shown
  -- default: symbol
  -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
  mode = 'symbol_text',

  -- default symbol map
  -- can be either 'default' (requires nerd-fonts font) or
  -- 'codicons' for codicon preset (requires vscode-codicons font)
  --
  -- default: 'default'
  preset = 'default',

  -- override preset symbols
  --
  -- default: {}
  symbol_map = CFG.lspkind_symbols
})

-- autopairs plugin
-- this inserts braces automatically after completing function and method names
local st, _ = pcall(require, "nvim-autopairs")
if st == true then
  cmp.event:on(
    'confirm_done',
    require('nvim-autopairs.completion.cmp').on_confirm_done()
  )
end

-- this translate cmp source names to readable strings
local cmp_item_menu = {
  buffer = "Buffer",
  nvim_lsp = "LSP",
  nvim_lua = "Lua",
  wordlist = "Wordlist",
  nvim_lsp_signature_help = "Signature",
  latex_symbols = "Latex",
  snippets = "Snippets",
  emoji = "Emoji",
  calc = "Calculate"
}

-- this translates source names to highlight groups
local cmp_menu_hl_group = {
  buffer = "CmpItemMenuBuffer",
  nvim_lsp = "CmpItemMenuLSP",
  nvim_lua = "CmpItemMenuLSP",
  path = "CmpItemMenuPath",
  snippets = "CmpItemMenuSnippet"
}

-- formatting function for the modern layout (icon with inverted 
-- highlight in front)
local f_modern_deprecated = function(entry, vim_item)
  local lkind = (vim_item.kind ~= nil) and utils.rpad(vim_item.kind, T.kind_maxwidth, " ") or string.rep(" ", T.kind_maxwidth)
  -- fancy icons and a name of kind. use the reversed highlight for the icon
  -- and the normal item kind color for the actual item.
  vim_item.kind_hl_group = "CmpItemKind" .. vim_item.kind .. "Rev"
  vim_item.abbr_hl_group = "CmpItemKind" .. vim_item.kind
  vim_item.kind = "▌" .. (lspkind.symbolic or lspkind.get_symbol)(vim_item.kind) .. "▐"
  vim_item.abbr = utils.truncate(vim_item.abbr .. " ", T.abbr_maxwidth)
  -- menu is the rightmost columns, includes item kind (LSP)
  -- and the source name
  vim_item.menu = lkind .. (cmp_item_menu[entry.source.name] or string.format("%s", entry.source.name))
  -- highlight groups for item.menu
  vim_item.menu_hl_group = "FgDim"
  -- detail information (optional)
  if entry.source.name == "nvim_lsp" then
    local cmp_item = entry:get_completion_item()
    -- Display which LSP servers this item came from.
    local lspserver_name = entry.source.source.client.name
    -- Some language servers provide details, e.g. type information.
    -- The details info hide the name of lsp server, but mostly we'll have one LSP
    -- per filetype, and we use special highlights so it's OK to hide it..
    if cmp_item.detail ~= nil and #cmp_item.detail > 0 then
      vim_item.menu = lkind .. cmp_item.detail
    else
      vim_item.menu = lkind .. lspserver_name
    end
  end
  vim_item.menu = utils.truncate(vim_item.menu, T.details_maxwidth)
  return vim_item
end

-- formatting function for the modern layout (icon with inverted 
-- highlight in front)
local f_modern = function(entry, vim_item)
  local abbr_prefix = "▌" .. (lspkind.symbolic or lspkind.get_symbol)(vim_item.kind) .. "▐"
  local abbr_prefix_len = #abbr_prefix
  vim_item.abbr = abbr_prefix .. " " .. utils.truncate(vim_item.abbr, T.abbr_maxwidth)
  vim_item.menu = (cmp_item_menu[entry.source.name] or string.format("%s", entry.source.name))
  vim_item.abbr_hl_group = {
    { "CmpItemKind" .. vim_item.kind .. "Rev", range = {0, abbr_prefix_len - 1}},
    { "Fg", range = { abbr_prefix_len + 1, 50 }}
  }
  vim_item.menu_hl_group = "CmpItemMenu"
  -- detail information (optional)
  if entry.source.name == "nvim_lsp" then
    local cmp_item = entry:get_completion_item()
    -- Display which LSP servers this item came from.
    local lspserver_name = entry.source.source.client.name
    -- Some language servers provide details, e.g. type information.
    -- The details info hide the name of lsp server, but mostly we'll have one LSP
    -- per filetype, and we use special highlights so it's OK to hide it..
    if cmp_item.detail ~= nil and #cmp_item.detail > 0 then
      vim_item.menu = cmp_item.detail
      vim_item.menu_hl_group = "CmpItemMenuDetail"
    else
      vim_item.menu = lspserver_name
      vim_item.menu_hl_group = "CmpItemMenuLSP"
    end
  elseif cmp_menu_hl_group[entry.source.name] ~= nil then
    vim_item.menu_hl_group = cmp_menu_hl_group[entry.source.name]
  end
  vim_item.menu = utils.truncate(vim_item.menu, T.details_maxwidth)
  return vim_item
end

-- classic formatting function. icon + item kind in column #2
local f_classic = function(entry, vim_item)
  vim_item.kind_hl_group = "CmpItemKind" .. vim_item.kind
  vim_item.kind = (lspkind.symbolic or lspkind.get_symbol)(vim_item.kind) .. " " .. vim_item.kind
  vim_item.abbr = utils.truncate(vim_item.abbr .. " ", T.abbr_maxwidth)
  -- menu is the rightmost columns, includes item kind (LSP)
  -- and the source name
  vim_item.menu = (cmp_item_menu[entry.source.name] or string.format("%s", entry.source.name))
  -- highlight groups for item.menu
  vim_item.menu_hl_group = "FgDim"
  -- detail information (optional)
  if entry.source.name == "nvim_lsp" then
    local cmp_item = entry:get_completion_item()
    -- Display which LSP servers this item came from.
    local lspserver_name = entry.source.source.client.name
    -- Some language servers provide details, e.g. type information.
    -- The details info hide the name of lsp server, but mostly we'll have one LSP
    -- per filetype, and we use special highlights so it's OK to hide it..
    if cmp_item.detail ~= nil and #cmp_item.detail > 0 then
      vim_item.menu = cmp_item.detail
    else
      vim_item.menu = lspserver_name
    end
  end
  vim_item.menu = utils.truncate(vim_item.menu, T.details_maxwidth)
  return vim_item
end

local cmp_layouts = {
  modern =   {
    fields = { "abbr", "kind", "menu" },
    fn = f_modern
  },
  classic =   {
    fields = { "abbr", "kind", "menu" },
    fn = f_classic
  },
  modern_old =   {
    fields = { "abbr", "kind", "menu" },
    fn = f_modern_deprecated
  },
}

cmp.setup({
  preselect = cmp.PreselectMode.Item,
  enabled = true,
  completion = {
    autocomplete = PCFG.cmp_automenu == true and { cmp_types.TriggerEvent.TextChanged } or {},
    completeopt = "menu,menuone",
  },
  view = {
    docs = {
      auto_open = PCFG.cmp_show_docs
    }
  },
  performance = {
    -- using all defaults here.
    --debounce = 60,
    --throttle = 30,
    --fetching_timeout = 500,
    --confirm_resolve_timeout = 80,
    --async_budget = 10,  -- default is 1
    --max_view_entries = 200,
  },
  experimental = {
    ghost_text = T.ghost
  },
  window = {
    documentation = {
      border = Borderfactory(T.decorations[T.decoration.doc].border),
      winhighlight = T.decorations[T.decoration.doc].whl_doc,
      max_height = 20,
      scrollbar = true,
      max_width = 80,
      winblend = T.winblend.doc
    },
    completion = {
      border = Borderfactory(T.decorations[T.decoration.comp].border),
      winhighlight = T.decorations[T.decoration.comp].whl_comp,
      scrollbar = true,
      side_padding = 0,
      winblend = T.winblend.menu
    },
  },
  mapping = {
    -- invoke completion popup manually. This works regardless of completion.autocomplete option
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete({
        reason = cmp.ContextReason.Manual,
      }), {"i", "c"}),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<Esc>"] = cmp.mapping.close(), -- ESC close complete popup. Feels more natural than <C-e>
    ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp_types.SelectBehavior.Select }),
    ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp_types.SelectBehavior.Select }),
    ["<PageDown>"] = cmp.mapping.select_next_item({ behavior = cmp_types.SelectBehavior.Select, count = 15 }),
    ["<PageUp>"] = cmp.mapping.select_prev_item({ behavior = cmp_types.SelectBehavior.Select, count = 15 }),
    ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
    ["<Insert>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
    ['<f1>']  = {
      i = function(fallback)
        if cmp.visible() then
          if cmp.visible_docs() then
            cmp.close_docs()
            PCFG.cmp_show_docs = false
          else
            cmp.open_docs()
            PCFG.cmp_show_docs = true
          end
          cmp.setup({
            view = {
              docs = {
                auto_open = PCFG.cmp_show_docs
              }
            }
          })
        else
          fallback()
        end
      end
    },
    ["<C-Up>"] = cmp.mapping.scroll_docs(-4),
    ["<C-Down>"] = cmp.mapping.scroll_docs(4),
  },
  formatting = {
    fields = cmp_layouts[PCFG.cmp_layout].fields,
    format = cmp_layouts[PCFG.cmp_layout].fn
  },
  sources = {
    { name = "nvim_lsp", priority = 110, group_index = 1, max_item_count = 50, trigger_characters = {".", ":", "->", "::" }, keyword_length = 1 },
    { name = "path", priority = 30 },
    { name = "snippets", priority = 70, group_index = 1, keyword_length = 2 },
    { name = "nvim_lsp_signature_help", priority = 110, keyword_length = 1 },
    { name = 'wordlist', priority = 55, group_index = 2, keyword_length = 3 },
    { name = 'rpncalc' },
    { name = 'emoji', priority = 10, max_item_count = 40 },        -- cmp-emoji source
    { name = 'nvim_lua', priority = 100, trigger_characters = {"."}, keyword_length = math.huge },    -- nvim lua api completion source
    { name = 'buffer', priority = 60, group_index = 2, keyword_length = 2,
      option = {
        max_indexed_line_length = 1024,
        keyword_pattern = [[\k\+]],
        get_bufnrs = function()
          local buf = vim.api.nvim_get_current_buf()
          local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
          if CFG.cmp.buffer_ft_allowed[ft] == nil then
            return {}
          end
          if CGLOBALS.cur_bufsize > T.buffer_maxsize then -- 300kb
            vim.notify("File " .. vim.api.nvim_buf_get_name(buf) .. " too big, cmp_buffer disabled.", vim.log.levels.INFO)
            return {}
          end
          return { buf }
        end
      }
    },
    { name = "latex_symbols",
      option = {
        strategy = 0,
        group_index = 2
      }
    }
  },
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      -- function(...) return cmp_helper.compare.deprioritize_snippet(...) end,
--      function(...)
--        return cmp_helper.compare.prioritize_argument(...)
--      end,
--      function(...)
--        return cmp_helper.compare.deprioritize_underscore(...)
--      end,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order
    }
  }
})

-- Command line completion
cmp.setup.cmdline("/", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = { { name = "buffer" } },
})

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
  completion = {
    completeopt = "menu,menuone,noselect",
    autocomplete = T.autocomplete == true and { cmp_types.TriggerEvent.TextChanged } or {}
  }
})
 -- Custom sorting/ranking for completion items.
cmp_helper.compare = {
  -- Deprioritize items starting with underscores (private or protected)
  deprioritize_underscore = function(lhs, rhs)
    local l = (lhs.completion_item.label:find "^_+") and 1 or 0
    local r = (rhs.completion_item.label:find "^_+") and 1 or 0
    if l ~= r then return l < r end
  end,
  -- Prioritize items that ends with "= ..." (usually for argument completion).
  prioritize_argument = function(lhs, rhs)
    local l = (lhs.completion_item.label:find "=$") and 1 or 0
    local r = (rhs.completion_item.label:find "=$") and 1 or 0
    if l ~= r then return l > r end
  end,
  deprioritize_snippet = function(lhs, rhs)
    if lhs:get_kind() == types.lsp.CompletionItemKind.Snippet then
      return false
    end
    if rhs:get_kind() == types.lsp.CompletionItemKind.Snippet then
      return true
    end
  end
}

CGLOBALS.cmp_setup_done = true

local M = {}

--- update the CMP configuration for the content style
--- The content style consists of a formatting function and a table specifying
--- the order of the menu columns.
--- @param layout string The content style.
function M.configure_layout(layout)
  if layout ~= "classic" and layout ~= "modern" then
    vim.notify(layout .. " is not a supported cmp content layout")
    return
  end
  PCFG.cmp_layout = layout
  cmp.setup({
    formatting = {
      fields = cmp_layouts[PCFG.cmp_layout].fields,
      format = cmp_layouts[PCFG.cmp_layout].fn
    }
  })
end

--- set the CMP theme
--- This sets the border style and configures the theme for the desired menu style
--- @param theme string menu style (content)
--- @param decoration string the decoration style for the completion popup
--- @param decoration_doc string the decoration style for the documentation popup
function M.setup_theme(theme, decoration, decoration_doc)
  local kind_attr = { bold=true, reverse=false }
  --if theme == "experimental" then
  --  kind_attr = { bold=true, reverse=true }
  --end
  CFG.theme.setup({
    attrib = {
      dark = {
        cmpkind = kind_attr
      },
      light = {
        cmpkind = kind_attr
      }
    }
  })
  CFG.theme.set()
  cmp.setup({
    window = {
      documentation = {
        -- border = Tweaks.borderfactory(T.decorations[decoration_doc].border),
        border = Borderfactory("thicc"),
        winhighlight = T.decorations[decoration_doc].whl_doc
      },
      completion = {
        border = Borderfactory(T.decorations[decoration].border),
        winhighlight = T.decorations[decoration].whl_comp,
        scrollbar = true,
        side_padding = 0
      }
    }
  })
end

function M.select_layout()
  local style, decoration
  vim.ui.select({ "1. Classic Menu layout, single border ",
                  "2. Classic Menu layout, borderless    ",
                  "3. Modern Menu layout, single border  ",
                  "4. Modern Menu layout, borderless     "}, {
    prompt = "Select CMP menu appearance",
    border = "single",
    format_item = function(item) return utils.pad(item, 50, " ") end
    },
    function(choice)
      if choice ~= nil then
        local nr = string.sub(choice, 1, 1)
        if nr == "1" then
          style = "classic"
          decoration = "bordered"
        elseif nr == "2" then
          style = "classic"
          decoration = "flat"
        elseif nr == "3" then
          style = "modern"
          decoration = "bordered"
        elseif nr == "4" then
          style = "modern"
          decoration = "flat"
        end
        M.configure_layout(style)
        M.setup_theme(style, decoration, decoration)
        M.update_hl()
      end
    end)
end

function M.update_hl()
  reverse_hl_groups()
  italizemenugroups()
end

return M

