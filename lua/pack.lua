-- manage plugins with vim.pack()
-- considered experimental for now
local M = {}

local rtp_to_add = {
  "nvim-treesitter-context",
  "lualine.nvim",
  "nvim-cokeline",
  "plenary.nvim",
  "nvim-jdtls",
  "nvim-metals",
  "snacks.nvim",
  "fzf-lua",
  "todo-comments.nvim",
  "gitsigns.nvim",
  "quickfavs.nvim",
  "oil.nvim",
  "neominimap.nvim",
  "glance.nvim",
  "commandpicker.nvim",
  "hover.nvim",
  "nvim-colorizer.lua",
  "quicker.nvim",
  "typst.nvim",
  "nvim-hlslens",
  "nvim-scrollbar",
  "nvim-dap",
  "symbols.nvim",
  "roslyn.nvim",
  "rzls.nvim"
}

local autocmd = vim.api.nvim_create_autocmd
local auto_pre, auto_post, auto_lsp = nil, nil, nil
local auto_pre_done, auto_post_done, auto_lsp_done = false, false, false
local agroup_pack = vim.api.nvim_create_augroup("pack", {})

-- this function rebuilds the rust fuzzy matcher for blink.cmp
-- used as a hook
local function build_blink(params)
  vim.notify('Building blink.cmp', vim.log.levels.INFO)
  local obj = vim.system({ 'cargo', 'build', '--release' }, { cwd = params.path }):wait()
  if obj.code == 0 then
    vim.notify('Building blink.cmp done', vim.log.levels.INFO)
  else
    vim.notify('Building blink.cmp failed', vim.log.levels.ERROR)
  end
end

