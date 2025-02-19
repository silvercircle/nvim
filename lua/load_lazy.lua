local lazy = require("lazy")
lazy.setup({
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
    event = "BufReadPre",
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require("plugins.others").setup.fidget()
    end
  },
  'nvim-lua/plenary.nvim',
  {
    'nvim-lualine/lualine.nvim',
    event = "UIEnter",
    config = function()
      require("plugins.lualine_setup")
    end
  },
  {
    "ibhagwan/fzf-lua",
    lazy = true,
    config = function()
      require("plugins.fzf-lua_setup")
    end
  },
  {
    dir = "/mnt/shared/data/code/neovim_plugins/commandpicker.nvim/",
    branch = "v1",
    lazy = true,
    event = "BufReadPost",
    config = function()
      require("commandpicker").setup({
        columns = {
          desc = { hl = "String" }
        },
        order = { 'desc', 'cmd', 'mappings', 'category' },
        custom_layout = SPL( { width=120, height=20, row=5, input="bottom", preview = false } ),
        width = 120,
        height = 20,
        preserve_mode = true,
      })
    end
  },
  {
    dir = "/mnt/shared/data/code/neovim_plugins/quickfavs.nvim/",
    -- 'https://gitlab.com/silvercircle74/quickfavs.nvim',
    lazy = true,
    config = function()
      require("quickfavs").setup({
        filename = vim.fs.joinpath(vim.fn.stdpath("config"), "favs"),
        telescope_theme = require("local_utils").Telescope_dropdown_theme,
        picker = "snacks",
        snacks_layout = SPL( { width = 120, height = 20, row = 5, input = "top" }),
        fzf_winopts = vim.g.tweaks.fzf.winopts.narrow_small_preview,
        explorer_layout = SPL( { width = 70 })
      })
    end
  },
  -- treesitter + friends
  {
    'nvim-treesitter/nvim-treesitter',
    event = "VeryLazy",
    branch = "master",
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
      }
    }
  },
  -- cmp and all its helpers
  -- using the magazine nvim-cmp fork.
  {
    --'hrsh7th/nvim-cmp',
    "iguanacucumber/magazine.nvim",
    name = 'nvim-cmp',
    lazy = true,
    cond = vim.g.tweaks.completion.version == "nvim-cmp",
    event = { "InsertEnter", "CmdLineEnter" },
    dependencies = {
      { "iguanacucumber/mag-cmdline", name = "cmp-cmdline" },
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
    dir = "/data/mnt/shared/data/code/neovim_plugins/blink.cmp/",
    branch = "mine",
    -- 'Saghen/blink.cmp',
    -- branch = "main",
    build = "cargo build --release",
    lazy = true,
    event = "ModeChanged",
    cond = vim.g.tweaks.completion.version == "blink",
    config = function()
      require("plugins.blink")
    end,
    dependencies = {
      { "rafamadriz/friendly-snippets" },
      {
        'Kaiser-Yang/blink-cmp-dictionary',
      },
      { "moyiz/blink-emoji.nvim" },
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
        'https://gitlab.com/silvercircle74/blink-cmp-wordlist'
      },
      {
        'https://gitlab.com/silvercircle74/blink-cmp-lua'
      }
    }
  },
  {
    'neovim/nvim-lspconfig',
    lazy = true,
    event = { "BufReadPost" },
    dependencies = {
      {
        "silvercircle/nvim-navic",
        branch = "mine",
        config = function()
          require("plugins.others").setup.navic()
        end
      },
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
        cmd = { "Neogen" },
        config = function()
          require("plugins.others").setup.neogen()
        end
      },
      {
        "lewis6991/hover.nvim",
        event = "BufReadPost",
        config = function()
          require("hover").setup({
            init = function()
              -- Require providers
              require("hover.providers.lsp")
              -- require('hover.providers.gh')
              -- require('hover.providers.gh_user')
              -- require('hover.providers.jira')
              -- require('hover.providers.dictionary')
              require('hover.providers.fold_preview')
              require('hover.providers.diagnostic')
              require('hover.providers.man')
            end,
            preview_opts = {
              border = Borderfactory("thicc")
            },
            preview_window = true,
            title = true
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
      map("n", "<leader>bm", bm.bookmark_toggle) -- add or remove bookmark at current line
      map("n", "<leader>bi", bm.bookmark_ann) -- add or edit mark annotation at current line
      map("n", "<leader>bc", bm.bookmark_clean) -- clean all marks in local buffer
      map("n", "<leader>bn", bm.bookmark_next) -- jump to next mark in local buffer
      map("n", "<leader>bp", bm.bookmark_prev) -- jump to previous mark in local buffer
      map("n", "<leader>bl", bm.bookmark_list) -- show marked file list in quickfix window
      map("n", "<leader>bx", bm.bookmark_clear_all) -- removes all bookmarks
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
    "folke/snacks.nvim",
    lazy = false,
    config = function()
      require("plugins.snacks_setup")
    end
  },
  {
    "saghen/blink.nvim",
    -- all modules handle lazy loading internally
    lazy = false,
    cond = vim.g.tweaks.indent.version == "blink",
    opts = {
      indent = {
        enabled = true,
        -- start with indent guides visible
        visible = true,
        blocked = {
          buftypes = {'nofile', 'prompt', 'terminal'},
          filetypes = {'alpha', 'help', 'sysmon'},
        },
        static = {
          enabled = true,
          char = "│",
          priority = 1,
          --highlights = { 'BlinkIndentRed', 'BlinkIndentOrange', 'BlinkIndentYellow', 'BlinkIndentGreen', 'BlinkIndentViolet', 'BlinkIndentCyan' },         -- specify multiple highlights here for rainbow-style indent guides
          highlights = { "IndentBlankLineChar" },
        },
        scope = {
          enabled = true,
          char = "┃",
          priority = 1024,
          -- set this to a single highlight, such as 'BlinkIndent' to disable rainbow-style indent guides
          -- highlights = { 'BlinkIndent' },
          highlights = {
            "IndentBlanklineIndent1",
            "IndentBlanklineIndent2",
            "IndentBlanklineIndent3",
            "IndentBlanklineIndent4",
            "IndentBlanklineIndent5",
            "IndentBlanklineIndent6",
            "IndentBlanklineIndent6",
          },
          underline = {
            -- enable to show underlines on the line above the current scope
            enabled = false,
            highlights = {
              "BlinkIndentRedUnderline",
              "BlinkIndentYellowUnderline",
              "BlinkIndentBlueUnderline",
              "BlinkIndentOrangeUnderline",
              "BlinkIndentGreenUnderline",
              "BlinkIndentVioletUnderline",
              "BlinkIndentCyanUnderline",
            },
          },
        },
      },
    },
  },
  --{
  --  'lukas-reineke/indent-blankline.nvim',
  --  event = "BufReadPost",
  --  config = function()
  --    require("plugins.iblsetup")
  --  end
  --},
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
            calm_down = true,    -- set to true to clear all lenses when cursor moves
            nearest_float_when = "never",
            nearest_only = true
          })
        end
      }
    }
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
    'nvim-tree/nvim-tree.lua',
    -- cond = vim.g.tweaks.tree.version == "Nvim",
    lazy = true,
    config = function()
      require("plugins.nvim-tree")
    end
  },
  --{
  --  'nvim-neo-tree/neo-tree.nvim',
  --  cond = vim.g.tweaks.tree.version == "Neo",
  --  config = function()
  --    require("plugins.neotree")
  --  end,
  --  event = "VeryLazy",
  --  dependencies = {
  --    'MunifTanjim/nui.nvim',
  --    {
  --      's1n7ax/nvim-window-picker',
  --      config = function()
  --        require("window-picker").setup({
  --          hint = 'floating-big-letter'
  --        })
  --      end
  --    }
  --  }
  --},
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
    'goolord/alpha-nvim',
    cond = true,
    branch = "main",
    config = function()
      require("plugins.alpha")
    end
  },
  --{
  --  'mfussenegger/nvim-dap',
  --  lazy = true,
  --  dependencies = {
  --    'nvim-neotest/nvim-nio',
  --    {
  --      'rcarriga/nvim-dap-ui',
  --      config = function()
  --        require("dap.nvim_dap_ui")
  --      end
  --    }
  --  },
  --  config = function()
  --    require("dap.nvim_dap")
  --  end
  --},
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = function()
      require("inc_rename").setup()
    end
  },
  {
    'gabrielpoca/replacer.nvim',
    ft = { "qf" }
  },
  {
    'silvercircle/nvim-cokeline', lazy = true, event="UIEnter",
    branch = "mine",
    config = function()
      require("plugins.cokeline")
    end
  },
  {
    'silvercircle/outline.nvim',
    branch = 'mine',
    cmd = { "Outline", "OutlineOpen", "OutlineClose" },
    lazy = true,
    dependencies = {
      {
        'epheien/outline-treesitter-provider.nvim'
      }
    },
    config = function()
      require("plugins.outline_setup")
    end
  },
  {
    'kevinhwang91/nvim-ufo',
    cond = false,
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
  --{
  --  "MaximilianLloyd/ascii.nvim",
  --  dependencies = {
  --    "MunifTanjim/nui.nvim"
  --  }
  --},
  {
    'seblyng/roslyn.nvim',
    cond = (vim.g.tweaks.lsp.csharp == "roslyn"),
    ft = { "cs", "razor" },
    config = function()
      require("plugins.roslyn")
    end,
    dependencies = {
      {
        'tris203/rzls.nvim',
        config = function()
          require('rzls').setup {}
          -- revert some wrong highlight redefinitions
        end,
        init = function()
      -- we add the razor filetypes before the plugin loads
          vim.filetype.add({
            extension = {
              razor = 'razor',
              cshtml = 'razor',
            }})
        end
      }
    }
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
    "stevearc/quicker.nvim",
    event = "FileType qf",
    config = function()
      require("quicker").setup()
    end
  },
  {
    'sindrets/diffview.nvim',
    lazy = true,
  }
},
{
  ui = {
    border = Borderfactory("thicc")
  },
})
