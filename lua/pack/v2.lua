-- new implementation of vim.pack support containing a more generic approach
-- all plugin defs are in an array of pack.Plugindef

--- @class pack.Plugindef
--- @field name string | nil
--- @field source string | nil
--- @field version string | nil
--- @field condition boolean | function
--- @field active boolean
--- @field phase string
--- @field config function | nil
--- @field hook function | nil
--- @field rtp string | nil
--- @field fn function | nil
--- @field conf_valid boolean | nil

--- @class pack.Phasedef
--- @field phase string
--- @field done  boolean

local autocmd = vim.api.nvim_create_autocmd         -- shortcut
local event_handler = nil
local agroup_pack = vim.api.nvim_create_augroup("pack", {})
local rtp_base = vim.fn.stdpath("data") .. "/site/pack/core/opt/"


--- add a path fragment to the runtime path
--- @param fragment string
local function add_to_rtp(fragment)
  vim.opt.rtp:prepend(rtp_base .. fragment)
end

local function setup_lualine()
  require("plugins.lualine_setup")
  require("plugins.lualine_setup").fixhl()
  require("plugins.cokeline")
end

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

local function install_blink()
  vim.pack.add({
    {
      src = "https://github.com/Saghen/blink.cmp",
      --commit = "cd79f572971c58784ca72551af29af3a63da9168"
      version = "main",
      post_install = build_blink,
      post_checkout = build_blink
    },
    {
      src = "https://github.com/moyiz/blink-emoji.nvim"
    },
    {
      src = "https://gitlab.com/silvercircle74/blink-cmp-wordlist"
    }
  })
  add_to_rtp("blink.cmp")
  add_to_rtp("blink-cmp-wordlist")
end

local function install_dap()
  vim.pack.add({ "https://github.com/mfussenegger/nvim-dap", "https://github.com/nvim-neotest/nvim-nio" })
  add_to_rtp("nvim-dap")

  if Tweaks.dap.ui == "dap-ui" then
    vim.pack.add({ "https://github.com/rcarriga/nvim-dap-ui" })
    add_to_rtp("nvim-dap-ui")
  end
  if Tweaks.dap.ui == "debugmaster" then
    vim.pack.add( { "https://github.com/miroshQa/debugmaster.nvim" })
    add_to_rtp("debugmaster.nvim")
  end
end

