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

local cmp_item_menu = {
  buffer = "Buffer",
  nvim_lsp = "LSP",
  nvim_lua = "Lua",
  wordlist = "Wordlist translation",
  nvim_lsp_signature_help = "Signature",
  latex_symbols = "Latex",
}

local cmp_menu_hl_group = {
  buffer = "CmpItemMenuBuffer",
  nvim_lsp = "CmpItemMenuLSP",
  path = "CmpItemMenuPath",
}

cmp.setup({
  preselect = cmp.PreselectMode.Item,
  enabled = true,
  completion = {
    autocomplete = Config.cmp.autocomplete == true and { cmp_types.TriggerEvent.TextChanged } or { },
    keyword_length = Config.cmp.autocomplete_kwlen,
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
  experimental = {
    ghost_text = Config.cmp.ghost_text
  },
  window = {
    -- respect the perm_config.telescope_borders setting. "squared", "rounded" or "none"
    documentation = {
      border = __Globals.perm_config.cmp_borders == "single" and { "┌", "─", "┐", "│", "┘", "─", "└", "│" }
               or ( __Globals.perm_config.cmp_borders == "rounded" and { '╭', '─', '╮', '│', '╯', '─', '╰', '│' } or { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' } ) , -- square
      winhighlight = "Normal:CmpFloat,FloatBorder:CmpBorder,CursorLine:Visual,Search:None",
    },
    completion = {
      border = __Globals.perm_config.cmp_borders == "single" and { "┌", "─", "┐", "│", "┘", "─", "└", "│" }
               or ( __Globals.perm_config.cmp_borders == "rounded" and { '╭', '─', '╮', '│', '╯', '─', '╰', '│' } or { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' } ) , -- square
      winhighlight = "Normal:CmpFloat,FloatBorder:CmpBorder,CursorLine:Visual",
    },
  },
  mapping = {
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
    ["<Tab>"] = { -- see GH-880, GH-897
      i = function(fallback) -- see GH-231, GH-286
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
    ['<C-g>'] = function()
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
    end,
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
    ["<C-Up>"] = cmp.mapping.scroll_docs(-4),
    ["<C-Down>"] = cmp.mapping.scroll_docs(4),
  },
  formatting = {
    format = function(entry, vim_item)
      -- Truncate the item if it is too long
      vim_item.abbr = __Globals.truncate(vim_item.abbr, Config.cmp.max_abbr_item_width)
        -- fancy icons and a name of kind
      vim_item.kind_symbol = (lspkind.symbolic or lspkind.get_symbol)(vim_item.kind)
      vim_item.kind = " " .. vim_item.kind_symbol .. " " .. Config.iconpad .. vim_item.kind
      -- The 'menu' section: source, detail information (lsp, snippet), etc.
      -- set a name for each source (see the sources section below)
      vim_item.menu = (cmp_item_menu)[entry.source.name] or string.format("%s", entry.source.name)
      -- highlight groups for item.menu
      vim_item.menu_hl_group = (cmp_menu_hl_group)[entry.source.name] -- default is CmpItemMenu
      -- detail information (optional)
      local cmp_item = entry:get_completion_item()
      if entry.source.name == "nvim_lsp" then
        -- Display which LSP servers this item came from.
        local lspserver_name = entry.source.source.client.name
        if lspserver_name == "lua_ls" then lspserver_name = "Lua" end
        vim_item.menu = lspserver_name
        -- Some language servers provide details, e.g. type information.
        -- The details info hide the name of lsp server, but mostly we'll have one LSP
        -- per filetype, and we use special highlights so it's OK to hide it..
        local detail_txt = (function(cmp_item)
          if not cmp_item.detail then
            return nil
          end
          -- OmniSharp sometimes provides details (e.g. for overloaded operators). So leave some
          -- space for them.
          if lspserver_name == "omnisharp" then
            return #cmp_item.detail > 0 and utils.rpad(string.sub(cmp_item.detail, 1, 8), 10, " ") .. "OmniSharp" or "          OmniSharp"
          end
          if lspserver_name == "pyright" and cmp_item.detail == "Auto-import" then
            local label = (cmp_item.labelDetails or {}).description
            return label and (" " .. __Globals.truncate(label, 20)) or nil
          else
            return lspserver_name == "Lua" and "Lua" or __Globals.truncate(cmp_item.detail, Config.cmp.max_detail_item_width)
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
  sources = {
    { name = "nvim_lsp", priority = 110, group_index = 1, max_item_count = 40 },
    { name = "path", priority = 30 },
    { name = "snippy", priority = 100, group_index = 1, keyword_length = 2 },
    { name = "nvim_lsp_signature_help", priority = 110, keyword_length = 2 },
    { name = 'wordlist', priority = 10, group_index = 2, keyword_length = 3 },
    { name = 'emoji', priority = 10 },        -- cmp-emoji source
    { name = 'nvim_lua', priority = 111 },    -- nvim lua api completion source
    { name = 'buffer', priority = 10, group_index = 2,
      option = {
        max_indexed_line_length = 256,
        get_bufnrs = function()
          local buf = vim.api.nvim_get_current_buf()
          local ft = vim.api.nvim_buf_get_option(buf, "filetype")
          if Config.cmp.buffer_ft_allowed[ft] == nil then
            return {}
          end
          if __Globals.cur_bufsize > Config.cmp.buffer_maxsize then -- 300kb
            vim.notify("File " .. vim.api.nvim_buf_get_name(buf) .. " too big, cmp_buffer disabled.", vim.log.levels.INFO)
            return {}
          end
          return { buf }
        end
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
      cmp.config.compare.locality,
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
    completeopt = "menu,menuone"
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

-- vim.cmd("doautocmd CmdLineEnter")

