local lazy = require("lazy")
lazy.setup({
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
