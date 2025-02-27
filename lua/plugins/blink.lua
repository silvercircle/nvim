-- blink.cmp configuration
-- supports some nvim-cmp sources: nvim_lua and my wordlist plugin
-- requires blink.compat

local T = Tweaks.blink
local border = T.border
local itemlist = nil
local M = {}

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

--- handle <Home> or <End> keys and scroll list to item begin or end
--- @param dir number 0 to scroll to begin of the list, any other numerical
--- value scrolls to the end.
local function list_home_or_end(dir)
  dir = dir or 0

  if itemlist == nil then
    itemlist = require("blink.cmp.completion.list")
  end

  if dir == 0 then
    itemlist.select(1)
  else
    itemlist.select(#itemlist.items)
  end
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
    "BlinkCmpKindFolder", "BlinkCmpKindEvent", "BlinkCmpKindReference",
    "BlinkCmpKindDict" }

  for _, v in ipairs(groups) do
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

  vim.iter(groups):map(function(k)
    local hl = vim.api.nvim_get_hl(0, { name = k })
    local name = hl.link or k
    local fg = vim.api.nvim_get_hl(0, { name = name }).fg
    local bg = vim.api.nvim_get_hl(0, { name = name }).bg
    vim.api.nvim_set_hl(0, k, { fg = fg, bg = bg, italic = true })
  end)
end

function M.update_hl()
  reverse_hl_groups()
  italizemenugroups()
end

M.update_hl()

-- this maps source names to highlight groups
local blink_menu_hl_group = {
  buffer = "CmpItemMenuBuffer",
  lsp = "CmpItemMenuLSP",
  lua = "CmpItemMenuLSP",
  path = "CmpItemMenuPath",
  snippets = "CmpItemMenuSnippet",
  wordlist = "CmpItemMenuBuffer"
}

