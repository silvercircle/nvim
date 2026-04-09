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
  {
    name = "multicusor.nvim", version = "main",
    source = "https://github.com/jake-stewart/multicursor.nvim",
    condition = true, active = true, phase = "boot",
    config = function() require("plugins.others").setup.multicursor_stewart() end, hook = nil,
    rtp = nil
  },
  {
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
  {
    name = "nvim-treesitter", version = "main",
    source = "https://github.com/nvim-treesitter/nvim-treesitter",
    condition = true, active = true, phase = "boot",
    config = function() require("plugins.treesitter") end,
    rtp = nil
  },
  {
    name = "nvim-treesitter-context", version = "main",
    source = "https://github.com/nvim-treesitter/nvim-treesitter-context",
    condition = true, active = true, phase = "pre",
    config = function() require("plugins.others").setup.treesitter_context() end,
    rtp = "nvim-treesitter-context"
  },
  {
    name = "lualine.nvim", version = "main",
    source = "https://github.com/nvim-lualine/lualine.nvim",
    condition = true, active = true, phase = "uie",
    config = function() setup_lualine() end,
    rtp = "lualine.nvim"
  },
}

local M = {}

function M.setup()
  local rtp_base = vim.fn.stdpath("data") .. "/site/pack/core/opt/"

  vim.iter(plugins):filter(function(v)
    vim.notify(v.name)
    vim.pack.add({
      {
        src = v.source,
        name = v.name
      }
    })
    if v.phase == "boot" and v.config ~= nil and type(v.config) == "function" then
      v.config()
    end
    if v.rtp ~= nil then
      vim.opt.rtp:prepend(rtp_base .. v.rtp)
    end
    return v
  end)

  -- autocommands that fire ONCE to initialize plugins at certain stages
  -- UIEnter
  auto_uie = autocmd({ "UIEnter" --[[, "BufNewFile"]] }, {
  callback = function(args)
    if not auto_uie_done then
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
