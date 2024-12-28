-- blink.cmp configuration
-- supports some nvim-cmp sources: emoji, snippy, nvim_lua and my wordlist plugin
-- requires blink.compat

local T = vim.g.tweaks.blink
local border = T.border
local list = require "blink.cmp.completion.list"

--- workaround for missing feature (scroll completion window page-wise)
--- @param idx number: number of entries to scroll
--- @param dir? number: direction to scroll (+1 to scroll down, -1 to scroll up, defaults to 1)-
--- this respects the cycle setting and ensures no invalid entries can be
--- selected.
--- reference: https://github.com/Saghen/blink.cmp/issues/569
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
    use_nvim_cmp_as_default = T.use_cmp_hl,
    -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = "mono",
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
    default = { 'lsp', 'path', 'buffer', 'snippets', 'emoji', 'wordlist', 'nvim_lua' },
    providers = {
      emoji = {
        name = "emoji",
        module = 'blink.compat.source'
      },
      wordlist = {
        name = "wordlist",
        module = 'blink.compat.source',
        min_keyword_length = 2
      },
      lsp = {
        score_offset = 10
      },
      nvim_lua = {
        name = 'nvim_lua',
        module = 'blink.compat.source',
        score_offset = 8
      },
      -- disable the snippets source, we use nvim-snippy
      -- LSP snippets are not affected by this
      snippets = {
        module = 'blink.cmp.sources.snippets',
        name = "Snippets",
        opts = {
          friendly_snippets = true,
        }
      },
      buffer = {
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
      }
    }
  },
  completion = {
    accept = {
      create_undo_point = false,
    },
    trigger = {
      prefetch_on_insert = T.prefetch
    },
    list = {
      selection = "manual"
    },
    menu = {
      auto_show = T.auto_show,
      border = border,
      max_height = T.window_height,
      draw = {
        align_to = 'label',
        treesitter = {"lua"},
        padding = 1,
        columns = {
          { "kind_icon", "sep1", "label", "label_description", gap = 0 },
          { "kind", "source_name", gap = 1 }
        },
        components = {
          label = {
            ellipsis = true,
            width = { fill = true, max = T.label_max_width }
          },
          sep = {
            text = function() return "▌ " end,
            highlight = "BlinkCmpMenuBorder",
          },
          sep1 = {
            text = function() return "┃" end,
            highlight = "BlinkCmpMenuBorder",
          },
          sep_end = {
            text = function() return "▐" end,
            highlight = "BlinkCmpMenuBorder",
          }
        }
      }
    },
    documentation = {
      auto_show = T.auto_doc,
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
      enabled = T.ghost_text
    }
  },
  signature = {
    enabled = true,
    window = { border = border }
  }
})