--- this array of Plugindef records holds all configured plugins
--- @type pack.Plugindef[]
local plugins = {
  { -- multicursor
    name = "multicursor.nvim", version = "*",
    source = "https://github.com/jake-stewart/multicursor.nvim",
    condition = true, active = true, phase = "boot",
    config = function() require("plugins.others").setup.multicursor_stewart() end, hook = nil,
    rtp = nil
  },
  { -- nvim-web-devicons
    name = "nvim-web-devicons", version = "*",
    source = "https://github.com/nvim-tree/nvim-web-devicons",
    condition = true, active = true, phase = "boot",
    config = function() require("nvim-web-devicons").setup({
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
        },
        yml = {
          icon = "",
          color = "#995555",
          name = "Yaml"
        }
      },
      color_icons = true,
      default = true})
    end,
    rtp = nil
  },
  { -- nvim-treesitter
    name = "nvim-treesitter", version = "*",
    source = "https://github.com/nvim-treesitter/nvim-treesitter",
    condition = true, active = true, phase = "boot",
    config = function() require("plugins.treesitter") end,
    rtp = nil
  },
  { -- nvim-treesitter-context
    name = "nvim-treesitter-context", version = "*",
    source = "https://github.com/nvim-treesitter/nvim-treesitter-context",
    condition = true, active = true, phase = "pre",
    config = function() require("plugins.others").setup.treesitter_context() end,
    rtp = "nvim-treesitter-context"
  },
  { -- lualine.nvim
    name = "lualine.nvim", version = "*",
    source = "https://github.com/nvim-lualine/lualine.nvim",
    condition = true, active = true, phase = "uie",
    config = function() setup_lualine() end,
    rtp = "lualine.nvim"
  },
  { -- guess-indent.nvim
    name = "guess-indent.nvim", version = "*",
    source = "https://github.com/nmac427/guess-indent.nvim",
    condition = true, active = true, phase = "uie",
    config = function() require("guess-indent").setup() end,
    rtp = nil
  },
  { -- nvim-cokeline
    name = "nvim-cokeline", version = "*",
    source = "https://github.com/silvercircle/nvim-cokeline",
    condition = true, active = true, phase = "none",        -- will be initialized by lualine
    config = function() end,
    rtp = nil
  },
  { -- plenary.nvim
    name = "plenary.nvim", version = "*",
    source = "https://github.com/nvim-lua/plenary.nvim",
    condition = true, active = true, phase = "none",
    config = nil,
    rtp = nil
  },
  { -- eyes-wide-bright
    name = "eyes-wide-bright", version = nil,
    source = "https://github.com/FractalCodeRicardo/eyes-wide-bright",
    condition = true, active = true, phase = "boot",
    config = function()
      require("eyes-wide-bright").setup({mode = "normal"})
    end,
    rtp = nil
  },
  { -- snacks.nvim
    name = "snacks.nvim", version = nil,
    source = "https://github.com/folke/snacks.nvim",
    condition = true, active = true, phase = "boot",
    config = function() require("plugins.snacks_setup") end,
    rtp = "snacks.nvim"
  },
  { -- nvim-tree.lua
    name = "nvim-tree.lua", version = nil,
    source = "https://github.com/nvim-tree/nvim-tree.lua",
    condition = Tweaks.tree.version == "Nvim", active = true, phase = "boot",
    config = function() require("plugins.nvim-tree") end,
    rtp = "nvim-tree.lua"
  },
  { -- alpha.nvim
    name = "alpha-nvim", version = nil,
    source = "https://github.com/goolord/alpha-nvim",
    condition = true, active = true, phase = "boot",
    config = function() require("plugins.alpha") end,
    rtp = nil
  },
  { -- fzf-lua
    name = "fzf-lua", version = nil,
    source = "https://github.com/ibhagwan/fzf-lua",
    condition = true, active = true, phase = "boot",
    config = function() require("plugins.fzf-lua_setup") end,
    rtp = "fzf-lua"
  },
  { -- mason
    name = "mason.nvim", version = nil,
    source = "https://github.com/williamboman/mason.nvim",
    condition = true, active = true, phase = "boot",
    config = function() require("mason").setup({
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      }
    }) end,
    rtp = nil
  },
  { -- quickfavs.nvim
    name = "quickfavs.nvim", version = nil,
    source = "https://gitlab.com/silvercircle74/quickfavs.nvim",
    condition = true, active = true, phase = "boot",
    config = function() require("quickfavs").setup({
      filename = vim.fs.joinpath(vim.fn.stdpath("config"), "favs"),
      telescope_theme = require("subspace.lib").Telescope_dropdown_theme,
      picker = "snacks",
      snacks_layout = SPL({ width = 120, height = 20, row = 5, input = "top" }),
      fzf_winopts = Tweaks.fzf.winopts.narrow_small_preview,
      explorer_layout = SPL({ width = 70 })
    })
    end,
    rtp = "quickfavs.nvim"
  },
  { -- symbols.nvim DEV version
    name = "symbols.nvim", version = "experiments",
    source = "/data/mnt/shared/data/code/neovim_plugins/symbols.nvim",
    condition = PCFG.is_dev == true, active = true, phase = "pre",
    config = function() require("plugins.others").setup.symbols() end,
    rtp = "symbols.nvim"
  },
  { -- symbols.nvim NORMAL
    name = "symbols.nvim", version = nil,
    source = "https://github.com/oskarrrrrrr/symbols.nvim",
    condition = PCFG.is_dev == false, active = true, phase = "pre",
    config = function() require("plugins.others").setup.symbols() end,
    rtp = "symbols.nvim"
  },
  { -- commandpicker.nvim
    name = "commandpicker.nvim", version = nil,
    source = "https://gitlab.com/silvercircle74/commandpicker.nvim",
    condition = true, active = true, phase = "post",
    config = function()
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
    end,
    rtp = "commandpicker.nvim"
  },
  { -- friendly-snippets
    name = "friendly-snippets", version = nil,
    source = "https://github.com/rafamadriz/friendly-snippets",
    condition = true, active = true, phase = "boot",
    config = nil,
    rtp = nil
  },
  { -- blink
    fn = install_blink,
    name = "blink.cmp", version = nil,
    source = nil,
    condition = Tweaks.completion.version == "blink", active = true, phase = "post",
    config = function()
      require("plugins.blink")
      vim.schedule(function() require("plugins.blink").update_hl() end)
    end,
    rtp = nil
  },
  { -- glance.nvim
    name = "glance.nvim", version = nil,
    source = "https://github.com/dnlhc/glance.nvim",
    condition = true, active = true, phase = "lsp",
    config = function() require("plugins.others").setup.glance() end,
    rtp = "glance.nvim"
  },
  { -- gitsigns
    name = "gitsigns.nvim", version = nil,
    source = "https://github.com/lewis6991/gitsigns.nvim",
    condition = true, active = true, phase = "pre",
    config = function() require("plugins.others").setup.gitsigns() end,
    rtp = "gitsigns.nvim"
  },
  { -- nvim-scrollbar
    name = "nvim-scrollbar", version = nil,
    source = "https://github.com/petertriho/nvim-scrollbar",
    condition = true, active = true, phase = "pre",
    config = function()
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
    end,
    rtp = "nvim-scrollbar"
  },
  { -- nvim-hlslens
    name = "nvim-hlslens", version = nil,
    source = "https://github.com/kevinhwang91/nvim-hlslens",
    condition = true, active = true, phase = "pre",
    config = function() end,
    rtp = "nvim-hlslens"
  },
  { -- quicker.nvim
    name = "quicker.nvim", version = nil,
    source = "https://github.com/stevearc/quicker.nvim",
    condition = true, active = true, phase = "post",
    config = function()
      require("quicker").setup({
        opts = {
          number = true,
          signcolumn = "yes:3"
        }
      })
    end,
    rtp = "quicker.nvim"
  },
  { -- nvim-colorizer.lua
    name = "nvim-colorizer.lua", version = nil,
    source = "https://github.com/catgoose/nvim-colorizer.lua",
    condition = true, active = true, phase = "post",
    config = function()
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
    end,
    rtp = "nvim-colorizer.lua"
  },
  { -- hover.nvim
    name = "hover.nvim", version = nil,
    source = "https://github.com/lewis6991/hover.nvim",
    condition = true, active = true, phase = "lsp",
    config = function()
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
    end,
    rtp = "hover.nvim"
  },
  { -- neominimap.nvim
    name = "neominimap.nvim", version = nil,
    source = "https://github.com/Isrothy/neominimap.nvim",
    condition = true, active = true, phase = "boot",
    config = function()
      require("plugins.others").setup.neominimap()
    end,
    rtp = "neominimap.nvim"
  },
  { -- roslyn.nvim
    name = "roslyn.nvim", version = nil,
    source = "https://github.com/seblyng/roslyn.nvim",
    condition = true, active = true, phase = "boot",
    config = function() end,
    rtp = "roslyn.nvim"
  },
  { -- todo-comments.nvim
    name = "todo-comments.nvim", version = nil,
    source = "https://github.com/folke/todo-comments.nvim",
    condition = true, active = true, phase = "pre",
    config = function()
      require("plugins.todo")
    end,
    rtp = "todo-comments.nvim"
  },
  { -- nvim-autopairs
    name = "nvim-autopairs", version = nil,
    source = "https://github.com/windwp/nvim-autopairs",
    condition = true, active = true, phase = "pre",
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({})
      local Rule = require("nvim-autopairs.rule")
      npairs.add_rules({
        Rule("<", ">")
      })
    end,
    rtp = nil
  },
  { -- oil.nvim
    name = "oil.nvim", version = nil,
    source = "https://github.com/stevearc/oil.nvim",
    condition = true, active = true, phase = "pre",
    config = function()
      require("plugins.oilsetup")
    end,
    rtp = "oil.nvim"
  },
  { -- diffview.nvim
    name = "diffview.nvim", version = nil,
    source = "https://github.com/sindrets/diffview.nvim",
    condition = true, active = true, phase = "pre",
    config = nil,
    rtp = nil
  },
  { -- nui.nvim
    name = "nui.nvim", version = nil,
    source = "https://github.com/MunifTanjim/nui.nvim",
    condition = Tweaks.tree.version == "Neo", active = true, phase = "boot",
    config = nil,
    rtp = nil
  },
  { -- neo-tree.nvim
    name = "neo-tree.nvim", version = nil,
    source = "https://github.com/nvim-neo-tree/neo-tree.nvim",
    condition = Tweaks.tree.version == "Neo", active = true, phase = "boot",
    config = function() require("plugins.neotree") end,
    rtp = "neo-tree.nvim"
  },
  { -- fidget.nvim
    name = "fidget.nvim", version = nil,
    source = "https://github.com/j-hui/fidget.nvim",
    condition = Tweaks.notifier == "fidget", active = true, phase = "boot",
    config = function() require("plugins.others").setup.fidget() end,
    rtp = nil
  },
  { -- typst.vim
    name = "typst.vim", version = nil,
    source = "https://github.com/kaarmu/typst.vim",
    condition = true, active = true, phase = "boot",
    config = nil,
    rtp = nil
  },
  { -- nvim-dap
    fn = install_dap,
    name = "nvim-dap", version = nil,
    source = nil,
    condition = Tweaks.dap.enabled == true, active = true, phase = "lsp",
    config = function()
      require("dap.nvim_dap")
      if Tweaks.dap.ui == "dap-ui" then
        require("dap.nvim_dap_ui")
      end
      if Tweaks.dap.ui == "debugmaster" then
        require("dap.debugmaster")
      end
    end,
    rtp = nil
  },
  { -- nvim-jdtls
    -- special case. These are configured via ftplugin
    name = "nvim-jdtls", version = nil,
    source = "https://github.com/mfussenegger/nvim-jdtls",
    condition = true, active = true, phase = "boot",
    config = nil,
    rtp = "nvim-jdtls"
  },
  { -- nvim-metals
    -- special case. These are configured via ftplugin
    name = "nvim-metals", version = nil,
    source = "https://github.com/scalameta/nvim-metals",
    condition = true, active = true, phase = "boot",
    config = nil,
    rtp = "nvim-metals"
  },
}

