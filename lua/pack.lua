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
  "nvim-colorizer.lua"
}

local autocmd = vim.api.nvim_create_autocmd
local auto_pre, auto_post = nil, nil
local auto_pre_done, auto_post_done = false, false
local agroup_pack = vim.api.nvim_create_augroup("pack", {})

function M.setup()
  -- vim.pack BEGIN (experimental)
  -- this shall be outsourced to its own file
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
  require("plugins.oilsetup")
  require("plugins.treesitter")
  require("plugins.others").setup.treesitter_context()
  require("guess-indent").setup()
  require("eyes-wide-bright").setup({
    mode = "normal"       -- options: "normal", "warm", "cold"
  })
  require("plugins.snacks_setup")
  require("plugins.fzf-lua_setup")
  require("plugins.others").setup.glance()

  -- condidtional plugins
  if Tweaks.notifier == "fidget" then
    vim.pack.add({ "https://github.com/j-hui/fidget.nvim" })
    require("plugins.others").setup.fidget()
  end

  if Tweaks.tree.version == "Nvim" then
    vim.pack.add({ "https://github.com/nvim-tree/nvim-tree.lua" })
    require("plugins.nvim-tree")
    table.insert(rtp_to_add, "nvim-tree.lua")
  end

  if Tweaks.tree.version == "Neo" then
    vim.pack.add({ "https://github.com/nvim-neo-tree/neo-tree.nvim" })
    vim.pack.add({ "https://github.com/MunifTanjim/nui.nvim" })
    require("plugins.neotree")
    table.insert(rtp_to_add, "neo-tree.nvim")
  end

  -- blink.cmp
  if Tweaks.completion.version == "blink" then
    vim.pack.add({
      {
        src = "https://github.com/Saghen/blink.cmp",
        commit = "cd79f572971c58784ca72551af29af3a63da9168"
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

  -- autocommands
  auto_pre = autocmd({ "BufReadPre" --[[, "BufNewFile"]] }, {
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" or vim.bo[args.buf].buflisted == false then return end
    if not auto_pre_done then
      require("plugins.todo")
      require("plugins.others").setup.gitsigns()
      require("plugins.others").setup.neominimap()
      auto_pre_done = true
    end
    vim.schedule(function()
      if auto_pre ~= nil and auto_pre_done == true then
        vim.api.nvim_del_autocmd(auto_pre)
      end
    end)
  end,
  group = agroup_pack})

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

function M.fixRtp()
  local base = vim.fn.stdpath("data") .. "/site/pack/core/opt/"
  vim.iter(rtp_to_add):filter(function(v)
    vim.opt.rtp:prepend(base .. v)
    return v
  end)
end

return M
