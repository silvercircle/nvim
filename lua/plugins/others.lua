-- various setup functions for smaller plugins
local M = {}

M.setup = {
  neogen = function()
    local i = require("neogen.types.template").item
    require("neogen").setup({
      enabled = true,
      snippet_engine = "nvim",
      languages = {
        cs = {
          template = {
            annotation_convention = "xmldoccustom",
            -- override the xmldoc configuration. I prefer the /** ... */ comment syntax over ///.
            -- Both is valid xmldoc
            xmldoccustom = {
              { nil,         "/**",                                    { no_results = true, type = { "func", "file", "class", "type" } } },
              { nil,         " * <summary>",                           { no_results = true, type = { "func", "file", "class", "type" } } },
              { nil,         " * $1",                                  { no_results = true, type = { "func", "file", "class", "type" } } },
              { nil,         " * </summary>",                          { no_results = true, type = { "func", "file", "class", "type" } } },
              { nil,         " */",                                    { no_results = true, type = { "func", "file", "class", "type" } } },

              { nil,         "/**",                                    { type = { "func", "class", "type" } } },
              { nil,         " * <summary>",                           {} },
              { nil,         " * $1",                                  {} },
              { nil,         " * </summary>",                          {} },
              { i.Parameter, ' * <param name="%s">$1</param>',         { type = { "func", "type" } } },
              { i.Tparam,    ' * <typeparam name="%s">$1</typeparam>', { type = { "func", "class" } } },
              { i.Return,    " * <returns>$1</returns>",               { type = { "func", "type" } } },
              { nil,         " */",                                    { type = { "func", "class", "type" }} }
            }
          }
        },
        lua = {
          template = {
            annotation_convention = "emmylua"
          }
        }
      }
    })
  end,

  navic = function()
    require("nvim-navic").setup({
      highlight = true,
      lazy_update_context = true,
      icons = CFG.lspkind_symbols,
    })
  end,

  treesitter_context = function()
    require("treesitter-context").setup {
      enable = true,                  -- Enable this plugin (Can be enabled/disabled later via commands)
      multiwindow = false,
      max_lines = 12,                 -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 0,          -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      line_numbers = false,
      multiline_threshold = 20,       -- Maximum number of lines to show for a single context
      trim_scope = "outer",           -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      mode = "cursor",                -- Line used to calculate context. Choices: 'cursor', 'topline'
      -- Separator between context and content. Should be a single character string, like '-'.
      -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      separator = "─",
      zindex = 10,       -- The Z-index of the context window
      on_attach = function()
        return true
      end
    }
  end,

  zk = function()
    require("zk").setup({
      -- can be "telescope", "fzf", "fzf_lua", "minipick", or "select" (`vim.ui.select`)
      -- it's recommended to use "telescope", "fzf", "fzf_lua", or "minipick"
      picker = "fzf_lua",

      lsp = {
        -- `config` is passed to `vim.lsp.start_client(config)`
        config = {
          cmd = { "zk", "lsp" },
          name = "zk",
          -- on_attach = ...
          -- etc, see `:h vim.lsp.start_client()`
        },
        -- automatically attach buffers in a zk notebook that match the given filetypes
        auto_attach = {
          enabled = false,
          filetypes = { "markdown", "liquid" },
        },
      }
    })
  end,

  ufo = function()
    require("ufo").setup({
      open_fold_hl_timeout = 0,
      --provider_selector = function(bufnr, filetype, buftype)
      provider_selector = function()
        return { "treesitter" }
      end,
      fold_virt_text_handler = CGLOBALS.ufo_virtual_text_handler,
      preview = {
        mappings = {
          scrollU = "<Up>",
          scrollD = "<Down>",
          jumpTop = "<Home>",
          jumpBot = "<End>"
        },
        win_config = {
          max_height = 30,
          winhighlight = "Normal:TreeNormalNC",
          border = Borderfactory("thicc")
        }
      }

    })
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
    vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
    vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith)
  end,

  trouble = function()
    local trouble = require("trouble")
    vim.g.setkey({ "n", "i" }, "<C-t>t", function() trouble.open() end, "Toggle Trouble window")
    vim.g.setkey({ "n", "i" }, "<C-t>q", function() trouble.close() end, "Toggle Trouble window")
    vim.g.setkey({ "n", "i" }, "<C-t><Down>", function() trouble.next({ skip_groups = true, jump = true }) end, "Trouble next item")
    vim.g.setkey({ "n", "i" }, "<C-t><Up>", function() trouble.previous({ skip_groups = true, jump = true }) end, "Trouble previous item")
    require("trouble").setup({
      position = "bottom",
      height = 15,
      width = 50,
      action_keys = {
        open_tab = {}
      }
    })
    vim.cmd("hi TroubleText guibg=NONE")
    vim.cmd("hi TroubleLocation guibg=NONE")
  end,

  gitsigns = function()
    require("gitsigns").setup({
      signs = {
        add          = { text = "┃" },
        change       = { text = "┃" },
        delete       = { text = "━" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
      },
      signs_staged = {
        add          = { text = "▌" },
        change       = { text = "▌" },
        delete       = { text = "━" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
      },
      signs_staged_enable = true,
      _refresh_staged_on_update = false,
      signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
      numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir = {
        interval = 2000,
        follow_files = true,
      },
      attach_to_untracked = true,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      sign_priority = 65535,
      update_debounce = 1000,
      status_formatter = nil, -- Use default
      max_file_length = 40000, -- Disable if file is longer than this (in lines)
      preview_config = {
        -- Options passed to nvim_open_win
        border = "single",

        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1
      }
      --yadm = {
      --  enable = false,
      --},
    })
  end,

  cabinet = function()
    require("cabinet"):setup()
  end,

  mini_extra = function()
    require("mini.extra").setup()
  end,

  mini_files = function()
    require("mini.files").setup({
      windows = {
        preview = true,
        width_preview = 80
      }
    })
  end,

  mini_pick = function()
    require("mini.pick").setup()
  end,

  -- https://github.com/j-hui/fidget.nvim
  fidget = function()
    CGLOBALS.notifier = require("fidget").notify
    vim.notify = require("fidget").notify
    require("fidget").setup({
      progress = {
        poll_rate = 1,
        ignore_done_already = true,
        ignore_empty_message = true,
        display = {
          render_limit = 4,
          skip_history = false
        }
      },
      notification = {
        override_vim_notify = true,
        history_size = 80,
        filter = vim.log.levels.TRACE,
        configs = {
          --default = require("fidget.notification").default_config
        },
        window = {
          winblend = 0,
          normal_hl = "NormalFloat",
          border = Borderfactory("thicc")
        }
      }
    })
  end,

  -- https://github.com/jake-stewart/multicursor.nvim
  multicursor_stewart = function()
    local mc = require("multicursor-nvim")

    mc.setup({
      shallowUndo = true
    })

    -- Add cursors above/below the main cursor.
    vim.keymap.set({ "n", "v" }, "<C-up>", function() mc.lineAddCursor(-1) end)
    vim.keymap.set({ "n", "v" }, "<C-down>", function() mc.lineAddCursor(1) end)
    vim.keymap.set({ "n", "v" }, "<M-up>", function() mc.lineSkipCursor(-1) end)
    vim.keymap.set({ "n", "v" }, "<M-down>", function() mc.lineSkipCursor(1) end)

    -- Add a cursor and jump to the next word under cursor.
    vim.keymap.set({ "n", "v" }, "<c-n>", function() mc.matchAddCursor(1) end)

    -- Jump to the next word under cursor but do not add a cursor.
    vim.keymap.set({ "n", "v" }, "<M-n>", function() mc.matchSkipCursor(1) end)

    -- add a cursor for all matches
    vim.keymap.set({"n", "x"}, "<leader>a", mc.matchAllAddCursors)

    -- Rotate the main cursor.
    vim.keymap.set({ "n", "v" }, "<C-left>", mc.nextCursor)
    vim.keymap.set({ "n", "v" }, "<C-right>", mc.prevCursor)

    -- Add and remove cursors with control + left click.
    vim.keymap.set("n", "<c-leftmouse>", mc.handleMouse)

    vim.keymap.set({ "n", "v" }, "<c-q>", function()
      mc.toggleCursor()
    end)

    vim.keymap.set({ "n", "v" }, "<leader>q", function()
      -- clone every cursor and disable the originals
      mc.duplicateCursors()
    end)

    vim.keymap.set("n", "<esc>", function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      elseif mc.hasCursors() then
        mc.clearCursors()
      else
        -- Default <esc> handler.
      end
    end)

    -- Align cursor columns.
    vim.keymap.set("n", "<leader>a", mc.alignCursors)

    -- Split visual selections by regex.
    vim.keymap.set("v", "S", mc.splitCursors)

    -- Append/insert for each line of visual selections.
    vim.keymap.set("v", "I", mc.insertVisual)
    vim.keymap.set("v", "A", mc.appendVisual)

    -- match new cursors within visual selections by regex.
    vim.keymap.set("v", "M", mc.matchCursors)

    -- Rotate visual selection contents.
    vim.keymap.set("v", "<leader>t", function() mc.transposeCursors(1) end)
    vim.keymap.set("v", "<leader>T", function() mc.transposeCursors(-1) end)

    -- Customize how cursors look.
    -- this is done by my theme which has support for this plugin. You may need to uncomment
    -- this for different themes
    -- vim.api.nvim_set_hl(0, "MultiCursorSign", { link = "Normal" })
    -- vim.api.nvim_set_hl(0, "MultiCursorCursor", { link = "Cursor" })
    -- vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "Visual" })
    -- vim.api.nvim_set_hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
    -- vim.api.nvim_set_hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    local hl = vim.api.nvim_set_hl
    hl(0, "MultiCursorSign", { link = "SignColumn"})
  end,

  -- https://github.com/brenton-leighton/multiple-cursors.nvim
  multicursor_brenton = function()
    require("multiple-cursors").setup({
      opts = {
        pre_hook = function()
          vim.cmd("set nocul")
          -- vim.cmd("NoMatchParen")
        end,
        post_hook = function()
          vim.cmd("set cul")
          -- vim.cmd("DoMatchParen")
        end,
        custom_key_maps = {
          {"n", "<Leader>>", function() require("multiple-cursors").align() end}
        }
      },
      keys = {
        {"<C-q>", "<Cmd>MultipleCursorsMouseAddDelete<CR>", mode = {"n", "i"}, desc = "Add or remove a cursor"},
      }
    })
  end,
  colortils = function()
    require("colortils").setup({})
  end,
  symbols = function()
    local Symbols = require("symbols")
    local r = require("symbols.recipes")
    Symbols.setup(r.DefaultFilters, CFG.SIDEBAR_FancySymbols, {
      sidebar = {
        auto_resize = {
          enabled = false,
          min_width = 10,
          max_width = 80
        },
        fixed_width = PCFG.outline.width,
        show_inline_details = true,
        open_direction = "right",
        on_open_make_windows_equal = false,
        show_guide_lines = true,
        unfold_on_goto = true,
        hide_cursor = false,
        cursor_follow = true,
        show_details_pop_up = false,
        chars = {
          hl_guides = "OutlineGuides",
          hl_foldmarker = "Operator"
        },
        hl_details = "String",
        on_symbols_complete = function(ctx)
          vim.api.nvim_set_option_value("statusline", "  Outline: " .. (ctx.pname or "None") ..
            (" (" .. ctx.symbolcount .. ")" ) .. (ctx.followmode and " follow" or ""), { win = ctx.id_win })
          -- unfold for some filetypes. Not a good idea for others (like lua) because
          -- they have excessiv symbol spam so keep the list collapsed.
          local unfold_for = { "tex", "markdown", "typst", "zig", "cpp", "cs", "scala", "toml", "python" }
          if vim.tbl_contains(unfold_for, vim.bo.filetype) then
            Symbols.sidebar.symbols.unfold_all(0)
          end
        end
      },
      providers = {
        lsp = {
          timeout_ms = 15000
        }
      }
    })
    local utility_key = Tweaks.keymap.utility_key
    vim.g.setkey({ 'n', 'i', 'v' }, utility_key ..  'sf', function()
      Symbols.sidebar.symbols.unfold_all(0)
    end, "SymbolsSidebar Unfold all")

    vim.g.setkey({ 'n', 'i', 'v' }, utility_key ..  'sg', function()
      Symbols.sidebar.symbols.fold_all(0)
    end, "SymbolsSidebar Fold all")

    vim.g.setkey({ 'n', 'i', 'v' }, utility_key ..  'ss', function()
      Symbols.sidebar.view_set(0, "search")
      Symbols.sidebar.focus(0)
    end, "SymbolsSidebar Search")

    vim.g.setkey({ 'n', 'i', 'v' }, utility_key ..  'sc', function()
      Symbols.sidebar.symbols_cursor_follow_toggle(0)
    end, "SymbolsSidebar Toggle follow")

    vim.g.setkey({ 'n', 'i', 'v' }, utility_key ..  'sd', function()
      Symbols.sidebar.symbols.goto_symbol_under_cursor(0)
    end, "SymbolsSidebar show symbol under cursor")
  end,
  glance = function()
    local glance = require("glance")
    local actions = glance.actions
    glance.setup({
      height = 25, -- Height of the window
      border = {
        enable = true, -- Show window borders. Only horizontal borders allowed
        top_char = "—",
        bottom_char = "—",
      },
      preview_win_opts = { -- Configure preview window options
        cursorline = true,
        number = true,
        wrap = false,
        foldcolumn = "0",
      },
      list = {
        position = "right", -- Position of the list window 'left'|'right'
        width = 0.25,   -- 33% width relative to the active window, min 0.1, max 0.5
      },
      theme = {         -- This feature might not work properly in nvim-0.7.2
        enable = false, -- Will generate colors for the plugin based on your current colorscheme
        mode = "darken", -- 'brighten'|'darken'|'auto', 'auto' will set mode based on the brightness of your colorscheme
      },
      mappings = {
        list = {
          ["j"] = actions.next, -- Bring the cursor to the next item in the list
          ["k"] = actions.previous, -- Bring the cursor to the previous item in the list
          ["<Down>"] = actions.next,
          ["<Up>"] = actions.previous,
          ["<Tab>"] = actions.next_location,   -- Bring the cursor to the next location skipping groups in the list
          ["<S-Tab>"] = actions.previous_location, -- Bring the cursor to the previous location skipping groups in the list
          ["<C-Up>"] = actions.preview_scroll_win(5),
          ["<C-Down>"] = actions.preview_scroll_win(-5),
          ["v"] = actions.jump_vsplit,
          ["s"] = actions.jump_split,
          ["t"] = actions.jump_tab,
          ["<CR>"] = actions.jump,
          ["o"] = actions.jump,
          ["<A-Left>"] = actions.enter_win("preview"), -- Focus preview window
          ["q"] = actions.close,
          ["Q"] = actions.close,
          ["<Esc>"] = actions.close,
        },
        preview = {
          ["Q"] = actions.close,
          ["<Tab>"] = actions.next_location,
          ["<S-Tab>"] = actions.previous_location,
          ["<A-Right>"] = actions.enter_win("list"), -- Focus list window
        },
      },
      folds = {
        fold_closed = "",
        fold_open = "",
        folded = false, -- Automatically fold list on startup
      },
      indent_lines = {
        enable = true,
        icon = "│",
      },
      winbar = {
        enable = true, -- Available strating from nvim-0.8+
      },
    })
  end,
  neominimap = function()
    -- The following options are recommended when layout == "float"
    vim.opt.wrap = false
    vim.opt.sidescrolloff = 36   -- Set a large value

    vim.g.neominimap = {
      x_multiplier = 3,
      auto_enable = false,
      log_level = vim.log.levels.OFF,
      layout = "split",
      delay = 800,
      split = {
        minimap_width = 15,
        fix_width = true,
        direction = "rightbelow",
        close_if_last_window = true
      },
      exclude_filetypes = {
        "help",
        "bigfile",
        "NvimTree"
      },
      exclude_buftypes = {
        "nofile",
        "nowrite",
        "quickfix",
        "terminal",
        "prompt",
      },
      treesitter = { enabled = Tweaks.minimap.features.treesitter },
      git = { enabled = Tweaks.minimap.features.git, mode = "icon" },
      search = { enabled = Tweaks.minimap.features.search },
      diagnostic = {
        enabled = Tweaks.minimap.features.diagnostic,
        mode = "line",
        severity = vim.diagnostic.severity.HINT
      },
      winopt = function(opt, _)
        opt.statuscolumn = ""
        opt.winbar = ""
        opt.signcolumn = "no"
        opt.statusline = "Minimap"
      end
    }
  end
}

return M

