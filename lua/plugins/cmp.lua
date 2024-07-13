-- nvim-cmp: completion support
local utils = require("local_utils")
local cmp_helper = {}
-- file types that allow buffer indexing for the cmp_buffer source

-- helper function for cmp <TAB> mapping.
local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local snippy = require("snippy")
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
  symbol_map = vim.g.lspkind_symbols
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

local cmp_item_menu = {
  buffer = "Buffer",
  nvim_lsp = "LSP",
  nvim_lua = "Lua",
  wordlist = "Wordlist",
  nvim_lsp_signature_help = "Signature",
  latex_symbols = "Latex",
  snippy = "Snippy",
  emoji = "Emoji",
  calc = "Calculate"

}

local cmp_menu_hl_group = {
  buffer = "CmpItemMenuBuffer",
  nvim_lsp = "CmpItemMenuLSP",
  path = "CmpItemMenuPath",
}

-- formatting function for the experimental ("modern") layout
local f_exp = function(entry, vim_item)
  local kind_maxlen = 13
  -- fancy icons and a name of kind
  vim_item.menu = utils.lpad(vim_item.kind, kind_maxlen, " ")
  vim_item.menu_hl_group = "CmpItemKind" .. vim_item.kind
  vim_item.kind = "▌" .. (lspkind.symbolic or lspkind.get_symbol)(vim_item.kind) -- .. "▐"
  -- Truncate the item if it is too long
  vim_item.abbr = utils.truncate(vim_item.abbr, vim.g.tweaks.cmp.abbr_maxwidth)
  -- The 'menu' section: source, detail information (lsp, snippet), etc.
  -- set a name for each source (see the sources section below)
  -- vim_item.menu = (cmp_item_menu)[entry.source.name] or string.format("%s", entry.source.name)
  -- highlight groups for item.menu
  -- detail information (optional)
  --local cmp_item = entry:get_completion_item()
  local dmw = vim.g.tweaks.cmp.details_maxwidth
  --vim_item.menu = vim_item.menu .. (cmp_item_menu[entry.source.name] or string.format("%s", entry.source.name))
  if vim.fn.strcharlen(vim_item.menu) < dmw then
    vim_item.menu = utils.lpad(vim_item.menu, dmw, " ")
  elseif vim.fn.strcharlen(vim_item.menu) > dmw then
    vim_item.menu = utils.truncate(vim_item.menu, dmw)
  end
  return vim_item
end

-- formatting function for the standard layout
local f_std = function(entry, vim_item)
  local menu_is_lsp = false
  -- fancy icons and a name of kind
  vim_item.kind_symbol = (lspkind.symbolic or lspkind.get_symbol)(vim_item.kind)
  -- vim_item.kind = " " .. vim_item.kind_symbol .. " " .. Config.iconpad .. vim_item.kind
  if vim_item.kind ~= nil then
    vim_item.kind = vim_item.kind_symbol .. " " .. vim_item.kind
  else
    vim_item.kind = vim_item.kind_symbol .. " "
  end
  vim_item.abbr = utils.truncate(vim_item.abbr, vim.g.tweaks.cmp.abbr_maxwidth)
  -- The 'menu' section: source, detail information (lsp, snippet), etc.
  -- set a name for each source (see the sources section below)
  vim_item.menu = cmp_item_menu[entry.source.name] or string.format("%s", entry.source.name)
  -- highlight groups for item.menu
  vim_item.menu_hl_group = cmp_menu_hl_group[entry.source.name]     -- default is CmpItemMenu
  -- detail information (optional)
  local cmp_item = entry:get_completion_item()
  local dmw = vim.g.tweaks.cmp.details_maxwidth
  if entry.source.name == "nvim_lsp" then
    -- Display which LSP servers this item came from.
    local lspserver_name = entry.source.source.client.name
    if lspserver_name == "lua_ls" then lspserver_name = "Lua" end
    vim_item.menu = lspserver_name
    menu_is_lsp = true
    -- Some language servers provide details, e.g. type information.
    -- The details info hide the name of lsp server, but mostly we'll have one LSP
    -- per filetype, and we use special highlights so it's OK to hide it..
    local detail_txt = (function(this_item)
      if not this_item.detail then
        return nil
      end
      -- OmniSharp sometimes provides details (e.g. for overloaded operators). So leave some
      -- space for them.
      if lspserver_name == "omnisharp" then
        --return #this_item.detail > 0 and utils.rpad(string.sub(this_item.detail, 1, 8), 10, " ") .. "OmniSharp" or "          OmniSharp"
        return this_item.detail .. "OmniSharp"
      end
      return lspserver_name == "Lua" and "Lua" or this_item.detail
    end)(cmp_item)
    if detail_txt then
      vim_item.menu = detail_txt
    end
  end
  vim_item.menu_hl_group = "CmpItemMenuDetail"
  if menu_is_lsp == true then
    if vim.fn.strcharlen(vim_item.menu) > dmw then
      vim_item.menu = utils.truncate(vim_item.menu, dmw)
    end
  else
    vim_item.menu = utils.lpad(vim_item.menu, vim.g.tweaks.cmp.details_maxwidth, " ")
  end
  return vim_item
