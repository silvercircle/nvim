-- blink.cmp configuration
-- supports some nvim-cmp sources: emoji, snippy, nvim_lua and my wordlist plugin
-- requires blink.compat

local T = vim.g.tweaks.blink
local border = T.border
local itemlist = nil

--- workaround for missing feature (scroll completion window page-wise)
--- @param idx number: number of entries to scroll
--- @param dir? number: direction to scroll (+1 to scroll down, -1 to scroll up, defaults to 1)-
--- this respects the cycle setting and ensures no invalid entries can be
--- selected.
--- reference: https://github.com/Saghen/blink.cmp/issues/569
local function select_next_idx(idx, dir)
  dir = dir or 1

  if itemlist == nil then
    itemlist = require("blink.cmp.completion.list")
  end

  if #itemlist.items == 0 then
    return
  end

  local target_idx
  -- haven't selected anything yet
  if itemlist.selected_item_idx == nil then
    if dir == 1 then
      target_idx = idx
    else
      target_idx = #itemlist.items - idx
    end
  elseif itemlist.selected_item_idx == #itemlist.items then
    if dir == 1 then
      target_idx = 1
    else
      target_idx = #itemlist.items - idx
    end
  elseif itemlist.selected_item_idx == 1 and dir == -1 then
    target_idx = #itemlist.items - idx
  else
    target_idx = itemlist.selected_item_idx + (idx * dir)
  end

  -- clamp
  if target_idx < 1 then
    target_idx = 1
  elseif target_idx > #itemlist.items then
    target_idx = #itemlist.items
  end

  itemlist.select(target_idx)
end

-- create the reverse highlight groups for the kind icon in the first
-- column.
local function reverse_hl_groups()
  local groups = {
  "BlinkCmpKindDefault", "BlinkCmpKind", "BlinkCmpMenuPath",
  "BlinkCmpKindStruct", "BlinkCmpKindConstructor", "BlinkCmpKindMethod",
  "BlinkCmpKindModule", "BlinkCmpKindClass", "BlinkCmpKindVariable",
  "BlinkCmpKindProperty", "BlinkCmpKindField", "BlinkCmpKindFunction",
  "BlinkCmpKindKeyword", "BlinkCmpKindText", "BlinkCmpKindUnit",
  "BlinkCmpKindConstant", "BlinkCmpKindEnum", "BlinkCmpKindEnumMember",
  "BlinkCmpKindSnippet", "BlinkCmpKindOperator", "BlinkCmpKindInterface",
  "BlinkCmpKindValue", "BlinkCmpKindTypeParameter", "BlinkCmpKindFile",
  "BlinkCmpKindFolder", "BlinkCmpKindEvent"}

  for _,v in ipairs(groups) do
    local hl = vim.api.nvim_get_hl(0, { name = v })
    if hl.link ~= nil then
      local fg = vim.api.nvim_get_hl(0, { name = hl.link }).fg
      vim.api.nvim_set_hl(0, v .. "Rev", { fg = fg, bg = "NONE", reverse = true, bold = true })
    end
  end
end

local function italizemenugroups()
  local groups = {
    "CmpItemMenu", "CmpItemMenuPath", "CmpItemMenuDetail",
    "CmpItemMenuBuffer", "CmpItemMenuSnippet", "CmpItemMenuLSP" }

  for _,v in ipairs(groups) do
    local fg, bg, name
    local hl = vim.api.nvim_get_hl(0, { name = v })
    if hl.link ~= nil then
      name = hl.link
    else
      name = v
    end
    fg = vim.api.nvim_get_hl(0, { name = name }).fg
    bg = vim.api.nvim_get_hl(0, { name = name }).bg
    vim.api.nvim_set_hl(0, v, { fg = fg, bg = bg, italic = true })
  end
end

reverse_hl_groups()
italizemenugroups()

-- this maps source names to highlight groups
local blink_menu_hl_group = {
  buffer = "CmpItemMenuBuffer",
  lsp = "CmpItemMenuLSP",
  lua = "CmpItemMenuLSP",
  path = "CmpItemMenuPath",
  snippets = "CmpItemMenuSnippet",
  wordlist = "CmpItemMenuBuffer"
}