function M.setup()
  -- vim.pack BEGIN (experimental)
  vim.pack.add({
    { src = "https://github.com/jake-stewart/multicursor.nvim" },
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
    { src = "https://github.com/nvim-lualine/lualine.nvim" },
    { src = "https://github.com/nmac427/guess-indent.nvim" },
    { src = "https://github.com/silvercircle/nvim-cokeline" },
    { src = "https://github.com/FractalCodeRicardo/eyes-wide-bright" },
    { src = "https://github.com/mfussenegger/nvim-jdtls" },
    { src = "https://github.com/scalameta/nvim-metals" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/folke/snacks.nvim" },
    { src = "https://github.com/ibhagwan/fzf-lua" },
    { src = "https://github.com/goolord/alpha-nvim"},
    { src = "https://github.com/folke/todo-comments.nvim"},
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/williamboman/mason.nvim" },
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://gitlab.com/silvercircle74/quickfavs.nvim" },
    { src = "https://github.com/sindrets/diffview.nvim" },
    { src = "https://github.com/Isrothy/neominimap.nvim" },
    { src = "https://github.com/windwp/nvim-autopairs" },
    { src = "https://github.com/dnlhc/glance.nvim" },
    { src = "https://gitlab.com/silvercircle74/commandpicker.nvim" },
    { src = "https://github.com/lewis6991/hover.nvim" },
    { src = "https://github.com/catgoose/nvim-colorizer.lua" },
    { src = "https://github.com/stevearc/quicker.nvim" },
    { src = "https://github.com/kaarmu/typst.vim" },
    { src = "https://github.com/kevinhwang91/nvim-hlslens" },
    { src = "https://github.com/petertriho/nvim-scrollbar" },
    { src = "https://github.com/seblyng/roslyn.nvim" },
    { src = "https://github.com/tris203/rzls.nvim" }
  })
  require("plugins.others").setup.multicursor_stewart()
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
      },
      css = {
        icon = "",
        color = "#20c0c0",
        name = "CSS"
      }
    },
    color_icons = true,
    default = true
  })

  require("mason").setup({
    ui = {
      border = Borderfactory("thicc"),
      backdrop = 100
    },
    registries = {
      "github:mason-org/mason-registry",
      "github:Crashdummyy/mason-registry",
    }
  })

  require("quickfavs").setup({
    filename = vim.fs.joinpath(vim.fn.stdpath("config"), "favs"),
    telescope_theme = require("subspace.lib").Telescope_dropdown_theme,
    picker = "snacks",
    snacks_layout = SPL({ width = 120, height = 20, row = 5, input = "top" }),
    fzf_winopts = Tweaks.fzf.winopts.narrow_small_preview,
    explorer_layout = SPL({ width = 70 })
  })

  local npairs = require("nvim-autopairs")
  npairs.setup({})
  local Rule = require("nvim-autopairs.rule")
  npairs.add_rules({
    Rule("<", ">")
  })
  require("plugins.alpha")
  require("plugins.treesitter")
  require("plugins.others").setup.treesitter_context()
  require("guess-indent").setup()
  require("eyes-wide-bright").setup({
    mode = "normal"       -- options: "normal", "warm", "cold"
  })
  require("plugins.snacks_setup")
  require("plugins.fzf-lua_setup")

  -- condidtional plugins
  -- most of the conditions are defined in tweaks-dist.lua
  if Tweaks.notifier == "fidget" then
    vim.pack.add({ "https://github.com/j-hui/fidget.nvim" })
    require("plugins.others").setup.fidget()
  end

  -- NvimTree was chosen as file tree
  if Tweaks.tree.version == "Nvim" then
    vim.pack.add({ "https://github.com/nvim-tree/nvim-tree.lua" })
    require("plugins.nvim-tree")
    table.insert(rtp_to_add, "nvim-tree.lua")
  end

  -- NeoTree was chosen as file tree
  if Tweaks.tree.version == "Neo" then
    vim.pack.add({ "https://github.com/nvim-neo-tree/neo-tree.nvim" })
    vim.pack.add({ "https://github.com/MunifTanjim/nui.nvim" })
    require("plugins.neotree")
    table.insert(rtp_to_add, "neo-tree.nvim")
  end

  require("plugins.others").setup.neominimap()

  -- blink.cmp
  if Tweaks.completion.version == "blink" then
    vim.pack.add({
      {
        src = "https://github.com/Saghen/blink.cmp",
        --commit = "cd79f572971c58784ca72551af29af3a63da9168"
        version = "main",
        post_install = build_blink,
        post_checkout = build_blink
      },
      {
        src = "https://github.com/rafamadriz/friendly-snippets"
      },
      {
        src = "https://github.com/moyiz/blink-emoji.nvim"
      },
      {
        src = "https://gitlab.com/silvercircle74/blink-cmp-wordlist"
      }
    })
    table.insert(rtp_to_add, "blink.cmp")
    table.insert(rtp_to_add, "blink-cmp-wordlist")
  end

  -- DAP
  if Tweaks.dap.enabled == true then
    vim.pack.add({ "https://github.com/mfussenegger/nvim-dap", "https://github.com/nvim-neotest/nvim-nio" })

    if Tweaks.dap.ui == "dap-ui" then
      vim.pack.add({ "https://github.com/rcarriga/nvim-dap-ui" })
      table.insert(rtp_to_add, "nvim-dap-ui")
    end
    if Tweaks.dap.ui == "debugmaster" then
      vim.pack.add( { "https://github.com/miroshQa/debugmaster.nvim" })
      table.insert(rtp_to_add, "debugmaster.nvim")
    end
  end

  -- needed for the roslyn/razor plugins
  vim.filetype.add({
    extension = {
      razor = "razor",
      cshtml = "razor",
    }
  })

  -- Symbols sidebar
  -- special case, use a local repo in case we are in dev mode
  if PCFG.is_dev == true then
    vim.pack.add({
      {
        src = "/data/mnt/shared/data/code/neovim_plugins/symbols.nvim",
        version = "experiments"
      }
    })
  else
    vim.pack.add({ "https://github.com/oskarrrrrrr/symbols.nvim" })
  end

  -- autocommands that fire ONCE to initialize plugins at certain stages
  -- BufReadPre
  auto_pre = autocmd({ "BufReadPre" --[[, "BufNewFile"]] }, {
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" or vim.bo[args.buf].buflisted == false then return end
    if not auto_pre_done then
      require("plugins.todo")
      require("plugins.others").setup.gitsigns()
      require("plugins.nvim-scrollbar")
      CGLOBALS.set_scrollbar()
      require("hlslens").setup({
        build_position_cb = function(plist, _, _, _)
          require("scrollbar.handlers.search").handler.show(plist.start_pos)
        end,
        calm_down = false, -- set to true to clear all lenses when cursor moves
        nearest_float_when = "never",
        nearest_only = true
      })
      auto_pre_done = true
    end
    vim.schedule(function()
      if auto_pre ~= nil and auto_pre_done == true then
        vim.api.nvim_del_autocmd(auto_pre)
      end
    end)
  end,
  group = agroup_pack})

  -- when the first LSP attaches
  -- set up lsp-related plugins
  auto_lsp = autocmd({ "LspAttach" }, {
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" or vim.bo[args.buf].buflisted == false then return end
    if not auto_lsp_done then
      require("dap.nvim_dap")
      if Tweaks.dap.ui == "dap-ui" then
        require("dap.nvim_dap_ui")
      end
      if Tweaks.dap.ui == "debugmaster" then
        require("dap.debugmaster")
      end
      require("plugins.oilsetup")
      require("plugins.others").setup.glance()
      auto_lsp_done = true
    end
    vim.schedule(function()
      if auto_lsp ~= nil and auto_lsp_done == true then
        vim.api.nvim_del_autocmd(auto_lsp)
      end
    end)
  end,
  group = agroup_pack})

  -- BufReadPost
  auto_post = autocmd({ "BufReadPost" --[[, "BufNewFile"]] }, {
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" or vim.bo[args.buf].buflisted == false then return end
    if not auto_post_done then
      if Tweaks.completion.version == "blink" then
        require("plugins.blink")
        vim.schedule(function() require("plugins.blink").update_hl() end)
      end
      require("commandpicker").setup({
        columns = {
          desc = { hl = "String" }
        },
        order = { "desc", "cmd", "mappings", "category" },
        custom_layout = SPL({ width = 120, height = 20, row = 5, input = "bottom", preview = false }),
        width = 120,
        height = 20,
        preserve_mode = true
      })
      require("plugins.others").setup.symbols()
      require("hover").setup({
        init = function()
          -- Require providers
          require("hover.providers.lsp")
          -- require('hover.providers.gh')
          -- require('hover.providers.gh_user')
          -- require('hover.providers.jira')
          require("hover.providers.dictionary")
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

      require("quicker").setup({
        opts = {
          number = true,
          signcolumn = "yes:3"
        }
      })

      require("colorizer").setup({
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
      })
      auto_post_done = true
    end
    vim.schedule(function()
      if auto_post ~= nil and auto_post_done == true then
        vim.api.nvim_del_autocmd(auto_post)
      end
    end)
  end,
  group = agroup_pack})

  -- handle events sent by vim.pack. 
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(event)
      local name, kind = event.data.spec.name, event.data.kind

      if name == "nvim-treesitter" and kind == "update" then
        if not event.data.active then
          vim.cmd.packadd('nvim-treesitter')
        end
        vim.cmd('TSUpdate')
      end
  end})
end

-- fix the runtime path, add all plugins that are needed later
function M.fixRtp()
  local base = vim.fn.stdpath("data") .. "/site/pack/core/opt/"
  vim.iter(rtp_to_add):filter(function(v)
    vim.opt.rtp:prepend(base .. v)
    return v
  end)
end

return M