end

local cmp_layouts = {
  -- classic layout field order
  standard =   {
    fields = { "abbr", "kind", "menu" },
    fn = f_std
  },
  -- modern. kind icon in front of symbol name
  experimental = {
    fields = { "kind", "abbr", "menu" },
    fn = f_exp
  }
}

cmp.setup({
  preselect = cmp.PreselectMode.Item,
  enabled = true,
  completion = {
    autocomplete = vim.g.tweaks.cmp.autocomplete == true and { cmp_types.TriggerEvent.TextChanged } or {},
    completeopt = "menu,menuone",
  },
  snippet = {
    expand = function(args)
      snippy.expand_snippet(args.body)
    end,
  },
  view = {
    docs = {
      auto_open = __Globals.perm_config.cmp_show_docs
    }
  },
  performance = {
    --debounce = 60,
    --throttle = 30,
    --fetching_timeout = 500,
    --confirm_resolve_timeout = 80,
    --async_budget = 10,  -- default is 1
    --max_view_entries = 200,
  },
  experimental = {
    ghost_text = vim.g.tweaks.cmp.ghost
  },
  window = {
    documentation = {
      border = vim.g.tweaks.borderfactory(vim.g.tweaks.cmp.decorations[vim.g.tweaks.cmp.decoration.doc].border),
      winhighlight = vim.g.tweaks.cmp.decorations[vim.g.tweaks.cmp.decoration.doc].whl_doc,
      max_height = 20,
      max_width = 80
    },
    completion = {
      border = vim.g.tweaks.borderfactory(vim.g.tweaks.cmp.decorations[vim.g.tweaks.cmp.decoration.comp].border),
      winhighlight = vim.g.tweaks.cmp.decorations[vim.g.tweaks.cmp.decoration.comp].whl_comp,
      scrollbar = false,
      side_padding = 1
    },
  },
  mapping = {
    -- invoke completion popup manually. This works regardless of completion.autocomplete option
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete({
        reason = cmp.ContextReason.Manual,
      }), {"i", "c"}),
    -- ["<C-Space>"] = cmp.mapping.complete({reason = cmp.ContextReason.Auto}),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<Esc>"] = cmp.mapping.close(), -- ESC close complete popup. Feels more natural than <C-e>
    ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp_types.SelectBehavior.Select }),
    ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp_types.SelectBehavior.Select }),
    ["<PageDown>"] = cmp.mapping.select_next_item({ behavior = cmp_types.SelectBehavior.Select, count = 15 }),
    ["<PageUp>"] = cmp.mapping.select_prev_item({ behavior = cmp_types.SelectBehavior.Select, count = 15 }),
    ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
    ["<Insert>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
    ["<Tab>"] = {
      i = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif snippy.can_expand_or_advance() then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>(snippy-expand-or-advance)", true, true, true), "")
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end,
    },
    ["<S-Tab>"] = {
      i = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif snippy.can_jump(-1) then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>(snippy-previous)", true, true, true), "")
        else
          fallback()
        end
      end,
    },
    -- toggle docs, remember it in a permconfig setting
    ['<f1>']  = {
      i = function(fallback)
        if cmp.visible() then
          if cmp.visible_docs() then
            cmp.close_docs()
            __Globals.perm_config.cmp_show_docs = false
          else
            cmp.open_docs()
            __Globals.perm_config.cmp_show_docs = true
          end
          cmp.setup({
            view = {
              docs = {
                auto_open = __Globals.perm_config.cmp_show_docs
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
    fields = cmp_layouts[__Globals.perm_config.cmp_layout].fields,
    format = cmp_layouts[__Globals.perm_config.cmp_layout].fn
  },
  sources = {
    { name = "nvim_lsp", priority = 110, group_index = 1, max_item_count = 50, trigger_characters = {".", ":", "->", "::" }, keyword_length = 2 },
    { name = "path", priority = 30 },
    { name = "snippy", priority = 100, group_index = 1, keyword_length = 3 },
    { name = "nvim_lsp_signature_help", priority = 110, keyword_length = 2 },
    { name = 'wordlist', priority = 10, group_index = 2, keyword_length = 3 },
    { name = 'rpncalc' },
    { name = 'emoji', priority = 10, max_item_count = 40 },        -- cmp-emoji source
    { name = 'nvim_lua', priority = 111, trigger_characters = {"."}, keyword_length = math.huge },    -- nvim lua api completion source
    { name = 'buffer', priority = 10, group_index = 2, keyword_length = 3,
      option = {
        max_indexed_line_length = 1024,
        keyword_pattern = [[\k\+]],
        get_bufnrs = function()
          local buf = vim.api.nvim_get_current_buf()
          local ft = vim.api.nvim_buf_get_option(buf, "filetype")
          if Config.cmp.buffer_ft_allowed[ft] == nil then
            return {}
          end
          if __Globals.cur_bufsize > vim.g.tweaks.cmp.buffer_maxsize then -- 300kb
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
      -- function(...) return cmp_buffer:compare_locality(...) end,
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      function(...) return cmp_helper.compare.deprioritize_snippet(...) end,
--      function(...)
--        return cmp_helper.compare.prioritize_argument(...)
--      end,
--      function(...)
--        return cmp_helper.compare.deprioritize_underscore(...)
--      end,
      cmp.config.compare.recently_used,
      -- cmp.config.compare.locality,
      cmp.config.compare.kind,
      --cmp.config.compare.sort_text,
      --cmp.config.compare.length,
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
    autocomplete = vim.g.tweaks.cmp.autocomplete == true and { cmp_types.TriggerEvent.TextChanged } or {}
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

local M = {}

--- update the CMP configuration for the content style
--- The content style consists of a formatting function and a table specifying
--- the order of the menu columns.
--- @param layout string The content style.
function M.configure_layout(layout)
  if layout ~= "standard" and layout ~= "experimental" then
    vim.notify(layout .. " is not a supported cmp content layout")
    return
  end
  __Globals.perm_config.cmp_layout = layout
  cmp.setup({
    formatting = {
      fields = cmp_layouts[__Globals.perm_config.cmp_layout].fields,
      format = cmp_layouts[__Globals.perm_config.cmp_layout].fn
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
  Config.theme.setup({
    attrib = {
      dark = {
        cmpkind = kind_attr
      },
      light = {
        cmpkind = kind_attr
      }
    }
  })
  Config.theme.set()
  cmp.setup({
    window = {
      documentation = {
        border = vim.g.tweaks.borderfactory(vim.g.tweaks.cmp.decorations[decoration_doc].border),
        winhighlight = vim.g.tweaks.cmp.decorations[decoration_doc].whl_doc
      },
      completion = {
        border = vim.g.tweaks.borderfactory(vim.g.tweaks.cmp.decorations[decoration].border),
        winhighlight = vim.g.tweaks.cmp.decorations[decoration].whl_comp,
        scrollbar = false,
        side_padding = 1
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
          style = "standard"
          decoration = "bordered"
        elseif nr == "2" then
          style = "standard"
          decoration = "flat"
        elseif nr == "3" then
          style = "experimental"
          decoration = "bordered"
        elseif nr == "4" then
          style = "experimental"
          decoration = "flat"
        end
        M.configure_layout(style)
        M.setup_theme(style, decoration, decoration)
      end
    end)
end
return M