local context_sources = {
  default = { "lsp", "path", "snippets", "buffer" },
  lua = { "lsp", "path", "snippets", "lua", "buffer" },
  text = { "lsp", "path", "snippets", "emoji", "wordlist", "dictionary", "buffer" },
}
require("blink.cmp").setup({
  fuzzy = {
    implementation = "rust"
  },
  appearance = {
    -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = "normal",
    kind_icons = vim.g.lspkind_symbols
  },
  keymap = {
    preset         = T.keymap_preset,
    ["<Esc>"]      = { "cancel", "fallback" }, -- make <Esc> behave like <C-e>
    ["<C-Up>"]     = { "scroll_documentation_up", "fallback" },
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
    ["<PageDown>"] = {
      function(cmp)
        if not cmp.is_visible() then
          return
        end
        vim.schedule(function()
          select_next_idx(T.window_height - 3)
        end)
        return true
      end,
      "fallback"
    },
    ["<PageUp>"]   = {
      function(cmp)
        if not cmp.is_visible() then
          return
        end
        vim.schedule(function()
          select_next_idx(T.window_height - 3, -1)
        end)
        return true
      end,
      "fallback"
    },
    ["<Home>"]     = {
      function(cmp)
        if not cmp.is_visible() then
          return
        end
        vim.schedule(function()
          list_home_or_end(0)
        end)
        return true
      end,
      "fallback"
    },
    ["<End>"]      = {
      function(cmp)
        if not cmp.is_visible() then
          return
        end
        vim.schedule(function()
          list_home_or_end(1)
        end)
        return true
      end,
      "fallback"
    },
    ["<f13>"]      = { "show_signature", "hide_signature", "fallback" },
    ["<C-k>"]      = {}
  },
  cmdline = {
    enabled = true,
    keymap = {
      preset = T.keymap_preset
    }, -- Inherits from top level `keymap` config when not set
    sources = function()
      local type = vim.fn.getcmdtype()
      -- Search forward and backward
      if type == "/" or type == "?" then return { "buffer" } end
      -- Commands
      if type == ":" or type == "@" then return { "cmdline" } end
      return {}
    end,
    completion = {
      trigger = {
        show_on_blocked_trigger_characters = {},
        show_on_x_blocked_trigger_characters = nil, -- Inherits from top level `completion.trigger.show_on_blocked_trigger_characters` config when not set
      },
      menu = {
        auto_show = false, -- Inherits from top level `completion.menu.auto_show` config when not set
        draw = {
          columns = { { "kind_icon", "label", "label_description", gap = 1 } },
        },
      }
    }
  },
  sources = {
    -- default = { 'lsp', 'path', 'snippets', 'emoji', 'wordlist', 'lua', 'dictionary', 'buffer' },
    default = function(_)
      if vim.bo.filetype == "lua" then
        return context_sources.lua
      elseif vim.tbl_contains({ "tex", "markdown", "typst", "html" }, vim.bo.filetype) then
        return context_sources.text
      else
        return context_sources.default
      end
    end,
    providers = {
      wordlist = {
        score_offset = 9,
        module = "blink-cmp-wordlist",
        name = "wordlist",
        opts = {
          wordfiles = { "wordlist.txt", "personal.txt", "/home/alex/foolist" },
          debug = false,
          read_on_setup = false,
          watch_files = true
        }
      },
      lua = {
        score_offset = 9,
        name = "Lua",
        module = "blink-cmp-lua"
      },
      emoji = {
        score_offset = 0,
        name = "emoji",
        module = "blink-emoji"
      },
      lsp = {
        score_offset = 10
      },
      --lazydev = {
      --  module = "lazydev.integrations.blink",
      --  score_offset = 8,
      --  name = "LazyDev"
      --},
      snippets = {
        score_offset = 5,
        min_keyword_length = 2,
        module = "blink.cmp.sources.snippets",
        name = "Snippets",
        opts = {
          friendly_snippets = true,
        }
      },
      buffer = {
        score_offset = 3,
        module = "blink.cmp.sources.buffer",
        min_keyword_length = 4,
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
        min_keyword_length = 3,
        max_items = 8,
        async = true,
        module = "blink-cmp-dictionary",
        name = "Dict",
        opts = {
          kind_icons = {
            Dict = " "
          },
          dictionary_directories = { vim.fn.expand("~/.config/nvim/dict") },
          get_command = "rg",
          get_command_args = function(prefix)
            return { -- make sure this command is available in your system
              "--color=never",
              "--no-line-number",
              "--no-messages",
              "--no-filename",
              "--ignore-case",
              "--",
              prefix
            }
          end,
        }
      }
    }
  },
  completion = {
    accept = {
      --create_undo_point = true,
      resolve_timeout_ms = 50,
      auto_brackets = {
        enabled = true,
        kind_resolution = {
          enabled = true
        },
        semantic_token_resolution = {
          enabled = true
        }
      }
    },
    trigger = {
      prefetch_on_insert = T.prefetch,
      show_on_trigger_character = true
    },
    list = {
      selection = { preselect = true, auto_insert = false }
    },
    menu = {
      enabled = true,
      auto_show = function() return PCFG.cmp_autocomplete end,
      border = Borderfactory(border),
      winblend = T.winblend.menu,
      max_height = T.window_height,
      draw = {
        align_to = "kind_icon",
        treesitter = {},
        padding = { 0, 1 },
        columns = {
          { "kind_icon", "label",       "label_description", gap = 1 },
          { "kind",      "source_name", gap = 1 }
        },
        components = {
          kind_icon = {
            text = function(ctx)
              -- ctx.kind_icon = ctx.kind == "Dict" and "󰘝 " or ctx.kind_icon
              return "▌" .. ctx.kind_icon .. "▐"
            end,
            highlight = function(ctx) return "BlinkCmpKind" .. ctx.kind .. "Rev" end
          },
          label = {
            ellipsis = true,
            width = { fill = true, max = T.label_max_width },
            highlight = function(ctx)
              -- label and label details
              local highlights = {
                { 0, #ctx.label, group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel" },
              }
              if ctx.label_detail then
                table.insert(highlights, { #ctx.label, #ctx.label + #ctx.label_detail, group = "BlinkCmpLabelDetail" })
              end

              -- characters matched on the label by the fuzzy matcher
              for _, idx in ipairs(ctx.label_matched_indices) do
                table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
              end

              return highlights
            end,
          },
          label_description = {
            text = function(ctx)
              return ctx.label_description or ""
            end,
            ellipsis = true,
            width = { fill = true, max = T.desc_max_width },
            highlight = "Comment"
          },
          source_name = {
            text = function(ctx)
              return Tweaks.blink.show_client_name == true and (ctx.item.client_name or ctx.source_name) or ctx.source_name
            end,
            highlight = function(ctx)
              --if ctx.item.detail ~= nil and #ctx.item.detail > 1 then
              --  return "CmpItemMenuDetail"
              --else
              return blink_menu_hl_group[ctx.source_id] or "CmpItemMenuDefault"
            end
          }
        }
      },
      cmdline_position = function()
        if vim.g.ui_cmdline_pos ~= nil then
          local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
          return { pos[1] - 1, pos[2] }
        end
        local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
        return { vim.o.lines - height, 0 }
      end
    },
    documentation = {
      auto_show = T.auto_doc,
      window = {
        border = Borderfactory(border),
        winblend = T.winblend.doc,
        min_width = 30,
        max_width = 95,
        max_height = 35,
        direction_priority = {
          menu_north = { "w", "e", "n", "s" },
          menu_south = { "w", "e", "s", "n" },
        }
      }
    },
    ghost_text = {
      enabled = function() return PCFG.cmp_ghost end,
      show_with_selection = true,
      show_without_selection = false,
      show_with_menu = true,
      show_without_menu = true
    }
  },
  signature = {
    enabled = true,
    trigger = {
      enabled = false,
      show_on_trigger_character = false,
      show_on_keyword = false,
      show_on_insert = false,
      show_on_insert_on_trigger_character = false
    },
    window = {
      show_documentation = true,
      border = Borderfactory(border),
    }
  }
})

CGLOBALS.blink_setup_done = true

return M
