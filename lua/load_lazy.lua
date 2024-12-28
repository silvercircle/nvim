local lazy = require("lazy")
lazy.setup({
  'nvim-tree/nvim-web-devicons',
  'nvim-lua/plenary.nvim',
  {
    'nvim-lualine/lualine.nvim',
    event = "UIEnter",
    config = function()
      require("plugins.lualine")
    end
  },
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
      local mc = require("multicursor-nvim")

      mc.setup({
        shallowUndo = true
      })

      -- Add cursors above/below the main cursor.
      vim.keymap.set({ "n", "v" }, "<C-up>", function() mc.addCursor("k") end)
      vim.keymap.set({ "n", "v" }, "<C-down>", function() mc.addCursor("j") end)

      -- Add a cursor and jump to the next word under cursor.
      vim.keymap.set({ "n", "v" }, "<c-n>", function() mc.addCursor("*") end)

      -- Jump to the next word under cursor but do not add a cursor.
      vim.keymap.set({ "n", "v" }, "<c-s>", function() mc.skipCursor("*") end)

      -- Rotate the main cursor.
      vim.keymap.set({ "n", "v" }, "<C-left>", mc.nextCursor)
      vim.keymap.set({ "n", "v" }, "<C-right>", mc.prevCursor)

      -- Delete the main cursor.
      vim.keymap.set({ "n", "v" }, "<leader>x", mc.deleteCursor)

      -- Add and remove cursors with control + left click.
      vim.keymap.set("n", "<c-leftmouse>", mc.handleMouse)

      vim.keymap.set({ "n", "v" }, "<c-q>", function()
        if mc.cursorsEnabled() then
          -- Stop other cursors from moving.
          -- This allows you to reposition the main cursor.
          mc.disableCursors()
        else
          mc.addCursor()
        end
      end)

      vim.keymap.set({ "n", "v" }, "<c-q>", function()
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
    end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = "main",
    event = { "BufReadPre" },
    config = function()
      require("plugins.treesitter")
    end,
  },
  --{
  --  'silvercircle/alpha-nvim',
  --  branch = "mine",
  --  config = function()
  --    require("plugins.alpha")
  --  end
  --},
  {
    'dcampos/nvim-snippy',
    lazy = true,
    config = function()
      require('snippy').setup({
        mappings = {
          is = {
            ['<Tab>'] = 'expand_or_advance',
            ['<S-Tab>'] = 'previous',
          },
          nx = {
            ['<leader>x'] = 'cut_text',
          },
        },
      })
    end
  },
  {
    'nvim-tree/nvim-tree.lua',
    config = function()
      require("plugins.nvim-tree")
    end
  },
  {
    'nvim-telescope/telescope.nvim', --  branch = '0.1.x',
    lazy = true,
    dependencies = {
      { 'nvim-telescope/telescope-fzf-native.nvim', build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build" },
      {
        'https://gitlab.com/silvercircle74/quickfavs.nvim',
        lazy = true,
        config = function()
          require("quickfavs").setup({
            telescope_theme = require("local_utils").Telescope_dropdown_theme,
          })
        end
      }
    },
    config = function()
      require("plugins.telescope_setup")
    end
  },
    -- blink (alternative to nvim-cmp)
  -- experimental, needs config!
  {
    'saghen/blink.cmp',
    -- version = '*',
    build = "cargo build --release",
    lazy = true,
    event = "ModeChanged",
    config = function()
      require("plugins.blink")
    end,
    dependencies = {
      { 'windwp/nvim-autopairs',
        config = function()
          require("nvim-autopairs").setup({})
          if __Globals.perm_config.autopair then
            require("nvim-autopairs").enable()
          else
            require("nvim-autopairs").disable()
          end
        end
      },
      {
        'https://gitlab.com/silvercircle74/cmp-wordlist.nvim',
        config = function()
          require("cmp_wordlist").setup({
            wordfiles = { 'wordlist.txt', "personal.txt" },
            debug = false,
            read_on_setup = false,
            watch_files = true,
            telescope_theme = __Telescope_dropdown_theme,
            blink_compat = true
          })
        end
      },
      {
        "saghen/blink.compat",
        -- use the latest release, via version = '*', if you also use the latest release for blink.cmp
        version = "*",
        -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
        lazy = true,
        -- make sure to set opts so that lazy.nvim calls blink.compat's setup
        opts = {},
      },
      "hrsh7th/cmp-emoji",
      "dcampos/cmp-snippy",
      'hrsh7th/cmp-nvim-lua',
      {
        "dcampos/nvim-snippy",
        lazy = true,
        config = function()
          require("snippy").setup({
            mappings = {
              is = {
                ["<Tab>"] = "expand_or_advance",
                ["<S-Tab>"] = "previous",
              },
              nx = {
                ["<leader>x"] = "cut_text",
              },
            },
          })
        end
      }
    }
  },
  -- lsp
  {
    'neovim/nvim-lspconfig',
    lazy = true,
    event = { "LspAttach" },
    dependencies = {
      'onsails/lspkind-nvim',
      {
        'dnlhc/glance.nvim',
        config = function()
          require("plugins.glance")
        end
      },
      --{
      --  "vigoux/notifier.nvim",
      --  event = "UIEnter",
      --  cond = false,
      --  lazy = true,
      --  config = function()
      --    require("notifier").setup({
      --      components = {
      --        --"nvim",
      --        -- "lsp"
      --      },
      --      notify = {
      --        min_level = 0
      --      }
      --    })
      --    -- vim.g.notifier = require("notifier")
      --  end
      --},
    },
    config = function()
      require("plugins.lsp")
    end
  },
  { 'tpope/vim-liquid', ft = "liquid" },
  {
    'tomasky/bookmarks.nvim',
    event = "UIEnter",
    config = function()
      require('bookmarks').setup({
        -- sign_priority = 8,  --set bookmark sign priority to cover other sign
        save_file = vim.fn.stdpath("state") .. "/.bookmarks", -- bookmarks save file path
        keywords = {
          ["@t"] = " ", -- mark annotation startswith @t ,signs this icon as `Todo`
          ["@w"] = " ",  -- mark annotation startswith @w ,signs this icon as `Warn`
          ["@f"] = " ", -- mark annotation startswith @f ,signs this icon as `Fix`
          ["@n"] = " ", -- mark annotation startswith @n ,signs this icon as `Note`
        }
      })
    end
  },
  {
    'kevinhwang91/nvim-hlslens', event = "BufReadPre",
    config = function()
      require("hlslens").setup({
        calm_down = false,    -- set to true to clear all lenses when cursor moves 
        nearest_float_when = "never",
        nearest_only = true
      })
    end
  },
  'lewis6991/gitsigns.nvim',
  { 'lukas-reineke/indent-blankline.nvim', event = "UIEnter", config = function() require("plugins.iblsetup") end },
  {
    'petertriho/nvim-scrollbar',
    event = "BufReadPre",
    config = function()
      require("plugins.nvim-scrollbar")
      __Globals.set_scrollbar()
    end
  },
  {
    'stevearc/dressing.nvim',
    event = { "UIEnter" },
    config = function()
      require("plugins.dressing")
    end
  },
  { 'voldikss/vim-floaterm',      cmd = { "FloatermNew", "FloatermToggle" } },
  { 'numToStr/FTerm.nvim', lazy=true },
  { 'preservim/vim-markdown',     ft = "markdown" },
  'echasnovski/mini.move',
  {
    'willothy/nvim-cokeline', branch = "main",
    event = "UIEnter",
    lazy = true,
    config = function()
      require("plugins.cokeline")
    end
  },
})
