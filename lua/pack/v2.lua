-- new implementation of vim.pack support containing a more generic approach
-- all plugin defs are in an array of pack.Plugindef

--- @class pack.Plugindef
--- @field name string
--- @field source string
--- @field condition boolean | function
--- @field active boolean
--- @field phase string
--- @field config function | nil
--- @field hook function | nil
--- @field rtp string | nil

local autocmd = vim.api.nvim_create_autocmd         -- shortcut
local auto_pre, auto_post, auto_lsp, auto_uie = nil, nil, nil, nil
local auto_pre_done, auto_post_done, auto_lsp_done, auto_uie_done = false, false, false, false
local agroup_pack = vim.api.nvim_create_augroup("pack", {})

local function setup_lualine()
  require("plugins.lualine_setup")
  require("plugins.lualine_setup").fixhl()
  require("plugins.cokeline")
end

--- @type pack.Plugindef[]
local plugins = {
  { -- multicursor
    name = "multicusor.nvim", version = "main",
    source = "https://github.com/jake-stewart/multicursor.nvim",
    condition = true, active = true, phase = "boot",
    config = function() require("plugins.others").setup.multicursor_stewart() end, hook = nil,
    rtp = nil
  },
  { -- nvim-web-devicons
    name = "nvim-web-devicons", version = "main",
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
        }
      },
      color_icons = true,
      default = true})
    end,
    rtp = nil
  },
  { -- nvim-treesitter
    name = "nvim-treesitter", version = "main",
    source = "https://github.com/nvim-treesitter/nvim-treesitter",
    condition = true, active = true, phase = "boot",
    config = function() require("plugins.treesitter") end,
    rtp = nil
  },
  { -- nvim-treesitter-context
    name = "nvim-treesitter-context", version = "main",
    source = "https://github.com/nvim-treesitter/nvim-treesitter-context",
    condition = true, active = true, phase = "pre",
    config = function() require("plugins.others").setup.treesitter_context() end,
    rtp = "nvim-treesitter-context"
  },
  { -- lualine.nvim
    name = "lualine.nvim", version = "main",
    source = "https://github.com/nvim-lualine/lualine.nvim",
    condition = true, active = true, phase = "uie",
    config = function() setup_lualine() end,
    rtp = "lualine.nvim"
  },
  { -- guess-indent.nvim
    name = "guess-indent.nvim", version = "main",
    source = "https://github.com/nmac427/guess-indent.nvim",
    condition = true, active = true, phase = "uie",
    config = function() require("guess-indent").setup() end,
    rtp = nil
  },
  { -- nvim-cokeline
    name = "nvim-cokeline", version = "main",
    source = "https://github.com/silvercircle/nvim-cokeline",
    condition = true, active = true, phase = "none",        -- will be initialized by lualine
    config = function() end,
    rtp = nil
  },
  { -- plenary.nvim
    name = "plenary.nvim", version = "main",
    source = "https://github.com/nvim-lua/plenary.nvim",
    condition = true, active = true, phase = "none",
    config = nil,
    rtp = nil
  },
  { -- eyes-wide-bright
    name = "eyes-wide-bright", version = "main",
    source = "https://github.com/silvercircle/nvim-cokeline",
    src = "https://github.com/FractalCodeRicardo/eyes-wide-bright",
    condition = true, active = true, phase = "boot",
    config = function()
      require("eyes-wide-bright").setup({mode = "normal"})
    end,
    rtp = nil
  },
  { -- snacks.nvim
    name = "snacks.nvim", version = "main",
    source = "https://github.com/folke/snacks.nvim",
    condition = true, active = true, phase = "boot",
    config = function() require("plugins.snacks_setup") end,
    rtp = "snacks.nvim"
  },
  { -- nvim-tree.lua
    name = "nvim-tree.lua", version = "main",
    source = "https://github.com/nvim-tree/nvim-tree.lua",
    condition = Tweaks.tree.version == "Nvim", active = true, phase = "boot",
    config = function() require("plugins.nvim-tree") end,
    rtp = "nvim-tree.lua"
  },
  { -- alpha.nvim
    name = "alpha-nvim", version = "main",
    source = "https://github.com/goolord/alpha-nvim",
    condition = true, active = true, phase = "boot",
    config = function() require("plugins.alpha") end,
    rtp = nil
  },
  { -- fzf-lua
    name = "fzf-lua", version = "main",
    source = "https://github.com/ibhagwan/fzf-lua",
    condition = true, active = true, phase = "boot",
    config = function() require("plugins.fzf-lua_setup") end,
    rtp = "fzf-lua"
  },
  { -- mason
    name = "mason.nvim", version = "main",
    source = "https://github.com/williamboman/mason.nvim",
    condition = true, active = true, phase = "boot",
    config = function() require("mason").setup() end,
    rtp = nil
  },
  { -- quickfavs.nvim
    name = "quickfavs.nvim", version = "main",
    source = "https://gitlab.com/silvercircle74/quickfavs.nvim",
    condition = true, active = true, phase = "boot",
    config = function() require("quickfavs").setup() end,
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
    name = "symbols.nvim", version = "main",
    source = "https://github.com/oskarrrrrrr/symbols.nvim",
    condition = PCFG.is_dev == false, active = true, phase = "pre",
    config = function() require("plugins.others").setup.symbols() end,
    rtp = "symbols.nvim"
  },
  { -- commandpicker.nvim
    name = "commandpicker.nvim", version = "main",
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
}

local phases_done = {
  uie = false, lsp = false, pre = false, post = false
}

--- @param phase string
local function execute_configs(phase)
  if phases_done[phase] == nil or phases_done[phase] == true then
    return
  end
  vim.iter(plugins):filter(function(v)
    if v.active == true and v.condition == true then
      if v.phase == phase and v.config ~= nil and type(v.config) == "function" then
        vim.notify("execute config for " .. v.name .. " in phase " .. phase)
        v.config()
      end
    end
    return v
  end)
  phases_done[phase] = true
end

local M = {}

function M.setup()
  local rtp_base = vim.fn.stdpath("data") .. "/site/pack/core/opt/"

  vim.iter(plugins):filter(function(v)
    if v.active == true and v.condition == true then
      vim.notify(v.name)
      vim.pack.add({
        {
          src = v.source,
          name = v.name,
          version = v.version
        }
      })
      if v.phase == "boot" and v.config ~= nil and type(v.config) == "function" then
        v.config()
      end
      if v.rtp ~= nil then
        vim.opt.rtp:prepend(rtp_base .. v.rtp)
      end
    end
    return v
  end)

  -- autocommands that fire ONCE to initialize plugins at certain stages
  -- UIEnter
  auto_uie = autocmd({ "UIEnter" --[[, "BufNewFile"]] }, {
  callback = function(_)
    if not auto_uie_done then
      execute_configs("uie")
      auto_uie_done = true
    end
    vim.schedule(function()
      if auto_uie ~= nil and auto_uie_done == true then
        vim.api.nvim_del_autocmd(auto_uie)
      end
    end)
  end,
  group = agroup_pack})

  -- BufReadPre
  auto_pre = autocmd({ "BufReadPre" --[[, "BufNewFile"]] }, {
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" or vim.bo[args.buf].buflisted == false then return end
    if not auto_pre_done then
      execute_configs("pre")
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
      execute_configs("lsp")
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
      execute_configs("post")
      auto_post_done = true
    end
    vim.schedule(function()
      if auto_post ~= nil and auto_post_done == true then
        vim.api.nvim_del_autocmd(auto_post)
      end
    end)
  end,
  group = agroup_pack})
end

return M
