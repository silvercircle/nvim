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
    preset = "enter"
  },
  completion = {
    menu = {
      border = "single",
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
      auto_show = true,
      window = { border = "single" }
    },
    ghost_text = {
      enabled = true
    }
  },
  signature = { window = { border = "single" } }
})
