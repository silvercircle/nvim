-- blink.cmp configuration
-- supports some nvim-cmp sources: nvim_lua and my wordlist plugin
-- requires blink.compat

local T = Tweaks.blink
local w_border = T.border
local itemlist = nil
local M = {}

local Types = require("blink.cmp.types")

-- local workaround when using neovide. This just temporarily disables
-- the cursor animation to avoid the confusing cursor-jumping when accepting
-- suggestions with <CR>
-- reference: https://github.com/Saghen/blink.cmp/issues/1247
-- this will be fixed in both blink and a future neovide release
local disable_animation = function()
    local origin_len = vim.g.neovide_cursor_animation_length
    local origin_trail = vim.g.neovide_cursor_trail_size
    vim.g.neovide_cursor_animation_length = 0
    vim.g.neovide_cursor_trail_size = 0
    vim.defer_fn(function()
        vim.g.neovide_cursor_animation_length = origin_len
        vim.g.neovide_cursor_trail_size = origin_trail
    end, 100)
end

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
    "BlinkCmpKindDict", "BlinkCmpKindColor" }

  for _, v in ipairs(groups) do
    local hl = vim.api.nvim_get_hl(0, { name = v })
    if hl.link ~= nil then
      local fg = vim.api.nvim_get_hl(0, { name = hl.link }).fg
      vim.api.nvim_set_hl(0, v .. "Rev", { fg = fg, bg = "NONE", reverse = true, bold = true })
    end
  end
end

---@diagnostic disable-next-line
local function italizemenugroups()
  local groups = {
    "CmpItemMenu", "CmpItemMenuPath", "CmpItemMenuDetail",
    "CmpItemMenuBuffer", "CmpItemMenuSnippet", "CmpItemMenuLSP" }

  vim.iter(groups):map(function(k)
    local hl = vim.api.nvim_get_hl(0, { name = k })
    local gg = hl.link and vim.api.nvim_get_hl(0, { name = hl.link }) or hl
    vim.api.nvim_set_hl(0, k, { fg = gg.fg, bg = gg.bg, italic = true })
  end)
end

function M.update_hl()
  reverse_hl_groups()
  -- italizemenugroups()
end

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
  default = { "lsp", "path", "snippets", "buffer", "wordlist" },
  lua = { "lsp", "path", "snippets", "buffer", "wordlist" },
  text = { "lsp", "path", "snippets", "emoji", "wordlist", "buffer" }-- , "dictionary" }
}

local icon_trans = {
  ["Color"] = " ",
  ["Unit"]  = " ",
  ["Dict"]  = " "
}

require("blink.cmp").setup({
  fuzzy = {
    implementation = "rust",
    use_proximity = false,
    use_frecency = true,
    sorts = {
      "score", "sort_text"
    }
  },
  appearance = {
    -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = "normal",
    kind_icons = CFG.lspkind_symbols
  },
  keymap = {
    preset         = T.keymap_preset,
    ["<cr>"]       = { function(cmp)
      if cmp.is_visible() then
        -- see: https://github.com/Saghen/blink.cmp/issues/1247
        disable_animation()
        cmp.accept()
        return true
      else
        return
      end
    end, "fallback"
    },
    ["<Esc>"]      = { "cancel", "fallback" }, -- make <Esc> behave like <C-e>
    ["<C-Up>"]     = { "scroll_documentation_up", "fallback" },
    ["<C-Down>"]   = { "scroll_documentation_down", "fallback" },
    ["<Tab>"]      = {
      function(cmp)
        -- see: https://github.com/Saghen/blink.cmp/issues/1247
        disable_animation()
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
    ["<C-Home>"]     = {
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
    ["<C-End>"]      = {
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
    ["<C-k>"]      = {}
  },
  cmdline = {
    keymap = {
      preset = T.keymap_preset,
    },
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
        draw = {
          columns = { { "kind_icon", "label", "label_description", gap = 1 } },
        },
      }
    }
  },
  sources = {
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
      emoji = {
        score_offset = 0,
        name = "emoji",
        module = "blink-emoji"
      },
      lsp = {
        transform_items = function(_, items)
          return vim.tbl_filter(function(item)
            return (item.kind ~= Types.CompletionItemKind.Text and item.kind ~= Types.CompletionItemKind.Snippet)
          end, items)
        end
      },
      snippets = {
        -- score_offset = -2,
        min_keyword_length = 2,
        module = "blink.cmp.sources.snippets",
        name = "Snippets",
        opts = {
          friendly_snippets = true,
        }
      },
      buffer = {
        -- score_offset = -10,
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
      obsidian = {
        module = "obsidian.completion.sources.blink.refs",
        score_offset = 5,
        min_keyword_length = 3
      },
      --dictionary = {
      --  score_offset = -3,
      --  min_keyword_length = 3,
      --  max_items = 8,
      --  async = true,
      --  module = "blink-cmp-dictionary",
      --  name = "Dict",
      --  opts = {
      --    dictionary_directories = { vim.fn.expand("~/.config/nvim/dict") },
      --    get_command = "rg",
      --    get_command_args = function(prefix)
      --      return { -- make sure this command is available in your system
      --        "--color=never",
      --        "--no-line-number",
      --        "--no-messages",
      --        "--no-filename",
      --        "--ignore-case",
      --        "--",
      --        prefix
      --      }
      --    end,
      --  }
      --}
    }
  },
  completion = {
    accept = {
      --create_undo_point = true,
      resolve_timeout_ms = 5000, -- some lsps can be *that* slow, hello pyright :)
      auto_brackets = {
        kind_resolution = {
          blocked_filetypes = { 'cpp', 'typescriptreact', 'javascriptreact', 'vue', 'rust' }
        },
        semantic_token_resolution = {
          enabled = false
        }
      }
    },
    trigger = {
      prefetch_on_insert = T.prefetch,
    },
    list = {
      selection = { preselect = true, auto_insert = false }
    },
    menu = {
      enabled = true,
      auto_show = function() return PCFG.cmp_automenu end,
      border = Borderfactory(w_border),
      winblend = T.winblend.menu,
      max_height = T.window_height,
      scrollbar = T.scrollbar.menu,
      draw = {
        align_to = "kind_icon",
        padding = { 0, 1 },
        treesitter = { "lsp "},
        columns = {
          { "kind_icon", "label",       "label_description", gap = 1 },
          { "kind",      "source_name", gap = 1 }
        },
        components = {
          kind_icon = {
            text = function(ctx)
              ctx.kind_icon = icon_trans[ctx.kind] or ctx.kind_icon
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
        border = Borderfactory(w_border),
        winblend = T.winblend.doc,
        min_width = 30,
        max_width = 95,
        max_height = 35,
        scrollbar = T.scrollbar.doc,
        direction_priority = {
          menu_north = { "w", "e", "n", "s" },
          menu_south = { "w", "e", "s", "n" },
        }
      }
    },
    ghost_text = {
      enabled = function() return PCFG.cmp_ghost end,
    }
  },
  signature = {
    enabled = true,
    trigger = {
      show_on_trigger_character = false,
      show_on_insert_on_trigger_character = false
    },
    window = {
      border = Borderfactory(w_border),
    }
  }
})

CGLOBALS.blink_setup_done = true
vim.g.setkey({ "n", "i" }, vim.g.fkeys.s_f1, function()
  local cmp = require("blink.cmp")
  local status = cmp.is_signature_visible()
  if status then cmp.hide_signature() else cmp.show_signature() end
end, "Toggle signature")
return M
