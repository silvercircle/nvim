local border = vim.g.tweaks.blink.border
local function select_next_idx(idx, dir)
  dir = dir or 1

  local list = require "blink.cmp.completion.list"
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
    -- Sets the fallback highlight groups to nvim-cmp's highlight groups
    -- Useful for when your theme doesn't support blink.cmp
    -- Will be removed in a future release
    use_nvim_cmp_as_default = true,
    -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = "mono"
  },
  keymap = {
    preset = vim.g.tweaks.blink.keymap_preset,
    ['<C-Up>']      = { 'scroll_documentation_up', 'fallback' },
    ['<C-Down>']    = { 'scroll_documentation_down', 'fallback' },
    ["<PageDown>"]  = {
      function(cmp)
        if not cmp.is_visible() then
          return
        end
        vim.schedule(function()
          select_next_idx(5)
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
          select_next_idx(5, -1)
        end)
        return true
      end,
      'fallback'
    }
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer', 'snippy', 'emoji', 'wordlist' },
    providers = {
      snippy = {
        name = "snippy",
        module = 'blink.compat.source'
      },
      emoji = {
        name = "emoji",
        module = 'blink.compat.source'
      },
      wordlist = {
        name = "wordlist",
        module = 'blink.compat.source'
      }
    }
  },
  completion = {
    menu = {
      border = border,
      draw = {
       columns = {
          { "label", "label_description", gap = 2 },
          { "kind_icon", "kind", gap = 2 }
        },
        -- columns = { { "kind_icon" }, { "label", "label_description", gap = 2 } },
        components = {
          item_idx = {
            text = function(ctx) return ctx.idx == 10 and "0" or ctx.idx >= 10 and " " or tostring(ctx.idx) end,
          }
        }
      }
    },
    documentation = {
      auto_show = vim.g.tweaks.blink.auto_doc,
      window = { border = border }
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
