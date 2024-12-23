-- blink.cmp configuration
-- supports some nvim-cmp sources: emoji, snippy, nvim_lua and my wordlist plugin
-- requires blink.compat

local border = vim.g.tweaks.blink.border
local list = require "blink.cmp.completion.list"

--- workaround for missing feature (scroll completion window page-wise)
--- @param idx number: number of entries to scroll
--- @param dir? number: direction to scroll (+1 to scroll down, -1 to scroll up, defaults to 1)-
--- this respects the cycle setting and ensures no invalid entries can be
--- selected.
local function select_next_idx(idx, dir)
  dir = dir or 1

  if #list.items == 0 then
    return
  end

  local target_idx
  -- haven't selected anything yet
  if list.selected_item_idx == nil then
    if dir == 1 then
      target_idx = idx
    else
      target_idx = #list.items - idx
    end
  elseif list.selected_item_idx == #list.items then
    if dir == 1 then
      target_idx = 1
    else
      target_idx = #list.items - idx
    end
  elseif list.selected_item_idx == 1 and dir == -1 then
    target_idx = #list.items - idx
  else
    target_idx = list.selected_item_idx + (idx * dir)
  end

  -- clamp
  if target_idx < 1 then
    target_idx = 1
  elseif target_idx > #list.items then
    target_idx = #list.items
  end

  list.select(target_idx)
end

require("blink.cmp").setup({
  appearance = {
    -- Will be removed in a future release
    use_nvim_cmp_as_default = vim.g.tweaks.blink.use_cmp_hl,
    -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = "mono",
    kind_icons = vim.g.lspkind_symbols
  },
  keymap = {
    preset = vim.g.tweaks.blink.keymap_preset,
    ['<Esc>']         = { 'hide', 'fallback' },     -- make <Esc> behave like <C-e>
    ['<C-Up>']      = { 'scroll_documentation_up', 'fallback' },
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
    ["<PageDown>"]  = {
      function(cmp)
        if not cmp.is_visible() then
          return
        end
        vim.schedule(function()
          select_next_idx(vim.g.tweaks.blink.window_height - 1)
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
          select_next_idx(vim.g.tweaks.blink.window_height - 1, -1)
        end)
        return true
      end,
      'fallback'
    }
  },
  sources = {
    default = { 'lsp', 'path', 'buffer', 'snippy', 'emoji', 'wordlist', 'nvim_lua' },
    providers = {
      snippy = {
        name = "snippy",
        module = 'blink.compat.source',
        score_offset = 5
      },
      emoji = {
        name = "emoji",
        module = 'blink.compat.source'
      },
      wordlist = {
        name = "wordlist",
        module = 'blink.compat.source'
      },
      lsp = {
        score_offset = 10
      },
      nvim_lua = {
        name = 'nvim_lua',
        module = 'blink.compat.source',
        score_offset = 8
      },
      snippets = {}
    }
  },
  completion = {
    trigger = {
      prefetch_on_insert = vim.g.tweaks.blink.prefetch
    },
    list = {
      selection = "auto_insert"
    },
    menu = {
      auto_show = vim.g.tweaks.blink.auto_show,
      border = border,
      max_height = vim.g.tweaks.blink.window_height,
      draw = {
        align_to_component = 'label',
        treesitter = {"lua"},
        padding = 1,
        columns = {
          { "kind_icon", "label", "label_description", gap = 1 },
          { "kind", "source_name", gap = 1 }
        },
        components = {
          label = {
            ellipsis = true,
            width = { fill = true, max = vim.g.tweaks.blink.label_max_width }
          }
        --  item_idx = {
        --    text = function(ctx) return ctx.idx == 10 and "0" or ctx.idx >= 10 and " " or tostring(ctx.idx) end,
        --  }
        }
      }
    },
    documentation = {
      auto_show = vim.g.tweaks.blink.auto_doc,
      window = {
        border = border,
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
      enabled = vim.g.tweaks.blink.ghost_text
    }
  },
  signature = {
    enabled = true,
    window = { border = border }
  }
})