require("blink.cmp").setup({
  appearance = {
    -- Will be removed in a future release
    use_nvim_cmp_as_default = T.use_cmp_hl,
    -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = "normal",
    kind_icons = vim.g.lspkind_symbols
  },
  keymap = {
    preset = T.keymap_preset,
    ['<Esc>']      = { 'hide', 'fallback' },     -- make <Esc> behave like <C-e>
    ['<C-Up>']     = { 'scroll_documentation_up', 'fallback' },
    ["<C-Down>"]   = { "scroll_documentation_down", "fallback" },
    ["<Tab>"]      = {
      function(cmp)
        if cmp.snippet_active() then
          return cmp.accept()
        else
          return cmp.select_and_accept()
        end
      end,
      "snippet_forward",
      "fallback"
    },
    ["<S-Tab>"]    = { "snippet_backward", "fallback" },
    -- PageUp/PageDown scroll the menu per page
    -- this uses a simple workaround
    ["<PageDown>"]  = {
      function(cmp)
        if not cmp.is_visible() then
          return
        end
        vim.schedule(function()
          select_next_idx(T.window_height - 1)
        end)
        return true
      end,
      "fallback"
    },
    ["<PageUp>"]    = {
      function(cmp)
        if not cmp.is_visible() then
          return
        end
        vim.schedule(function()
          select_next_idx(T.window_height - 1, -1)
        end)
        return true
      end,
      'fallback'
    }
  },
  sources = {
    default = { 'lsp', 'path', 'buffer', 'snippets', 'emoji', 'wordlist', 'nvim_lua', 'dictionary' },
    providers = {
      emoji = {
        score_offset = 0,
        name = "emoji",
        module = 'blink-emoji'
      },
      wordlist = {
        name = "wordlist",
        module = 'blink.compat.source',
        min_keyword_length = 2,
        score_offset = 0
      },
      lsp = {
        score_offset = 10
      },
      nvim_lua = {
        name = 'nvim_lua',
        module = 'blink.compat.source',
        score_offset = 8
      },
      snippets = {
        score_offset = 5,
        module = 'blink.cmp.sources.snippets',
        name = "Snippets",
        opts = {
          friendly_snippets = true,
        }
      },
      buffer = {
        score_offset = 3,
        module = "blink.cmp.sources.buffer",
        min_keyword_length = 3,
        opts = {
          -- enable the buffer source for filetypes listed
          -- in tweaks.blink.buffer_source_ft_allowed
          get_bufnrs = function()
            return vim.iter(vim.api.nvim_list_wins())
              :map(function(win) return vim.api.nvim_win_get_buf(win) end)
              :filter(function(buf)
                return (vim.bo[buf].buftype ~= "nofile") and ((#T.buffer_source_ft_allowed == 0) or
                  (vim.tbl_contains(T.buffer_source_ft_allowed, vim.bo[buf].filetype) == true))
              end):totable()
          end,
        }
      },
      dictionary = {
        module = 'blink-cmp-dictionary',
        name = 'Dict',
        opts = {
          get_command = {
            "rg",             -- make sure this command is available in your system
            "--color=never",
            "--no-line-number",
            "--no-messages",
            "--no-filename",
            "--ignore-case",
            "--",
            "${prefix}",                                                  -- this will be replaced by the result of 'get_prefix' function
            vim.fn.expand("~/.config/nvim/american-english"),             -- where you dictionary is dict
          },
          documentation = {
            enable = true,
            get_command = {
              "wn",                    -- make sure this command is available in your system
              "${word}",               -- this will be replaced by the word to search
              "-over"
            }
          }
        }
      }
    }
  },
  completion = {
    accept = {
      create_undo_point = false,
    },
    trigger = {
      prefetch_on_insert = T.prefetch,
      show_on_trigger_character = true
    },
    list = {
      selection = {preselect = true, auto_insert = false }
    },
    menu = {
      enabled = true,
      auto_show = function() return __Globals.perm_config.cmp_autocomplete end,
      border = vim.g.tweaks.borderfactory(T.border),
      winblend = T.winblend.menu,
      max_height = T.localwindow_height,
      draw = {
        align_to = 'kind_icon',
        treesitter = {"lsp"},
        padding = { 0, 1 },
        columns = {
          { "kind_icon", "label", "label_description", gap = 1 },
          { "kind", "source_name", gap = 1 }
        },
        components = {
          kind_icon = {
            text = function(ctx)
              return "▌" .. ctx.kind_icon .. "▐"
            end,
            highlight = function(ctx) return "BlinkCmpKind" .. ctx.kind .. "Rev" end
          },
          label = {
            ellipsis = true,
            width = { fill = true, max = T.label_max_width }
          },
          label_description = {
            ellipsis = true,
            width = { fill = true, max = T.desc_max_width },
            highlight = "Comment"
          },
          source_name = {
            text = function(ctx)
              if ctx.item.detail ~= nil and #ctx.item.detail > 1 then
                return ctx.item.detail
              end
              return ctx.source_name
            end,
            highlight = function(ctx)
              if ctx.item.detail ~= nil and #ctx.item.detail > 1 then
                return "CmpItemMenuDetail"
              else
                if blink_menu_hl_group[ctx.source_id] ~= nil then
                  return blink_menu_hl_group[ctx.source_id]
                else
                  return "CmpItemMenuDefault"
                end
              end
            end
          }
        }
      }
    },
    documentation = {
      auto_show = T.auto_doc,
      window = {
        border = vim.g.tweaks.borderfactory(T.border),
        winblend = T.winblend.doc,
        min_width = 30,
        max_width = 85,
        max_height = 30,
        direction_priority = {
          menu_north = { "w", "e", "n", "s" },
          menu_south = { "w", "e", "s", "n" },
        }
      }
    },
    ghost_text = {
      enabled = T.ghost_text
    }
  },
  signature = {
    enabled = true,
    window = {
      show_documentation = true,
      border = vim.g.tweaks.borderfactory(T.border)
    }
  }
})