--- @type pack.Phasedef[]
local phases_done = {
  ["UIEnter"]     =  { phase = "uie",  done = false },
  ["LspAttach"]   =  { phase = "lsp",  done = false },
  ["BufReadPre"]  =  { phase = "pre",  done = false },
  ["BufReadPost"] =  { phase = "post", done = false }
}

--- execute all configs for the given phase
--- @param event string the event name for which we execute configurations
local function execute_configs(event)
  if phases_done[event] == nil or phases_done[event].done == true then
    return
  end
  local this_phase = phases_done[event].phase
  vim.iter(plugins):filter(function(v)
    if v.phase == this_phase then
      if v.conf_valid == true then
        v.config()
      end
    end
    return v
  end)
  phases_done[event].done = true
end

local M = {}

function M.setup()
  local to_install = {}

  vim.iter(plugins):filter(function(v)
    v.conf_valid = false
    if v.active == true and v.condition == true then
      if v.fn ~= nil and type(v.fn) == "function" then
        v.fn()
      else
        table.insert(to_install,
          {
            src = v.source,
            name = v.name,
            version = (v.version ~= nil and v.version ~= "*") and v.version or nil
          }
        )
      end
      if v.rtp ~= nil then
        add_to_rtp(v.rtp)
      end
      if v.config ~= nil and type(v.config) == "function" then
        v.conf_valid = true
      end
    end
    return v
  end)
  vim.pack.add(to_install)

  vim.iter(plugins):filter(function(v)
    if v.phase == "boot" and v.conf_valid == true then
      v.config()
    end
    return v
  end)
  -- autocommand handler that handles all initialization phases.
  -- it uses phases_done[] to keep track of what has been done.
  event_handler = autocmd({ "UIEnter", "BufReadPre", "BufReadPost", "LspAttach" }, { callback = function(args)
    if not phases_done[args.event].done then
      execute_configs(args.event)
    end
    if phases_done["UIEnter"].done == true and phases_done["LspAttach"].done == true
      and phases_done["BufReadPre"].done == true and phases_done["BufReadPost"].done == true then
      vim.notify("pack.V2: ALL phases complete, deleting auto command")
      vim.schedule(function()
        vim.api.nvim_del_autocmd(event_handler)
        vim.api.nvim_del_augroup_by_id(agroup_pack)
      end)
    end
  end,
  group = agroup_pack})
end

return M
