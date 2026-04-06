local lazy = require("lazy")
lazy.setup({
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
      "Saghen/blink.cmp",
      branch = "main",
      commit = "cd79f572971c58784ca72551af29af3a63da9168",
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
            require('hover.providers.dictionary')
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
          -- filetypes = {
          --   "!css",
          --   "!sass"
          -- },
          user_default_options = {
            names = false,
            mode = "virtualtext",
            virtualtext ="",
            virtualtext_inline = "before",
            css = true
          },
          filetypes = {
            html = {
              mode = "foreground",
            },
            lua = {
              mode = "virtualtext"
            },
            css = {
              names = true
            }
          }
        }
      end
    },
    {
      "rcarriga/nvim-dap-ui",
      cond = Tweaks.dap.enabled == true and Tweaks.dap.ui == "dap-ui",
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
      "miroshQa/debugmaster.nvim",
      cond = Tweaks.dap.enabled == true and Tweaks.dap.ui == "debugmaster",
      event = { "TabNew" },
      dependencies = {
        {
          "mfussenegger/nvim-dap",
          config = function() require("dap.nvim_dap") end
        },
        "nvim-neotest/nvim-nio"
      },
      config = function() require("dap.debugmaster") end
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
          branch = "pullDiags",
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
      "Isrothy/neominimap.nvim",
      branch = "v4",
      lazy = true,
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
    --{
    --  "nmac427/guess-indent.nvim",
    --  event = "UIEnter",
    --  config = function() require("guess-indent").setup {} end,
    --},
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
    },
    {
      'kaarmu/typst.vim',
      ft = { "typst" },
      cond = false,
      config = function()
        vim.g.typst_conceal = 1
        vim.g.typst_conceal_math = 0
        vim.g.typst_conceal_emoji= 1
        vim.g.typst_auto_open_quickfix = 0
        vim.g.typst_folding = 1
        vim.g.typst_foldnested = 1
      end
    }
  },
  {
    ui = {
      border = Borderfactory("thicc"),
      backdrop = 100
    },
  })
