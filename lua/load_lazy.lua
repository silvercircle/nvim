local lazy = require("lazy")
lazy.setup({
    {
      "stevearc/oil.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
      -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
      lazy = true,
      config = function()
        require("plugins.oilsetup")
      end
    },
    {
      "nvim-tree/nvim-web-devicons",
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
      "jake-stewart/multicursor.nvim",
      event = "BufReadPost",
      branch = "1.0",
      config = function()
        require("plugins.others").setup.multicursor_stewart()
      end
    },
    {
      --(Tweaks.use_foldlevel_patch == true) and "silvercircle/fidget.nvim" or "j-hui/fidget.nvim",
      "j-hui/fidget.nvim",
      cond = Tweaks.notifier == "fidget",
      config = function()
        require("plugins.others").setup.fidget()
      end
    },
    {
      "nvim-lualine/lualine.nvim",
      event = "UIEnter",
      config = function()
        require("plugins.lualine_setup")
        require("plugins.lualine_setup").fixhl()
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
      dir = PCFG.is_dev and "/mnt/shared/data/code/neovim_plugins/commandpicker.nvim/" or nil,
      url = PCFG.is_dev and nil or "https://gitlab.com/silvercircle74/commandpicker.nvim",
      branch = "v1",
      lazy = true,
      event = "BufReadPost",
      config = function()
        require("commandpicker").setup({
          columns = {
            desc = { hl = "String" }
          },
          order = { "desc", "cmd", "mappings", "category" },
          custom_layout = SPL({ width = 120, height = 20, row = 5, input = "bottom", preview = false }),
          width = 120,
          height = 20,
          preserve_mode = true,
        })
      end
    },
    {
      "https://gitlab.com/silvercircle74/quickfavs.nvim",
      lazy = true,
      config = function()
        require("quickfavs").setup({
          filename = vim.fs.joinpath(vim.fn.stdpath("config"), "favs"),
          telescope_theme = require("subspace.lib").Telescope_dropdown_theme,
          picker = "snacks",
          snacks_layout = SPL({ width = 120, height = 20, row = 5, input = "top" }),
          fzf_winopts = Tweaks.fzf.winopts.narrow_small_preview,
          explorer_layout = SPL({ width = 70 })
        })
      end
    },
    -- treesitter + friends
    {
      "nvim-treesitter/nvim-treesitter",
      branch = "master",
      event = "BufReadPre",
      config = function()
        require("plugins.treesitter")
      end,
      dependencies = {
        {
          "nvim-treesitter/nvim-treesitter-context",
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
      name = "nvim-cmp",
      lazy = true,
      cond = Tweaks.completion.version == "nvim-cmp",
      event = { "InsertEnter", "CmdLineEnter" },
      dependencies = {
        "onsails/lspkind-nvim",
        { "iguanacucumber/mag-cmdline",  name = "cmp-cmdline" },
        { "iguanacucumber/mag-nvim-lsp", name = "cmp-nvim-lsp", opts = {} },
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-emoji",
        { "iguanacucumber/mag-nvim-lua", name = "cmp-nvim-lua" },
        "PhilRunninger/cmp-rpncalc",
        "kdheepak/cmp-latex-symbols",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        {
          "https://gitlab.com/silvercircle74/cmp-wordlist.nvim",
          config = function()
            require("cmp_wordlist").setup({
              wordfiles = { "wordlist.txt", "personal.txt" },
              debug = false,
              read_on_setup = false,
              watch_files = true
            })
          end
        },
        --{ 'hrsh7th/cmp-buffer' },
        { "iguanacucumber/mag-buffer",   name = "cmp-buffer" },
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
            }
          }
        }
      },
      config = function()
        require("plugins.cmp_setup")
      end
    },
    {
      "Saghen/blink.cmp",
      branch = "main",
      build = "cargo build --release",
      lazy = true,
      event = "ModeChanged",
      cond = Tweaks.completion.version == "blink",
      config = function()
        require("plugins.blink")
        vim.schedule(function() require("plugins.blink").update_hl() end)
      end,
      dependencies = {
        { "rafamadriz/friendly-snippets" },
        {
          -- 'Kaiser-Yang/blink-cmp-dictionary',
        },
        { "moyiz/blink-emoji.nvim" },
        {
          "https://gitlab.com/silvercircle74/blink-cmp-wordlist"
        }
      }
    },
    {
      "dnlhc/glance.nvim",
      lazy = true,
      config = function()
        require("plugins.others").setup.glance()
      end
    },
    {
      "danymat/neogen",
      lazy = true,
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
            require("hover.providers.fold_preview")
            require("hover.providers.diagnostic")
            require("hover.providers.man")
          end,
          preview_opts = {
            border = Borderfactory("thicc")
          },
          preview_window = true,
          title = true
        })
      end
    },
    {
      "williamboman/mason.nvim",
      cmd = "Mason",
      config = function()
        require("mason").setup({
          ui = {
            border = Borderfactory("thicc"),
            backdrop = 100
          }
        })
      end
    },
    {
      "lewis6991/gitsigns.nvim",
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
      "petertriho/nvim-scrollbar",
      event = "BufReadPre",
      config = function()
        require("plugins.nvim-scrollbar")
        CGLOBALS.set_scrollbar()
      end,
      dependencies = {
        {
          "kevinhwang91/nvim-hlslens",
          event = "BufReadPre",
          config = function()
            require("hlslens").setup({
              build_position_cb = function(plist, _, _, _)
                require("scrollbar.handlers.search").handler.show(plist.start_pos)
              end,
              calm_down = false, -- set to true to clear all lenses when cursor moves
              nearest_float_when = "never",
              nearest_only = true
            })
          end
        }
      }
    },
    {
      "catgoose/nvim-colorizer.lua",
      event = "BufReadPost",
      config = function()
        require "colorizer".setup {
          filetypes = {
            "!css",
            "!sass"
          },
          user_default_options = {
            mode = "virtualtext",
            virtualtext ="",
            virtualtext_inline = "before",
            css = true
          },
          html = {
            mode = "foreground",
          }
        }
      end
    },
    {
      "nvim-tree/nvim-tree.lua",
      -- LAZY = true,
      config = function()
        require("plugins.nvim-tree")
      end
    },
    --{
    --  "zk-org/zk-nvim",
    --  lazy = true,
    --  ft = { "markdown" },
    --  config = function()
    --    require("plugins.others").setup.zk()
    --  end
    --},
    {
      "obsidian-nvim/obsidian.nvim",
      version = "*", -- recommended, use latest release instead of latest commit
      lazy = true,
      ft = "markdown",
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
      config = function()
        require("plugins.obsidian")
      end
    },
    {
      "folke/todo-comments.nvim",
      event = "BufReadPre",
      config = function()
        require("plugins.todo")
      end
    },
    {
      "goolord/alpha-nvim",
      cond = true,
      branch = "main",
      config = function()
        require("plugins.alpha")
      end
    },
    {
      "rcarriga/nvim-dap-ui",
      cond = Tweaks.dap.enabled == true,
      lazy = true,
      dependencies = {
        {
          "mfussenegger/nvim-dap",
          config = function() require("dap.nvim_dap") end
        },
        "nvim-neotest/nvim-nio"
      },
      config = function() require("dap.nvim_dap_ui") end
    },
    {
      "silvercircle/nvim-cokeline",
      lazy = true,
      event = "UIEnter",
      branch = "mine",
      config = function()
        require("plugins.cokeline")
      end
    },
    {
      "kevinhwang91/nvim-ufo",
      cond = false,
      config = function()
        require("plugins.others").setup.ufo()
      end,
      dependencies = {
        "kevinhwang91/promise-async"
      }
    },
    {
      "mfussenegger/nvim-jdtls",
      lazy = true
    },
    {
      "scalameta/nvim-metals",
      cond = LSPDEF.advanced_config.scala,
      ft = { "scala", "sbt" },
      dependencies = {
        "nvim-lua/plenary.nvim"
      }
    },
    {
      "seblyng/roslyn.nvim",
      ft = { "cs", "razor" },
      init = function()
        vim.filetype.add({
          extension = {
            razor = "razor",
            cshtml = "razor",
          }
        })
      end,
      config = function()
        require("plugins.roslyn")
      end,
      dependencies = {
        {
          "tris203/rzls.nvim",
          ft = { "razor" },
          config = function()
            require("rzls").setup({
              capabilities = require("lsp.config").get_lsp_capabilities(),
              on_attch = function(client, buf)
                ON_LSP_ATTACH(client, buf)
              end
            })
          end,
        }
      }
    },
    {
      "stevearc/quicker.nvim",
      event = "FileType qf",
      config = function()
        require("quicker").setup({
          opts = {
            number = true,
            signcolumn = "yes:3"
          }
        })
      end
    },
    {
      url = PCFG.is_dev and nil or "https://github.com/oskarrrrrrr/symbols.nvim",
      dir = PCFG.is_dev and "/mnt/shared/data/code/neovim_plugins/symbols.nvim/" or nil,
      cmd = { "Symbols", "SymbolsOpen" },
      lazy = true,
      branch = PCFG.is_dev and "experiments" or "main",
      config = function()
        require("plugins.others").setup.symbols()
      end
    },
    {
      -- url = PCFG.is_dev and "https://github.com/silvercircle/neominimap.nvim" or "https://github.com/Isrothy/neominimap.nvim",
      "Isrothy/neominimap.nvim",
      branch = "v4",
      event = "BufReadPost",
      cond = true,
      init = function()
        require("plugins.others").setup.neominimap()
      end
    },
    {
      "sindrets/diffview.nvim",
      lazy = true,
      cmd = { "DiffviewOpen" }
    },
    {
      "nmac427/guess-indent.nvim",
      event = "UIEnter",
      config = function() require("guess-indent").setup {} end,
    },
    {
      'windwp/nvim-autopairs',
      event = "InsertEnter",
      config = function()
        local npairs = require('nvim-autopairs')
        npairs.setup({})
        local Rule = require('nvim-autopairs.rule')
        npairs.add_rules({
          Rule("<", ">")
        })
      end
    }
  },
  {
    ui = {
      border = Borderfactory("thicc"),
      backdrop = 100
    },
  })
