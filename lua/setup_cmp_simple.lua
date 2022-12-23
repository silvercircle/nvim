-- nvim-cmp: completion support
vim.opt.completeopt = { "menu", "menuone", "noselect" }

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local luasnip = require("luasnip")
require("luasnip.loaders.from_snipmate").load()
local cmp = require("cmp")
local cmp_types = require("cmp.types.cmp")
local max_abbr_item_width = 40
local max_detail_item_width = 40

local lspkind = nil
if vim.g.features['lsp']['enabled'] == true then
  lspkind = require("lspkind")
end

cmp.setup({
  completion = {
    autocomplete = false,
    keyword_length = 20
  },
  preselect = cmp.PreselectMode.Item,
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  window = {
    documentation = {
      -- border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }, a rounded
      -- variant
      border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" }, -- square
    },
    completion = {
      border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
      winhighlight = "Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None",
    },
  },
  formatting = {
    format = function(entry, vim_item)
      -- Truncate the item if it is too long
      vim_item.abbr = Truncate(vim_item.abbr, max_abbr_item_width)
      if lspkind ~= nil then
        -- fancy icons and a name of kind
        vim_item.kind_symbol = (lspkind.symbolic or lspkind.get_symbol)(vim_item.kind)
        vim_item.kind = " " .. vim_item.kind_symbol .. " " .. vim_item.kind
      end
      -- The 'menu' section: source, detail information (lsp, snippet), etc.
      -- set a name for each source (see the sources section below)
      vim_item.menu = string.format("%s", entry.source.name)
      -- highlight groups for item.menu
      vim_item.menu_hl_group = ({
        buffer = "CmpItemMenuBuffer",
        nvim_lsp = "CmpItemMenuLSP",
        path = "CmpItemMenuPath",
      })[entry.source.name] -- default is CmpItemMenu
      -- detail information (optional)
      local cmp_item = entry:get_completion_item()

      if entry.source.name == "nvim_lsp" then
        -- Display which LSP servers this item came from.
        local lspserver_name = nil
        pcall(function()
          lspserver_name = entry.source.source.client.name
          vim_item.menu = lspserver_name
        end)

        -- Some language servers provide details, e.g. type information.
        -- The details info hide the name of lsp server, but mostly we'll have one LSP
        -- per filetype, and we use special highlights so it's OK to hide it..
        local detail_txt = (function(cmp_item)
          if not cmp_item.detail then
            return nil
          end

          if lspserver_name == "pyright" and cmp_item.detail == "Auto-import" then
            local label = (cmp_item.labelDetails or {}).description
            return label and (" " .. Truncate(label, 20)) or nil
          else
            return Truncate(cmp_item.detail, max_detail_item_width)
          end
        end)(cmp_item)
        if detail_txt then
          vim_item.menu = detail_txt
          vim_item.menu_hl_group = "CmpItemMenuDetail"
        end
      end

      -- Add a little bit more padding
      vim_item.menu = " " .. vim_item.menu
      return vim_item
    end,
  },
  mapping = {
    -- See ~/.vim/plugged/nvim-cmp/lua/cmp/config/mapping.lua
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete({
        reason = cmp.ContextReason.Auto,
      }), {"i", "c"}),
    ["<C-y>"] = cmp.config.disable,
    ["<Esc>"] = cmp.mapping.close(), -- ESC close complete popup. Feels more natural than <C-e>
    ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp_types.SelectBehavior.Select }),
    ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp_types.SelectBehavior.Select }),
    --    ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp_types.SelectBehavior.Insert }),
    --    ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp_types.SelectBehavior.Insert }),
    ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
    ["<Tab>"] = { -- see GH-880, GH-897
      i = function(fallback) -- see GH-231, GH-286
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
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
        elseif luasnip.jumpable(-1) then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
        else
          fallback()
        end
      end,
    },
  },
  sources = {
    -- Note: make sure you have proper plugins specified in plugins.vim
    -- https://github.com/topics/nvim-cmp
    { name = "nvim_lsp", priority = 100, keyword_length = 1, max_item_count = 40 },
--    { name = "path", priority = 30 },
    { name = "luasnip", priority = 120, keyword_length = 2 },
    { name = "nvim_lsp_signature_help", priority = 110, keyword_length = 2 },
    { name = 'emoji', priority = 120, keyword_length = 2 }  -- cmp-emoji source
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
})