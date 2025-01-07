local lazy = require("lazy")
lazy.setup({
  {
    "luukvbaal/statuscol.nvim",
    cond = vim.g.tweaks.use_foldlevel_patch == false,
    lazy = true,
    event = "BufReadPost",
    config = function()
      -- local builtin = require("statuscol.builtin")
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        -- configuration goes here, for example:
        relculright = true,
        segments = {
          {
            sign = { namespace = { ".*" }, name = { ".*" }, maxwidth = 2, colwidth = 1, fillchar = " ", auto = false},
            click = ""
          },
          {
            sign = { namespace = { "diagnostic/sign" }, maxwidth = 2, colwidth = 2, fillchar = " ", auto = false},
            click = ""
          },
          { text = { builtin.lnumfunc }, maxwidth = 5, click = "v:lua.ScLa", },
          { text = { " ", builtin.foldfunc, " " }, click = "v:lua.ScFa" }
        }
      })
    end,
  },
  {
    "smjonas/snippet-converter.nvim",
    cond = false,
    config = function()
      local template = {
        sources = {
          snipmate = {
            vim.fn.stdpath("config") .. "/oldsnippets"
          }
        },
        output = {
          vscode_luasnip = {
            vim.fn.stdpath("config") .. "/snippets"
          }
        }
      }
      require("snippet_converter").setup {
        templates = { template }
      }
    end
  },
  'sharkdp/fd',
  {
    "lervag/vimtex",
    ft = "tex",
    init = function()
      -- Use init for configuration, don't use the more common "config".
    end
  },
  'BurntSushi/ripgrep',
  {
    'nvim-tree/nvim-web-devicons',
    config = function()
      require("nvim-web-devicons").setup({
      override = {
        zsh = {
          icon = " ",
          color = "#428850",
          cterm_color = "65",
          name = "Zsh",
        },
        cs = {
          color = "#59a006",
          icon = "󰌛",
          name = "CSharp"
        }
      },
      color_icons = true,
      default = true
      })
    end
  },
  {
    "brenton-leighton/multiple-cursors.nvim",
    cond = vim.g.tweaks.multicursor == "brenton-leighton",
    version = "*", -- Use the latest tagged version
    keys = {
      { "<C-Down>",      "<Cmd>MultipleCursorsAddDown<CR>",          mode = { "n", "i" } },
      { "<C-Up>",        "<Cmd>MultipleCursorsAddUp<CR>",            mode = { "n", "i" } },
      { "<C-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>",   mode = { "n", "i" } },
      { "<C-n>",         "<Cmd>MultipleCursorsAddMatches<CR>",       mode = { "n", "x" } },
      { "<C-n><C-n>",    "<Cmd>MultipleCursorsAddJumpNextMatch<CR>", mode = { "n", "x" } },
      { "<C-n><C-l>",    "<Cmd>MultipleCursorsLock<CR>",             mode = { "n", "x" } },
      { "<leader>n",     "<Cmd>MultipleCursorsJumpNextMatch<CR>",    mode = { "n", "x" } }
    },
    config = function()
      require("plugins.others").setup.multicursor_brenton()
    end
  },
  {
    "jake-stewart/multicursor.nvim",
    cond = vim.g.tweaks.multicursor == "jake-stewart",
    branch = "1.0",
    config = function()
      require("plugins.others").setup.multicursor_stewart()
    end
  },
  {
    --(vim.g.tweaks.use_foldlevel_patch == true) and "silvercircle/fidget.nvim" or "j-hui/fidget.nvim",
    "silvercircle/fidget.nvim",
    cond = vim.g.tweaks.notifier == "fidget",
    branch = "mine",
    lazy = true,
    event = "BufReadPost",
    config = function()
      require("plugins.others").setup.fidget()
    end
  },
  {
    "rcarriga/nvim-notify",
    cond = vim.g.tweaks.notifier == "nvim-notify",
    config = function()
      local stages_util = require("notify.stages.util")
      require("notify").setup({
        fps = 2,
        top_down = false,
        render = "default",
        level = 0,
        stages = {
          function(state)
            local next_height = state.message.height + 2
            local next_row = stages_util.available_slot(state.open_windows, next_height, "bottom_up")
            if not next_row then
              return nil
            end
            return {
              relative = "editor",
              anchor = "NE",
              width = state.message.width,
              height = state.message.height,
              col = vim.opt.columns:get(),
              row = next_row,
              border = "single",
              style = "minimal",
            }
          end,
          function()
            return {
              col = vim.opt.columns:get(),
              time = true,
            }
          end,
        }
      })
      vim.notify = require("notify")
    end
  },
  'nvim-lua/plenary.nvim',
  {
    'nvim-lualine/lualine.nvim',
    -- commit = "ef3f2ee04140aeca037bdcabafab4339da4d5b5f",
    event = "UIEnter",
    config = function()
      require("plugins.lualine_setup")
    end
  },
  -- telescope + extensions, mandatory
  {
    'nvim-telescope/telescope.nvim', --  branch = '0.1.x',
    lazy = true,
    dependencies = {
      { 'nvim-telescope/telescope-fzf-native.nvim', build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build" },
      {
        'FeiyouG/commander.nvim',
        version = "v0.1.0",
        -- dev = (vim.g.tweaks.use_foldlevel_patch == true) and true or false,
        event = { "BufReadPost" },
        config = function()
          require("plugins.command_center_setup")
        end
      },
      {
        'https://gitlab.com/silvercircle74/quickfavs.nvim',
        lazy = true,
        config = function()
          require("quickfavs").setup({
            telescope_theme = require("local_utils").Telescope_dropdown_theme
          })
        end
      }
    },
    config = function()
      require("plugins.telescope")
    end
  },
  -- treesitter + friends
  {
    'nvim-treesitter/nvim-treesitter',
    branch = "master",
    event = { "BufReadPre" },
    config = function()
      require("plugins.treesitter")
    end,
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-context',
        lazy = true,
        config = function()
          require("plugins.others").setup.treesitter_context()
        end
      },
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        cond = false,
        lazy = true,
        config = function()
        end
      }
    }
  },
  -- cmp and all its helpers
  {
    --'hrsh7th/nvim-cmp',
    "iguanacucumber/magazine.nvim",
    name = 'nvim-cmp',
    lazy = true,
    cond = vim.g.tweaks.completion.version == "nvim-cmp",
    event = { "InsertEnter", "CmdLineEnter" },
    dependencies = {
      { "iguanacucumber/mag-cmdline", name = "cmp-cmdline" },
      --'hrsh7th/cmp-cmdline',
      --'hrsh7th/cmp-nvim-lsp',
      { "iguanacucumber/mag-nvim-lsp", name = "cmp-nvim-lsp", opts = {} },
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-emoji',
      { "iguanacucumber/mag-nvim-lua", name = "cmp-nvim-lua" },
      'PhilRunninger/cmp-rpncalc',
      "kdheepak/cmp-latex-symbols",
      'hrsh7th/cmp-nvim-lsp-signature-help',
      {
        'https://gitlab.com/silvercircle74/cmp-wordlist.nvim',
        config = function()
          require("cmp_wordlist").setup({
            wordfiles = { 'wordlist.txt', "personal.txt" },
            debug = false,
            read_on_setup = false,
            watch_files = true,
            telescope_theme = __Telescope_dropdown_theme
          })
        end
      },
      --{ 'hrsh7th/cmp-buffer' },
      { "iguanacucumber/mag-buffer", name = "cmp-buffer" },
      { "rafamadriz/friendly-snippets" },
      {
        "garymjr/nvim-snippets",
        config = function()
          require("snippets").setup({
            friendly_snippets = true
          })
        end,
        keys = {
          {
            "<Tab>",
            function()
              if vim.snippet.active({ direction = 1 }) then
                vim.schedule(function()
                  vim.snippet.jump(1)
                end)
                return
              end
              return "<Tab>"
            end,
            expr = true,
            silent = true,
            mode = "i",
          },
          {
            "<Tab>",
            function()
              vim.schedule(function()
                vim.snippet.jump(1)
              end)
            end,
            expr = true,
            silent = true,
            mode = "s",
          },
          {
            "<S-Tab>",
            function()
              if vim.snippet.active({ direction = -1 }) then
                vim.schedule(function()
                  vim.snippet.jump(-1)
                end)
                return
              end
              return "<S-Tab>"
            end,
            expr = true,
            silent = true,
            mode = { "i", "s" },
          },
        },
      },
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
    },
    config = function()
      require("plugins.cmp_setup")
    end
  },
  -- blink.cmp (alternative to nvim-cmp)
  {
    'saghen/blink.cmp',
    build = "cargo build --release",
    lazy = true,
    event = "ModeChanged",
    cond = vim.g.tweaks.completion.version == "blink",
    config = function()
      require("plugins.blink")
    end,
    dependencies = {
      { "rafamadriz/friendly-snippets" },
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
      -- this is also a nvim-cmp source, usable via blink.compat
      {
        'https://gitlab.com/silvercircle74/cmp-wordlist.nvim',
        config = function()
          require("cmp_wordlist").setup({
            wordfiles = { 'wordlist.txt', "personal.txt" },
            debug = false,
            read_on_setup = false,
            watch_files = true,
            telescope_theme = __Telescope_dropdown_theme,
            -- this is needed for blink.compat.
            blink_compat = true
          })
        end
      },
      {
        "saghen/blink.compat",
        version = "*",
        lazy = true,
        opts = {},
      },
      -- cmp sources which will be used via blink.compat
      "hrsh7th/cmp-emoji",
      'hrsh7th/cmp-nvim-lua',
    }
  },
    -- lsp
  {
    "SmiteshP/nvim-navbuddy",
    lazy = true,
    cond = vim.g.tweaks.breadcrumb == "navic",
    event = "BufReadPre",
    dependencies = {
      {
        "silvercircle/nvim-navic",
        branch = "mine",
        config = function()
          require("plugins.others").setup.navic()
        end
      }
    },
    config = function()
      require("plugins.others").setup.navbuddy()
    end
  },
  {
    'neovim/nvim-lspconfig',
    lazy = true,
    event = { "LspAttach" },
    dependencies = {
      { 'Hoffs/omnisharp-extended-lsp.nvim', cond = (vim.g.tweaks.lsp.csharp == "omnisharp") },         -- omnisharp decompilation support
      { 'Decodetalkers/csharpls-extended-lsp.nvim', cond = (vim.g.tweaks.lsp.csharp == "csharp_ls") },  -- this is for csharp_ls decompilation support
      'onsails/lspkind-nvim',
      {
        'https://gitlab.com/silvercircle74/lsp_lines.nvim',
        cond = vim.g.tweaks.lsp.virtual_lines == true,
        config = function()
          require("lsp_lines").setup()
        end
      },
      {
        'dnlhc/glance.nvim',
        config = function()
          require("plugins.others").setup.glance()
        end
      },
      { "danymat/neogen",
        config = function()
          require("plugins.others").setup.neogen()
        end
      },
      {
        "lewis6991/hover.nvim",
        config = function()
          require("hover").setup({
            init = function()
              -- Require providers
              require("hover.providers.lsp")
              -- require('hover.providers.gh')
              -- require('hover.providers.gh_user')
              -- require('hover.providers.jira')
              -- require('hover.providers.man')
              -- require('hover.providers.dictionary')
            end,
            preview_opts = {
              border = __Globals.perm_config.float_borders
            },
            preview_window = false,
            title = false
          })
        end
      }
    },
    config = function()
      require("plugins.lsp")
    end
  },
  {
    'williamboman/mason.nvim',
    cmd = "Mason",
    config = function()
      require("mason").setup({
        ui = {
          border = __Globals.perm_config.float_borders
        }
      })
    end
  },
  -- { 'tpope/vim-liquid', ft = "liquid" },
  {
    'tomasky/bookmarks.nvim',
    event = "UIEnter",
    config = function()
      local bm = require "bookmarks"
      require("bookmarks").setup({
        -- sign_priority = 8,  --set bookmark sign priority to cover other sign
        save_file = vim.fn.stdpath("state") .. "/.bookmarks", -- bookmarks save file path
        keywords = {
          ["@t"] = " ", -- mark annotation startswith @t ,signs this icon as `Todo`
          ["@w"] = " ", -- mark annotation startswith @w ,signs this icon as `Warn`
          ["@f"] = " ", -- mark annotation startswith @f ,signs this icon as `Fix`
          ["@n"] = "󰈔 ", -- mark annotation startswith @n ,signs this icon as `Note`
        }
      })
      local map = vim.keymap.set
      map("n", "mm", bm.bookmark_toggle) -- add or remove bookmark at current line
      map("n", "mi", bm.bookmark_ann) -- add or edit mark annotation at current line
      map("n", "mc", bm.bookmark_clean) -- clean all marks in local buffer
      map("n", "mn", bm.bookmark_next) -- jump to next mark in local buffer
      map("n", "mp", bm.bookmark_prev) -- jump to previous mark in local buffer
      map("n", "ml", bm.bookmark_list) -- show marked file list in quickfix window
      map("n", "mx", bm.bookmark_clear_all) -- removes all bookmarks
    end
  },
  {
    'lewis6991/gitsigns.nvim',
    lazy = true,
    event = "BufReadPre",
    config = function()
      require("plugins.others").setup.gitsigns()
    end
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    event = "BufReadPre",
    config = function()
      require("plugins.iblsetup")
    end
  },
  {
    'petertriho/nvim-scrollbar',
    event = "BufReadPre",
    config = function()
      require("plugins.nvim-scrollbar")
      __Globals.set_scrollbar()
    end,
    dependencies = {
      {
        'kevinhwang91/nvim-hlslens', event = "BufReadPre",
        config = function()
          require("hlslens").setup({
            build_position_cb = function(plist, _, _, _)
              require("scrollbar.handlers.search").handler.show(plist.start_pos)
            end,
            calm_down = false,    -- set to true to clear all lenses when cursor moves
            nearest_float_when = "never",
            nearest_only = true
          })
        end
      }
    }
  },
  {
    'stevearc/dressing.nvim',
    event = { "UIEnter" },
    config = function()
      require("plugins.dressing")
    end
  },
  {
    'akinsho/toggleterm.nvim',
    lazy = true,
    config = function()
      require("plugins.others").setup.toggleterm()
    end
  },
  {
    "norcalli/nvim-colorizer.lua",
    lazy = true,
    event = { 'BufReadPre'},
    config = function()
      require "colorizer".setup {
        "css",
        "scss",
        html = {
          mode = "foreground",
        }
      }
    end
  },
  {
    'echasnovski/mini.move',
    lazy = true,
    event = { 'BufReadPre'},
    config = function()
      require("mini.move").setup()
    end
  },
  {
    'echasnovski/mini.pick',
    version = false,
    lazy = true,
    config = function()
      require("plugins.others").setup.mini_pick()
    end
  },
  {
    'echasnovski/mini.extra',
    version = false,
    lazy = true,
    config = function()
      require("plugins.others").setup.mini_extra()
    end
  },
  {
    'echasnovski/mini.files',
    version = false,
    lazy = true,
    config = function()
      require("plugins.others").setup.mini_files()
    end
  },
  {
    'nvim-tree/nvim-tree.lua',
    cond = vim.g.tweaks.tree.version == "Nvim",
    config = function()
      require("plugins.nvim-tree")
    end
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    cond = vim.g.tweaks.tree.version == "Neo",
    config = function()
      require("plugins.neotree")
    end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      {
        's1n7ax/nvim-window-picker',
        event = "VeryLazy",
        config = function()
          require("window-picker").setup({
            hint = 'floating-big-letter'
          })
        end
      }
    }
  },
  {
    "zk-org/zk-nvim",
    lazy = true,
    ft = { "markdown" },
    config = function()
      require("plugins.others").setup.zk()
    end
  },
  {
    'folke/todo-comments.nvim',
    event = "BufReadPre",
    config = function()
      require("plugins.todo")
    end
  },
  {
    'silvercircle/alpha-nvim',
    branch = "mine",
    cond = Config.plain == false,
    config = function()
      require("plugins.alpha")
    end
  },
  {
    'mfussenegger/nvim-dap',
    lazy = true,
    dependencies = {
      'nvim-neotest/nvim-nio',
      {
        'rcarriga/nvim-dap-ui',
        config = function()
          require("dap.nvim_dap_ui")
        end
      }
    },
    config = function()
      require("dap.nvim_dap")
    end
  },
  { 'kevinhwang91/rnvimr', cond = false, lazy = true, cmd = { "RnvimrToggle" } },
  {
    "smjonas/inc-rename.nvim",
    event = { "BufRead" },
    config = function()
      require("inc_rename").setup()
    end
  },
  {
    'gabrielpoca/replacer.nvim',
    ft = { "qf" }
  },
  {
    'willothy/nvim-cokeline', lazy = true, event="UIEnter", branch = "main",
    config = function()
      require("plugins.cokeline")
    end
  },
  {
    'silvercircle/outline.nvim',
    branch = 'mine',
    cmd = { "Outline", "OutlineOpen", "OutlineClose" },
    lazy = true,
    config = function()
      require("plugins.outline_setup")
    end
  },
  {
    'stevearc/aerial.nvim',
    branch = 'mine',
    cond = false,
    lazy = true,
    config = function()
      require("plugins.aerialsetup")
    end
  },
  {
    'edluffy/hologram.nvim',
    lazy = true,
    config = function()
      require("hologram").setup({})
    end
  },
  {
    'kevinhwang91/nvim-ufo',
    cond = false,
    --event = "UIEnter",
    config = function()
      require("plugins.others").setup.ufo()
    end,
    dependencies = {
      'kevinhwang91/promise-async'
    }
  },
  {
    'mfussenegger/nvim-jdtls',
    lazy = true
  },
  {
    "scalameta/nvim-metals",
    ft = { "scala", "sbt" },
  },
  {
    "folke/trouble.nvim",
    event = "LspAttach",
    config = function()
      require("plugins.others").setup.trouble()
    end
  },
  {
    "MaximilianLloyd/ascii.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim"
    }
  },
  {
    'seblj/roslyn.nvim',
    cond = (vim.g.tweaks.lsp.csharp == "roslyn"),
    ft = { "cs" },
    config = function()
      require("plugins.roslyn")
    end
  },
  {
    "jlcrochet/vim-razor",
    ft = { "cshtml", "razor" }
  },
  {
    "carbon-steel/detour.nvim",
    lazy = true,
    cmd = { "Detour", "DetourCurrentWindow" },
    config = function()
      vim.keymap.set("n", "<c-w><enter>", ":DetourCurrentWindow<cr>")
    end
  },
  {
    'folke/edgy.nvim',
    cond = false,
    event = "VeryLazy",
    config = function()
      require("plugins.edgy")
    end
  },
  {
    "ibhagwan/fzf-lua",
    lazy = true,
    event = "BufReadPost",
    config = function()
      require("plugins.fzf-lua_setup")
    end
  },
  --{
  --  "folke/noice.nvim",
  --  event = "VeryLazy",
  --  config = function()
  --    require("plugins.noice")
  --  end
  --}
},
{
  ui = {
    border = __Globals.perm_config.float_borders
  },
  --dev = {
  --  path = "/mnt/shared/data/code/neovim_plugins",
  --  patterns = { "FeiyouG" },
  --  fallback = false
  --}
})
